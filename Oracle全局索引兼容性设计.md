# 01. 需求
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
#### 索引操作
###### 创建逻辑
#todo
先创建对应的index page，挂在指定的内存中，再填数据，落入InnoDB中写入数据文件
- mysql_inplace_alter_table
	- ha_innopart::prepare_inplace_alter_table
		- ddl::create_index
			- dict_create_index_tree_in_mem
				- btr_create
###### 索引entry
#todo
###### insert
#todo

![[Pasted image 20231116154239.png]]
###### update
#todo

###### drop
#todo

###### select
#todo

1. partition prune：根据partition key查找对应的partition_id,获得一个使用的partition list。
2. 再对列表中的每个分区表，进行select操作。
3. 把对整体分区表的操作分散到每个分区表。
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
#### 思路
把分区表当成一个非分区表，为这个表添加一个secondary index，key值为用户自定义，value值为（part_id，pk_key)
![[Pasted image 20240108191326.png]]

