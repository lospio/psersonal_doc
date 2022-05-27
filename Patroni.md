#author/zhangzhilingyun 

# 1. 基本概念
## 定义
- 官方定义
>Patroni is a template for you to create your own customized, high-availability solution using Python and - for maximum accessibility - a distributed configuration store like ZooKeeper, etcd, Consul or Kubernetes.
- 理解
	- **template** patroni为我们提供了一套可以自定义的用于构造高可用pg环境的模板（或者说是框架），他并不是一套现成的，即插即用的系统（far from being a one-size-fits-all or plug-and-play replication system），需要根据现有的情况做自定义的配置
	- **Python** patroni使用python作为开发语言，并且留出了一部分钩子（hook)，对此我们可以便捷的加入需要的功能
	- **DCS** Distributed Configuration Store  用于控制和存储一些关键的信息
		- etcd
			- Distributed key-value store
			- [Implements RAFT](http://thesecretlivesofdata.com/raft/)  实现了RAFT选举算法
			- Needs more than 2 nodes (optimal: odd number)
- 我们可以利用patroni通过创建、管理、维护和监控高可用性 PostgreSQL 集群
## why
- 开源的高可用方案 [对比结果](https://scalegrid.io/blog/managing-high-availability-in-postgresql-part-3/#:~:text=PostgreSQL%20HA%20Framework%20Testing%3A%20PAF%20vs.%20repmgr%20vs.%20Patroni)
	1. PostgreSQL Automatic Failover by [ClusterLabs](https://www.clusterlabs.org/)
	2. Replication Manager for PostgreSQL Clusters by [repmgr](https://repmgr.org/) (2ndQuadrant)
    3. Patroni by [Zalando](https://github.com/zalando/patroni)
- patroni是PostgreSQL HA 的主流解决方案，参考openGauss
- patroni支持PostgreSQL集群中的端到端设置
- 利用PostgreSQL的原生机制很好的支持了Replication，Failover，Recovery场景
- 支持REST APIs 和HAProxy的集成
- 支持自定义回调操作，内部定义了某些操作会触发的事件通知
- 利用DCS保持一致性，各端达成共识，用户可以灵活选择DCS工具
>Patroni 是 PostgreSQL 数据库管理员 (DBA) 的宝贵工具，因为它执行 PostgreSQL 集群的端到端设置和监控。 选择 DCS 和创建备用数据库的灵活性对最终用户来说是一个优势，因为我们可以选择自己喜欢的方法。 REST API、HaProxy 集成、看门狗支持、回调及其功能丰富的管理使 Patroni 成为 PostgreSQL HA 管理的最佳解决方案。

## how
- DCS  分布式键值对存储
- patroni
	patroni作为PostgreSQL实例的管理和观察者，介于pg和DCS之间。
	- pg无法直接同DCS交换信息，patroni作为中间角色交换信息
	-  [Implements RAFT](http://thesecretlivesofdata.com/raft/)  实现了RAFT算法 ，是一种实现分布式共识的协议
	- 防止brain split 在任意时刻保持只有一个leader
		- 每个节点都尝试获取leader lock
		- leader lock只能在不存在时被获取
		- leader lock存在时无法获取
		- leader 定时更新leader lock，超过ttl没有更新就失去leader lock 被降级
	- REST API 和 HAProxy
		命令和控制接口，可以用来控制和监控节点
		- GET /master and /replica endpoints for the load balancer
		- GET /patroni in order to get system information
		- POST /restart in order to restart the node
		- POST /reinitialize in order to remove the data directory and reinitialize from the master(pg_basebackup)
		- POST /failover with leader and optional member names in order to do a
		controlled failover
		- patronictl to do it in a more user-friendly way
	- Callbacks
		```yaml
		postgresql:
			callbacks:
			on_start: /etc/patroni/callback.sh
			on_stop: /etc/patroni/callback.sh
			on_role_change: /etc/patroni/callback.sh
		```
		- on start
		- on stop
		- on restart
		- on change role
		
	
[[patroni_ha.excalidraw]]
![[Pasted image 20220527151252.png]]

# 2. 最佳实践
Patroni 是一个开源工具套件，它是用 Python 编写的，可确保 PostgreSQL HA 集群的端到端设置，包括流复制。 它的功能通过 REST API 显示，也通过一个名为 patronictl 的命令行实用程序显示。 它通过使用其运行状况检查 API 来处理负载平衡来支持与 HAProxy 的集成。 在这个 HA 解决方案中，etcd 用于分布式配置存储 (DCS)，以实现最大的可访问性。
![[Pasted image 20220527112322.png]]
[[patroni配置]]
# 3. 参考
- https://scalegrid.io/blog/managing-high-availability-in-postgresql-part-3/
- https://www.ibm.com/docs/el/cabi/1.1.5?topic=administering-configuring-postgresql-high-availability