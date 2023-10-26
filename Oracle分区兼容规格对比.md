# 1. 官方文档
Oracle Database 11g Release 2 (11.2):
- [partitioning](https://docs.oracle.com/cd/E11882_01/server.112/e25523/intro.htm)

MySQL 8.0:
- [partitioning](https://dev.mysql.com/doc/refman/8.0/en/partitioning.html)

## Partition 概览
分区特点:
- 表或索引的每个分区必须具有相同的逻辑属性，例如列名、数据类型和约束。

分区键(Partitioned Key):
- 分区键由==一列或多列==组成，这些列确定存储每一行​​的分区
# 2. 分区策略
## Oracle支持项
### Single-level:
单级分区策略仅使用一种数据分布方法
#### Range Partitioning
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/range_partitions.gif)

按照分区键的范围进行分区.
```sql
create table t(a date ,b varchar(10)) partition by range(a,b) (partition p0 values less than ('31-JAN-2007',100));
```
 - 包含 values less than 语句,  是一个开区间的上限
 - 分区键类型和上限的类型相同或者可以相互转换
	 ```sql
	 SQL> create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (100));
	create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (100))
	--  类型保持一致
	ERROR at line 1:
	ORA-00932: inconsistent datatypes: expected BINARY got NUMBER

    -- 类型可以转换
    SQL> create table t(a int , b varchar(10)) partition by range(b) (partition p0 values less than (100));

	Table created.
	```
 - 上限允许的类型为:
	 - string
	 - datetime 
	 - interval literal
	 - number
	 - MAXVALUE
	 ```sql
	SQL> create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (sysguid()));
	create table t(a date ,b raw(16)) partition by range(b) (partition p0 values less than (sysguid()))
	--  类型限制
	ERROR at line 1:
	ORA-14019: partition bound element must be one of: string, datetime or interval
	literal, number, or MAXVALUE
	```
#### Interval Partitioning
区间分区是范围分区的扩展。如果插入的数据超出现有分区范围，Oracle 数据库会自动创建指定间隔的分区
```sql
SQL>
CREATE TABLE interval_sales
    ( prod_id        NUMBER(6)
  3      , cust_id        NUMBER
    , time_id        DATE
    , channel_id     CHAR(1)3)(1)
    , promo_id       NUMBER(6)
  6      , quantity_sold  NUMBER(3)
    , amount_sold    NUMBER(10,2)
    )
  PARTITION BY RANGE (time_id)
  INTERVAL(NUMTOYMINTERVAL(1, 'MONTH'))
    ( PARTITION p0 VALUES LESS THAN (TO_DATE('1-1-2010', 'DD-MM-YYYY'))
    , PARTITION p1 VALUES LESS THAN (TO_DATE('1-1-2011', 'DD-MM-YYYY'))
    , PARTITION p2 VALUES LESS THAN (TO_DATE('1-7-2012', 'DD-MM-YYYY'))
 15      , PARTITION p3 VALUES LESS THAN (TO_DATE('1-1-2013', 'DD-MM-YYYY')) );

Table created.

SQL> INSERT INTO interval_sales VALUES (39,7602,'10-OCT-14',9,null,1,11.79);

1 row created.

SQL> COL PNAME FORMAT a9
SQL> COL HIGH_VALUE FORMAT a40
SQL> SELECT PARTITION_NAME AS PNAME, HIGH_VALUE FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'INTERVAL_SALES';

PNAME	  HIGH_VALUE
--------- ----------------------------------------
P0	  TO_DATE(' 2010-01-01 00:00:00', 'SYYYY-M
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P1	  TO_DATE(' 2011-01-01 00:00:00', 'SYYYY-M
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P2	  TO_DATE(' 2012-07-01 00:00:00', 'SYYYY-M
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P3	  TO_DATE(' 2013-01-01 00:00:00', 'SYYYY-M
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

PNAME	  HIGH_VALUE
--------- ----------------------------------------

SYS_P79   TO_DATE(' 2014-11-01 00:00:00', 'SYYYY-M
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA
```
#### List Partitioning
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/list_partitions.gif)
 使用离散值列表作为分区键
 ```sql
 create table t (id int , name varchar(10)) partition by list (id)(partition p0 values(1,2,3,4,5), partition p1 values('6'));
```
-  允许按照一列进行分区
	```sql
	SQL> create table t (id int , name varchar(10)) partition by list (id,name)(partition p0 values(1,2,3,4,5),('a','b'), partition p1 values('6'));
	create table t (id int , name varchar(10)) partition by list (id,name)(partition p0 values(1,2,3,4,5),('a','b'), partition p1 values('6'))
	                                                                      *
	ERROR at line 1:
	ORA-14304: List partitioning method expects a single partitioning column
	```
- 允许的类型:
	- string
	- datetime
	- interval
	- literal
	- number
	- NULL
	```sql
	QL> create table t(a raw(16)) partition by list (a) (partition p0 values(sysguid()));
	create table t(a raw(16)) partition by list (a) (partition p0 values(sysguid()))
	                                                                              *
	ERROR at line 1:
	ORA-14308: partition bound element must be one of: string, datetime or interval
	literal, number, or NULL
	```
#### Hash Partitioning
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/hash_partitions.gif)

individual_hash_partitions::=
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/individual_hash_partitions.gif)


hash_partitions_by_quantity::=
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/hash_partitions_by_quantity.gif)
根据用户指定的分区键的哈希算法将行映射到分区。
```sql
SQL> create table t(id int , val raw(16)) partition by hash(val) partitions 2;

Table created.
```
-  Oracle 内置类型中,除 LOB 外都支持
### Composite Partitioning
复合分区是基本数据分布方法的组合；通过一种数据分布方法对表进行分区，然后使用第二种数据分布方法将每个分区进一步细分为==子分区==。
```sql
-- hash-hash
SQL> create table t(a int , b int) partition by hash(a) subpartition by hash(b) subpartitions 4 partitions 2;

Table created.

-- hash-list

```