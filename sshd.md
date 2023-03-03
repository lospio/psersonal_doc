- 超时设置
	>1.修改server端的etc/ssh/sshd_config
ClientAliveInterval 60 ＃server每隔60秒发送一次请求给client，然后client响应，从而保持连接
ClientAliveCountMax 3 ＃server发出请求后，客户端没有响应得次数达到3，就自动断开连接，正常情况下，client不会不响应

## 连接缓慢
	- 修改sshd_config 
		- UseDNS no
		- GSSAPIAuthentication no
	- 修改ssh_config
		- GSSAPIAuthentication no
	- 容器无法访问外网 需要配置iptables
## 配置文件
- sshd_config配置server
- ssh_conifg配置client
