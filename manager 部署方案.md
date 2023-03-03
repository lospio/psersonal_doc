# 0. Image
1. 编译好的PostgreSQL，存放指定路径，以版本后缀区分.
2. 编译好的Citus，存放指定路径，以版本后缀区分.
3. Patroni源码，存放指定路径，以版本后缀区分.
4. BigBoard可执行文件，存放指定路径 .
# 1. 通用安装
1. 安装PostgreSQL. 在对应版本路径下，执行`make install` 
2. 安装Citus. 在对应版本路径下，执行`make install` 
3. 安装Patroni. 在对应版本路径下，执行`pip3 install ./`  
# 2. 启动
## A 通用
- 脚本执行，`create extension citus`
- 每个节点配置groupID，用于区别所属高可用组.
- bigboard配置.
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
# 3. 配置
### 通用
- 在templates文件夹下面添加模板文件，使用FreeMarker解释渲染，生成配置文件.
- 可以在metainfo中添加配置项，在控制台进行配置参数.
- `configuration.yaml`中可以按照角色作区分配置项.
### Postgresql
利用模板渲染，可满足配置项。
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
```
### Patroni
利用GroupID，区分不同的高可用cluster
- scope
	- 3.0版本以前 每个group独立名称
	- 3.0版本以后，同一cluster集群一个名称
- namespace 默认即可，etcd上的存储路径
- name，同一scope内保持唯一
- restapi 配置本地即可
- etcd 同一配置
- PostgreSQL 根据自身ip，port配置
- tags：根据角色配置
### bigboard
#### 需要适配的部分
##### 采集、存储、可视化数据组件
bigboard监控效果由多个组件协同工作实现，对于操作系统的变化或者cpu架构的改变，组件有可能不可用，需要进行适配
##### 适配方法
除grafana组件外均采用复制二进制可执行文件的方式进行安装，适配时仅需对各组件的二进制文件进行替换即可
##### prometheus
[Release 2.39.1 / 2022-10-07 · prometheus/prometheus · GitHub](https://github.com/prometheus/prometheus/releases/tag/v2.39.1)
在此链接中获取编译好的prometheus，用其中的prometheus和promtool替换掉bigboard/roles/prometheus/files/prometheus/bin/ 下的同名文件
##### alertmanager
[Release 0.24.0 / 2022-03-24 · prometheus/alertmanager · GitHub](https://github.com/prometheus/alertmanager/releases/tag/v0.24.0)
在此链接中获取编译好的alertmanager，用其中的alertmanager和amtool替换掉bigboard/roles/prometheus/files/alertmanager/bin/ 下的同名文件
##### node_exporter
[Release 1.4.0 / 2022-09-24 · prometheus/node_exporter · GitHub](https://github.com/prometheus/node_exporter/releases/tag/v1.4.0)
在此链接中获取编译好的node_exporter，用其中的node_exporter替换掉bigboard/roles/monitor/files/ 下的同名文件
##### pg_exporter
[Release v0.5.0 Release · Vonng/pg_exporter · GitHub](https://github.com/Vonng/pg_exporter/releases/tag/v0.5.0)
在此链接中获取编译好的pg_exporter，用其中的pg_exporter替换掉bigboard/roles/monitor/files/ 下的同名文件(该链接中没有arm版本的pg_exporter，如果需要适配arm平台需要下载源码自己编译)
##### grafana
grafana版本固定为7.5.6，从[Download Grafana | Grafana Labs](https://grafana.com/grafana/download/7.5.6?platform=linux) 链接中获取合适的rpm包，将rpm包改名成grafana.rpm ，用改名后的grafana.rpm替换掉bigboard/roles/grafana/files/ 下的同名文件




