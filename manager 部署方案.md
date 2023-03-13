# 0. 镜像
#### A. ETCD
- manager自带etcd
	- etcdctl version: 3.0.4
	- API version: 2
#### B. Spacture
- PostgreSQL
- Citus
- Patroni
- pg_exporter
#### C. Big Board
- node_exporter
- prometheus
- grafana
# 1. manager支持机制
#### A. 执行流程
![[Pasted image 20230307170936.png]]
#### B. 模型
![[Pasted image 20230307172230.png]]
#### C. 服务
- 服务是manager中处理的基本的单元，一个服务对应一个pod。
- 服务以及角色的定义和行为都在metainfo.yaml中配置。
- 服务层级的配置项全局通用
#### D. 角色
- 同一个服务可以划分为不同的角色
- 自定义每个角色的属性
- 角色在各个阶段可以有job 流，解析进行操作
# 2. 架构
[[Drawing 2023-03-07 15.30.45.excalidraw]]
# 3. Spacture服务
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
port=${service['coordinator.port']}
...
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
## C. 启动
### ⅰ 通用
- Patroni：每个节点配置groupID，用于区别所属高可用组.（具体方法需要与manager相关人员讨论，groupid是个虚拟概念）
### ⅱ Master操作
启动patroni,`patroni conf_file &`
### ⅲ Slave操作
启动patroni，`patroni conf_file &`
### ⅳ 创建citus
- pg_exporter 启动
- Citus： 创建extension。`create extension citus`
### ⅴ 在CN那一组Pod上添加worker节点
```sql
-- 需要手动更改脚本，或者考虑在生成时配置该sql文件。 语句根据citus版本作区分。
-- before 10
select master_update_node();
-- over10
select citus_add_node();
```
# 4. Bigboard 服务
## A. Image
- node_exporter
- prometheus
- grafana
## B. 配置
#### 静态参数
参考bigboard，使用本地配置
#### 动态参数
- prometheus 配置各个pg_exporter
## C. 启动
### ⅰ master 启动node_exporter
### ⅱ slave 启动 prometheus grafana
# 5. 参考
- [Metainfo开发手册](https://wiki.transwarp.io/pages/viewpage.action?pageId=24576772)
- [Spacture Metainfo](http://172.16.1.41/managability/application-metainfo/tree/dev/SPACTURE/spacture-1.1.0-final)
# TODO
- [x] 给定12个实例，部署在6个物理机上，pg一主一备，1cn5worker
- [x] pg citus patrni bigboard etcd
- [x] 拓扑 对象 物理机 节点 安装和配置 静态动态
- [ ] Spacture其他
- [ ] 两个高版本的image:
- [x] 拆开bigboard和spacture 主备分开设计
- [ ] patroni配置文件实例 2 节点4实例
- [x] bigboard启动 分开设计

