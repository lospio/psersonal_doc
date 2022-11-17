1. 停止集群内所有节点的patroni
2. patronictl remove
3. etcdctl ls /service
4. 主机启动patroni
5. patronictl restart主机
6. 保存备机的日志
7. pg_ctl stop 备机pg
8. 删除备机PGDATA目录{注意$PGDATA/bak目录}
9. 备机启动patroni
10. 查看备机patroni日志
11. 查看备机pg日志
