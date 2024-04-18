# 配置
```text
--binlog_order_commits=on --sync-binlog=1 --innodb_flush_log_at_trx_commit=1
```

```bash
--threads=10 --report-interval=5 --db-driver=mysql --db-ps-mode=auto  /usr/share/sysbench/oltp_write_only.lua --tables=100 --table_size=100000 --time=40 run
```
# mysql-stable-8.0.30
SQL statistics:
    queries performed:
        read:                            0
        write:                           2767656
        other:                           1383828
        total:                           4151484
    transactions:                        691914 (5765.56 per sec.)
    queries:                             4151484 (34593.37 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          120.0067s
    total number of events:              691914

Latency (ms):
         min:                                    0.60
         avg:                                    1.73
         max:                                  269.90
         95th percentile:                        2.48
         sum:                              1199327.21

Threads fairness:
    events (avg/stddev):           69191.4000/366.07
    execution time (avg/stddev):   119.9327/0.00

SQL statistics:
    queries performed:
        read:                            0
        write:                           1239028
        other:                           619514
        total:                           1858542
    transactions:                        309757 (5161.82 per sec.)
    queries:                             1858542 (30970.91 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          60.0075s
    total number of events:              309757

Latency (ms):
         min:                                    0.59
         avg:                                    1.94
         max:                                  292.29
         95th percentile:                        2.91
         sum:                               599698.43

Threads fairness:
    events (avg/stddev):           30975.7000/118.75
    execution time (avg/stddev):   59.9698/0.00

SQL statistics:
    queries performed:
        read:                            0
        write:                           1614804
        other:                           807402
        total:                           2422206
    transactions:                        403701 (10090.72 per sec.)
    queries:                             2422206 (60544.31 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          40.0057s
    total number of events:              403701

Latency (ms):
         min:                                    0.50
         avg:                                    0.99
         max:                                  276.77
         95th percentile:                        0.97
         sum:                               399670.58

Threads fairness:
    events (avg/stddev):           40370.1000/389.36
    execution time (avg/stddev):   39.9671/0.00



50000行 10并发 100tables write_only
```text
SQL statistics:
    queries performed:
        read:                            0
        write:                           3679044
        other:                           1839522
        total:                           5518566
    transactions:                        919761 (7663.91 per sec.)
    queries:                             5518566 (45983.44 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          120.0105s
    total number of events:              919761

Latency (ms):
         min:                                    0.53
         avg:                                    1.30
         max:                                  269.72
         95th percentile:                        1.44
         sum:                              1199192.26

Threads fairness:
    events (avg/stddev):           91976.1000/321.96
    execution time (avg/stddev):   119.9192/0.00
```
# parallel_binlog_flush 40s
60s后hang住
SQL statistics: 
    queries performed:
        read:                            0
        write:                           1571011
        other:                           1255305
        total:                           2826316
    transactions:                        471052 (11774.24 per sec.)
    queries:                             2826316 (70645.55 per sec.)
    ignored errors:                      1      (0.02 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          40.0055s
    total number of events:              471052

Latency (ms):
         min:                                    0.44
         avg:                                    0.85
         max:                                  147.29 
         95th percentile:                        0.92
         sum:                               399615.94

Threads fairness:
    events (avg/stddev):           47105.2000/257.03
    execution time (avg/stddev):   39.9616/0.00# 

SQL statistics:
    queries performed:
        read:                            0
        write:                           1749924
        other:                           874962
        total:                           2624886
    transactions:                        437481 (10934.96 per sec.)
    queries:                             2624886 (65609.78 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          40.0060s
    total number of events:              437481

Latency (ms):
         min:                                    0.50
         avg:                                    0.91
         max:                                  217.81
         95th percentile:                        0.92
         sum:                               399637.57

Threads fairness:
    events (avg/stddev):           43748.1000/486.66
    execution time (avg/stddev):   39.9638/0.00



- 10 thread 10000 write
```text
SQL statistics:
    queries performed:
        read:                            0
        write:                           1896020
        other:                           948010
        total:                           2844030
    transactions:                        474005 (11847.78 per sec.)
    queries:                             2844030 (71086.66 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          40.0065s
    total number of events:              474005

Latency (ms):
         min:                                    0.52
         avg:                                    0.84
         max:                                  191.92
         95th percentile:                        0.89
         sum:                               399603.17

Threads fairness:
    events (avg/stddev):           47400.5000/388.22
    execution time (avg/stddev):   39.9603/0.00
```
# 结果
| 分支                    | tps              | qps              | 95th percentile latency | 测试脚本                |
| --------------------- | ---------------- | ---------------- | ----------------------- | ------------------- |
| mysql-8.0.30-stable   | 5765.56 per sec  | 34593.37 per sec | 2.48                    | oltp_write_only.lua |
| parallel_binlog_flush | 11774.24 per sec | 70645.55 per sec | 0.92                    | oltp_write_only.lua |
|                       |                  |                  |                         |                     |
# SQL
```sql
runtime_output_directory/mysqld --user=root --binlog_order_commits=on --sync-binlog=1 --innodb_flush_log_at_trx_commit=1 --max_prepared_stmt_count=999999

```


```sql
set global before_commit_time_cnt=0;
set global all_stage_time_cnt=0;
set global flush_stage_time_cnt=0;
set global sync_stage_time_cnt=0;
set global commit_stage_time_cnt=0;
set global change_stage_in_flush_time_cnt=0;
set global flush_redo_to_file_time_cnt=0;
set global flush_thread_cache_to_binlog_time_cnt=0;
set global flush_binlog_cache_to_file_time_cnt=0;
set global sync_binlog_file_time_cnt=0;
set global flush_stage_follower_wait_time_cnt=0;
set global flush_stage_follower_cnt=0;
set global sync_stage_follower_wait_time_cnt=0;
set global sync_stage_follower_cnt=0;
set global all_stage_cnt=0;
set global flush_stage_cnt=0;
set global sync_stage_cnt=0;
set global commit_stage_cnt=0;
set global crud_time_cnt=0;
set global la_exec=0;
set global la_commit=0;
set global la_cmd=0;
set global la_flush_leader=0;
set global la_flush_fow=0;


set @time=100; # 单位：秒  
set @thread=100; # 并发数
select @@crud_time_cnt/10000/@time/@thread 'sql执行延时比例';
select @@crud_time_cnt/1000/@@all_stage_cnt 'sql执行延时(ms)';
select @@before_commit_time_cnt/10000/@time/@thread 'before commit延时比例';
select @@before_commit_time_cnt/1000/@@all_stage_cnt 'before commit延时(ms)';
select @@all_stage_time_cnt/10000/@time/@thread '组提交延时比例';
select @@all_stage_time_cnt/1000/@@all_stage_cnt '组提交延时(ms)';
select (100-(@@crud_time_cnt+@@before_commit_time_cnt+@@all_stage_time_cnt))/10000/@time/@thread '网络延时比例';
select (1000*@thread*@time-(@@crud_time_cnt+@@before_commit_time_cnt+@@all_stage_time_cnt)/1000)/@@all_stage_cnt '网络延时(ms)';
select @@change_stage_in_flush_time_cnt/@@flush_stage_cnt/1000 'change stage in flush stage';
select @@flush_redo_to_file_time_cnt/@@flush_stage_cnt/1000 'sync redo to file';
select @@flush_thread_cache_to_binlog_time_cnt/@@flush_stage_cnt/1000 'merge binlog cache';
select @@flush_binlog_cache_to_file_time_cnt/@@flush_stage_cnt/1000 'flush binlog to io cache';
select (@@sync_stage_time_cnt-@@sync_binlog_file_time_cnt)/@@sync_stage_cnt/1000 'change stage in sync stage';
select @@sync_binlog_file_time_cnt/@@sync_stage_cnt/1000 'sync binlog to file';
select @@commit_stage_time_cnt/@@commit_stage_cnt/1000 'commit stage';
select @@flush_stage_follower_wait_time_cnt/@@flush_stage_follower_cnt/1000 '一阶段follower延时';
select @@sync_stage_follower_wait_time_cnt/@@sync_stage_follower_cnt/1000 '二阶段follower延时';

set @time=100; # 单位：秒  
set @thread=100; # 并发数  
select @@crud_time_cnt/10000/@time/@thread 'sql执行延时比例';  
select @@crud_time_cnt/1000/@@all_stage_cnt 'sql执行延时(ms)';  
select @@before_commit_time_cnt/10000/@time/@thread 'before commit延时比例';  
select @@before_commit_time_cnt/1000/@@all_stage_cnt 'before commit延时(ms)';  
select @@all_stage_time_cnt/10000/@time/@thread '组提交延时比例';  
select @@all_stage_time_cnt/1000/@@all_stage_cnt '组提交延时(ms)';  
select 100-(@@crud_time_cnt+@@before_commit_time_cnt+@@all_stage_time_cnt)/10000/@time/@thread '网络延时比例';  
select (1000*@thread*@time-(@@crud_time_cnt+@@before_commit_time_cnt+@@all_stage_time_cnt)/1000)/@@all_stage_cnt '网络延时(ms)';  
select @@change_stage_in_flush_time_cnt/@@flush_stage_cnt/1000 'change stage in flush stage';  
select @@flush_redo_to_file_time_cnt/@@flush_stage_cnt/1000 'sync redo to file';  
select @@flush_thread_cache_to_binlog_time_cnt/@@flush_stage_cnt/1000 'merge binlog cache';  
select @@flush_binlog_cache_to_file_time_cnt/@@flush_stage_cnt/1000 'flush binlog to io cache';  
select (@@sync_stage_time_cnt-@@sync_binlog_file_time_cnt)/@@sync_stage_cnt/1000 'change stage in sync stage';  
select @@sync_binlog_file_time_cnt/@@sync_stage_cnt/1000 'sync binlog to file';  
select @@commit_stage_time_cnt/@@commit_stage_cnt/1000 'commit stage';  
select @@flush_stage_follower_wait_time_cnt/@@flush_stage_follower_cnt/1000 '一阶段follower延时';  
select @@sync_stage_follower_wait_time_cnt/@@sync_stage_follower_cnt/1000 '二阶段follower延时';
select (@@flush_thread_cache_to_binlog_time_cnt/@@flush_stage_cnt/1000)/(@@change_stage_in_flush_time_cnt/@@flush_stage_cnt/1000 + @@flush_redo_to_file_time_cnt/@@flush_stage_cnt/1000 + @@flush_thread_cache_to_binlog_time_cnt/@@flush_stage_cnt/1000 + @@flush_binlog_cache_to_file_time_cnt/@@flush_stage_cnt/1000 + ((@@sync_stage_time_cnt-@@sync_binlog_file_time_cnt)/@@sync_stage_cnt/1000) + @@sync_binlog_file_time_cnt/@@sync_stage_cnt/1000 + @@commit_stage_time_cnt/@@commit_stage_cnt/1000)  'merge binlog cache 比例';

select @@la_commit/@@la_cmd 'commit 比例';

select @@crud_time_cnt/1000000 'sql执行延时(s)';
select @@before_commit_time_cnt/10000000 'before commit延时(s)';
select @@all_stage_time_cnt/1000000 '组提交延时(ms)';
select @@change_stage_in_flush_time_cnt/1000000 'change stage in flush stage';
select @@flush_redo_to_file_time_cnt/1000000 'sync redo to file';
select @@flush_thread_cache_to_binlog_time_cnt/1000000 'merge binlog cache';
select @@flush_binlog_cache_to_file_time_cnt/1000000 'flush binlog to io cache';
select (@@sync_stage_time_cnt-@@sync_binlog_file_time_cnt)/1000 'change stage in sync stage';
select @@sync_binlog_file_time_cnt/1000000 'sync binlog to file';
select @@commit_stage_time_cnt/1000000 'commit stage';
select @@flush_stage_follower_wait_time_cnt/1000000 '一阶段follower延时';
select @@sync_stage_follower_wait_time_cn/1000000 '二阶段follower延时';
select @@la_exec/1000/1000;
select @@la_commit/1000/1000;
select @@la_cmd/1000/1000;
select @@la_flush_leader/1000/1000;
select @@la_flush_fow/1000/1000;



select @@all_stage_cnt;
select @@flush_stage_cnt;
select @@sync_stage_cnt
select @@commit_stage_cnt;
select @@crud_cnt;









```

# 配置主备
```sql
CHANGE REPLICATION SOURCE TO SOURCE_HOST='127.0.0.1',  SOURCE_PORT=3306,  SOURCE_USER='repl', SOURCE_PASSWORD='123', - SOURCE_AUTO_POSITION=1;


CREATE TABLE `percona`.`dsns` (  `id` int(11) NOT NULL AUTO_INCREMENT, `parent_id` int(11) DEFAULT NULL, `dsn` varchar(255) NOT NULL, PRIMARY KEY (`id`) );
```