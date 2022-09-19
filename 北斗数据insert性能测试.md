- [ ] benchmark insert最佳实践
- [ ] 如何对insert调优
# 1. 环境
## a. 1CN4wk
- 文婷： 
	- 172.22.7.9~12 root/abcd1234
	- coordinator  172.22.7.10:5432，
	- 15432 是worker，配置可以在这看 http://172.22.7.9:8180/#/services/100/configuration admin/admin
	- `docker ps |grep spac|grep -v pause` 这样可以看容器id
- 邓杰：
	- cn: [172.22.7.9](http://172.22.7.9): 7432 dockername: 1cn4wk_cn1_1

## b. 1CN2wk
-  文婷：172.22.7.11:5532，worker 172.22.7.12:15532，172.22.7.10:15532
-  邓杰： cn: [172.22.7.9](http://172.22.7.9): 7533 dockername: 1cn2wk_cn1_1

# 2. sql
```sql

set citus.shard_count TO 20;


create table beidou_pts(
         id int8
        ,alarm int8
        ,altitude double precision
        ,direction double precision
        ,lat double precision
        ,lon double precision
        ,message_id int8
        ,process_time timestamp
        ,time timestamp
        ,truck_plate_color int2
        ,truck_no char(10)
        ,truck_speed double precision
        ,truck_status int2
        ,day date
        ,the_geom geometry(POINT,4326)
);

create sequence beidou_pts_id_seq;
alter table beidou_pts alter column id set default nextval('beidou_pts_id_seq');
alter sequence beidou_pts_id_seq owned by beidou_pts.id;

select create_distributed_table('beidou_pts','id');

insert into beidou_pts(
								alarm,
								altitude,
								direction,
								lat,
								lon,
								message_id,
								process_time,
								time,
								truck_plate_color,
								truck_no,
								truck_speed,
								truck_status,
								day,
								the_geom) 
values (
                               0
                              ,0
                              ,301
                              ,30.579017
                              ,104.022598
                              ,81517296
                              ,'2020-11-01 00:20:00'
                              ,'2020-11-01 00:19:00'
                              ,2
                              ,'truck1'
                              ,0
                              ,3
                              ,'2020-11-01'
                              ,'POINT(104.022598 30.579017)');

select * from beidou_pts;
```
# 3. pgbench
```bash
pgbench -c 1 -j 1 -n -T 300 -f beidou_pts.sql -p 5432 -U postgres > result &
```
# 4. 结果
## a. 文婷环境

### ⅰ. 1CN4wk
- 初始配置：

	|CN数量|worker数量|clients|threads|time|latency|tps|
	|:---|:---|:---|:---|:---|:---|:---|
	|1|0|1|1|5min|0.535ms|1870.196033 (including connections establishing)|
	|1|4|1|1|5min|1.324ms|755.251594 (including connections establishing)|
	|1|4|1|1|20min|1.320ms|757.770294 (including connections establishing)|
	|1|4|256|64|5min|14.151ms|18090.709168 (including connections establishing)|
	|1|4|64|64|10min|2.812ms|22760.790106 (including connections establishing)|
	|1|4|128|128|10min|5.976ms|21417.437748 (including connections establishing)|
	|1|4|256|256|10min|13.401ms|19102.456184 (including connections establishing)|

- 优化参数

	|CN数量|worker数量|clients|threads|time|latency|tps|
	|:---|:---|:---|:---|:---|:---|:---|
	|1|4|1|1|5min|1.313ms|761.845679  (including connections establishing)|
	|1|4|256|64|5min|13.229ms|19351.213462  (including connections establishing)|
	|1|4|64|64|5min|2.730ms|23445.895085  (including connections establishing)|
	|1|4|128|128|5min|5.858ms|21849.467683  (including connections establishing)|


### ⅱ. 1CN2wk
- 初始配置：

	|CN数量|worker数量|clients|threads|time|latency|tps|
	|:---|:---|:---|:---|:---|:---|:---|
	|1|1|1|1|5min|1.303ms|767.353231 (including connections establishing)|
	|1|2|256|64|5min|12.101 ms|21155.658058 (including connections establishing)|
	|1|2|64|64|5min|2.786ms|22971.828155 (including connections establishing)|
	|1|2|128|128|5min|5.540ms|23102.654593 (including connections establishing)|
	|1|2|256|256|5min|11.879ms|21551.542697 (including connections establishing)|	
	|1|2|512|512|5min|25.989ms|19700.644659 (including connections establishing)|	
- 修改log_statements `all`->`ddl`

	|CN数量|worker数量|clients|threads|time|latency|tps|
	|:---|:---|:---|:---|:---|:---|:---|
	|1|2|256|256|5min|7.513ms|34075.511721 (including connections establishing)|

- max_prepared_transactions

	|CN数量|worker数量|clients|threads|time|latency|tps|
	|:---|:---|:---|:---|:---|:---|:---|
	|1|2|256|256|5min|3.433ms|37282.076352 (including connections establishing)|
	|1|2|128|128|5min|3.490 ms|36679.742170  (including connections establishing)|

## b. 邓杰环境

### b. 1CN2wk with patroni
- 初始配置：

	|CN数量|worker数量|clients|threads|time|latency|tps|
	|:---|:---|:---|:---|:---|:---|:---|
	|1|2|1|1|5min|1.402ms|713.458714 (including connections establishing)|
	|1|2|256|64|5min| 5.508ms|46476.061429 (including connections establishing)|
	|1|2|64|64|5min|2.786ms|22971.828155 (including connections establishing)|
	|1|2|128|128|5min|3.751 ms|34127.117735 (including connections establishing)|
	|1|2|256|256|5min|6.094 ms|42011.285078 (including connections establishing)|	
	|1|2|512|512|5min|13.670|37455.201831 (including connections establishing)|	

- citus
	![[Pasted image 20220615151813.png]]
# 5.  分析
- [ ] CN和worker同一个物理机
1. 集群配置
	- 单节点物理机性能
2. pgbench 和 CN在同一台机器
3. 表结构不同

# 5. 参考
https://docs.citusdata.com/en/v11.0-beta/performance/performance_tuning.html#:~:text=Insert%20Throughput,%EF%83%81

