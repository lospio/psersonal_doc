# 1. replica状态下lag是否会继续扩大，WAL大小
- 结论：
 缺少WAL日志状态下，备机无法同步复制，lag持续扩大，主机WAL日志文件持续扩大，checkpoint无法remove，recycle WAL日志文件
 - 推测
`replication slot`
>Replication slots provide an automated way to ensure that the primary does not remove WAL segments until they have been received by all standbys, and that the primary does not remove rows which could cause a [recovery conflict](https://www.postgresql.org/docs/14/hot-standby.html#HOT-STANDBY-CONFLICT "27.4.2. Handling Query Conflicts") even when the standby is disconnected.

![[Pasted image 20220719115649.png]]

- 主机状态
	- 初始状态
		- lag大小
		
			![[Pasted image 20220719101920.png]]
		- WAL大小
		
			![[Pasted image 20220719102039.png]]
	- 写入50分钟后
		- lag大小
	
			![[Pasted image 20220719111837.png]]
		- WAL大小
		
			![[Pasted image 20220719111805.png]]
	- log 日志

		![[Pasted image 20220719120855.png]]
- 备机状态
	- 初始
	
		![[Pasted image 20220719112004.png]]
	- 写入50分钟后
	
		![[Pasted image 20220719112043.png]]
# 2. patroni on_role_change 机制
- 调用的参数 确定为 四个 （脚本名称；动作；角色；集群名称）
- 在follow和promote中调用on_role_change
```python
def call_nowait(self, cb_name):

        """ pick a callback command and call it without waiting for it to finish """

        if self.bootstrapping:

            return

        if cb_name in (ACTION_ON_START, ACTION_ON_STOP, ACTION_ON_RESTART, ACTION_ON_ROLE_CHANGE):

            self.__cb_called = True

  

        if self.callback and cb_name in self.callback:

            cmd = self.callback[cb_name]

            try:
				# 调用的参数明确为四个
                cmd = shlex.split(self.callback[cb_name]) + [cb_name, self.role, self.scope]

                self._callback_executor.call(cmd)

            except Exception:

                logger.exception('callback %s %s %s %s failed', cmd, cb_name, self.role, self.scope)
```
# 3. lag计算
- 计算代码
	```C
	lag = (self.cluster.last_lsn or 0) - wal_position
	```
- wal_position 计算方式
	- 如果是leader,计算当前写入的lsn与初始的写入差值,单位是bytes
		```sql
		pg_wal_lsn_diff(pg_catalog.pg_current_wal_lsn(), '0/0')::bigint
		```

	>- `pg_wal_lsn_diff` ( _`lsn1`_ `pg_lsn`, _`lsn2`_ `pg_lsn` ) → `numeric`
	>Calculates the difference in bytes (_`lsn1`_ - _`lsn2`_) between two write-ahead log locations. This can be used with `pg_stat_replication` or some of the functions shown in [Table 9.87](https://www.postgresql.org/docs/14/functions-admin.html#FUNCTIONS-ADMIN-BACKUP-TABLE "Table 9.87. Backup Control Functions") to get the replication lag.
	>- `pg_current_wal_lsn` () → `pg_lsn`
	>	Returns the current write-ahead log write location (see notes below).
	
	- 如果非leader，找回放和接受的WAL文件，lsn较大的值
		```python
		max(received_location or 0, replayed_location or 0)
		```
- `cluster.last_lsn`存储在`/status/optime`，为leader的last_lsn
# 4. demote
1. 检查能否rewind,运行命令`pg_rewind --help`
2. 查看postgresql配置项`remove_data_directory_on_diverged_timelines`
3. 修改rewind状态
4. 停止pg实例
5. 检查dsc里其他的member能否承担master的责任，如果可以就释放锁，调整自身状态为`demoted`
6. 设置`synchronous_standby_names`为空
7. 重启pg实例，follow一个健康的node或者reinit rewind

# 5. 同步复制
- 1. 选择 按照sync_state 和 lag大小查找最优的候选人，满足nofailover 和 max_lag
```sql
SELECT pg_catalog.lower(application_name), sync_state, pg_wal_lsn_diff(flush_lsn, '0/0')::bigint
FROM pg_catalog.pg_stat_replication
WHERE state = 'streaming' AND flush_lsn IS NOT NULL
ORDER BY sync_state DESC, flush_lsn DESC;
```
 2. 有更改，更新dcs sync值 包含leader和sync_standby
 3. 更新PG主机`synchronous_standby_names`
# 6. 选主
