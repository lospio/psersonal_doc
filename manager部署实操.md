---
ctime: <% tp.file.creation_date () %>
tags: log
author: zhangzhilingyun
alias: 
---
# 01：环境准备
- manager集群
	- 172.18.128.45 tw-node45
	- 172.18.128.46 tw-node46
	- 172.18.128.47 tw-node47
	- 172.18.128.48 tw-node48
- image：`tw-node45:5000/transwarp/spacture-1.2.0:v1`
- 编译docker
	```bash
	docker build -t transwarp/spacture-1.2.0:v1 . --network=host
	docker tag transwarp/spacture-1.2.0:v1 tw-node45:5000/transwarp/spacture-1.2.0:v1
	docker push tw-node45:5000/transwarp/spacture-1.2.0:v1
	```
# 02：规格
#### 组件
- PostgreSQL 10.23 (Transwarp)
- Citus 8.3.1
- Patroni 2.1.7
#### 功能
- 支持一主多备的高可用
- 支持Citus分布式
- 支持Leader和Replica的关键属性配置
	- 整个服务集体配置，支持单个实例配置
- 支持备机多实例，按照角色分组区分
#### 结构
- 基础角色有两种，leader和replica，属于高可用层级的主备概念
- 多组主备使用groupName区分，<mark style="background: #FF5582A6;">强制要求CN那一组groupName以`-cn`结尾</mark>
#### 设计图
- Spacture 服务
![[Pasted image 20230331113621.png]]
- 物理架构
![[Pasted image 20230324175252.png]]
- 逻辑结构
![[Pasted image 20230324175313.png]]
# 03：安装步骤
1. 登录`http://172.18.128.45:8180` admin:admin
2. 选择左侧仪表盘->集群->添加服务
3. 选择产品->其他->其他->SPACTURE->添加
4. 去掉勾选的仅展示最新版本，打开下拉框，选择spacture-1.2.0(本地镜像)->下一步->下一步
5. <mark style="background: #FF5582A6;">分配角色，选择左侧添加Scope</mark> <mark style="background: #FFB86CA6;">注意</mark>
	- 添加一组CN，名称以<mark style="background: #ADCCFFA6;">cn结尾</mark>
	- 同一组主机和备机使用不同的物理机
	- 控制单个物理机上的只有一个主机
	  >推荐使用跟当前节点序号相同的物理机做主机，其他节点上安装备机，循环使用，可以完成改配置，减少出错
 6. 配置参数
	 - <mark style="background: #FF5582A6;">推荐配置项</mark>
		 - leader.port
		 - replica.port
		 - leader.restapi.port
		 - replica.restapi.port
		 - leader.data.dir
		 - replica.data.dir
 1. 启动
# 05：参考
在四个节点的集群上，搭建一个一主三备的Spacture服务

| group name | node      | role    |
| ---------- | --------- | ------- |
| scope-cn   | <mark style="background: #FF5582A6;">tw-node45</mark> | <mark style="background: #FF5582A6;">leader </mark> |
| scope-cn   | tw-node46 | replica |
| scope-cn  | tw-node47 | replica |
| scope-cn   | tw-node48 | replica        |

| group name | node      | role    |
| ---------- | --------- | ------- |
| scope-wk1   | tw-node45 | replica |
| scope-wk1   | <mark style="background: #FF5582A6;">tw-node46</mark> | <mark style="background: #FF5582A6;">leader</mark> |
| scope-wk1  | tw-node47 | replica |
| scope-wk1  | tw-node48 | replica        |

| group name | node      | role    |
| ---------- | --------- | ------- |
| scope-wk2  | tw-node45 | replica |
| scope-wk2  | tw-node46 | replica |
| scope-wk2  | <mark style="background: #FF5582A6;">tw-node47</mark> | <mark style="background: #FF5582A6;">leader</mark>  |
| scope-wk2  | tw-node48 | replica |

| group name | node      | role    |
| ---------- | --------- | ------- |
| scope-wk3   | tw-node45 | replica |
| scope-wk3   | tw-node46 | replica |
| scope-wk3  | tw-node47 | replica |
| scope-wk3  | <mark style="background: #FF5582A6;">tw-node48</mark> | <mark style="background: #FF5582A6;">leader</mark>        |