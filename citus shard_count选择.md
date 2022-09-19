## How do I choose the shard count when I hash-partition my data?[](https://docs.citusdata.com/en/v11.0/faq/faq.html#how-do-i-choose-the-shard-count-when-i-hash-partition-my-data "Permalink to How do I choose the shard count when I hash-partition my data?")

One of the choices when first distributing a table is its shard count. This setting can be set differently for each co-location group, and the optimal value depends on use-case. It is possible, but difficult, to change the count after cluster creation, so use these guidelines to choose the right size.

In the [Multi-Tenant Database](https://docs.citusdata.com/en/v11.0/faq/faq.html../get_started/what_is_citus.html#mt-blurb) use-case we recommend choosing between 32 - 128 shards. For smaller workloads say <100GB, you could start with 32 shards and for larger workloads you could choose 64 or 128. This means that you have the leeway to scale from 32 to 128 worker machines.

In the [Real-Time Analytics](https://docs.citusdata.com/en/v11.0/faq/faq.html../get_started/what_is_citus.html#rt-blurb) use-case, shard count should be related to the total number of cores on the workers. To ensure maximum parallelism, you should create enough shards on each node such that there is at least one shard per CPU core. We typically recommend creating a high number of initial shards, e.g. 2x or 4x the number of current CPU cores. This allows for future scaling if you add more workers and CPU cores.

To choose a shard count for a table you wish to distribute, update the `citus.shard_count` variable. This affects subsequent calls to [create\_distributed\_table](https://docs.citusdata.com/en/v11.0/faq/faq.html../develop/api_udf.html#create-distributed-table). For example

```sql
SET citus.shard_count = 64;
-- any tables distributed at this point will have
-- sixty-four shards
```

