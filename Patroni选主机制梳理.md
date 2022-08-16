# 1. 没有主机时
每个节点判断`is_healthiest`
检查项
- 检查释放leader锁的时间是否小于ttl
- 检查cluster is pause;nofailover;更新failover键值
- 检查pg实例状态
- 检查watchdog
- 检查自己是否在候选者里面
- 检查wal日志lag 是否大于`maxium_lag_on_failover`
- 检查timeline
- 检查到其他所有节点的连通性，wal日志位置：同步模式下必须在其他节点之后(即自身和primary的lag最小)