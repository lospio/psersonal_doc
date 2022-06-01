# Citus Query Tune
## 1. What is Citus?

Citus is an open source extension to Postgres that distributes data and queries across multiple nodes in a cluster. 

## 2. How does Citus work?
Citus transforms Postgres into a distributed database with features like sharding, a distributed SQL engine, reference tables, and distributed tables.
### a. Distributed Query Executor
Citus’s distributed executor runs distributed query plans and handles failures. The executor is well suited for getting fast responses to queries involving filters, aggregations and co-located joins, as well as running single-tenant queries with full SQL coverage. It opens one connection per shard to the workers as needed and sends all fragment queries to them. It then fetches the results from each fragment query, merges them, and gives the final results back to the user.
### b. Push-pull design
By recursively planning the query Citus can run the subquery separately, push the results to all workers, run the main fragment query, and pull the results back to the coordinator. The “push-pull” design supports subqueries like the one above.

## 3. Tune
### a. Table Distribution and Shards
###### ⅰ. 首先创建分布式表，我们应该选取合适的分布式列，遵循以下标准：
- 必须包含primary key ,unique index
- 选取最常用的join key
- 选取最常用的filter column
###### ⅱ. 合适的分布列可以帮助我们优化数据库性能，通过如下方式：
- filter 剪枝 
	prune away unrelated shards，ensuring that the query hits only those shards which overlap with the WHERE clause ranges
- join key 下推
	The Citus executes the join only between those shards which have matching  overlapping distribution column ranges. All these shard joins can be executed in parallel on the workers and hence are more efficient.
### b. PostgreSQL tuning
#### ⅰ. 步骤
1. 创建Citus集群，导入数据
2. 在CN节点运行EXPLAIN命令
3. 分析plan
#### ⅱ. Read Performance
- `shared_buffers` 定义了数据库用于缓存数据的内存大小。
	- 当节点RAM不小于1GB的时候，建议设置为内存的1/4。
	- 否则，建议设置为15%。
	- 设置上限为内存的40%，超过这个上限PostgreSQL的表现没有变得更好。
- `work_mem` 定义了在写入临时磁盘文件之前查询操作（例如排序或哈希表）使用的基本最大内存量。
	- 有很多复杂排序时，增加该值。
	- 磁盘活动比较高，但是内存很大的时候，且处于空闲时，增加该值。
#### ⅲ. Write Performance
- `checkpoint_timeout` 自动检查WAL检查点之间的最长时间。增加这个值，会增加recovery的时长，但是会减少checkpoint的调用次数。
- `max_wal_size` 在自动checkpoint之间允许的WAL大小。增加这个值，会增加recovery的时长，但是会减少checkpoint的调用次数。
### c. Scaling Out Performance

### parameter
1. distribution column 分布列 合适的分布式列应该是最常使用的join key 以及 filter column。
	
2. using SSDS rather than HDDS
> This is because HDDs are able to show decent performance when you have sequential reads over contiguous blocks of data, but have significantly lower random read / write performance.

3. the number of shards
shards数应该大于等于cpu核数
>To ensure maximum parallelism, you should create enough shards on each node such that there is at least one shard per CPU core.Another consideration to keep in mind is that Citus will prune away unrelated shards if the query has filters on the distribution column. So, creating more shards than the number of cores might also be beneficial so that you can achieve greater parallelism even after shard pruning.

4. `max_intermediate_result_size`
允许的中间结果大小，超过会报错
5. CTEs avoid push-pull excution
	>- Tables should be colocated
	>- The CTE queries should not require any merge steps (e.g., LIMIT or GROUP BY on a non distributionkey)
	>- Tables and CTEs should be joined on distribution keys
6. `citus.max_adaptive_exectuor_pool_size` 
>Set citus.max_adaptive_executor_pool_size (integer) to a low value like 1 or 2 for transactional workloads with short queries (e.g. < 20ms of latency).For analytical workloads where parallelism is critical, leave this setting at its default value of 16.
7. `citus.executor_slow_start_interval`
>a high value like 100ms for transactional workloads comprised of short queries that are bound on network latency rather than parallelism. For analytical workloads, leave this setting at its default value of 10ms.
8. `citus.max_cached_conns_per_worker`
>The default value of 1 for citus.max_cached_conns_per_worker (integer) is reasonable. A larger value such as 2 might be helpful for clusters that use a small number of concurrent sessions, but it’s not wise to go much further (e.g. 16 would be too high). If set too high, sessions will hold idle connections and use worker resources unnecessarily.
9. `citus.max_shared_pool_size`
 和worker的设置`max_connections`匹配
10. `citus.task_assignment_policy`根据shard位置分配任务，可以设置分配算法
	- The greedy policy 均匀分配
	>The greedy policy aims to distribute tasks evenly across the workers. This policy is the default and works well in most of the cases.
    - The round-robin policy 循环分配
    >The round-robin policy assigns tasks to workers in a round-robin fashion alternating between different replicas. This enables much better cluster utilization when the shard count for a table is low compared to the number of workers.
	- The first-replica policy 
	>The third policy is the first-replica policy which assigns tasks on the basis of the insertion order of placements (replicas) for the shards. With this policy, users can be sure of which shards will be accessed on each machine. This helps in providing stronger memory residency guarantees by allowing you to keep your working set in memory and use it for querying.
11. `citus.enable_binary_protocol` 允许传送数据使用二进制文件 减少带宽使用
12. Insert and Update: Throughput Checklist
	- Check the network latency between your application and your database. High latencies will impact your write throughput.
	- Ingest data using concurrent threads. If the roundtrip latency during an INSERT is 4ms, you can process 250 INSERTs/second over one thread. If you run 100 concurrent threads, you will see your write throughput increase with the number of threads.
	- Check whether the nodes in your cluster have CPU or disk bottlenecks. Ingested data passes through the coordinator node, so check whether your coordinator is bottlenecked on CPU.
	- Avoid closing connections between INSERT statements. This avoids the overhead of connection setup.
	- Remember that column size will affect insert speed. Rows with big JSON blobs will take longer than those with small columns like integers.