#  Citus Query Tune
## What is Citus?

Citus is an open source extension to Postgres that distributes data and queries across multiple nodes in a cluster. 

## How does Citus work?
Citus transforms Postgres into a distributed database with features like sharding, a distributed SQL engine, reference tables, and distributed tables.
### Distributed Query Executor
Citus’s distributed executor runs distributed query plans and handles failures. The executor is well suited for getting fast responses to queries involving filters, aggregations and co-located joins, as well as running single-tenant queries with full SQL coverage. It opens one connection per shard to the workers as needed and sends all fragment queries to them. It then fetches the results from each fragment query, merges them, and gives the final results back to the user.
### push-pull design
By recursively planning the query Citus can run the subquery separately, push the results to all workers, run the main fragment query, and pull the results back to the coordinator. The “push-pull” design supports subqueries like the one above.

## Tune
1. parameter
	- distribution column 分布列
	合适的分布式列应该是最常使用的join key 以及