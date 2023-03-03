# 测试情况
在sql1查询100并发下出现错误
```bash
开始测试:
     测试文件:sql1 sql2
     输出文件:gbase_test_result
     并发数:1 5 10 20 50 100


当前测试文件:sql1
pgbench -c 1 -j 1 -n -T 300 -f sql1 >> gbase_test_result 
pgbench -c 5 -j 5 -n -T 300 -f sql1 >> gbase_test_result 
pgbench -c 10 -j 10 -n -T 300 -f sql1 >> gbase_test_result 
pgbench -c 20 -j 20 -n -T 300 -f sql1 >> gbase_test_result 
pgbench -c 50 -j 50 -n -T 300 -f sql1 >> gbase_test_result 
pgbench -c 100 -j 100 -n -T 300 -f sql1 >> gbase_test_result 
client 1 aborted in command 0 of script 0; ERROR:  remote server returned an error

当前测试文件:sql2
pgbench -c 1 -j 1 -n -T 300 -f sql2 >> gbase_test_result 
pgbench -c 5 -j 5 -n -T 300 -f sql2 >> gbase_test_result 
pgbench -c 10 -j 10 -n -T 300 -f sql2 >> gbase_test_result 
pgbench -c 20 -j 20 -n -T 300 -f sql2 >> gbase_test_result 
pgbench -c 50 -j 50 -n -T 300 -f sql2 >> gbase_test_result 
pgbench -c 100 -j 100 -n -T 300 -f sql2 >> gbase_test_result 
当前测试完成
```
# 测试结果
- sql1
	- query
		```sql
		select

		    t1.*
		
		from
		
		    gf_surf_wea_chn_mul_hor_tab_server2 t1,
		
		    MV_STATION_INFO t2,
		
		    china_city area
		
		where
		
		    t1.v01301 = t2.v01301
		
		    and t2.netcode = '1'
		
		    and t1.d_datetime = '2021-12-10 09:00:00'
		
		    and ST_Within(t2.point, ST_Transform (area.geom, 4326)) = true
		
		    and area.city_name = '北京城区';
		```
	- result
		
		| clients | threads | result num | 远端surf_wea_chn_mul_hor_tab返回的 数量 | mv_station_info | china_city | latency average(s) | tps |
		| ------- | ------- | ---------- | --------------------------------------- | --------------- | ---------- | ------------------- | --- |
		| 1       | 1       | 10207      | 69096                         |20420          |    394             | 29.46  | 0.033938            |     
		| 5       | 5       | 10207      | 69096                             |20420        |          394       | 30.40 | 0.164424            |     
		| 10      | 10      | 10207      | 69096                             |20420        |              394   | 32.20  | 0.310528            |     
		| 20      | 20      | 10207      | 69096                            |20420         |                 394| 35.77  | 0.559065            |     
		| 50      | 50      | 10207      | 69096                              |20420       |        394         | 46.484  | 1.075633            |     
		| 100     | 100     | 10207      | 69096                              |20420       |         394        | 124.87 | 0.800858            |     

- sql2
	- query
		```sql
		select
		
		    t1.*
		
		from
		
		    gf_surf_wea_chn_mul_hor_tab_server2 t1,
		
		    MV_STATION_INFO_2 t2,
		
		    china_river t3
		
		where
		
		    t1.v01301 = t2.v01301
		
		    and t2.netcode = '1'
		
		    and t1.D_DATETIME > '2022-01-17 23:00:00'
		
		    and t1.D_DATETIME <= '2022-01-18 00:00:00'
		
		    and t3.nam = 'HAI HE'
		
		    and ST_DWithin(t2.point, ST_Transform (t3.geom, 4326), 5);

		```
	- result
		
		| clients | threads | result num | 远端surf_wea_chn_mul_hor_tab返回的数量 | mv_station_info | china_river | latency average(s) | tps |
		| ------- | ------- | ---------- | -------------------------------------- | --------------- | ----------- | ------------------- | --- |
		| 1       | 1       | 8489       | 64406                                  |    20422|51432             | 25.019   | 0.039970            |     
		| 5       | 5       | 8489       | 64406                                  |      20422|51432             | 25.34  | 0.197334            |    
		| 10      | 10      | 8489       | 64406                                  |     20422|51432              | 27.21  | 0.367547            |     
		| 20      | 20      | 8489       | 64406                                  |     20422|51432              | 31.76  | 0.629658            |     
		| 50      | 50      | 8489       | 64406                                  |    20422|51432               | 36.51   | 1.369526            |     
		| 100     | 100     | 8489       | 64406                                  |     20422|51432              | 107.42  | 0.930949            |     

