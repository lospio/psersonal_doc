 # 1. 需求
## 1.1 需求描述
MySQL 分区功能对齐 Oracle
- 优先解决各分区功能支持多种数据类型(string, datetime, number)
- 优先解决分区键限制(任意键)
## 1.2 需求分析
#### Oracle 分区功能
| 分区策略       | 数据分布           | 
| -------------- | ------------------ | 
| range          | 数据范围           | 
| list           | 一组确定的值       | 
| hash           | hash 算法          | 
| range-range    | range 和 range组合分区   |                  
| range-list     | range 和 list 组合分区 |                  
| range-hash     | range 和 hash 组合分区 |                  
| list-list      | list和list 组合分区    |                  
| hash-hash      |   hash 和 hash 组合分区                 |                  
| hash-range     |     hash 和 range 组合分区                |                  
| hash-list      |         hash 和 list 组合分区            |                  
| interval       |       range 分区, 落入不存在分区的时候根据 interval 自动创建分区             |                  
| interval-range |     interval 和 range 组合分区                |                  
| interval-list  |       interval 和 list 组合分区              |                  
| interval-hash  |        interval 和 hash 组合分区             |                  
| reference      |     将外键作为分区键和该外键指向表保持相同的分区策略               |                  
| vritual column               |   将虚拟列作为分区                 |                  

#### MySQL VS Oracle 分区功能对比

###### 分区策略

| 策略         | Oracle                      | MySQL                              |
| ------------ | --------------------------- | ---------------------------------- |
| range        | 支持 多列,支持多种类型      | 一列,仅支持整型                    |
| list         | 支持多种类型 ;语法不需要 in | 仅支持整型  ;语法需要 in           |
| range column | 不支持                      | 支持多列,支持 string,date,datetime |
| list column  | 不支持                      | 支持多列,支持 string,date,datetime |
| hash         | 支持多种类型                | 仅支持整型                         |
| subpartition | 子分区数量没有限制          | 各个 partition 子分区数量一致      |
| internal     | 支持                        | 不支持                             |
| reference    | 支持                        | 不支持                             |
| 最大分区数量 |  (1,024 K-1) = 1,048,575                            |    8192                                |
###### 索引
|                                | Oracle | MySQL  |
| ------------------------------ | ------ | ------ |
| local index                    | 支持   | 支持   |
| global index                   | 支持   | 不支持 |
| 分区键 | 任意列   | 主键和唯一索引的交集的子集       |
## 1.3 需求规格
| 功能                                                                   | 优先级 | 细节 | 进展 |
| ---------------------------------------------------------------------- | ------ | ---- | ---- |
| range，list，hash支持非整型字段，支持函数 （string，datetime，number） | 高     | 开发 |      |
| 支持非主键列                                                           | 高     | 开发 |      |
| 全局索引                                                               | 高     | 开发 |      |
| 查询指定分区（对接）select 指定分区       from t1 partition p0                                            | 高     | 适配 |      |
| range，list支持多列分区（range column 增强）                           | 中     | 开发 |      |
| 分区管理ddl（新增功能支持ddl）                                         | 中     | 适配 |      |
| 分区视图信息                                                           | 中     | 适配 |      |
| Oracle子分区：range-hash，range-list（语法，使用对齐）                 | 低     | 开发 |      |
| interval分区                                                           | 低     | 开发 |      |

### Oracle与MySQL RANGE分区差异
|                | Oracle range | MySQL range        | MySQL range columns |
| -------------- | ------------ | ------------------ | ------------------- |
| string, date   | 是           | 不支持             | 是                  |
| number(float, double,decimal )        | 是           | 不支持             | 不支持              |
| 表达式(加, 减, 乘) | 不支持       | 是                 | 不支持              |
| 表达式(除)     | 不支持       | 不支持             | 不支持              |
| 表达式(函数)   | 不支持       | 支持(返回值为整型) | 不支持              |
| 多列           | 最多 16 列   | 不支持             | 最多 16 列          |
### Oracle与MySQL LIST分区差异
|                       | Oracle List | MySQL List | MySQL List Columns |
| --------------------- | ----------- | ---------- | ------------------ |
| date, string          | 是          | 不支持     | 是                 |
| float, double,decimal | 是          | 不支持     | 是                 |
| 表达式                | 不支持      | 是         | 不支持             |
| 多列                  | 不支持      | 不支持     | 不支持                   |
### Oracle与MySQL HSAH分区差异
|                       | Oracle Hash | MySQL Hash | MySQL KEY |
| --------------------- | ----------- | ---------- | --------- |
| date,string           | 是          | 不支持     | 是        |
| float, double,decimal | 是          | 不支持     | 是        |
| 表达式                | 不支持      | 是         | 不支持    |
| 多列                  | 支持        | 不支持     | 支持      |
| 空列                  | 不支持      | 不支持     | 支持      |
| lob                   | 不支持      | 不支持     | 不支持          |


# 2. 友商方案
# 3. 设计实现
## 3.1 Range
### 3.1.1 任务
- 扩展支持分区键类型,扩展为(string, datetime, number)
- 扩展支持分区键的列数,当前仅为 1 列,目标参考 Oracle 支持 16 列
### 3.1.2 扩展支持类型
```sql
create table t (id int , id1 int) partition by range (id) (partition p1 values less than (100), partition p2 values less than(maxvalue));
```
- range columns 为什么不支持表达式
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

#### 具体流程
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
#### A. 思路:
 主要修改 Server 层现有代码,去除限制
参照 MySQL 既有 RANGE COLUMNS 功能代码,进行二次开发
1. 修改基础Class,添加对 Item 的适配支持,包括`PT_part_type_def` `partition_info`
2. 修改'get_partition_id_range'函数,  查找分区 id 的函数
3. 修改过程中对于类型的校验
#### B.  沿用现有的 range columns
修改parser
# 3. 关联模块
# 4. 概要设计
# 参考 
- [oracle create table](https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_7002.htm#i2146287)