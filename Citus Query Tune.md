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
#### ⅰ. 影响因素
1. 使用SSDS。
2. 选择足够空间的硬盘。查询各个表占用内存大小，通过基础的统计信息，获取对硬件的需求
由于 Citus 在工作节点上并行运行所有片段查询，假设使用了合适的内存，用户可以将查询的性能横向扩展为集群中所有 CPU 内核的计算能力的累积。
3. 选择合适的shard数量
	```shell
	1.shards num = worker num;
	2.shards num = worker num * cpu cores * 因子(1/4);
	```
- `using SSDS rather than HDDS`
	SSDS和HDDS在顺序读取连续数据块时有相似的性能，但是随机读取，写数据时，SSDS数倍优于HDDS
> This is because HDDs are able to show decent performance when you have sequential reads over contiguous blocks of data, but have significantly lower random read / write performance.
### d. Distributed Query Performance Tuning 
一旦将数据分布在集群中，并且每个worker都针对最佳性能进行了优化，此时我们应该能够看到查询的高性能提升。 在此之后，最后一步是调整一些分布式性能调整参数。
#### ⅰ. 步骤
1. 首先检查分布式查询运行的时间。使用`\timing`参数，在CN上运行`query`，在worker上运行`fragment query`,更方便的找到系统瓶颈点。
2. 调整参数。
#### ⅱ. General Parameter
- `max_intermediate_result_size` 允许的worker间传递的中间结果大小，超过会报错。
	由于 [Subquery/CTE Push-Pull Execution](https://docs.citusdata.com/en/v11.0-beta/develop/reference_processing.html#push-pull-execution)，我们需要避免网络传输花费过多的影响性能，我们可以设置该参数，避免中间结果过大，增加网络传输消耗进而影响性能。
- `CTEs avoid push-pull excution`
	>- Tables should be colocated
	>- The CTE queries should not require any merge steps (e.g., LIMIT or GROUP BY on a non distributionkey)
	>- Tables and CTEs should be joined on distribution keys
#### ⅲ. Advanced Parameter
#####  A. Connection Managemen
在执行多分片查询时，Citus 必须平衡并行性的收益与数据库连接的开销。 查询执行部分解释了将查询转换为worker任务并获得与worker的数据库连接的步骤。
- `citus.max_adaptive_exectuor_pool_size`  对transactional workloads，设置为一个小的值类似于1或者2；对analytical workloads，默认值16是一个很好的选择。
- `citus.executor_slow_start_interval`  对transactional workloads设置为一个高的值（100ms);对analytical workloads，默认值（10ms）
- `citus.max_cached_conns_per_worker` 默认值 1 是合理的。 对于使用少量并发会话的集群来说，较大的值（例如 2）可能会有所帮助，但更进一步是不明智的（例如，16 会太高）。 如果设置得太高，会话将保持空闲连接并不必要地使用工作人员资源。
- `citus.max_shared_pool_size` 和worker的设置`max_connections`匹配。
##### B. Task Assignment Policy
Citus 查询计划器根据分片位置将任务分配给工作节点。 可以通过设置 citus.task_assignment_policy 配置参数来选择进行这些分配时使用的算法。 用户可以更改此配置参数以选择最适合其用例的策略。
- The greedy policy 旨在将任务平均分配给worker。 此策略是默认策略，在大多数情况下都能正常工作。
- The round-robin policy 以循环方式在不同副本之间交替将任务分配给工作人员。 当表的分片数量与工作人员的数量相比较低时，这可以实现更好的集群利用率。
- The first-replica policy 它根据分片的放置（副本）的插入顺序分配任务。 使用此策略，用户可以确定将在每台机器上访问哪些分片。 通过允许您将工作集保存在内存中并将其用于查询，这有助于提供更强大的内存驻留保证。
##### C. Intermediate Data Transfer Format
在 Postgres 13 及更低版本上，Citus 默认以文本格式在工作人员之间传输中间查询数据。 对于某些数据类型，如 hll 或 hstore 数组，序列化和反序列化数据的成本可能很高。 在这种情况下，使用二进制格式传输中间数据可以提高查询性能。 您可以启用 `citus.binary_worker_copy_format (boolean)` 配置选项以使用二进制格式。
##### D. Binary protocol
在某些情况下，大部分查询时间都花在将查询结果从工作人员发送到协调器上。 这主要发生在查询请求多行时（例如 select * from table），或者当结果列使用大类型（例如来自 postgresql-hll 和 tdigest 扩展的 hll 或 tdigest）时。
在这些情况下，将 `citus.enable_binary_protocol` 设置为 true 可能会有所帮助，这会将结果的编码更改为二进制，而不是使用文本编码。 二进制编码显着降低了具有紧凑二进制表示的类型的带宽，例如 hll、tdigest、时间戳和双精度。