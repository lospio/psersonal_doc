# 00：概述
#### 结论：
Citus在parse SQL时，会将原表名替换成对应的子表名，并将原来的表名添加为为alias。子表名组成为`表名_shardid`.
#### 表现：
```c
// 原查询 select * from tt01;
Breakpoint 2, SqlTaskList (job=0x2218fc0) at planner/multi_physical_planner.c:2698
2698    planner/multi_physical_planner.c: No such file or directory.
(gdb) p sqlQueryString->data
$1 = 0x224c000 "SELECT id, name FROM tt01_102614 tt01 WHERE true"
```
# 01：调研
#### 查询计划
```sql
postgres=# explain analyze verbose select * from tt01;
                                                           QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------
 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=16.254..16.811 rows=10000 loops=1)
   Output: remote_scan.id, remote_scan.name
   Task Count: 32
   Tasks Shown: One of 32
   ->  Task
         Node: host=tw-node47 port=9432 dbname=postgres
         ->  Seq Scan on public.tt01_102614 tt01  (cost=0.00..5.17 rows=317 width=6) (actual time=0.008..0.036 rows=317 loops=1)
               Output: id, name
             Planning time: 0.022 ms
             Execution time: 0.058 ms
 Planning time: 3.010 ms
 Execution time: 17.398 ms
(12 rows)

```
#### 拼接sql
- 调用栈
	```cpp
	//AnchorRangeTableId 选择锚定的表，规则是选择shard_count最大的表
	//RangeTableFragmentsList 返回目标表的所有shard
	//FragmentAlias 修改实际查询的表名，添加alias
	
	#0  get_from_clause_item (jtnode=0x224a970, query=0x224a2e0, context=0x7ffdd4852e40) at utils/ruleutils_10.c:6954
	#1  0x00007f79f23a7501 in get_from_clause (query=0x224a2e0, prefix=0x7f79f23ce57c " FROM ", context=0x7ffdd4852e40) at utils/ruleutils_10.c:6844
	#2  0x00007f79f239e17a in get_basic_select_query (query=0x224a2e0, context=0x7ffdd4852e40, resultDesc=0x0) at utils/ruleutils_10.c:2302
	#3  0x00007f79f239db02 in get_select_query_def (query=0x224a2e0, context=0x7ffdd4852e40, resultDesc=0x0) at utils/ruleutils_10.c:2103
	#4  0x00007f79f239d589 in get_query_def_extended (query=0x224a2e0, buf=0x224b3c0, parentnamespace=0x0, distrelid=0, shardid=0, resultDesc=0x0, prettyFlags=0, wrapColumn=0,startIndent=0) at utils/ruleutils_10.c:1923
	#5  0x00007f79f239d38b in get_query_def (query=0x224a2e0, buf=0x224b3c0, parentnamespace=0x0, resultDesc=0x0, prettyFlags=0, wrapColumn=0, startIndent=0) at utils/ruleutils_10.c:1856
	#6  0x00007f79f239a8a9 in pg_get_query_def (query=0x224a2e0, buffer=0x224b3c0) at utils/ruleutils_10.c:450
	#7  0x00007f79f2362178 in SqlTaskList (job=0x22193c0) at planner/multi_physical_planner.c:2696
	#8  0x00007f79f2360eae in BuildJobTreeTaskList (jobTree=0x22193c0, plannerRestrictionContext=0x21c56f0) at planner/multi_physical_planner.c:2021
	#9  0x00007f79f235dbed in CreatePhysicalDistributedPlan (multiTree=0x2219450, plannerRestrictionContext=0x21c56f0) at planner/multi_physical_planner.c:221
	#10 0x00007f79f234a45f in CreateDistributedPlan (planId=4, originalQuery=0x21c4780, query=0x21c4890, boundParams=0x0, hasUnresolvedParams=0 '\000',plannerRestrictionContext=0x21c56f0) at planner/distributed_planner.c:788
	#11 0x00007f79f234a062 in CreateDistributedPlannedStmt (planId=4, localPlan=0x21bfc08, originalQuery=0x21c4780, query=0x21c4890, boundParams=0x0, plannerRestrictionContext=0x21c56f0)at planner/distributed_planner.c:519
	#12 0x00007f79f2349ae9 in distributed_planner (parse=0x21c4890, cursorOptions=256, boundParams=0x0) at planner/distributed_planner.c:180
	#13 0x000000000077a6dd in planner (parse=0x21c4890, cursorOptions=256, boundParams=0x0) at /opt/transwarp/spatial/build/postgresql/src/backend/optimizer/plan/planner.c:208
	#14 0x000000000085a293 in pg_plan_query (querytree=0x21c4890, cursorOptions=256, boundParams=0x0) at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:819
	#15 0x000000000085a3b3 in pg_plan_queries (querytrees=0x21c50b8, cursorOptions=256, boundParams=0x0) at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:885
	#16 0x000000000085a6d4 in exec_simple_query (query_string=0x21c3a38 "select * from tt01;") at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:1050
	#17 0x000000000085ec4d in PostgresMain (argc=1, argv=0x2160380, dbname=0x2160248 "postgres", username=0x2160228 "postgres")at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:4154
	#18 0x00000000007c7e61 in BackendRun (port=0x2134e10) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:4466
	#19 0x00000000007c757a in BackendStartup (port=0x2134e10) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:4130
	#20 0x00000000007c3b96 in ServerLoop () at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:1777
	#21 0x00000000007c3175 in PostmasterMain (argc=17, argv=0x210bb00) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:1385
	#22 0x0000000000702ebf in main (argc=17, argv=0x210bb00) at /opt/transwarp/spatial/build/postgresql/src/backend/main/main.c:228
	```
- 关键路径
	- `SqlTaskList`
		- `AnchorRangeTableId`
		- `RangeTableFragmentsList`
			- `PruneShards` 
				- `DistributedTableCacheEntry`
					- `LookupDistTableCacheEntry`
						- `cacheEntry`
							```c
							(gdb)  p *cacheEntry
							$61 = {relationId = 24654, isValid = 1 '\001', isDistributedTable = 1 '\001', hasUninitializedShardInterval = 0 '\000', hasUniformHashDistribution = 1 '\001',
							  hasOverlappingShardInterval = 0 '\000',
							  partitionKeyString = 0x2246678 "{VAR :varno 1 :varattno 1 :vartype 23 :vartypmod -1 :varcollid 0 :varlevelsup 0 :varnoold 1 :varoattno 1 :location -1}",
							  partitionColumn = 0x2246708, partitionMethod = 104 'h', colocationId = 6, replicationModel = 99 'c', shardIntervalArrayLength = 32, sortedShardIntervalArray = 0x2246758,
							  shardColumnCompareFunction = 0x2247c08, shardIntervalCompareFunction = 0x2247c58, hashFunction = 0x2256228, referencedRelationsViaForeignKey = 0x0,
							  referencingRelationsViaForeignKey = 0x0, arrayOfPlacementArrays = 0x2246868, arrayOfPlacementArrayLengths = 0x2246978}
							(gdb)  p ** cacheEntry->sortedShardIntervalArray
							$62 = {type = {extensible = {type = T_ExtensibleNode, extnodename = 0x7f79f23ca33e "ShardInterval"}, citus_tag = T_ShardInterval}, relationId = 24654, storageType = 116 't',
							  valueTypeId = 23, valueTypeLen = 4, valueByVal = 1 '\001', minValueExists = 1 '\001', maxValueExists = 1 '\001', minValue = 2147483648, maxValue = 2281701375, shardId = 102614,
							  shardIndex = 0}
						```
		- `UpdateRangeTableAlias`
			- `FragmentAlias`
				- `AppendShardIdToName(&fragmentName, shardId);`
				- `ModifyRangeTblExtraData(rangeTableEntry, CITUS_RTE_SHARD,schemaName, fragmentName, NIL);`
		- `pg_get_query_def`
			- ...
			- `get_from_clause_item`
				```c
				case RTE_FUNCTION:
				/* if it's a shard, do differently */
				if (GetRangeTblKind(rte) == CITUS_RTE_SHARD)
				{
					char *fragmentSchemaName = NULL;
					char *fragmentTableName = NULL;
					ExtractRangeTblExtraData(rte, NULL, &fragmentSchemaName, &fragmentTableName, NULL);
					/* use schema and table name from the remote alias */
					appendStringInfoString(buf,
										   generate_fragment_name(fragmentSchemaName,
																  fragmentTableName));
					break;
	
				}
				```
#### 分配task
- 调用栈
	```c
	#0  GreedyAssignTask (workerNode=0x7f79fa62b5d0, taskList=0x7f79fa62a970, activeShardPlacementLists=0x7f79fa62ca08) at planner/multi_physical_planner.c:4994
	#1  0x00007f79f2365b64 in GreedyAssignTaskList (taskList=0x7f79fa62a970) at planner/multi_physical_planner.c:4929
	#2  0x00007f79f2365a57 in AssignAnchorShardTaskList (taskList=0x2262648) at planner/multi_physical_planner.c:4875
	#3  0x00007f79f23654b7 in AssignTaskList (sqlTaskList=0x2262648) at planner/multi_physical_planner.c:4630
	#4  0x00007f79f2360ece in BuildJobTreeTaskList (jobTree=0x224f048, plannerRestrictionContext=0x224ba20) at planner/multi_physical_planner.c:2030
	#5  0x00007f79f235dbed in CreatePhysicalDistributedPlan (multiTree=0x224f0d8, plannerRestrictionContext=0x224ba20) at planner/multi_physical_planner.c:221
	#6  0x00007f79f234a45f in CreateDistributedPlan (planId=1, originalQuery=0x21c4a48, query=0x21c4490, boundParams=0x0, hasUnresolvedParams=0 '\000',plannerRestrictionContext=0x224ba20) at planner/distributed_planner.c:788
	#7  0x00007f79f234a062 in CreateDistributedPlannedStmt (planId=1, localPlan=0x224c100, originalQuery=0x21c4a48, query=0x21c4490, boundParams=0x0, plannerRestrictionContext=0x224ba20)at planner/distributed_planner.c:519
	#8  0x00007f79f2349ae9 in distributed_planner (parse=0x21c4490, cursorOptions=256, boundParams=0x0) at planner/distributed_planner.c:180
	#9  0x000000000077a6dd in planner (parse=0x21c4490, cursorOptions=256, boundParams=0x0) at /opt/transwarp/spatial/build/postgresql/src/backend/optimizer/plan/planner.c:208
	#10 0x000000000085a293 in pg_plan_query (querytree=0x21c4490, cursorOptions=256, boundParams=0x0) at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:819
	#11 0x000000000085a3b3 in pg_plan_queries (querytrees=0x22182b0, cursorOptions=256, boundParams=0x0) at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:885
	#12 0x000000000085a6d4 in exec_simple_query (query_string=0x21c3638 "select * from tt01;") at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:1050
	#13 0x000000000085ec4d in PostgresMain (argc=1, argv=0x215b980, dbname=0x215b848 "postgres", username=0x215b828 "postgres")at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:4154
	#14 0x00000000007c7e61 in BackendRun (port=0x2134e10) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:4466
	#15 0x00000000007c757a in BackendStartup (port=0x2134e10) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:4130
	#16 0x00000000007c3b96 in ServerLoop () at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:1777
	#17 0x00000000007c3175 in PostmasterMain (argc=17, argv=0x210bb00) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:1385
	#18 0x0000000000702ebf in main (argc=17, argv=0x210bb00) at /opt/transwarp/spatial/build/postgresql/src/backend/main/main.c:228
	
	```
- 关键路径
	- `AssignTaskList`
		- `AssignAnchorShardTaskList`
			- `GreedyAssignTaskList`
				- `GreedyAssignTask`