# Citus概述
1. CItus是PostgreSQL的一个开源拓展，可以将PostgreSQL转换为分布式数据库
2. Citus是作为一个shared library，在每次PG Server启动前加载
3. Citus使用`distributed table` `reference table` 和 `distributed SQL query engine`==水平拓展==PostgreSQL
	- Distributed table. Distributed tables are hash-partitioned along a distribution column into multiple logical shards with each shard containing a contiguous range of hash values.
	- Reference tables. Reference tables are replicated to all nodes in a Citus cluster, including the coordinator.
	- Co-location. Citus ensures that the same range of (hash) values is always on the same worker node among distributed tables that are co-located.
# 简单查询过程
```sql
create table tt01(id int, name char);
set citus.shard_count to 4;
select create_dsitribtued_table('tt01','id');
insert into tt01 select generate_series(1,1000),substr(md5(random()::text),1,1);
select * from tt01;

postgres=# explain analyze verbose select * from tt01;
                                                           QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------
 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=8.858..8.985 rows=1000 loops=1)
   Output: remote_scan.id, remote_scan.name
   Task Count: 4
   Tasks Shown: All
   ->  Task
         Node: host=localhost port=6432 dbname=postgres
         ->  Seq Scan on public.tt01_102148 tt01  (cost=0.00..6.47 rows=247 width=6) (actual time=0.022..0.068 rows=247 loops=1)
               Output: id, name
             Planning time: 0.060 ms
             Execution time: 0.136 ms
   ->  Task
         Node: host=localhost port=7432 dbname=postgres
         ->  Seq Scan on public.tt01_102149 tt01  (cost=0.00..6.63 rows=263 width=6) (actual time=0.019..0.059 rows=263 loops=1)
               Output: id, name
             Planning time: 0.077 ms
             Execution time: 0.107 ms
   ->  Task
         Node: host=localhost port=6432 dbname=postgres
         ->  Seq Scan on public.tt01_102150 tt01  (cost=0.00..6.38 rows=238 width=6) (actual time=0.014..0.045 rows=238 loops=1)
               Output: id, name
             Planning time: 0.043 ms
             Execution time: 0.111 ms
   ->  Task
         Node: host=localhost port=7432 dbname=postgres
         ->  Seq Scan on public.tt01_102151 tt01  (cost=0.00..6.52 rows=252 width=6) (actual time=0.014..0.051 rows=252 loops=1)
               Output: id, name
             Planning time: 0.044 ms
             Execution time: 0.092 ms
 Planning time: 2.492 ms
 Execution time: 9.169 ms
(30 rows)
```
![[citus adaptive executor专题 2023-08-16 .excalidraw]]
# 分布式计划器

Citus的分布式计划是在PG计划器的基础上构建的，首先调用PG的standard planner，生成一个基础计划，然后处理分布式表，例如为分布式表的每个shard添加一个worker job，worker job上层添加CustomerScan node用于汇集各个子任务查询的数据，替换表名等等。
> The distributed query planner produces a PostgreSQL query plan that contains a CustomScan node, which contains the distributed query plan. A distributed query plan consists of a set of tasks (queries on shards) to run on the workers, and optionally a set of subplans whose results need to be broadcast or re-partitioned, such that their results can be read by subsequent tasks.
#### 种类
- A. Fast path planner handles simple CRUD queries on a single table with a single distribution column value.
	![[Pasted image 20230816173120.png]]
- B. Router planner handles arbitrarily complex queries that can be scoped to one set of co-located shards.
	![[Pasted image 20230816173049.png]]
- C. Logical planner handles queries across shards by constructing a multi-relational algebra tree .
	- Logical pushdown planner detects whether the join tree can be fully pushed down.
		![[Pasted image 20230816173212.png]]
	- Logical join order planner determines the optimal execution order for join trees involving non-co-located joins.
		![[Pasted image 20230816173233.png]]

#### 流程
![[Drawing 2023-08-16 16.29.48.excalidraw]]
# 代码
- `PrunableExpressions`
	- 对 or进行拆分 ``A AND (B OR C) AND D) into (A AND B AND D), (A AND C AND D)`
	- 对一个表达式，一个var和一个const进行操作，如果var是分布列，
# 参考
- [How the Citus distributed query executor adapts to your Postgres workload](https://www.citusdata.com/blog/2020/04/27/how-citus-distributed-query-executor-adapts-to-postgres-workload/)
- 