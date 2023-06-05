# 01: 调研
#### Citus Enterprise
利用逻辑复制
>Citus’ shard rebalancing uses PostgreSQL logical replication to move data from the old shard (called the “publisher” in replication terms) to the new (the “subscriber.”) Logical replication allows application reads and writes to continue uninterrupted while copying shard data. Citus puts a brief write-lock on a shard only during the time it takes to update metadata to promote the subscriber shard as active.

#### `master_copy_shard_placement`
>If a shard placement fails to be updated during a modification command or a DDL operation, then it gets marked as inactive. The master_copy_shard_placement function can then be called to repair an inactive shard placement using data from a healthy placement.
To repair a shard, the function first drops the unhealthy shard placement and recreates it using the schema on the coordinator. Once the shard placement is created, the function copies data from the healthy placement and updates the metadata to mark the new shard placement as healthy. This function ensures that the shard will be protected from any concurrent modifications during the repair.

# 02: 测试
#### 测试用例1：2wk，3shard，创建tt01分布式表，插入数据。再添加wk，继续插入数据，检查tt01增删改查功能
```sql
select master_remove_node('tw-node46','9432');wo
select * from pg_dist_node;
set citus.shard_count = 3;
create table tt01(id int , name char);
-- 先插入数据
insert into tt01 select generate_series(1,10000),'a';
select create_distributed_table('tt01','id');
select count(*) from tt01;
-- 在插入数据
insert into tt01 select generate_series(10001,20000),'b';
select count(*) from tt01;
select master_add_node('tw-node46',9432);
select * from pg_dist_node;
insert into tt01 select generate_series(20001,30000),'c';
select count(*) from tt01;
-- 在每个node上 \d+

create table tt02 (id int, name char);
insert into tt02 select generate_series(1,10000),'a';
select create_distributed_table('tt02','id');
```
- [ ] 实际使用场景
	- [ ] 旧表
	- [ ] 新表
- [ ] 机制
	- [ ] 查询的时候，shard和数据关系，从shard取数据
- [ ] 扩容对系统的影响
	- [ ] 旧表不重分布，新节点利用不起来
	- [ ] colocation default影响
	- [ ] add node拷贝复制表
	- [ ] 查看常年值表和业务表的colocation是什么，影响查询性能，待确认
- [ ] 扩容的需求点
	- [ ] 接入新业务还是扩容旧业务
#### citus分配查询任务给shard
