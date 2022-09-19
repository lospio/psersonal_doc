# TODO
- [ ] on role change 机制
- [ ] 多cn
- [x] citus版本适配
- [x] 配置文件麻烦
- [x] 按review意见修改
- [x] 确认节点打印信息
# 1. 部署步骤
#### 每个节点：
1. 解压安装包至任一路径（后文称`$dir`)
2. 修改`$dir`所有者，执行权限
	```bash
	chown -R postgres:postgres $dir
	chmod +x {$dir}/citus_failover.py
	```
3. 修改当前节点patroni配置文件，在postgresql中添加`callbacks`如下:
	```yaml
	postgresql:
	  listen: 0.0.0.0:6432
	  connect_address: 172.22.7.11:6432
	  data_dir: /var/lib/postgresql/data
	  bin_dir: /usr/local/pgsql/bin
	  authentication:
	    replication:
	      username: repl
	      password: Space_666
	    superuser:
	      username: postgres
	      password: '123456'
	  basebackup:
	    max-rate: 100M
	    checkpoint: fast
	    .
	    .
	    .
	    .
	  # 添加内容
	  callbacks:
	    on_role_change: {$dir}/citus_failover.py

	```
4. 修改`$dir/switch.yml` ，按照需求配置参数
	```yaml
	# cn配置项
	
	cn:
	
	  connect_address: 172.16.238.160
	
	  username: postgres
	
	  password: "123456"
	
	  databases: postgres
	
	  
	
	# etcd 配置项
	
	etcd:
	
	  hosts:
	
	    -
	
	      host: 172.16.238.150
	
	      port: 2379
	
	    -
	
	      host: 172.16.238.151
	
	      port: 2379
	
	    -
	
	      host: 172.16.238.152
	
	      port: 2379
	
	  namespace: service
	
	  cluster_name: spatial_worker
	```
5. 启动patroni
#### 任一节点：
运行`pre_switch.py`
# 2. 流程介绍
[[自动流量切换流程.excalidraw]]