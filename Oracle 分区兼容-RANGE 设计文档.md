# todo 
- range 功能点
- 不同模式的 yacc 文件,查看 mariadb 
- dml 改动点, select ,update , insert 语句
- insert 类型限制;
- subpartition;
- year, time , timestamp类型;
- range sql 标准
# 01. 需求
## 需求描述
MySQL RANGE分区功能对齐 Oracle
- RANGE分区功能支持多种数据类型
- RANGE分区功能支持多列分区
## 需求分析
#### Oracle语法
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/range_partitions.gif)

#### Oracle功能
按照分区键的范围进行分区.
 - 包含 values less than (value)语句,  value是一个(左闭右开)区间的上限
 - 分区键可以包含最多 16 列
 - 分区键类型和上限的类型相同或者可以相互转换
 -  区间上限允许的类型为
	 - string类型
	 - datetime 
	 - interval literal
	 - number
	 - MAXVALUE
#### 示例SQL
```sql
-- 基础示例
create table t(a date ,b varchar(10)) partition by range(a,b) (partition p0 values less than ('31-JAN-2007',100));

-- 类型保持一致
create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (100));

ERROR at line 1:
ORA-00932: inconsistent datatypes: expected BINARY got NUMBER

-- 类型可以转换
create table t(a int , b varchar(10)) partition by range(b) (partition p0 values less than (100));

Table created.

--  类型限制
create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (sysguid()));
create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (sysguid()))
ERROR at line 1:
ORA-14019: partition bound element must be one of: string, datetime or interval
literal, number, or MAXVALUE
```

#### Oracle与MySQL RANGE分区差异
|                              | Oracle range | MySQL range        | MySQL range columns |
| ---------------------------- | ------------ | ------------------ | ------------------- |
| string, date                 | 是           | 不支持             | 是                  |
| float, double,decimal        | 是           | 不支持             | 不支持              |
| 表达式(加, 减, 乘)           | 不支持       | 是                 | 不支持              |
| 表达式(除)                   | 不支持       | 不支持             | 不支持              |
| 表达式(函数)                 | 不支持       | 支持(返回值为整型) | 不支持              |
| 多列                         | 最多 16 列   | 不支持             | 最多 16 列          |
| year                         |              |                    | 不支持              |
| time                         |              |                    | 支持                |
| timestamp                    |              |                    | 不支持              |
| add partition                | 是           |        是             |                     |
| drop partition               | 是           |        是            |                     |
| exchange partition           | 是           |     是               |                     |
| merge partition              | 是           |         是           |                     |
| Modifying Default Attributes |   是           |                    |                     |
| move partition               |       是       |                    |                     |
| rename partition             |     是         |      是              |                     |
| split partition              |      是        |         是           |                     |
| truncate partition                             |      是        | 是|                     |
```cpp
switch (sql_type) {  
  case MYSQL_TYPE_TINY:  
  case MYSQL_TYPE_SHORT:  
  case MYSQL_TYPE_LONG:  
  case MYSQL_TYPE_LONGLONG:  
  case MYSQL_TYPE_INT24:  
    *result_type = INT_RESULT;  
    *need_cs_check = false;  
    return false;  
  case MYSQL_TYPE_NEWDATE:  
  case MYSQL_TYPE_DATE:  
  case MYSQL_TYPE_TIME:  
  case MYSQL_TYPE_DATETIME:  
  case MYSQL_TYPE_TIME2:  
  case MYSQL_TYPE_DATETIME2:  
    *result_type = STRING_RESULT;  
    *need_cs_check = true;  
    return false;  
  case MYSQL_TYPE_VARCHAR:  
  case MYSQL_TYPE_STRING:  
  case MYSQL_TYPE_VAR_STRING:  
    *result_type = STRING_RESULT;  
    *need_cs_check = true;  
    return false;  
  case MYSQL_TYPE_BOOL:  
  case MYSQL_TYPE_NEWDECIMAL:  
  case MYSQL_TYPE_DECIMAL:  
  case MYSQL_TYPE_TIMESTAMP:  
  case MYSQL_TYPE_TIMESTAMP2:  
  case MYSQL_TYPE_NULL:  
  case MYSQL_TYPE_FLOAT:  
  case MYSQL_TYPE_DOUBLE:  
  case MYSQL_TYPE_BIT:  
  case MYSQL_TYPE_ENUM:  
  case MYSQL_TYPE_SET:  
  case MYSQL_TYPE_GEOMETRY:  
  case MYSQL_TYPE_INVALID:  
    goto error;  
  default:  
    goto error;  
}
```
## 需求规格
1. range 语法支持string data types(除 text, lob), date and time data types , numeric data types
2. range 语法支持多列表达式进行分区
3. numeric data types 延后

#？ oracle 仅支持多个列名,不支持表达式,是否需要对齐

```sql
CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    (create_definition,...)
    [table_options]
    [partition_options]
    
partition_options:
    PARTITION BY
        { 
        RANGE(expr_list)
        }
    [PARTITIONS num]
    [(partition_definition [, partition_definition] ...)]

partition_definition:
    PARTITION partition_name
        [
	        VALUES LESS THAN {(value_list) | MAXVALUE}
        ]
        [(subpartition_definition [, subpartition_definition] ...)]

```
#### RANGE(expr_lists)
确定以一个或者多个表达式进行分区
1. 多个expr之间以 ',' 隔开,关系是`AND`,最多 16 列
2. 允许的类型
	- integer, float, double, decimal
	- date, time , datetime, timestamp
	- string data types 除(LOB, TEXT)
3.  允许的表达式
	- 列名
	- 包含列名的表达式
	- 函数
	```sql
	create table t(id1 int , id2 int) partition by range(id1, id2) (partition p0 values less than (120, 220), partition p0 values less than (1000,1000));
	create table t(id int , name varchar(20)) partition by range(name) (partition p0 values less than 'lihua');
	create table t(id int , name varchar(20)) partition by range(id % 100 +12)(partition p0 values less than (100));
	create table t(id int , bir_date date) partition by range(year(bir_date))(partition p0 values less than (2000));
	```
# 02. 设计实现
#### 相关流程
1. parser解析DDL, 初始化存储分区的信息
2. 处理表达式中的常量值,做合法性校验
3. 将处理的信息存入缓存当中
4. innodb 从缓存中读取该表 ,调用 parser重新解析获取解析树
5. 计算分区功能中包含的表达式, 存储每个分区对应的上限
```sql
create table t (id int , name varchar(20)) partition by range(id)
(
  partition p0 values less than (10),
  partition p1 values less than (20),
  partition p2 values less than (30),
  partition p3 values less than (40)
);
```
![[Pasted image 20231116154239.png]]
[[partition table]]
- Server
	1. 解析 QUERY,构造Partition(`PT_partition`) 实例,Partition_type(`PT_part_type_def`) 实例, partition_info(`partition_info`)实例,
		- 记录分区类型(Range by clause)
		- 记录分区键的表达式(id)
		- 分区信息(分区数量, 每个分区的上限值, 分区名称,子分区)
		- 分区 id 相关的函数指针
	2. 校验
		- 检查分区函数 `partition_info::check_partition_info`
		- 检查 null 值, MAXVALUE,分区函数返回值 `partition_info::fix_parser_data`
		- 子分区校验`partition_info::check_partition_info`
		- 校验区间重叠,column的值`partition_info::check_list_constants`
	3. 创建缓存数据 table_share DDtable (DATA Directionary)
- innodb
	1. 从table_share 读取 table 信息
	2. 再次解析 Query, 创建关键数据结构(`fix_partition_func`)
	3. 遍历所有分区建表
#### 总结
分区类型主要由 Server 层限制,限制的因素在于二分查找中的比较方法
1. 原生 mysql 只实现了对于 int 类型的二分查找函数
2. 原生 mysql 使用 ulonglong 类型存储分区上限值
3. range columns 中添加了对于多种分区键类型的支持,包括存储和查找方法
## RANGE 功能限制
#### 基本思路
1. 修改基本数据结构,用于存储多种类型的表达式
2. 去掉 server 层的类型校验
3. 修改分区键的查找方法
#### 实现方法
##### A. 修改 range 代码适配多种类型
1. 分区的基础数据结构
2. 分区查找函数
3. server层中的类型校验
###### 影响分析
该方法改动代码较多,但是可以将 range 和 range columns 拆开管理,同时添加多个表达式分区支持,oracle 并不支持这一点
##### B. 使用现有的 range columns,把 range 解析为 range columns
1. MySQL 中RANGE 和 RANGE COLUMNS 分别定义为两个关键字,彼此有各自得实现类
2. parser 扫描 query ,在 partition clause中 匹配了 RANGE 就会实例化一个对应 PT_part_type_def_range_expr ;匹配了 RANGE COLUMNS 就会实例化一个 PT_part_type_def_range_columns
 可以修改 bison 的语法文件,把 RANGE 匹配规则中实例化的类修改为 RANGE columns 对应的类,后续功能全部按照 range columns 处理,对 range columns 添加 float, double, decimal 支持
###### 影响分析
该方法使用较少的修改,但是 range成为 range columns 的一个简单封装,无法剥离开来
## 附录
#### 代码流程分析
##### part_column_list_val
1. parser 只会填充 max_value 或提供表达式
2. fix_column_value_function填充column_value、part_info、partition_id、null_value; add_column_list_values 修改 item tree node ; 

 after add_column_list_values fixed = 1;
 afet other fixing, fixed = 2;
##### set_up_field_array

##### check_partition_info

##### fix_partition_values
- 设置最大值以及对应的 range_value 为 LLONG_MAX
- 遍历partition的 filed,检查是否包含 null 值,range 不允许包含空值
- 判断 filed->result_type()
- 设置 fixed = 2
##### handle_list_of_fields
- 对于 columns 
- 判断 分区键是否存在于 table columns 中
- 判断的值位`List<char> part_field_list;`
##### fix_fields_part_func
- 在解析器中检查该函数是否不包含不可缓存的部分（如随机函数）
- 检查该函数是否不是常量函数。
- set_up_field_array
	- 二次检查 field 是否在表中
	- 将 table->field 的值存入 partition_info 的 part_field_array 中
##### check_range_constants 修改
- fix_column_value_functions
	- 逐一设置每个 filed 的值,存入内存
- 设置 range_value 检查重复区间

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
							
#### 类图
```plantuml
class PT_partition{  
  typedef Parse_tree_node super;  
  
  PT_part_type_def *const part_type_def;  
  const uint opt_num_parts;  
  PT_sub_partition *const opt_sub_part;  
  const POS part_defs_pos;  
  Mem_root_array<PT_part_definition *> *part_defs;  
  
 public:  
  partition_info part_info;
  }
  
  class PT_part_type_def{   
}

class partition_info {  
 public:  
  
  /* NULL-terminated array of fields used in partitioned expression */  
  Field **part_field_array;  
  Field **subpart_field_array;  
  Field **part_charset_field_array;  
  Field **subpart_charset_field_array;  

  MY_BITMAP full_part_field_set;  
  
  /*  
    When we have a field that requires transformation before calling the    partition functions we must allocate field buffers for the field of    the fields in the partition function.  */  uchar **part_field_buffers;  
  uchar **subpart_field_buffers;  
  uchar **restore_part_field_ptrs;  
  uchar **restore_subpart_field_ptrs;  
  
  Item *part_expr;  
  Item *subpart_expr;  
  
  Item *item_list;  
  
 MY_BITMAP read_partitions;  
  MY_BITMAP lock_partitions;  
  bool bitmaps_are_initialized;  
  // TODO: Add first_read_partition and num_read_partitions?  
  
  union {  
    longlong *range_int_array;  
    LIST_PART_ENTRY *list_array;  
    part_column_list_val *range_col_array;  
    part_column_list_val *list_col_array;  
  };  
  
et_partitions_in_range_iter get_part_iter_for_interval;  
  get_partitions_in_range_iter get_subpart_iter_for_interval;  
  

  longlong err_value;  
  
  char *part_func_string;     //!< Partition expression as string  
  char *subpart_func_string;  //!< Subpartition expression as string  
  
  uint num_columns;  
  
  TABLE *table;  
Key_map all_fields_in_PF, all_fields_in_PPF, all_fields_in_SPF;  
  Key_map some_fields_in_PF;  
  
  handlerton *default_engine_type;  
  partition_type part_type;  
  partition_type subpart_type;  
  
  size_t part_func_len;  
  size_t subpart_func_len;  
  
  uint num_parts;  
  uint num_subparts;  
  
  uint num_list_values;  
  
  uint num_part_fields;  
  uint num_subpart_fields;  
  uint num_full_part_fields;  
  
  uint has_null_part_id;  
uint16 linear_hash_mask;  
  
  enum_key_algorithm key_algorithm;  
  
  /* Only the number of partitions defined (uses default names and options). */  
  bool use_default_partitions;  
  bool use_default_num_partitions;  
  /* Only the number of subpartitions defined (uses default names etc.). */  
  bool use_default_subpartitions;  
  bool use_default_num_subpartitions;  
  bool default_partitions_setup;  
  bool defined_max_value;  
  bool list_of_part_fields;     // KEY or COLUMNS PARTITIONING  
  bool list_of_subpart_fields;  // KEY SUBPARTITIONING  
  bool linear_hash_ind;         // LINEAR HASH/KEY  
  bool fixed;  
  bool is_auto_partitioned;  
  bool has_null_value;  
  bool column_list;  // COLUMNS PARTITIONING, 5.5+  
}
```

```cpp
partition_info::fix_partition_values
```
# 参考 
- [ORACLE create table 语法细则](https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_7002.htm#i2146287)
- [Partitioning in MySQL](https://dev.mysql.com/doc/refman/8.0/en/partitioning-overview.html)
