- 检查service启动错误信息
	`journalctl -xe`
- yum被锁
	`rm -f /var/run/yum.pid`强制关掉
- gpssh 在多个节点执行命令
- 开启core
	```bash
	cat /proc/sys/kernel/core_pattern
	/var/crash/core.%e.%p.%h.%t
	# 改路径必须存在
	ulimit -c unlimited
	```