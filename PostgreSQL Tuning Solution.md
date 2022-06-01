# 1.Prepare
当我们遇到一个调优问题，我们需要做哪些准备工作来指导我们的调优？或者说我们需要获取什么情报来进行进一步的操作？
## 1.1 Explain
首先我们需要执行explain拿到查询计划。
- explain 是一个关键字，放在查询首部可以显式地告诉用户查询计划器计划如何执行给定的查询。根据查询的复杂性，它将显示连接策略、从表中提取数据的方法、执行查询所涉及的估计行数以及许多其他有用信息。 与 ANALYZE 一起使用时，EXPLAIN 还将显示在执行无法在内存中完成的查询、排序和合并所花费的时间等等(**注意 `explain analyze`命令会实际执行sql，因此在update，delete，insert into时需要额外注意该参数**)。 在识别查询性能瓶颈和机会时，这些信息非常宝贵，并帮助我们了解查询规划器在为我们做出决策时正在使用哪些信息。
- 下面是一个典型sql的执行计划
	```shell
	EXPLAIN ANALYZE SELECT *
	FROM tenk1 t1, tenk2 t2
	WHERE t1.unique1 < 10 AND t1.unique2 = t2.unique2;
	
															   QUERY PLAN
	-------------------------------------------------------------------​--------------------------------------------------------------
	 Nested Loop  (cost=4.65..118.62 rows=10 width=488) (actual time=0.128..0.377 rows=10 loops=1)
	   ->  Bitmap Heap Scan on tenk1 t1  (cost=4.36..39.47 rows=10 width=244) (actual time=0.057..0.121 rows=10 loops=1)
			 Recheck Cond: (unique1 < 10)
			 ->  Bitmap Index Scan on tenk1_unique1  (cost=0.00..4.36 rows=10 width=0) (actual time=0.024..0.024 rows=10 loops=1)
				   Index Cond: (unique1 < 10)
	   ->  Index Scan using tenk2_unique2 on tenk2 t2  (cost=0.29..7.91 rows=1 width=244) (actual time=0.021..0.022 rows=1 loops=10)
			 Index Cond: (unique2 = t1.unique2)
	 Planning time: 0.181 ms
	 Execution time: 0.501 ms
	```
- 关于plan
	- 如何读
	查询计划的结构是计划节点树。树的底层节点是扫描节点：它们从表中返回原始行。不同的表访问方法有不同类型的扫描节点：顺序扫描、索引扫描和位图索引扫描。还有非表行源，比如 FROM 中的 VALUES 子句和 set-returning 函数，它们都有自己的扫描节点类型。如果查询需要对原始行进行连接、聚合、排序或其他操作，则在扫描节点之上会有额外的节点来执行这些操作。同样，通常有不止一种可能的方式来执行这些操作，因此这里也可以出现不同的节点类型。 EXPLAIN 的输出对于计划树中的每个节点都有一行，显示基本节点类型以及计划程序为执行该计划节点所做的成本估计。可能会出现其他行，从节点的摘要行缩进，以显示节点的其他属性。第一行（最顶层节点的摘要行）包含计划的估计总执行成本；规划者试图最小化这个数字。
	- 算子
		- nested loop
		- hash
		- merge join
	- 外表驱动内内表
	- select 叶节点都是scan，一次取一个数据
	- 关键信息
		1. 时间 `actual time =start up time...total time`
		2. 结果行数
- 如何使用plan
	拿到了上述关键信息，我们可以明确每一个算子执行的时间，返回的结果数量，这些数据都可以进一步指导我们进行调优工作，下述几个简单例子
	- 索引 对一个命中率低的条件筛选，如果是顺序扫描上来的数据，我们可以尝试在这一列上添加索引
	- 复杂查询中，sort操作有很多，我们可以尝试增加work mem参数来提高性能
- [ ] 总结
利用查询计划去做性能调优
- 理解sql
- 分析sql如何执行，有策略和手段
	- 策略是找到瓶颈点
	- 手段是如何改善瓶颈点
	- 瓶颈点
		- 单点  经验性
		- 综合 
- 相对粗粒度 单位算子
## 1.2 Flame Graph
什么是火焰图？基本机制 做了什么
采样某一段时间
请看下图。
![[jdbc_fdw_sql1_test1.svg]]
- 如何读
该图显示了一个程序的调用栈以及占用cpu的时间。从下往上看是一个完整地调用栈，横坐标显示了cpu占用的时间，他们并不是连续的，累计时间如此
- 如何用
如果通过plan我们没法进一步定位问题，就要借助火焰图完成更深层次的调优了。利用调用栈查找占用时间异常的步骤，阅读源码，甚至于修改源码，来达到优化查询的目的

# 2.Tuning
有了如上的两种输入，我们可以分析数据库的瓶颈点，做出试验性猜想，再做实验验证猜想,结合情况分析我们可以修改如下的参数做静态的调整。
## General Parameter
- `max_connections` 允许连接的最大客户端数量。影响一些参数(特别是work_mem),通常是一个好的硬件设施可以支持几百个连接
- `shared_buffers` 设置了PostgreSQL用于缓存的数据的内存。建议值是系统内存的1/4。如果系统RAM较少，建议设置为15%。设置上限为内存的40%，超过这个上限PostgreSQL的表现没有变得更好，因为pg还依赖于系统使用的缓存
- `effective_cahe_size`  操作系统和数据库本身可用于磁盘缓存的内存量。这个值只会在查询计划中用到，用于估算代价。通常设置为总内存的1/2,3/4也是一个更具侵略性但是合理的数值。在类UNIX系统上，free+cached的数量就是一个合适值
- `autovacuum` 通常建议设置为开，更频繁的vacuum会使得只有少量的需要清理。在短时间内批量加载大量数据时可以设置为false
- `default_statistics_target`   在没有得到合适的查询计划时可以提高这个配置项，默认值就很合理。
- `work_mem`  用于提升复杂排序的性能。该参数设置需要考虑max_connections(`connections * work_mem`是实际所需内存)
- `wal_sync_method` 
- `wal_buffers`  默认值为`shared_buffers`1/16，很少需要调整
- `constraint_exclusion`  默认值partition，几乎在所有情况下都是正确的做法
- `checkpoint_timeout` 默认值5min适用于大多数情况下。
- `cursor_tuple_fraction` 
- `max_prepared_transactions` (`integer`) 在不使用prepared transactions时应该设置为0；否则应该至少和`max_connections`一样大. **注意：备机上该项设置应该不小于主机上的设置，否则会影响备机查询**
- `autovacuum_work_mem` (`integer`) 超过1GB不会进一步提升autovaccum
- `wal_buffers` (`integer`) 用于尚未写入磁盘的 WAL 数据的共享内存量。 默认设置 -1 选择大小等于 shared_buffers 的 1/32（约 3%），但不小于 64kB 也不大于一个 WAL 段的大小（通常为 16MB）。将该值提高可以提升繁忙服务器的写入性能。
## populating a database
- disable `autocommit`.只在最后commit一次
- 使用copy.
- 移除index，插入数据后重新在创建index. 对已经存在的数据建立索引比增量更新要快。**注意：对已经存在的索引删除要小心，可能会影响性能；尤其注意唯一索引被删除的时候**
- 移除foreign key constraint，插入数据后重建. **注意：当插入大量数据时，会导致服务器出错（trigger event queue overflow available memory,leading to intolerable swapping or even outright failure of the command.)**
- 增加`maintenance_work_mem` 设置 VACUUM, CREATE INDEX, and ALTER TABLE ADD FOREIGN KEY等操作可以使用的内存，增加该设置可以提升vacuuming和数据库转储的表现
- 增加`max_wal_size` 导入大量数据会导致checkpoint被更频繁的调用，增加该参数，减少checkpoint调用次数
- set `wal_level`to `minimal`, `archive_mode`to `off`, and `max_wal_senders`to 0；导入大量数据时，使用base backup比增量更新wal 数据更快。
# 3.参考
- https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server