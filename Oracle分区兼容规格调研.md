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
 - 分区键可以包含最多 16 列
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
#### List Partitioning
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/list_partitions.gif)
 使用离散值列表作为分区键
 ```sql
 create table t (id int , name varchar(10)) partition by list (id)(partition p0 values(1,2,3,4,5), partition p1 values('6'));
```
- 分区键可以包含最多 16 列
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
- Composite Hash-Hash Partitioning
- Composite Hash-Range Partitioning
- Composite Hash-List Partitioning
- Composite Range-Range Partitioning
- Composite Range-Hash Partitioning
- Composite Range-List Partitioning
- Composite List-Range Partitioning
- Composite List-Hash Partitioning
- Composite List-List Partitioning

```sql
-- hash-hash
SQL> create table t(a int , b int) partition by hash(a) subpartition by hash(b) subpartitions 4 partitions 2;

Table created.

-- hash-range
create table t (  a int,  b int)
partition by hash(a)  
subpartition by range(b) 
subpartition template(subpartition sub_1 values less than (5) ) 
partitions 2 ;

-- range-hash
CREATE TABLE sales
  ( prod_id       NUMBER(6)
  , cust_id       NUMBER
  , time_id       DATE
  , channel_id    CHAR(1)
  , promo_id      NUMBER(6)
  , quantity_sold NUMBER(3)
  , amount_sold   NUMBER(10,2)
  )
 PARTITION BY RANGE (time_id) SUBPARTITION BY HASH (cust_id)
  SUBPARTITIONS 8 
 ( PARTITION sales_q1_2006 VALUES LESS THAN (TO_DATE('01-APR-2006','dd-MON-yyyy'))
  , PARTITION sales_q2_2006 VALUES LESS THAN (TO_DATE('01-JUL-2006','dd-MON-yyyy'))
  , PARTITION sales_q3_2006 VALUES LESS THAN (TO_DATE('01-OCT-2006','dd-MON-yyyy'))
  , PARTITION sales_q4_2006 VALUES LESS THAN (TO_DATE('01-JAN-2007','dd-MON-yyyy'))
 );
-- range-list
CREATE TABLE quarterly_regional_sales
      (deptno number, item_no varchar2(20),
       txn_date date, txn_amount number, state varchar2(2))
  PARTITION BY RANGE (txn_date)
    SUBPARTITION BY LIST (state)
      (PARTITION q1_1999 VALUES LESS THAN (TO_DATE('1-APR-1999','DD-MON-YYYY'))
         (SUBPARTITION q1_1999_northwest VALUES ('OR', 'WA'),
          SUBPARTITION q1_1999_southwest VALUES ('AZ', 'UT', 'NM'),
          SUBPARTITION q1_1999_northeast VALUES ('NY', 'VM', 'NJ'),
          SUBPARTITION q1_1999_southeast VALUES ('FL', 'GA'),
          SUBPARTITION q1_1999_northcentral VALUES ('SD', 'WI'),
          SUBPARTITION q1_1999_southcentral VALUES ('OK', 'TX')
         ),
       PARTITION q2_1999 VALUES LESS THAN ( TO_DATE('1-JUL-1999','DD-MON-YYYY'))
         (SUBPARTITION q2_1999_northwest VALUES ('OR', 'WA'),
          SUBPARTITION q2_1999_southwest VALUES ('AZ', 'UT', 'NM'),
          SUBPARTITION q2_1999_northeast VALUES ('NY', 'VM', 'NJ'),
          SUBPARTITION q2_1999_southeast VALUES ('FL', 'GA'),
          SUBPARTITION q2_1999_northcentral VALUES ('SD', 'WI'),
          SUBPARTITION q2_1999_southcentral VALUES ('OK', 'TX')
         ),
       PARTITION q3_1999 VALUES LESS THAN (TO_DATE('1-OCT-1999','DD-MON-YYYY'))
         (SUBPARTITION q3_1999_northwest VALUES ('OR', 'WA'),
          SUBPARTITION q3_1999_southwest VALUES ('AZ', 'UT', 'NM'),
          SUBPARTITION q3_1999_northeast VALUES ('NY', 'VM', 'NJ'),
          SUBPARTITION q3_1999_southeast VALUES ('FL', 'GA'),
          SUBPARTITION q3_1999_northcentral VALUES ('SD', 'WI'),
          SUBPARTITION q3_1999_southcentral VALUES ('OK', 'TX')
         ),
       PARTITION q4_1999 VALUES LESS THAN ( TO_DATE('1-JAN-2000','DD-MON-YYYY'))
         (SUBPARTITION q4_1999_northwest VALUES ('OR', 'WA'),
          SUBPARTITION q4_1999_southwest VALUES ('AZ', 'UT', 'NM'),
          SUBPARTITION q4_1999_northeast VALUES ('NY', 'VM', 'NJ'),
          SUBPARTITION q4_1999_southeast VALUES ('FL', 'GA'),
          SUBPARTITION q4_1999_northcentral VALUES ('SD', 'WI'),
          SUBPARTITION q4_1999_southcentral VALUES ('OK', 'TX')
         )
      );
 ```
### 拓展功能
#### Interval Partitioning
- interval
- interval-hash
- interval-list
- interval-range
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
P0	  TO_DATE(' 2010-01-01 00:00:00', 'SYYYY-M'
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P1	  TO_DATE(' 2011-01-01 00:00:00', 'SYYYY-M'
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P2	  TO_DATE(' 2012-07-01 00:00:00', 'SYYYY-M'
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P3	  TO_DATE(' 2013-01-01 00:00:00', 'SYYYY-M'
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

PNAME	  HIGH_VALUE
--------- ----------------------------------------

SYS_P79   TO_DATE(' 2014-11-01 00:00:00', 'SYYYY-M'
	  M-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

-- interval-list
CREATE TABLE sales_interval_list
  ( product_id       NUMBER(6)
  , customer_id      NUMBER
  , channel_id       CHAR(1)
  , promo_id         NUMBER(6)
  , sales_date       DATE
  , quantity_sold    INTEGER
  , amount_sold      NUMBER(10,2)
  )
 PARTITION BY RANGE (sales_date) INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
 SUBPARTITION BY LIST (channel_id)
   SUBPARTITION TEMPLATE
   ( SUBPARTITION p_catalog VALUES ('C')
   , SUBPARTITION p_internet VALUES ('I')
   , SUBPARTITION p_partners VALUES ('P')
   , SUBPARTITION p_direct_sales VALUES ('S')
   , SUBPARTITION p_tele_sales VALUES ('T')
   )
 (PARTITION before_2017 VALUES LESS THAN (TO_DATE('01-JAN-2017','dd-MON-yyyy'))
  );

SELECT TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME FROM USER_TAB_SUBPARTITIONS WHERE TABLE_NAME ='SALES_INTERVAL_LIST';


SQL> SELECT TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME FROM USER_TAB_SUBPARTITIONS WHERE TABLE_NAME ='SALES_INTERVAL_LIST';

TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
SUBPARTITION_NAME
------------------------------
SALES_INTERVAL_LIST	       BEFORE_2017
BEFORE_2017_P_CATALOG

SALES_INTERVAL_LIST	       BEFORE_2017
BEFORE_2017_P_INTERNET

SALES_INTERVAL_LIST	       BEFORE_2017
BEFORE_2017_P_PARTNERS


TABLE_NAME		       PARTITION_NAME
------------------------------ ------------------------------
SUBPARTITION_NAME
------------------------------
SALES_INTERVAL_LIST	       BEFORE_2017
BEFORE_2017_P_DIRECT_SALES

SALES_INTERVAL_LIST	       BEFORE_2017
BEFORE_2017_P_TELE_SALES
```
#### Reference Partitioning
在引用分区中，子表的分区策略仅通过与父表的外键关系来定义。

对于父表中的每个分区，子表中都存在一个对应的分区。

父表将父记录存储在特定分区中，子表将子记录存储在相应的分区中。
```sql
CREATE TABLE orders
    ( order_id           NUMBER(12),
      order_date         DATE,
      order_mode         VARCHAR2(8),
      customer_id        NUMBER(6),
      order_status       NUMBER(2),
      order_total        NUMBER(8,2),
      sales_rep_id       NUMBER(6),
      promotion_id       NUMBER(6),
      CONSTRAINT orders_pk PRIMARY KEY(order_id)
    )
  PARTITION BY RANGE(order_date)
    ( PARTITION Q1_2015 VALUES LESS THAN (TO_DATE('01-APR-2015','DD-MON-YYYY')),
      PARTITION Q2_2015 VALUES LESS THAN (TO_DATE('01-JUL-2015','DD-MON-YYYY')),
      PARTITION Q3_2015 VALUES LESS THAN (TO_DATE('01-OCT-2015','DD-MON-YYYY')),
      PARTITION Q4_2015 VALUES LESS THAN (TO_DATE('01-JAN-2016','DD-MON-YYYY'))
    );

CREATE TABLE order_items
    ( order_id           NUMBER(12) NOT NULL,
      line_item_id       NUMBER(3)  NOT NULL,
      product_id         NUMBER(6)  NOT NULL,
      unit_price         NUMBER(8,2),
      quantity           NUMBER(8),
      CONSTRAINT order_items_fk
      FOREIGN KEY(order_id) REFERENCES orders(order_id)
    )
    PARTITION BY REFERENCE(order_items_fk);


SQL>  SELECT PARTITION_NAME AS PNAME, HIGH_VALUE FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'ORDERS';

PNAME
------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
Q1_2015
TO_DATE(' 2015-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

Q2_2015
TO_DATE(' 2015-07-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

Q3_2015
TO_DATE(' 2015-10-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA


PNAME
------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
Q4_2015
TO_DATE(' 2016-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA


SQL>  SELECT PARTITION_NAME AS PNAME, HIGH_VALUE FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'ORDER_ITEMS';

PNAME
------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
Q1_2015


Q2_2015


Q3_2015



PNAME
------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
Q4_2015
```
#### Virtual Column-Based Partitioning
分区键可以使用虚拟列,意味着可以使用表达式
```sql
create table t(
	a int , 
	b int generated always as (a*10) virtual)
 partition by range(b) (partition p0 values less than (100));
```
所有基本分区策略都支持基于虚拟列的分区，包括hash分区以及internal和internal-* 复合分区。
### 分区策略小结
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

# 3. 分区索引
## Local Indexes
本地索引是一个分区表上的一个索引，它与底层的分区表相结合，从表中“继承”分区策略
耦合支持优化的分区维护；例如，当一个表分区被删除时，Oracle也只需删除相应的索引分区。没有昂贵的索引维护 是必需的。本地索引在数据仓库环境中最为常见。
- Local prefixed indexes
	分区键位于索引定义的前沿。
- Local nonprefixed indexes
	分区键不位于索引定义的前沿。
## Global Partitioned Indexes
全局分区索引是分区或非分区表上的索引，该索引使用与表不同的分区键或分区策略进行分区.
全局分区的索引可以使用范围分区或哈希分区进行分区，并从底层表中解耦
例如，一个表可以按月划分为范围，并且有12个分区，而==该表上的一个索引可以使用不同的分区键进行范围分区==，并有分不同数量的分区。全局。
```sql
CREATE INDEX time_channel_sales_idx ON time_range_sales (channel_id)
   GLOBAL PARTITION BY RANGE (channel_id)
      (PARTITION p1 VALUES LESS THAN (3),
       PARTITION p2 VALUES LESS THAN (4),
       PARTITION p3 VALUES LESS THAN (MAXVALUE));

```
## Global Non-Partitioned Indexes
全局非分区索引本质上与非分区表上的索引相同。索引结构没有从底层表中进行分区和分离。在数据仓库环境中,全局非分区索引最常用的用法是强制执行主键约束。
## 分区管理操作
添加新的分区、删除、分割、移动、合并、截断和可选地压缩分区。

# 4. 差异对比
## 分区策略
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
### TODO
1. 支持非主键列
2. range，list支持多列分区（range column 增强）
3. range，list，hash支持非整型字段，支持函数 （string，datetime，number） 做成什么样 怎么做
4. Oracle子分区：range-hash，range-list（语法，使用对齐）
5. interval分区
6. 全局索引
7. 查询指定分区
8. 分区管理ddl
## 索引
|                                | Oracle | MySQL  |
| ------------------------------ | ------ | ------ |
| local index                    | 支持   | 支持   |
| global index                   | 支持   | 不支持 |
| 分区键 | 任意列   | 主键和唯一索引的交集的子集       |
# 5. 参考实现
## openGauss
```cpp
// 关键数据结构修改
+/*
+ * Used as key of hash table for PagetableEntry.
+ */
+typedef struct PagetableEntryNode_s {
+    BlockNumber blockNo;    /* page number (hashtable key) */
+    Oid partitionOid;       /* used for GLOBAL partition index to indicate partition table */
+} PagetableEntryNode;

@@ -473,6 +519,7 @@ typedef struct BTScanPosItem { /* what we remember about each match */
     ItemPointerData heapTid;   /* TID of referenced heap item */
     OffsetNumber indexOffset;  /* index item's location within page */
     LocationIndex tupleOffset; /* IndexTuple's offset in workspace, if any */
+    Oid partitionOid;          /* partition table oid in workspace, if any */
 } BTScanPosItem;

@@ -154,6 +154,7 @@ typedef struct RelationData {
     bytea* rd_options; /* parsed pg_class.reloptions */
 
     /* These are non-NULL only for an index relation: */
+    Oid rd_partHeapOid;   /* partition index's partition oid */
     Form_pg_index rd_index; /* pg_index tuple describing this index */
     /* use "struct" here to avoid needing to include htup.h: */
     struct HeapTupleData* rd_indextuple; /* all of pg_index tuple */
     ...
     }
// tid bitmap scan
-638,12 +658,14 @@ TBMIterateResult* tbm_iterate(TBMIterator* iterator)
      */
     if (iterator->schunkptr < tbm->nchunks) {
         PagetableEntry* chunk = tbm->schunks[iterator->schunkptr];
-        BlockNumber chunk_blockno;
-
-        chunk_blockno = chunk->blockno + iterator->schunkbit;
-        if (iterator->spageptr >= tbm->npages || chunk_blockno < tbm->spages[iterator->spageptr]->blockno) {
+        PagetableEntryNode pnode;
+        pnode.blockNo = chunk->entryNode.blockNo + iterator->schunkbit;
+        pnode.partitionOid = chunk->entryNode.partitionOid;
+        if (iterator->spageptr >= tbm->npages ||
+            IS_CHUNK_BEFORE_PAGE(pnode, tbm->spages[iterator->spageptr]->entryNode)) {
             /* Return a lossy page indicator from the chunk */
-            output->blockno = chunk_blockno;
+            output->blockno = pnode.blockNo;
+            output->partitionOid = pnode.partitionOid;
             output->ntuples = -1;
             output->recheck = true;
             iterator->schunkbit++;
@@ -680,7 +702,8 @@ TBMIterateResult* tbm_iterate(TBMIterator* iterator)
                 }
             }
         }
-        output->blockno = page->blockno;
+        output->blockno = page->entryNode.blockNo;
+        output->partitionOid = page->entryNode.partitionOid;
         output->ntuples = ntuples;
         output->recheck = page->recheck;
         iterator->spageptr++;

// read index tuple
while (offnum <= maxoff) {  
    itup = _bt_checkkeys(scan, page, offnum, dir, &continuescan);  
    if (itup != NULL) {  
        /* Get partition oid for global partition index */  
        isnull = false;  
        partOid = scan->xs_want_ext_oid  
                      ? DatumGetUInt32(index_getattr(itup, PartitionOidAttr, tupdesc, &isnull))  
                      : heapOid;  
        Assert(!isnull);  
        /* tuple passes all scan key conditions, so remember it */  
        _bt_saveitem(so, itemIndex, offnum, itup, partOid);  
        itemIndex++;  
    }  
    if (!continuescan) {  
        /* there can't be any more matches, so stop */  
        so->currPos.moreRight = false;  
        break;  
    }  
  
    offnum = OffsetNumberNext(offnum);  
}

@@ -40,7 +40,7 @@ typedef struct IndexTupleData {
      *
      * 15th (high) bit: has nulls
      * 14th bit: has var-width attributes
-     * 13th bit: unused
+     * 13th bit: AM-defined meaning
      * 12-0 bit: size of tuple
      * ---------------
      */

typedef struct IndexScanDescData {
     AbsIdxScanDescData sd;
     /* scan parameters */
-    Relation heapRelation;  /* heap relation descriptor, or NULL */
-    Relation indexRelation; /* index relation descriptor */
-    Snapshot xs_snapshot;   /* snapshot to see */
-    int numberOfKeys;       /* number of index qualifier conditions */
-    int numberOfOrderBys;   /* number of ordering operators */
-    ScanKey keyData;        /* array of index qualifier descriptors */
-    ScanKey orderByData;    /* array of ordering op descriptors */
-    bool xs_want_itup;      /* caller requests index tuples */
+    Relation heapRelation;   /* heap relation descriptor, or NULL */
+    Relation indexRelation;  /* index relation descriptor */
+    GPIScanDesc xs_gpi_scan;  /* global partition index scan use information */
+    Snapshot xs_snapshot;    /* snapshot to see */
+    int numberOfKeys;        /* number of index qualifier conditions */
+    int numberOfOrderBys;    /* number of ordering operators */
+    ScanKey keyData;         /* array of index qualifier descriptors */
+    ScanKey orderByData;     /* array of ordering op descriptors */
+    bool xs_want_itup;       /* caller requests index tuples */
+    bool xs_want_ext_oid;    /* global partition index need partition oid */
 
     /* signaling to index AM about killing index tuples */
     bool kill_prior_tuple;      /* last-returned tuple is dead */
@@ -162,6 +164,20 @@ typedef struct IndexScanDescData {



@@ -473,6 +519,7 @@ typedef struct BTScanPosItem { /* what we remember about each match */
     ItemPointerData heapTid;   /* TID of referenced heap item */
     OffsetNumber indexOffset;  /* index item's location within page */
     LocationIndex tupleOffset; /* IndexTuple's offset in workspace, if any */
+    Oid partitionOid;          /* partition table oid in workspace, if any */
 } BTScanPosItem;
// 创建全局索引
  
/*  
 * ReindexGlobalIndexInternal - This routine is used to recreate a single global index */void ReindexGlobalIndexInternal(Relation heapRelation, Relation iRel, IndexInfo* indexInfo)  
{  
    List* partitionList = NULL;  
    /* We'll open any partition of relation by partition OID and lock it */  
    partitionList = relationGetPartitionList(heapRelation, ShareLock);  
  
    /* We'll build a new physical relation for the index */  
    RelationSetNewRelfilenode(iRel, InvalidTransactionId);  
  
    /* Initialize the index and rebuild */  
    /* Note: we do not need to re-establish pkey setting */    index_build(heapRelation, NULL, iRel, NULL, indexInfo, false, true, INDEX_CREATE_GLOBAL_PARTITION);  
  
    releasePartitionList(heapRelation, &partitionList, NoLock);  
  
    // call the internal function, update pg_index system table  
    ATExecSetIndexUsableState(IndexRelationId, iRel->rd_id, true);  
}

// insert index tuple
--- a/src/include/utils/rel.h
+++ b/src/include/utils/rel.h
@@ -154,6 +154,7 @@ typedef struct RelationData {
     bytea* rd_options; /* parsed pg_class.reloptions */
 
     /* These are non-NULL only for an index relation: */
+    Oid rd_partHeapOid;   /* partition index's partition oid */
     Form_pg_index rd_index; /* pg_index tuple describing this index */
     /* use "struct" here to avoid needing to include htup.h: */
     struct HeapTupleData* rd_indextuple; /* all of pg_index tuple */



/* Save an index item into so->currPos.items[itemIndex] */  
static void _bt_saveitem(BTScanOpaque so, int itemIndex, OffsetNumber offnum, const IndexTuple itup, Oid partOid)  
{  
    BTScanPosItem* currItem = &so->currPos.items[itemIndex];  
  
    currItem->heapTid = itup->t_tid;  
    currItem->indexOffset = offnum;  
    currItem->partitionOid = partOid;  
    if (so->currTuples) {  
        Size itupsz = IndexTupleSize(itup);  
  
        currItem->tupleOffset = (uint16)so->currPos.nextTupleOffset;  
        errno_t rc = memcpy_s(so->currTuples + so->currPos.nextTupleOffset, itupsz, itup, itupsz);  
        securec_check(rc, "", "");  
        so->currPos.nextTupleOffset += MAXALIGN(itupsz);  
    }  
}


void tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool recheck, Oid partitionOid)
 {
     int i;
 
@@ -266,6 +282,7 @@ void tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool rech
         BlockNumber blk = ItemPointerGetBlockNumber(tids + i);
         OffsetNumber off = ItemPointerGetOffsetNumber(tids + i);
         PagetableEntry* page = NULL;
+        PagetableEntryNode pageNode = {blk, partitionOid};
         int wordnum, bitnum;
 
         /* safety check to ensure we don't overrun bit array bounds */
@@ -276,11 +293,11 @@ void tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool rech
                     errmsg("tuple offset out of range: %u", off)));
         }
 
-        if (tbm_page_is_lossy(tbm, blk)) {
+        if (tbm_page_is_lossy(tbm, pageNode)) {
             continue; /* whole page is already marked */
         }
 
-        page = tbm_get_pageentry(tbm, blk);
+        page = tbm_get_pageentry(tbm, pageNode);
 
         if (page->ischunk) {
             /* The page is a lossy chunk header, set bit for itself */
...
...
...
}
  */
 void tbm_add_page(TIDBitmap* tbm, BlockNumber pageno)
 {
+    PagetableEntryNode pnode = {pageno, InvalidOid};
     /* Enter the page in the bitmap, or mark it lossy if already present */
-    tbm_mark_page_lossy(tbm, pageno);
+    tbm_mark_page_lossy(tbm, pnode);
     /* If we went over the memory limit, lossify some more pages */
     if (tbm->nentries > tbm->maxentries) {
         tbm_lossify(tbm);
 ...
}



```
- startScan
	- startScanEntry (Start* functions setup beginning state of searches: finds correct buffer and pins it.)
		-
```cpp
typedef struct RelationData {
     bytea* rd_options; /* parsed pg_class.reloptions */
 
     /* These are non-NULL only for an index relation: */
+    Oid rd_partHeapOid;   /* partition index's partition oid */
     Form_pg_index rd_index; /* pg_index tuple describing this index */
     /* use "struct" here to avoid needing to include htup.h: */
     struct HeapTupleData* rd_indextuple; /* all of pg_index tuple */
     ...
     ...
 }
/*  
 * btbuild() -- build a new btree index. 
 * */
Datum btbuild(PG_FUNCTION_ARGS)  {
	GlobalIndexBuildHeapScan{
		foreach(partitionCell, partitionIdList) {  
		    partitionId = lfirst_oid(partitionCell);  
		    partition = partitionOpen(heapRelation, partitionId, ShareLock);  
		    heapPartRel = partitionGetRelation(heapRelation, partition);  
		    relTuples = IndexBuildHeapScan(heapPartRel, indexRelation, indexInfo, true, callback, callbackState);  {
			    /*  
				 * Scan all tuples in the base relation. 
				 */
				 while ((heapTuple = heap_getnext(scan, ForwardScanDirection)) != NULL) {
					 reltuples += 1;
					 /* Set up for predicate or expression evaluation */  
					(void)ExecStoreTuple(heapTuple, slot, InvalidBuffer, false);
					/*  
					 * For the current heap tuple, extract all the attributes we use in * this index, and note which are null.  This also performs evaluation of any expressions needed. 
					 */
					 FormIndexDatum(indexInfo, slot, estate, values, isnull);
				 }
		    }
		    globalIndexTuples[partitionIdx] = relTuples;  
		    releaseDummyRelation(&heapPartRel);  
		    partitionClose(heapRelation, partition, NoLock);  
		    partitionIdx++;  
		}
	}
	/*  
   * given a spool loaded by successive calls to _bt_spool, * create an entire btree. 
   */
   _bt_leafbuild(buildstate.spool, buildstate.spool2);
}

/*  
 * btgetbitmap() -- gets all matching tuples, and adds them to a bitmap */
 Datum btgetbitmap(PG_FUNCTION_ARGS){
	 /* This loop handles advancing to the next array elements, if any */  
	do {  
	    /* Fetch the first page & tuple */  
	    if (_bt_first(scan, ForwardScanDirection)) {  
	        /* Save tuple ID, and continue scanning */  
	        heapTid = &scan->xs_ctup.t_self;  
+	        Oid currPartOid = so->currPos.items[so->currPos.itemIndex].partitionOid;  
+	        tbm_add_tuples(tbm, heapTid, 1, false, currPartOid);  
	        ntids++;  
	  
	        for (;;) {  
	            /*  
	             * Advance to next tuple within page.  This is the same as the             * easy case in _bt_next().             */            if (++so->currPos.itemIndex > so->currPos.lastItem) {  
	                /* let _bt_next do the heavy lifting */  
	                if (!_bt_next(scan, ForwardScanDirection)) {  
	                    break;  
	                }  
	            }  
	  
	            /* Save tuple ID, and continue scanning */  
	            heapTid = &so->currPos.items[so->currPos.itemIndex].heapTid;  
+	            currPartOid = so->currPos.items[so->currPos.itemIndex].partitionOid;  
+	            tbm_add_tuples(tbm, heapTid, 1, false, currPartOid);  
	            ntids++;  
	        }  
	    }  
	    /* Now see if we have more array keys to deal with */  
	} while (so->numArrayKeys && _bt_advance_array_keys(scan, ForwardScanDirection));
 }
//tidbitmap.cpp

/*  
 * Used as key of hash table for PagetableEntry. 
 */
typedef struct PagetableEntryNode_s {
+    BlockNumber blockNo;    /* page number (hashtable key) */
+    Oid partitionOid;       /* used for GLOBAL partition index to indicate partition table */
+} PagetableEntryNode;


/*  
 * The hashtable entries are represented by this data structure.  For an exact page, blockno is the page number and bit k of the bitmap represents tuple offset k+1.
 */
 typedef struct PagetableEntry {
-    BlockNumber blockno; /* page number (hashtable key) */
+    PagetableEntryNode entryNode;
     bool ischunk;        /* T = lossy storage, F = exact */
     bool recheck;        /* should the tuples be rechecked? */
     bitmapword words[Max(WORDS_PER_PAGE, WORDS_PER_CHUNK)];
 } PagetableEntry;

/*  
 * Here is the representation for a whole TIDBitMap: */
 struct TIDBitmap {  
    NodeTag type;          /* to make it a valid Node */  
    MemoryContext mcxt;    /* memory context containing me */  
    TBMStatus status;      /* see codes above */  
    HTAB* pagetable;       /* hash table of PagetableEntry's */  
    int nentries;          /* number of entries in pagetable */  
    int maxentries;        /* limit on same to meet maxbytes */  
    int npages;            /* number of exact entries in pagetable */  
    int nchunks;           /* number of lossy entries in pagetable */  
    bool iterating;        /* tbm_begin_iterate called? */  
+  bool isGlobalPart;     /* represent global partition index tbm */  
    PagetableEntry entry1; /* used when status == TBM_ONE_PAGE */  
    /* these are valid when iterating is true: */    PagetableEntry** spages;  /* sorted exact-page list, or NULL */  
    PagetableEntry** schunks; /* sorted lossy-chunk list, or NULL */  
};

oid tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool recheck, Oid partitionOid)  
{  
    for (i = 0; i < ntids; i++) {  
        PagetableEntry* page = NULL;  
        PagetableEntryNode pageNode = {blk, partitionOid};  
        int wordnum, bitnum;  
        if (tbm_page_is_lossy(tbm, pageNode)) {  
            continue; /* whole page is already marked */  
        }  
+      page = tbm_get_pageentry(tbm, pageNode){
+			 /* Initialize it if not present before */  
+			if (!found) {  
+			    rc = memset_s(page, sizeof(PagetableEntry), 0, sizeof(PagetableEntry));  
+			    securec_check(rc, "", "");  
+			    page->entryNode.blockNo = pageNode.blockNo;  
+			    page->entryNode.partitionOid = pageNode.partitionOid;  
+			    /* must count it too */  
+			    tbm->nentries++;  
+			    tbm->npages++;  
			}
		}
        if (page->ischunk) {  
            /* The page is a lossy chunk header, set bit for itself */  
            wordnum = bitnum = 0;  
        } else {  
            /* Page is exact, so set bit for individual tuple */  
            wordnum = WORDNUM(off - 1);  
            bitnum = BITNUM(off - 1);  
        }  
        page->words[wordnum] |= ((bitmapword)1 << (unsigned int)bitnum);  
        page->recheck |= recheck;  
  
        if (tbm->nentries > tbm->maxentries) {  
            tbm_lossify(tbm);  
        }  
    }  
}



```
## TODO
## PolarDB
PolarDB MySQL版支持在分区表上创建全局二级索引（Global Secondary Index，简称GSI）。使用全局二级索引可以实现透明分区表，可以像使用单表一样使用分区表，大大减少分区键对分区表的使用限制。
1. 对于name字段上的等值查询，在GSI上进行二分查找，找到对应的<name, id>，即<Mike, 16>。
2. 根据id=16和分区规则，自动路由到具体的分片p0；
3. 在分片p0中，在id主键上根据id=16进行二分索引，找到正确的位置；
![[Pasted image 20231027153503.png]]
# 6. 参考
- [Database VLDB and Partitioning Guide](https://docs.oracle.com/cd/E11882_01/server.112/e25523/intro.htm)
- [PolarDB 数据库内核月报 － 2022 / 08](http://mysql.taobao.org/monthly/2022/08/03/)
- [dev.mysql.com](https://dev.mysql.com/doc/refman/8.0/en/partitioning-overview.html)
# 7. TODO
- [ ] 拉会确认需求,方向
- [ ] 写设计文档,遇到走不通的细节再找资料