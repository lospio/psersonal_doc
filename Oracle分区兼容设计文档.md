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
| 查询指定分区（对接）                                                   | 高     | 适配 |      |
| range，list支持多列分区（range column 增强）                           | 中     | 开发 |      |
| 分区管理ddl（新增功能支持ddl）                                         | 中     | 适配 |      |
| 分区视图信息                                                           | 中     | 适配 |      |
| Oracle子分区：range-hash，range-list（语法，使用对齐）                 | 低     | 开发 |      |
| interval分区                                                           | 低     | 开发 |      |

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
#### 相关流程
- Server
	1. 解析 QUERY,构造Partition(`PT_partition`) 实例,Partition_type(`PT_part_type_def`) 实例, partition_info(`partition_info`)实例,
		- 记录分区类型(Range by clause)
		- 记录分区键的表达式(id)
		- 分区信息(分区数量, 每个分区的上限值, 分区名称,子分区)
		- 分区 id 相关的函数指针
	2. 校验
		- 检查分区函数是否合法 `partition_info::check_partition_info`
		- 检查 null 值, MAXVALUE,分区函数返回值 `partition_info::fix_parser_data`
		- 子分区校验`partition_info::check_partition_info`
		- 校验区间重叠,column的值`partition_info::check_list_constants`
	3. 创建缓存数据 table_share DDtable (DATA Directionary)
- innodb
	1. 从table_share 读取 table 信息
	2. 再次解析 Query, 创建关键数据结构,包括==校验分区键类型信息==(`fix_partition_func`)
	3. 遍历所有分区建表
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
PT_partition *-- PT_part_type_def
```

```cpp
partition_info::fix_partition_values
```
#### A. 思路:
参照 MySQL 既有 RANGE COLUMNS 功能代码,进行二次开发
1. 修改基础Class,添加对 Item 的适配支持,包括`PT_part_type_def` `partition_info`
2. 修改'get_partition_id_range'函数,  查找分区 id 的函数
4. 修改过程中对于类型的校验

# 3. 关联模块
# 4. 概要设计
