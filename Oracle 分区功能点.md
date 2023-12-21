#todo 
1. review excel
2. 添加 mtr 测试用例 test, result
3. 
# 01. General
1. 最大分区数1024K-1
2. 可以向拥有分区的分区表添加数据;无法向非分区表添加一个分区
3. 可以为每个分区指定名字;也可以不指定由系统生成
4. 可以为 table segment 和 lob segments 分别指定 tablestapce.对于 interval 类型,指定表空间列表,自动循环使用
	```sql
	CREATE TABLE sales
	( prod_id NUMBER(6)
	, cust_id NUMBER
	, time_id DATE
	, quantity_sold NUMBER(3)
	, amount_sold NUMBER(10,2)
	)
	PARTITION BY RANGE (time_id)
	INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
	STORE IN (tbs1, tbs2, tbs3)
	( PARTITION sales_before_1998 VALUES LESS THAN (TO_DATE('01-JAN-1998','DD-MON-YYYY')) );
	```
5. 嵌套表和分区表默认同等分区
>在Oracle中，嵌套表是一种复杂的数据类型，允许你在一个单独的数据库表列中存储一个表。换句话说，嵌套表是表中的表。  
  嵌套表通常用于存储具有一对多关系的数据。例如，一个客户可以有多个电话号码，所以你可以创建一个包含电话号码的嵌套表，并将其存储在客户表的一个列中。
	```sql
	CREATE OR REPLACE TYPE phone_list_typ AS TABLE OF VARCHAR2(25);
	CREATE TABLE customers
	( cust_id NUMBER(6)
	, cust_name VARCHAR2(25)
	, phone_numbers phone_list_typ
	)
	NESTED TABLE phone_numbers STORE AS phone_numbers_nt
	PARTITION BY RANGE (cust_id)
	( PARTITION p1 VALUES LESS THAN (1000),
	PARTITION p2 VALUES LESS THAN (2000),
	PARTITION p3 VALUES LESS THAN (3000),
	PARTITION p4 VALUES LESS THAN (MAXVALUE)
	);
	```
6. cluster tables 无法分区
7. Oracle不允许对定义为索引组织表的嵌套表或可变数组进行分区
8. 不能对包含 long 或者long raw 类型列的表分区
# 02. range
1. 按照多个列进行分区
2. 对于索引组织表,分区键必须为主键列的子集
3. 忽略 partition 名字的时候自动生成
4. 指定区间的上限,多个列时一一对应
5. MAXVALUE 在排序中为最大值,包括 null 值
6. 为最高分区边界指定 MAXVALUE 以外的值会对表施加隐式完整性约束。
7. value less than 中无法指定 NULL 值
8. 分区键列的类型必须为 CHAR、NCHAR、VARCHAR2、NVARCHAR2、VARCHAR、NUMBER、FLOAT、DATE、TIMESTAMP、TIMESTAMP WITH LOCAL TIMEZONE 或 RAW。

## test case
```sql
--  测试最大分区数限制
-- oracle
DECLARE
  l_sql CLOB;
BEGIN
  l_sql := 'CREATE TABLE t (id INT) PARTITION BY RANGE (id) (';

  FOR i IN 1..8192 LOOP
    DBMS_LOB.APPEND(l_sql, ' PARTITION p' || i || ' VALUES LESS THAN (' || i || '),');
  END LOOP;

  -- Remove the trailing comma and add the closing parenthesis
  DBMS_LOB.TRIM(l_sql, DBMS_LOB.GETLENGTH(l_sql) - 1);
  DBMS_LOB.APPEND(l_sql, ')');

  EXECUTE IMMEDIATE l_sql;
END;
/

SELECT COUNT(*) AS partition_count

FROM DBA_TAB_PARTITIONS

WHERE table_name = 'T';

-- 向拥有一个分区的表插入分区
create table t(id int , name varchar(20), d date) partition by range(name) (partition values less than ('adfafda'));
alter table t add partition p1 values less than('bdcdc');

--  向一个普通表插入分区
create table t(id int , name varchar(20), d date);
alter table t add partition p1 values less than('bdcdc');

-- 插入两个分区不指定名字
create table t(id int , name varchar(20), d date) partition by range(name) (partition values less than ('adfafda'), partition values less than ('bcdcdfda'));
select table_name, partition_name from dba_tab_partitions where table_name ='T';

-- 创建分区表分别指定名字
create table t(id int , name varchar(20), d date) partition by range(name) (partition p1 values less than ('adfafda'), partition p2 values less than ('bcdcdfda'));
select table_name, partition_name from dba_tab_partitions where table_name ='T';


-- 对包含 long raw 类型的表分区
create table t(id int , data long raw ) partition by range(id) (partition p0 values less than(100));
-- 测试其他所有类型


-- 多列分区
CREATE TABLE t (id INT, name VARCHAR(10), d DATE) PARTITION BY RANGE (id, name, d) (
PARTITION p1 VALUES LESS THAN (100, 'A', TO_DATE('2023-01-01', 'YYYY-MM-DD')),
PARTITION p2 VALUES LESS THAN (200, 'B', TO_DATE('2024-01-01', 'YYYY-MM-DD')),
PARTITION p3 VALUES LESS THAN (MAXVALUE, MAXVALUE, MAXVALUE));

-- values less than 指定分区上限
create table t(id int) partition by range(id) (partition values less than (1));
insert into t values(0);
insert into t values(1);

-- 多列一一对应
-- 规则实例
-- (1,1,1)
-- if(id < 1) return ok
-- if(id ==1 ){
--   if(id1 < 1) return ok
--    if(id1 ==1 && id2 <1 ) return ok
-- }
-- return wrong
create table t(id int, id1 int, id2 int) partition by range(id,id1,id2)(partition values less than(1,1,1,) );
insert into t values(1,1,1);
insert into t values(0,1,1);
insert into t values(1,0,1);
insert into t values(1,1,0);
insert into t values(1,1,0);
insert into t values(0,3,3);

--  分区上限之间不重叠
alter table t add partition values less than (1,1,1);
alter table t add partition values less than (0,0,0);
alter table t add partition values less than (0,100,1000);
alter table t add partition values less than (1,1,2);
insert into t values (0,1,1);
select * from t partition(p1);
select * from t partition(SYS_P745);

-- Maxvalue 最大
insert into t values(null, null ,null);
alter table t add partition p3 values less than (maxvalue, maxvalue, maxvalue);
insert into t values(null, null ,null);
-- add partition
alter table t add partition values less than(2,2,2);
alter table t drop partition values less than(2,2,2);
-- exchange partition
create table t_1(id int, id1 int, id2 int);
alter table t exchange partition p1 with table t_1;
select table_name, partition_name from dba_tab_partitions where table_name ='T';
select * from t partition(p1);
select * from t_1;
```
# 03. List
1. 按照某一列的值,进行分区,可以将某一行数据放入指定的分区.
2. 每个分区中至少有一个值.
3. 任何值(包括 NULL)不能出现在多个分区中.
4. 可以指定 NULL值,访问时需要使用 is null.
5. DEFAULT 关键字将创建一个分区,数据库将在其中插入任何未映射到另一个分区的行.
6. 只能给一个分区指定 default.
7. 指定的 default 分区不能指定其他值.
8. default 分区只能是最后一个分区.
9. default 分区的使用类似于 range中的 MAXVALUE.
10. 包含每个分区的值列表的字符串最多可达 4K 字节.
11. 所有分区的值总数不能超过 64K-1.
12. 只能指定一列为分区键.
13. 分区键列的类型必须为 CHAR、NCHAR、VARCHAR2、NVARCHAR2、VARCHAR、NUMBER、FLOAT、DATE、TIMESTAMP、TIMESTAMP WITH LOCAL TIMEZONE 或 RAW.
# 04. Hash
1. 使用指定为分区键的列中的值的哈希函数将行分配给分区.
2. 可以指定单独的 hash 分区.
3. 可以指定分区个数.
4. 指定分区个数时,自动命名分区,SYS_Pn.
5. 建议分区个数为 2 的 n 次幂.
6. 分区键列数不能超过 16
7. 分区键列的类型必须为 CHAR、NCHAR、VARCHAR2、NVARCHAR2、VARCHAR、NUMBER、FLOAT、DATE、TIMESTAMP、TIMESTAMP WITH LOCAL TIMEZONE 或 RAW。