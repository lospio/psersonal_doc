- 检查service启动错误信息
	`journalctl -xe`
- yum被锁
	`rm -f /var/run/yum.pid`强制关掉
