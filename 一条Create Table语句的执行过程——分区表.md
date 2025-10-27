# 01. Parser

![[mysqld1 1.svg]]
1. 词法解析生成tokens
2. 语法解析匹配语法文件,执行对应的 c/c++代码,初始化实例实例
3. 做简单赋值
	- 命令类型: create table
	- 分区方法: range, list, hash
	- 分区定义: partition_info, partition_def
4. 生成语法树
5. 生成cmd
# 02. Executor
![[executor.svg]]
## Data Dictionary——MySQL 的数据字典
### 概述
- MySQL预留了多张系统的 DD 表来持久化和构建 DD object 信息
- DD object 的描述是一种树形结构
- 不同的系统 DD 表通过外键关联
![[dd-tree.png]]
### 背景
#### Before 8.0
##### 现象
- Server 层和存储引擎（比如 InnoDB）会各自保留一份元数据（schema name, table definition 等）
- 不同存储引擎之间（比如 InnoDB 和 MyISAM）有着不同的元数据存储形式和位置(.FRM, .PAR, .OPT, .TRN and .TRG files)
##### 问题
- 信息冗余，不同步
- 元数据无法统一管理
- 将元数据存放在不支持事务的表和文件中，使得 DDL 变更不会是原子的，crash recovery 也会成为一个问题。
##### 图示
![[before-self.jpeg]]
#### after 8.0
##### 现象
- 引入 data directionary(下文简称 DD)统一管理
- 存储在 InnoDB 中
##### 影响
- 只有一份数据,解决了元数据管理,同步
- InnoDB 自然支持原子性
##### 图示
![[after-self.jpeg]]
### 架构
![[arch.jpeg]]

#### 两级缓存
避免每次对元数据对象的访问都需要去持久存储中读取多个表的数据，使生成的元数据内存对象能够复用
- client 和底层存储之间通过两级缓存来加速对元数据对象的内存访问，两级缓存都是基于 hash map 实现的
- 一层缓存是 local 的，由每个 client（每个线程对应一个 client）独享
- 二级缓存是 share 的，为所有线程共享的全局缓存
- 获取的整体过程就是一级局部缓存 -> 二级共享缓存 -> 存储引擎
#### API
提供了统一的 client API 供 Server 层和引擎层使用，包含对元数据访问的 acquire() / drop() / store() / update() 基本操作
#### 存储
底层实现了对 InnoDB 引擎存放的数据字典表的读写操作，包含开表(open table)、构造主键、主键查找等过程


### 实现
![[dd 1.svg]]
#### 代码流程
- create_table_impl
	- check_partition_info at sql_table.cc:8833
		- fix_parser_data at partition_info.cc:1436
			- fix_partition_values at partition_info.cc:2448 
	- check_if_table_exists
	- mysql_prepare_create_table
	- rea_create_base_table
		- dd::create_table
			- fill_dd_table_from_create_info
				- fill_dd_partition_from_create_info
		- ha_create_table
			- open_table_from_share
				- unpack_partition_info
					- mysql_unpack_partition
					- fix_partition_func
						- handle_list_of_fields
						- fix_fields_part_func
							- set_up_field_array
						- check_range_constants
							- fix_column_value_functions
						- check_part_func_fields
						- check_primary_key
					- set_up_partition_func_pointers
#### 重点模块
##### 创建
1. `check_if_table_exists`判断表是否存在，以便在表存在时报错。
	这里会产生一次空读，这次空读会完整读穿DD模块直至底层存储引擎，不过此时相关DD信息尚未构建
2. `rea_create_base_table`时构建DD信息并保存到存储引擎InnoDB, 保存在多级缓存中的局部缓存中
3. 事务提交过程会在将dd表信息落盘的同时清理之前放入缓存的表信息
##### 获取
新建表时不存在 table,会通过`open_table_from_share`构建对象
![[Pasted image 20231218005346.png]]
分区表在这一过程中会重新经历 parser 的过程
## Storage engine
![[storage_engine 1.svg]]
在存储层,分区表主要是遍历所有分区,挨个创建表和索引
![[Pasted image 20231218011431.png]]
```cpp
for (const auto dd_part : *table_def->leaf_partitions()) {  
  std::string partition;  
  /* Build the partition name. */  
  dict_name::build_partition(dd_part, partition);  
  
  std::string part_table;  
  /* Build the partitioned table name. */  
  dict_name::build_table("", saved_table_name, partition, false, false,  
                         part_table);  
  
  if (part_table.length() + 1 >= FN_REFLEN - 1) {  
    error = HA_ERR_INTERNAL_ERROR;  
    my_error(ER_PATH_LENGTH, MYF(0), part_table.c_str());  
    break;  
  }  
  const dd::Properties &options = dd_part->options();  
  dd::String_type index_file_name;  
  dd::String_type data_file_name;  
  const char *tablespace_name;  
  
  if (options.exists(index_file_name_key))  
    (void)options.get(index_file_name_key, &index_file_name);  
  if (options.exists(data_file_name_key))  
    (void)options.get(data_file_name_key, &data_file_name);  
  ut_ad(created < tablespace_names.size());  
  tablespace_name = tablespace_names[created];  
  
  if (!data_file_name.empty()) {  
    create_info->data_file_name = data_file_name.c_str();  
  }  
  if (!index_file_name.empty()) {  
    create_info->index_file_name = index_file_name.c_str();  
  }  
  if (!data_file_name.empty() &&  
      dd_part->tablespace_id() == dd::INVALID_OBJECT_ID &&  
      (tablespace_name == nullptr ||  
       strcmp(tablespace_name, dict_sys_t::s_file_per_table_name) != 0)) {  
    create_info->tablespace = nullptr;  
  } else {  
    create_info->tablespace = tablespace_name;  
  }  info.flags_reset();  
  info.flags2_reset();  
  
  if ((error = info.prepare_create_table(part_table.c_str())) != 0) {  
    break;  
  }  
  info.set_remote_path_flags();  
  
  if ((error = info.create_table(&dd_part->table(), nullptr)) != 0) {  
    break;  
  }  
  if ((error = info.create_table_update_global_dd<dd::Partition>(  
           const_cast<dd::Partition *>(dd_part))) != 0) {  
    break;  
  }  
  if ((error = info.create_table_update_dict()) != 0) {  
    break;  
  }  
  info.detach();  
  
  ++created;  
  create_info->data_file_name = table_data_file_name;  
  create_info->index_file_name = table_index_file_name;  
  create_info->tablespace = table_level_tablespace_name;  
}
```
# 参考
1. [MySQL · 源码分析 · 详解 Data Dictionary](http://mysql.taobao.org/monthly/2021/08/02/)
2. [MySQL 中的元数据管理](http://mysql.taobao.org/monthly/2023/10/03/)
3. [MySQL · 源码分析 · TABLE信息的生命周期](http://mysql.taobao.org/monthly/2022/01/04/)
4. [MySQL · 功能分析 · MySQL表定义缓存](http://mysql.taobao.org/monthly/2015/08/10/)
5. [MySQL · 源码分析 · 8.0 · DDL的那些事](http://mysql.taobao.org/monthly/2020/05/05/)
6. [MySQL 8.0: Data Dictionary Architecture and Design](https://dev.mysql.com/blog-archive/mysql-8-0-data-dictionary-architecture-and-design/)
# 附录
```sql
create table t (id int, name char(10)) 
partition by range(id, name)
(partition p0 values less than(1,'aaa'), 
 partition p1 values less than (2,'bbb'), 
 partition p2 values less than(maxvalue, maxvalue)
 );
```
[[tp0.txt]]
[[tp1.txt]]
[[tp2.txt]]