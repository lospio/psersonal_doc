## WAL
#### 基本描述
we can describe WAL as a stream of log entries of variable length. 可变长度的日志项流
#### 记录内容
- page modifications performed in the buffer cache—since writes are deferred
- transaction commits and rollbacks—since the status change happens in CLOG buffers and does not make it to disk right away
- file operations (like creation and deletion of files and directories when tables get added or removed)—since such operations must be in sync with data changes
#### 不记录的内容
- operations on UNLOGGED tables
- operations on temporary tables—since their lifetime is anyway limited by the session that spawns them
- Prior to PostgreSQL 10, hash indexes were not logged either. Their only purpose was to match hash functions to different data types.
#### wal_buffers 
- 描述： the size of the cache used by WAL. 
- 默认值：1/32 of the total buffer cache size
- 影响：影响磁盘同步的频率。过小会增加频率
#### LSN （log sequence number）
- 原文：It represents a 64-bit offset in bytes from the start of the WAL to an entry. An LSN is displayed as two 32-bit numbers in the hexadecimal notation separated by a slash
- 描述：是WAL Entity的序号，标注了该entity在整个WAL stream中的偏移量
- 与page关联：在page的header中存储了最新的lsn
- 与database cluster的关联
	- There is only one WAL for the whole database cluster, and new entries constantly get appended to it
	- 一对一的关系，WAL stream只存在一个。可以解释lsn的作用
- 与CLOG的关联
	- the LSN of the latest WAL entry has to be tracked for CLOG pages too. But this information is stored in RAM, not in the page itself.
	- CLOG page需要追踪最新的wal entity lsn
	- 先写WAL日志，在写CLOG
- 使用：
	- 两个lsn的差值：If you know two WAL positions, you can calculate the size of WAL entries between them (in bytes) by simply subtracting one position from the other.
#### pg_waldump 
- 查看wal文件
- 使用
#### checkpoint
- start 
	- The checkpointer process flushes to disk everything that can be written instantaneously: CLOG transaction status, subtransactions’ metadata, and a few other structures.
	- 将所有可以瞬间写入的内容刷新到磁盘上
- excution
	- flush dirty page to disk
		1. a special tag is set in the headers of all the buffers . very fast since no I/O
		2. traverses all the buffers and writes the tagged ones to disk.,remove tags.
		3. When all the buffers that were dirty at the start of the checkpoint are written to disk, the checkpoint is considered complete
		4. Finally, checkpointer creates a WAL entry that corresponds to the checkpoint completion, specifying the checkpoint’s start LSN.
#### Recovery
- pg_controldata
- 从redo-point开始，顺序遍历wal entity，跟涉及的page比较lsn，应用更新的版本
- full page write 无须比较，直接覆盖
- 最后执行checkpoint
#### Background Writing
- 辅助将脏页刷到磁盘
- 和eviction共用一个搜索算法，但是使用自己的时钟导致永远先于eviction执行
#### WAL Setup
- `checkpoint_completion_target`
	- The checkpoint duration (to be more exact, the duration of writing dirty buffers to disk)
	- 避免设置为1，可能导致下一个checkpoint在上一个checkpoint未完成时启动。同时两个checkpoint在运行
- `checkpoint_timeout`两次自动checkpoint之间的时间间隔
- `wal_max_size`
- 在平均负载下计算checkpoint_timeout间生成的wal日志大小乘以（1+checkpoint_complietion_target)是recovery过程需要的wal大小
#### Configuration Background Writing
- `bgwriter_delay` bgwriter执行间隔
- `bgwriter_lru_multiplier`在上个执行周期copy的pages 数量乘以该参数为当前周期预计执行的数量
- `bgwriter_lru_maxpages` 
## High Availability, Load Balancing, and Replication
#### Different Solutions
- Shared Disk Failover使用一个a single disk array，共享一份数据库文件
- File System (Block Device) Replication 数据文件全部拷贝到standby
- Write-Ahead Log Shipping 拷贝WAL日志文件
- Logical Replication 通过流，拷贝传送所有数据修改
- Trigger-Based Master-Standby Replication 将数据修改的query发送到master，master在发送到standby
- Statement-Based Replication Middleware 通过中间件控制每个query发送到所有服务器
- Asynchronous Multimaster Replication 每个主机独立工作，定期通信，通过规则或手动解决冲突
- Synchronous Multimaster Replication 每个服务器都可以接受读写请求。对于写入，会在事务提交前转发到其他所有服务器
- Data Partitioning 将数据表拆分为数据集，每个数据集由一台服务器管控
- Multiple-Server Parallel Query Execution  单个插叙由多个服务器共同完成
#### Log-Shipping Replication
###### 描述
Directly moving WAL records from one database server to another is typically described as log shipping。基于wal日志文件的备份，每次传送一个wal日志文件。wal记录在commit后才会被传送，所以在主备间存在一个窗口，期间的数据可能丢失
- archive_timeout 可控制上述丢失数据量
- warm standby 可以用做备机，不能做其他操作 
- hot standby 可以做备机，read-only 
#### Streaming Replication
 The standby connects to the primary, which streams WAL records to the standby as they're generated, without waiting for the WAL file to be filled. WAL记录在生成的时候就同步到备机，无需等待文件传送
- asynchronous mode 主备存在lag，主机commit了某一个事务，但是该修改在备机还未可见
- 保证备机需要的WAL日志：
	- wal_keep_segments设置的足够大，保证备机需要的WAL日志还存在
	- 使用replication slot，一直保持使用该slot的备机需要的所有WAL日志存在
	- 设置一个备机可获取的WAL archive，无需堆积WAL日志。该archive需要在第三个机器或者是备机上
- max_wal_senders
- `pg_current_wal_lsn` on the primary and `pg_last_wal_receive_lsn` on the standby。主备间的WAL lag可以通过比较这两个lsn获得
- 从pg_replication view可以获得每个WAL sender process的信息，查看网络时延和当前系统的负载
#### Replication Slots
Replication slots provide an automated way to ensure that the master does not remove WAL segments until they have been received by all standbys, and that the master does not remove rows which could cause a [recovery conflict](https://www.postgresql.org/docs/10/hot-standby.html%23HOT-STANDBY-CONFLICT "26.5.2. Handling Query Conflicts") even when the standby is disconnected.
- 保留需要的WAL日志
- 造成WAL囤积
- pg_replication_slots
#### Synchronous Replication
Synchronous replication offers the ability to confirm that all changes made by a transaction have been transferred to one or more synchronous standby servers.
等待所有synchronous standby都接收到了该事务相关的WAL日志，才做提交
- 配置项
	- synchronous_standby_names 配置使用同步备份模式的备机名称
	- synchronous_commit 设置为on
	- `synchronous_standby_names = 'FIRST 2 (s1, s2, s3)'` s1 s2 为synchronous standbys，s3为 potential synchronous standby
	- first方法和any方法
	- synchronous_standby_names = 'ANY 2 (s1, s2, s3)' 等待至少两个恢复就可以提交
	- any The method `ANY` specifies a quorum-based synchronous replication and makes transaction commits wait until their WAL records are replicated to _at least_ the requested number of synchronous standbys in the list.
- standby ->catup mode->streaming: 连接到primary->无lag
- Continuous archiving in standby
#### Hot Standby
Hot Standby is the term used to describe the ability to connect to the server and run read-only queries while the server is in archive recovery or standby mode. The term Hot Standby also refers to the ability of the server to move from recovery through to normal operation while users continue running queries and/or keep their connections open.
- 恢复模式或者standby状态，可以连接到主机，执行read-only query
- 需要设置`hot_standby`为`on` 存在`recovery·conf`
- 和主机查询结果可能存在差异
###### 允许的操作
-   Query access - `SELECT`, `COPY TO`
-   Cursor commands - `DECLARE`, `FETCH`, `CLOSE`
-   Parameters - `SHOW`, `SET`, `RESET`
-   Transaction management commands
    -   `BEGIN`, `END`, `ABORT`, `START TRANSACTION`
    -   `SAVEPOINT`, `RELEASE`, `ROLLBACK TO SAVEPOINT`
    -   `EXCEPTION` blocks and other internal subtransactions
-   `LOCK TABLE`, though only when explicitly in one of these modes: `ACCESS SHARE`, `ROW SHARE` or `ROW EXCLUSIVE`.
-   Plans and resources - `PREPARE`, `EXECUTE`, `DEALLOCATE`, `DISCARD`
-   Plugins and extensions - `LOAD`
-   `UNLISTEN`
###### 不允许的操作
**Transactions started during hot standby will never be assigned a transaction ID and cannot write to the system write-ahead log.**
-   Data Manipulation Language (DML) - `INSERT`, `UPDATE`, `DELETE`, `COPY FROM`, `TRUNCATE`. Note that there are no allowed actions that result in a trigger being executed during recovery. This restriction applies even to temporary tables, because table rows cannot be read or written without assigning a transaction ID, which is currently not possible in a Hot Standby environment.
-   Data Definition Language (DDL) - `CREATE`, `DROP`, `ALTER`, `COMMENT`. This restriction applies even to temporary tables, because carrying out these operations would require updating the system catalog tables.
-   `SELECT ... FOR SHARE | UPDATE`, because row locks cannot be taken without updating the underlying data files
-   Rules on `SELECT` statements that generate DML commands.
-   `LOCK` that explicitly requests a mode higher than `ROW EXCLUSIVE MODE`.
-   `LOCK` in short default form, since it requests `ACCESS EXCLUSIVE MODE`.
-   Transaction management commands that explicitly set non-read-only state:
    -   `BEGIN READ WRITE`, `START TRANSACTION READ WRITE`
    -   `SET TRANSACTION READ WRITE`, `SET SESSION CHARACTERISTICS AS TRANSACTION READ WRITE`
    -   `SET transaction_read_only = off`
-   Two-phase commit commands - `PREPARE TRANSACTION`, `COMMIT PREPARED`, `ROLLBACK PREPARED` because even read-only transactions need to write WAL in the prepare phase (the first phase of two phase commit).
-   Sequence updates - `nextval()`, `setval()`
-   `LISTEN`, `NOTIFY`
###### 处理查询冲突
- 性能影响。主库发生大量数据负载，备库查询可能争夺系统资源。
- hard conflicts：查询可能需要取消，有些会话可能要断开：
	-   Access Exclusive locks taken on the primary server, including both explicit `LOCK` commands and various DDL actions, conflict with table accesses in standby queries. 主机访问了排它锁，在备机表中还在进行查询
	-   Dropping a tablespace on the primary conflicts with standby queries using that tablespace for temporary work files. 主库删除了tablespace备库还在查询。
	-   Dropping a database on the primary conflicts with sessions connected to that database on the standby. 主库删除了database，备库存在连接到该database的会话。
	-   Application of a vacuum cleanup record from WAL conflicts with standby transactions whose snapshots can still “see” any of the rows to be removed. 主机清理了备机还处于可见状态的WAL记录。
	-   Application of a vacuum cleanup record from WAL conflicts with queries accessing the target page on the standby, whether or not the data to be removed is visible. 主机清理了备机查询需要获取目标page值的WAL记录。
- 发生上述冲突时，备库必须要重放主库已经进行的WAL操作，首先继续当前查询，然后replay WAL 记录
	- `max_standby_archive_delay` `max_standby_streaming_delay`用于控制当前继续查询的最大时间（两种备份方案），超时过后查询会被取消
		- 单个查询的时间必须小于该参数设置
		- wal日志接收到的时间点到现在经过的时间 与该参数作比较
		- wal日志已经积压，延后，查询的时间delay会更短
- 主库清理了备机还需要的WAL记录，导致冲突。主服务器上的清理可能会删除备用服务器上的事务仍然可见的行版本。
	- vacuum freeze
	- row version cleanup and row version freezing
	- 设置`hot_standby_feedback`可以避免删除最近失效的行。但是可能导致延迟清理，table bloat
	- 增加`vacuum_defer_cleanup_age`,不会立即清理失效的行
	- **可以通过`pg_stat_database_conflicts`查看冲突的信息，`pg_stat_database`存在概括信息**
###### 参数设置
- 主库
	- `wal_level`
	- `vacuum_defer_cleanup_age`
- 备库·
	- `hot_standby`
	- `max_standby_archive_delay`
	- `max_standby_streaming_delay`

## TODO
- [ ] WAL结构
- [ ] recovery 时如何比较lsn更新
- [ ] pg复制方式