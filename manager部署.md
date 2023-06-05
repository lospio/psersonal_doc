---
ctime: <% tp.file.creation_date () %>
tags: simlpe-card
author:zhangzhilingyun
alias: 
---
#log #vault-squirreldoc 
# 0. 软件包准备
#### A. ETCD
manager自带etcd
- etcdctl version: 3.0.4
- API version: 2
#### B. Spacture
- PostgreSQL
- Citus
- Patroni
#### C. Big Board
- node_exporter
- prometheus
- grafana
# 1. Spacture服务制作
## A. Image
1. PostgreSQL
2. Citus
3. Patroni
4. pg_exporter
## B. 配置
### 配置方式
- 在templates文件夹下面添加模板文件，生成配置文件，按照角色区分属性。
- 在metainfo中添加配置项，在控制台进行配置参数。
- Configurations以配置项为单位，给应用提供动态配置的能力。
### Postgresql
#### 静态参数
```ftl
listen_addresses = ${service['listen_addresses']}
log_destination = ${service['log_destination']}
logging_collector = ${service['logging_collector']}
log_rotation_size = ${service['log_rotation_size']}
log_statement = ${service['log_statement']}
shared_preload_libraries = ${service['shared_preload_libraries']}
spacture.node_conninfo = ${service['spacture.node_conninfo']}
shared_buffers = ${service['shared_buffers']}
port=${service['coordinator.port']}
...![[010BE2AC.png]]
```
#### 动态参数,可在控制台配置
```yaml
# 参考调优常用参数
max_connections
shared_buffers
work_mem
maintenance_work_mem
max_wal_size
min_wal_size
checkpoint_timeout
...
```
### Patroni
#### 静态参数
参考[[postgres0.yml]]
#### 动态参数
- scope
	- 3.0版本以前 每个group独立名称
	- 3.0版本以后，同一cluster集群一个名称
- namespace 默认即可，etcd上的存储路径
- name，同一scope内保持唯一
- restapi 配置本地即可
- etcd 所有节点同一个配置（etcd使用v2版本的api，etcd3配置项使用v3的api）
- PostgreSQL 根据自身ip，port配置
- tags：根据角色配置
### bigboard
#### 静态参数
参考bigboard，使用本地配置
#### 动态参数
- prometheus 配置各个pg_exporter
# 3. 启动
## A 通用
- 脚本执行，`create extension citus`
- 每个节点配置groupID，用于区别所属高可用组.
- 启动脚本
## B Master操作
启动patroni,`patroni conf_file &`
## C Slave操作
启动patroni，`patroni conf_file &`
## D 在CN那一组Pod上添加worker节点
```sql
-- 需要手动更改脚本，或者考虑在生成时配置该sql文件。 语句根据citus版本作区分。
-- before 10
select master_update_node();
-- over10
select citus_add_node();
```
# 4. manager支持机制
#### A. 执行流程
![[Pasted image 20230307170936.png]]
#### B. 服务
服务是manager中处理的基本的单元，一个服务对应一个pod。服务以及角色的定义和行为都在metainfo.yaml中配置。


# TODO
1. 给定12个实例，部署在6个物理机上，pg一主一备，1cn5worker
2. pg citus patrni bigboard etcd
3. 拓扑 对象 物理机 节点 安装和配置 静态动态

