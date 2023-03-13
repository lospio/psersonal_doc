---
ctime: 2022-08-04 11:50
tags: simlpe card
author: lche
alias: PostgreSQL Partition Table, PostgreSQL Partitionf
---
#vault-squirreldoc 
#参考
- [[PostgreSQL 5min 20.为什么分区表的分区过多会导致性能下降?]]
- [[Video Notes @ Practical Partitioning in Production with Postgres]]
- [手册](https://postgresql.org/docs/14/interactive/ddl-partitioning.html)
	- [[Doc@ PostgreSQL Documentation 14 5.11. Table Partitioning]]
- [PostgreSQL playground partition](https://www.crunchydata.com/developers/playground/partitioning)
	- [[PostgreSQL Playground#^8924a9]]
## 0. 概述
`partition本质是对表的水平切分, PostgreSQL中使用declarative partition.
![[PostgreSQL 分区表 2022-10-27_0.excalidraw]]
## 1. 基本概念
 #### Declarative Partitioning
 PostgreSQL使用声明式的partition定义.
 声明中包含两个类型:
 - #Partitioned-table , 是一种virtual table, 不实际存储数据.
 - #partitions, regular table, 存储数据, 有独立的索引, 约束, 默认值等.
 


![[PostgreSQL 分区表 2022-10-27.excalidraw]]

#### Partition Pruning
受enable_partition_pruning参数控制.
基于partition key,  剪枝待扫描的relation. 例如
```sql
SET enable_partition_pruning = off;
EXPLAIN SELECT count(*) FROM measurement WHERE logdate >= DATE '2008-01-01';
                                    QUERY PLAN
-----------------------------------------------------------------------------------
 Aggregate  (cost=188.76..188.77 rows=1 width=8)
   ->  Append  (cost=0.00..181.05 rows=3085 width=0)
         ->  Seq Scan on measurement_y2006m02  (cost=0.00..33.12 rows=617 width=0)
               Filter: (logdate >= '2008-01-01'::date)
         ->  Seq Scan on measurement_y2006m03  (cost=0.00..33.12 rows=617 width=0)
               Filter: (logdate >= '2008-01-01'::date)
...
         ->  Seq Scan on measurement_y2007m11  (cost=0.00..33.12 rows=617 width=0)
               Filter: (logdate >= '2008-01-01'::date)
         ->  Seq Scan on measurement_y2007m12  (cost=0.00..33.12 rows=617 width=0)
               Filter: (logdate >= '2008-01-01'::date)
         ->  Seq Scan on measurement_y2008m01  (cost=0.00..33.12 rows=617 width=0)
               Filter: (logdate >= '2008-01-01'::date)

SET enable_partition_pruning = on;
EXPLAIN SELECT count(*) FROM measurement WHERE logdate >= DATE '2008-01-01';
                                    QUERY PLAN
-----------------------------------------------------------------------------------
 Aggregate  (cost=37.75..37.76 rows=1 width=8)
   ->  Seq Scan on measurement_y2008m01  (cost=0.00..33.12 rows=617 width=0)
         Filter: (logdate >= '2008-01-01'::date)

```
## 2. 技术分析
#### 为什么用
- 管理.大表不便于管理.
	- archive
		- delete vs drop
	- vacuum
		- autovaccum的处理单位是表, 大表垃圾回收慢.
		- 索引垃圾回收占用内存.索引的垃圾回收, 先扫描表, 然后把垃圾的行号存储在内存中.
	- freeze
	- pg_dump
	- 不能并行逻辑复制
- 性能.
	- pruning
	- hidden pitfall.(多个表文件,mdnblock问题 )
- 突破PostgreSQL的单表最大限制.
#### 问题
- 过多的分区数, 生成计划的代价大(时间长, relcache大(内存))

## 3. 最佳实践
#### 适用的场景
1. very large table, 经验值(超过database server的物理内存)
2. OLAP over OLTP.

#### do
0. 基本思路
	- 分区表设计的前提, 了解数据,和实际场景绑定, 动态计算
1. 选择partition column
	- 与查询关联, 能够起到pruning效果.
	- 足够多的cardinality, 使数据可以分散.
	- 避免选用值常被修改的column.
2. 选择numbers of partitions.过多、不足的分区都不合适.
	1. 参考值
		-  内存值.
		- 30GB一个分区.
		-  ssd
			- 高频IUD. 5000万.
			- 少量更新, append only. 5亿.
	1. 不足的分区数(not enough), 会导致表、索引仍然比较大, low cache hit ratios.
	2. 过的的分区数.
		1. longer query planning times.
		2. higher memory  consumption, 尤其是场景: many sessions touch large numbers of partitions
			1. each partition 要求其metadata加载到session的local memory.
3. 注意
	1. attach partition 要避免对表的full scan [[Doc@ PostgreSQL Documentation 14 ALTER TABLE]]
		 > 	If the new partition is a regular table, a full table scan is performed to check that existing rows in the table do not violate the partition constraint. It is possible to avoid this scan by adding a valid `CHECK` constraint to the table that allows only rows satisfying the desired partition constraint before running this command. The `CHECK` constraint will be used to determine that the table need not be scanned to validate the partition constraint. This does not work, however, if any of the partition keys is an expression and the partition does not accept `NULL` values. If attaching a list partition that will not accept `NULL` values, also add `NOT NULL` constraint to the partition key column, unless it's an expression.
#### 生产环境, 普通表改造
[[Video Notes @ Practical Partitioning in Production with Postgres#^a7a0f0]]
#### 工具
- [[pg_rewrite]]
- [[pg_partman]]


#关联概念 
- [[PostgreSQL dump]]
- [[PostgreSQL autovacuum]]
- [[PostgreSQL freeze]]
- [[PostgreSQL 逻辑复制]]
- [[PostgreSQL tablespaces]]
- [[PostgreSQL delete]]
- [[PostgreSQL relcache]]
- [[pg_rewrite]]
