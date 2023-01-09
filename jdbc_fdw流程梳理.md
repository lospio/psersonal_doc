## 堆栈
```bash
#0  jq_exec_id (conn=0x12deec8, query=0x13012c8 "SELECT d_record_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, d_datetime_met, v_evn, d_foretime, d_foretime_met, v_level, v_latend, v_latstart, v_lonend, v_lonstart, v_ele_code, v_data"...,
    resultSetID=resultSetID@entry=0x172c588) at jq.c:590
#1  0x00007f579f06593a in jdbcBeginForeignScan (node=0x172ace8, eflags=<optimized out>) at jdbc_fdw.c:1118
#2  0x000000000060b164 in ExecInitForeignScan (node=node@entry=0x1293228, estate=estate@entry=0x172aad8, eflags=eflags@entry=16) at nodeForeignscan.c:231
#3  0x00000000005eb944 in ExecInitNode (node=node@entry=0x1293228, estate=estate@entry=0x172aad8, eflags=eflags@entry=16) at execProcnode.c:277
#4  0x00000000005e830c in InitPlan (eflags=16, queryDesc=0x10) at execMain.c:1046
#5  standard_ExecutorStart (queryDesc=queryDesc@entry=0x172a6c8, eflags=16, eflags@entry=0) at execMain.c:265
#6  0x00007f57aa3b3baa in CitusExecutorStart (queryDesc=0x172a6c8, eflags=0) at executor/multi_executor.c:96
#7  0x000000000070dcf2 in PortalStart (portal=portal@entry=0x11df0b8, params=params@entry=0x0, eflags=eflags@entry=0, snapshot=snapshot@entry=0x0) at pquery.c:520
#8  0x000000000070a1f6 in exec_simple_query (query_string=0x1292078 "select * from f_tt03;") at postgres.c:1083
#9  0x000000000070b526 in PostgresMain (argc=<optimized out>, argv=argv@entry=0x122e438, dbname=0x122e2e8 "postgres", username=<optimized out>) at postgres.c:4142
#10 0x000000000047ad00 in BackendRun (port=0x1227ee0) at postmaster.c:4453
#11 BackendStartup (port=0x1227ee0) at postmaster.c:4117
#12 ServerLoop () at postmaster.c:1777
#13 0x00000000006a4fb9 in PostmasterMain (argc=argc@entry=1, argv=argv@entry=0x11bfa70) at postmaster.c:1385
#14 0x000000000047ba73 in main (argc=1, argv=0x11bfa70) at main.c:228
```
## log
```bash
DEBUG:  In jdbcGetForeignRelSize
DEBUG:  Added server = pg_server to hashtable
DEBUG:  In jq_connect_db_params
DEBUG:  In jdbc_jvm_init
DEBUG:  Successfully created a JVM with 3000 MB heapsize
DEBUG:  JVM OPTION CLASSPATH =[-Xrs]
DEBUG:  In jdbc_create_JDBC_connection
DEBUG:  Created a JDBC connection: jdbc:postgresql://172.16.3.124:5002/postgres
DEBUG:  In jdbcGetForeignPaths
DEBUG:  In jdbcGetForeignPlan
DEBUG:  Added server = pg_server to hashtable
DEBUG:  SQL: SELECT d_record_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, d_datetime_met, v_evn, d_foretime, d_foretime_met, v_level, v_latend, v_latstart, v_lonend, v_lonstart, v_ele_code, v_data, geom FROM tt03
DEBUG:  In jdbcBeginForeignScan
DEBUG:  Added server = pg_server to hashtable
DEBUG:  In jq_exec_id(0x12deec8): SELECT d_record_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, d_datetime_met, v_evn, d_foretime, d_foretime_met, v_level, v_latend, v_latstart, v_lonend, v_lonstart, v_ele_code, v_data, geom FROM tt03
^CCancel request sent
DEBUG:  Get resultSetID successfully, ID: 1
DEBUG:  In jdbcIterateForeignScan
DEBUG:  In jq_iterate
DEBUG:  In jq_transaction_status

```
## 流程
1. `jdbcGetForeignRelSize`开始，传入查询计划。
	- 获取foreign table，foreign server，设置查询属性（use_remote_estimate,cost），foreign user mapping。
	- 获取连接
		- 创建连接，注册连接各种状态的处理函数，在事务和子事务结束时清理环境
			- 检查配置参数
			- 初始化jvm
			- 建立连接
		- 继续使用连接。查找serverid 和 userid对应hash方法的值，存在则继续使用该链接
	- 解析查询条件，判断baserestrictinfo clauses在远端执行是否合理，安全，做出区分（查看jdbc_foreign_expr_walker，contain_mutable_functions函数）
	- 解析远端的target list
	- 估算外表扫描的代价
2. `jdbcGetForeignPaths` 设置查询路径
3. `jdbcGetForeignPlan` 对join clause区分远端查询和本地查询语句
	- `RELOPT_BASEREL`, `RELOPT_OTHER_MEMBER_REL`
	- `RELOPT_JOINREL`,`RELOPT_UPPER_REL`
	- 获取连接connection
	- 解析并构建查询query 包括 `select ... from where limit` 