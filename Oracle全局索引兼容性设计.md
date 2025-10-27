.00# 01. 需求
## 需求描述
MySQL分区表支持全局索引
- 可以为分区表创建全局索引
## 需求分析
#### [Oracle Global Partitioned Indexes](https://docs.oracle.com/cd/E11882_01/server.112/e25523/partition.htm#i461446:~:text=Partitioned%20Indexes%22.-,Global%20Partitioned%20Indexes,-Oracle%20offers%20global)
1. 将全局索引按照hash，或者range进行分区。
2. 特定索引分区中的键可以引用存储在多个基础表分​​区或子分区中的行。
3. Oracle支持Hash和Range两种分区。

![[vldbg007.gif]]
#### [Oracle Global Nonpartitioned Indexes](https://docs.oracle.com/cd/E11882_01/server.112/e25523/partition.htm#i461446:~:text=Partitioned%20Indexes%22.-,Global%20Nonpartitioned%20Indexes,-Global%20nonpartitioned%20indexes)
表现类似于非分区表的索引
![[vldbg006.gif]]
## 需求规格
1. MySQL支持全局非分区索引
2. MySQL支持全局分区索引
# 02. 设计实现
## 相关机制
了解MySQL分区表中cluster index，secondary index实现的机制；当前分区键必须为唯一索引子集限制的原因；如何创建，维护，使用二级索引。
#### MySQL分区表中的索引
MySQL中支持local index，特定索引分区中的所有键仅引用存储在单个基础表分​​区中的行。
![[vldbg003.gif]]
在建表的时候会遍历partition_info中的每一个分区定义，创建分区表和cluster index。
对于CREATE INDEX语法，遵循同样的原则，遍历每个分区创建同名索引。
#### 分区键限制原因
```text
All columns used in the partitioning expression for a partitioned table must be part of every unique key that the table may have.
```
分区键必须是每个（可能有多个）唯一索引的子集。
- 保证分区键值相等的元组全部存在于一个分区上
- 保证单一分区子表的唯一性
- 拓展到全局唯一性0
###### 正向推理
```cpp
if a1 == a2 && b1 == b2
then get_part_id(a1,b1) == get_part_id(a2,b2)
then part_id1 == part_id2
```
###### 反证
![[Pasted image 20240108182414.png]]
###### Oracle中索引组织表的分区键同样具有限制
分区键必须是主键的子集
```sql
SQL> create table t(a int ,b int primary key) ORGANIZATION INDEX partition by range(a) (partition p0 values less than(1));
create table t(a int ,b int primary key) ORGANIZATION INDEX partition by range(a) (partition p0 values less than(1))
                                                                               *
ERROR at line 1:
ORA-25199: partitioning key of a index-organized table must be a subset of the
primary key
```
unique索引没有限制
```sql
SQL> create table t(a int unique,b int primary key) ORGANIZATION INDEX partition by range(b) (partition p0 values less than(1));

Table created.
```
#### 索引操作
###### 创建逻辑
先创建对应的index page，挂在指定的内存中，再填数据，落入InnoDB中写入数据文件
- mysql_inplace_alter_table
	- ha_innopart::prepare_inplace_alter_table
		- ddl::create_index
			- dict_create_index_tree_in_mem
				- btr_create
			- dict_index_build_internal_non_clust
				- 添加cluster index中用于唯一性判断的列 `index->n_fields + 1 + clust_index->n_uniq`
###### 索引entry
![[Pasted image 20240126173220.png]]
[[test7]]
###### insert
`row_ins_sec_index_entry`
1. 根据插入的值算出所属的分区id（part_id)。
2. 调用set_partition，设置分区上下文。
3. 调用普通表对应的处理函数。
4. 遍历该表上的所有index（第一个为cluster index），插入新的值。
5. 插入二级索引entry时，首先遍历找到对应的位置，插入该entry。

![[Pasted image 20231116154239.png]]
###### update
- Sql_cmd_dml::execute
	- sql_cmd_update::prepare_inner
		- Query_block::apply_local_transforms
			- prune_partitions
	- sql_cmd_update::execute_inner
		- update_single_table
			- prune_partitions
				- find_used_partitions 根据select中的查询条件查找使用的partition_id,设置read_partitions
				- read_partitions和lock_partitions做相交得到最终的read_partitions
			- update_row
				- ph_update_row 拿更改的fields和每个index中的fields判断是否需要更新index
					- write_row_in_part在新的分区写入记录
						- ha_innobase::write_row
					- delete_row_in_part在旧的分区删除记录
						- set_partition(part_id);
						- delete_row
							- row_upd_step
								- row_upd
									- row_upd_changes_some_index_ord_field_binary 检查记录修改是否影响index
									- row_upd_clust_step
									- row_upd_sec_step
						- update_partition(part_id)
					- update_row_in_part 两条记录在一个分区
###### drop
同update
- select
- delete
###### select
优化阶段，会对join中使用的分区表进行优化，主要内容是生成每个分区表的read_partitions，该值类型为bitmap，存储每个分区的使用情况
- optimize
	- JOIN::prune_table_partitions
		- prune_partitions
			- find_used_partitions 根据select中的查询条件查找使用的partition_id,设置read_partitions
			- read_partitions和lock_partitions做相交得到最终的read_partitions
执行阶段，根据bitmap值再次对分区剪枝，具体做法就是查找bitmap中下一个为1的值
- execute
	- common_index_read
		- partition_scan_set_up
			- prune_partition_set
				- 遍历read_partitions，找到值为1的值，返回
		- handle_unordered_scan_next_partition
			- ha_innopart::read_range_first_in_part
				- set_partition设置当前查询的partition
				- ha_innobase::index_read


1. partition prune：根据partition key查找对应的partition_id,获得一个使用的partition list。
2. 再对列表中的每个分区表，进行select操作。
3. 把对整体分区表的操作分散到每个分区表。¬øø
#### InnoDB文件物理结构
#todo

![[image007.png]]
#### InnoDB Online DDL
#todo

| Operation | Instant | In Place | Rebuilds Table | Permits Concurrent DML | Only Modifies Metadata |
| ---- | ---- | ---- | ---- | ---- | ---- |
| Creating or adding a secondary index | No | Yes | No | Yes | No |
| Dropping an index | No | Yes | No | Yes | Yes |
| Renaming an index | No | Yes | No | Yes | Yes |
| Adding a `FULLTEXT` index | No | Yes* | No* | No | No |
| Adding a `SPATIAL` index | No | Yes | No | No | No |
| Changing the index type | Yes | Yes | No | Yes | Yes |
## 总结
1. 分区表中各自的索引，数据分文件独立存储
2. 分区中的操作会扩展为多个分区子表的操作
3. 二级索引中存储key值以及对应行主键的key值
## 设计思路
### 前提
Oracle对于索引组织表的分区键有一个限制条件：
索引组织表的分区键必须是主键的子集。
### 思路
对于所有分区，创建一个共同的二级索引，我们需要通过该二级索引获得<font color="#ff0000">该行数据所属的分区</font>。根据分区表的处理规则我们知道，在每次操作前需要将上下文替换为相应的分区，这一步需要我们或计算或读取partition_id，所以我们的设计就围绕partition_id获取这一目标展开。
#### 设计A 将partition_id存储于二级索引
将partition_id存储于二级索引中，添加一列filed。
这样对于分区表的global secondary index就表现为
![[Pasted image 20240129100941.png]]
![[Pasted image 20240129104423.png]]
##### 问题点
#todo 
索引中的fields有三种类型
- columns（用户定义）
- system columns（系统定义）
- virtual columns（用户定义）

每个field必须绑定到对应的column
- 索引中只存储了该field在cluster index中的序号
- 索引中的fields和dml中更改的columns作比较，可以得到需要更新的索引

解决该问题需要将分区键中的fields加入索引键中，这样分区键相关的修改可以触发索引更改

#### 设计B
延用Oracle的限制条件，修改唯一索引的唯一约束实现
# 参考
- [MySQL · 内核分析 · InnoDB主键约束和唯一约束的实现分析](http://mysql.taobao.org/monthly/2021/04/05/)
- [MySQL · 引擎特性 · 二级索引分析](http://mysql.taobao.org/monthly/2020/01/01/)
- [MySQL · 源码阅读 · 创建二级索引](http://mysql.taobao.org/monthly/2020/11/03/)
- [MySQL · 源码分析 · innodb 空间索引实现](http://mysql.taobao.org/monthly/2022/08/04/)
- 索引干啥的 ，怎么使用的关键函数，打开代码，有没有修改