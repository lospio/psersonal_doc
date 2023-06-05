# 00: 背景
#### 结论
<mark style="background: #FF5582A6;">相同shard_count，分布列类型的表，在所有节点分布一致。</mark>
#### 表现
 1. 1cn2wk时，使用默认shard_count，创建分布式表
	```sql
	create table tt01(id int ,name char);
	select create_distribtued_table('tt01','id');
	```
2. 添加一个wk，使用默认shard_count创建分布式表
	```sql
	create table tt02(id int ,name char);
	select create_distributed_table('tt02','id');
	```
3. `tt02`和`tt01`都只分布在原有的wk上，新添加的wk上没有相关子表。
# 01: 调研
#### 调用栈
```c
Breakpoint 3, CreateColocatedShards (targetRelationId=24698, sourceRelationId=24694, useExclusiveConnections=0 '\000') at master/master_create_shards.c:277
277     master/master_create_shards.c: No such file or directory.
(gdb) bt
#0  CreateColocatedShards (targetRelationId=24698, sourceRelationId=24694, useExclusiveConnections=0 '\000') at master/master_create_shards.c:277
#1  0x00007f79f2314e1c in CreateHashDistributedTableShards (relationId=24698, colocatedTableId=24694, localTableEmpty=1 '\001') at commands/create_distributed_table.c:501
#2  0x00007f79f2314bac in CreateDistributedTable (relationId=24698, distributionColumn=0x2259ba8, distributionMethod=104 'h', colocateWithTableName=0x225a5f8 "default", viaDeprecatedAPI=0 '\000') at commands/create_distributed_table.c:381
#3  0x00007f79f231492c in create_distributed_table (fcinfo=0x2245538) at commands/create_distributed_table.c:245
#4  0x0000000000699bf7 in ExecInterpExpr (state=0x2245460, econtext=0x2245158, isnull=0x7ffdd485309f "") at /opt/transwarp/spatial/build/postgresql/src/backend/executor/execExprInterp.c:677
#5  0x00000000006d15ed in ExecEvalExprSwitchContext (state=0x2245460, econtext=0x2245158, isNull=0x7ffdd485309f "") at /opt/transwarp/spatial/build/postgresql/src/include/executor/executor.h:314
#6  0x00000000006d1665 in ExecProject (projInfo=0x2245458) at /opt/transwarp/spatial/build/postgresql/src/include/executor/executor.h:348
#7  0x00000000006d1814 in ExecResult (pstate=0x2245048) at /opt/transwarp/spatial/build/postgresql/src/backend/executor/nodeResult.c:136
#8  0x00000000006a9f04 in ExecProcNodeFirst (node=0x2245048) at /opt/transwarp/spatial/build/postgresql/src/backend/executor/execProcnode.c:431
#9  0x00000000006a28eb in ExecProcNode (node=0x2245048) at /opt/transwarp/spatial/build/postgresql/src/include/executor/executor.h:250
#10 0x00000000006a4de6 in ExecutePlan (estate=0x2244e38, planstate=0x2245048, use_parallel_mode=0 '\000', operation=CMD_SELECT, sendTuples=1 '\001', numberTuples=0, direction=ForwardScanDirection, dest=0x22738b8, execute_once=1 '\001')
    at /opt/transwarp/spatial/build/postgresql/src/backend/executor/execMain.c:1723
#11 0x00000000006a2db1 in standard_ExecutorRun (queryDesc=0x22676f8, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at /opt/transwarp/spatial/build/postgresql/src/backend/executor/execMain.c:364
#12 0x00007f79f2331a07 in CitusExecutorRun (queryDesc=0x22676f8, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at executor/multi_executor.c:149
#13 0x00000000006a2c39 in ExecutorRun (queryDesc=0x22676f8, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at /opt/transwarp/spatial/build/postgresql/src/backend/executor/execMain.c:305
#14 0x0000000000860c85 in PortalRunSelect (portal=0x2270d08, forward=1 '\001', count=0, dest=0x22738b8) at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/pquery.c:932
#15 0x00000000008608eb in PortalRun (portal=0x2270d08, count=9223372036854775807, isTopLevel=1 '\001', run_once=1 '\001', dest=0x22738b8, altdest=0x22738b8, completionTag=0x7ffdd48534f0 "") at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/pquery.c:773
#16 0x000000000085a866 in exec_simple_query (query_string=0x21c3a38 "select create_distributed_table('tt12','id');") at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:1122
#17 0x000000000085ec4d in PostgresMain (argc=1, argv=0x2160380, dbname=0x2160248 "postgres", username=0x2160228 "postgres") at /opt/transwarp/spatial/build/postgresql/src/backend/tcop/postgres.c:4154
#18 0x00000000007c7e61 in BackendRun (port=0x2134e10) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:4466
#19 0x00000000007c757a in BackendStartup (port=0x2134e10) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:4130
#20 0x00000000007c3b96 in ServerLoop () at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:1777
#21 0x00000000007c3175 in PostmasterMain (argc=17, argv=0x210bb00) at /opt/transwarp/spatial/build/postgresql/src/backend/postmaster/postmaster.c:1385
#22 0x0000000000702ebf in main (argc=17, argv=0x210bb00) at /opt/transwarp/spatial/build/postgresql/src/backend/main/main.c:228
```
#### 关键执行路径
- `CreateDistributedTable`
	- `ColocationIdForNewTable` 返回colocation id
		- `ColocationId` <mark style="background: #FF5582A6;">shard count</mark>, <mark style="background: #FF5582A6;">replication factor</mark> and <mark style="background: #FF5582A6;">distribution column type</mark>. 查找`pg_dist_colocation`
	- `ColocatedTableId`返回该colocation 组内的一个表oid
	- `CreateHashDistributedTableShards`
		- `CreateColocatedShards`
			- `InsertShardPlacementRow` 
#### 相关系统表
```sql
                                  Table "pg_catalog.pg_dist_colocation"
         Column         |  Type   | Collation | Nullable | Default | Storage | Stats target | Description
------------------------+---------+-----------+----------+---------+---------+--------------+-------------
 colocationid           | integer |           | not null |         | plain   |              |
 shardcount             | integer |           | not null |         | plain   |              |
 replicationfactor      | integer |           | not null |         | plain   |              |
 distributioncolumntype | oid     |           | not null |         | plain   |              |
Indexes:
    "pg_dist_colocation_pkey" PRIMARY KEY, btree (colocationid)
    "pg_dist_colocation_configuration_index" btree (shardcount, replicationfactor, distributioncolumntype)
Replica Identity: ???
postgres=# select * from pg_dist_colocation;
 colocationid | shardcount | replicationfactor | distributioncolumntype
--------------+------------+-------------------+------------------------
            1 |        128 |                 1 |                     23
            2 |          3 |                 1 |                     23
            6 |         32 |                 1 |                     23
            7 |          9 |                 1 |                     23
            8 |          6 |                 1 |                     23
            9 |          4 |                 1 |                     23
           10 |         32 |                 1 |                   1042
(7 rows)


postgres=# \d+ pg_dist_placement
                                                     Table "pg_catalog.pg_dist_placement"
   Column    |  Type   | Collation | Nullable |                        Default                         | Storage | Stats target | Description
-------------+---------+-----------+----------+--------------------------------------------------------+---------+--------------+-------------
 placementid | bigint  |           | not null | nextval('pg_dist_placement_placementid_seq'::regclass) | plain   |              |
 shardid     | bigint  |           | not null |                                                        | plain   |              |
 shardstate  | integer |           | not null |                                                        | plain   |              |
 shardlength | bigint  |           | not null |                                                        | plain   |              |
 groupid     | integer |           | not null |                                                        | plain   |              |
Indexes:
    "pg_dist_placement_placementid_index" UNIQUE, btree (placementid)
    "pg_dist_placement_groupid_index" btree (groupid)
    "pg_dist_placement_shardid_index" btree (shardid)
Triggers:
    dist_placement_cache_invalidate AFTER INSERT OR DELETE OR UPDATE ON pg_dist_placement FOR EACH ROW EXECUTE PROCEDURE master_dist_placement_cache_invalidate()
Replica Identity: ???
-- 关联shard和node
```