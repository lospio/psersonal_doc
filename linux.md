- 检查service启动错误信息
	`journalctl -xe`
- yum被锁
	`rm -f /var/run/yum.pid`强制关掉
- gpssh 在多个节点执行命令
