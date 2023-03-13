
---
ctime: <% tp.file.creation_date () %>
tags: simlpe-card
author: zhangzhilingyun
alias: 
---
#方案 #vault-squirreldoc 

# 01：背景
- 就装了pg（版本可能是9.6或者10。可能有多个pg实例）
- postgis插件(版本)
- 迁移到tdc arm环境（我们需要上架产品）
- 给了6个节点规划，需要高可用分布式

>2023/3/10 云上贵州
陈原老师沟通
数据量
PG数据量：不到100GB
三维文本：大约6T左右 需要存入hdfs
迁移中间介质
无
迁移过程种是否存在读写
保证迁移过程中不会有增量
DDL是否要修改（表是怎么用的？）
原封不动的
未来数据量（增量）
说不准（有政府部门有商务采购的数据，说不准）
迁入迁出所需要的时间
集群相对闲置，时间不强求极短时间
pgdump表结构信息

# 02：问题
1. 迁移数据量大小 不到100G
2. 迁移中间介质 网络互通
3. 迁移过程中是否存在读写 不存在
4. 是否需要做ddl修改 不需要
5. 预估未来数据量 不确定
6. 迁入迁出所需要的时间 不要求
7. 每个实例有多少database
```sql
-- 查看tablsespace
\db+
-- 查看sequence
\ds+
```
# 03：迁移步骤

## 步骤 1：遍历所有PostgreSQL实例，按ip_port存放至文件夹。后续步骤全部基于所有文件夹操作
## 步骤 2：导出database中的表定义
```bash
# 关键字pg实例，获取每个实例的ip和port
pg_dumpall -f 5432_schema.out  --quote-all-identifiers -v  -s -h localhost -U postgres > ../log 2>&1 &
```
- 整理sequence修改脚本，切换连接数据库，SELECT pg_catalog.setval,后缀为_seq ()
- 整理index到单独一个文件，包括切换数据库，创建index语句,后缀为_idx
- 将需要创建分布式的表，整理到文件中，后缀为_dist
-  **<mark style="background: #FF5582A6;">优化表设计</mark>**
	- 分区
	- 分布式
## 步骤 3：导出database中的数据
```bash
nohup pg_dumpall -a -f 5432_data.out -v --quote-all-identifiers -h data_host -p data_post > ../log 2>&1 &
```
## 步骤4： 导入表定义

```bahs
psql -h data_host -p data_post -f 5432_schema.out  > ../log 2>&1 &
```
## 步骤5：执行分布式表创建脚本
```bash
psql -h data_host -p data_post -f xxx_dist > ../log 2>&1 &
```
## 步骤6：导入数据
```bash
nohup psql -h data_host -p data_post -f xxx_data > ../log 2>&1 &
```
## 步骤7：创建索引
```bash
nohup psql -h data_host -p data_post -f xxx_dist > ../log 2>&1 &
```
## 步骤8：更改Sequence 
```bash
nohup psql -h data_host -p data_post -f xxx_seq > ../log 2>&1 &
```
## 步骤9：校验
- 检查日志报错
- 全量检查数据，将所有信息按照表名字典序写入文件，对比得到的两个文件。
	- 表名 行数
# 04: TODO
- [ ] 哪些表是分布式表
	- [ ] 选择分布式列
	- [ ] 定shard数
	- [ ] 创建分布式表
- [ ] sequence，在导完数据后重新设置值
	- [ ] 验证9.6或者10版本下，pg_dumpall是否自带setval语句
- [ ] 额外处理tablespace
- [ ] 索引如何处理
	- [ ] 先删，导出以后再建
- [ ] 导入操作写成脚本，一键执行
	- [ ] 记录日志
	- [ ] 记录操作
	- [ ] 记录错误
- [x] extension 会创建，需要提前安装
- [ ] 确认database数量，如果比较少，可以使用pg_dump可以更高效更精确的完成迁移
- [ ] 确认新库是否需要删除再创建 （-c）
- [ ] 数据包含类型
	- [ ] sequence
	- [ ] table
	- [ ] function
	- [ ] 