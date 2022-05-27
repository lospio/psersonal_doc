- Query 1
	- sql
		```sql
		select * 
		from 
			gf_tt t1,
			MV_STATION_INFO t2, 
			china_county area 
		where 
			t1.v01301=t2.v01301 and t2.netcode='1'
			and t1.d_datetime='2022-03-21 00:00:00'
			and ST_Within(
					t2.point,
					ST_Transform
							(area.geom,4326)
					)=true 
			and area.city_name='北京城区';
		
		```
	- 结果

		|类型|latency average(ms)|结果数量(行)|surf_wea_chn_mul_hor_tab(类型:数量)|mv_station_info(类型:数量)|china_county(类型:数量)|
		|:---|:---|:---|:---|:---|:---|
		|单机|89371.180|10012 行|gbase外表：11689 行|本地表：10143 行|本地表：2853行|
		|分布式|8351.097|10012 行|gbase外表：11689 行|分布式表：10143 行|复制表：2853行|
- Query 2
	- sql
		```sql
		select * 
		from 
			gf_tt t1,
			MV_STATION_INFO t2
		where 
			t1.v01301=t2.v01301 
			and t2.netcode= '1'
			and t1.d_datetime> '2022-01-17'
			and t1.d_datetime <= '2023-01-17 03:00:00'
			and
			ST_DWithin(
						t2.point,
						ST_Transform((select geom from china_river where china_river.nam='HAI HE'),4326),5);
		
		```
	- 结果

		|类型|latency average(ms)|结果数量(行)|surf_wea_chn_mul_hor_tab(类型:数量)|mv_station_info(类型:数量)|china_river(类型:数量)|
		|:---|:---|:---|:---|:---|:---|
		|单机|1922.201|10012 行|gbase外表：11689 行|本地表：10143 行|本地表：51432 行|
		|分布式|2635.973|10012 行|gbase外表：11689 行|分布式表：10143 行|复制表：51432 行|
---
# 优化后
- Query 1
	- sql
		```sql
		with t1 as(
                 select * from gf_tt where d_datetime='2022-03-21 00:00:00'
		)
		select 
			t1.*
		from
	        t1,
	        MV_STATION_INFO t2,
	        china_county_tmp area
		where
	        t1.v01301=t2.v01301
	        and t2.netcode='1'
	        and ST_Within(  t2.point,area.geom_tmp ) = true
	        and area.city_name='北京城区';

		```
	- 结果

		|类型|latency average(ms)|结果数量(行)|surf_wea_chn_mul_hor_tab(类型:数量)|mv_station_info(类型:数量)|china_county(类型:数量)|
		|:---|:---|:---|:---|:---|:---|
		|优化前|8351.097|10012 行|gbase外表：11689 行|分布式表：10143 行|复制表：2853行|
		|优化后|1177.862|10012 行|gbase外表：11689 行|分布式表：10143 行|复制表：2853行|
		
- Query 2
	- sql
		```sql
		 with t1 as (
						select * from gf_tt where d_datetime> '2022-01-17' and d_datetime <= '2023-01-17 03:00:00'
					)
        select 
	        t1.*
        from
                t1,
                MV_STATION_INFO t2
        where
                t1.v01301=t2.v01301 and t2.netcode= '1'
                and ST_DWithin(
                                t2.point,
                                (select geom_tmp from china_river_tmp where china_river_tmp.nam='HAI HE'),5
                );

		```
	- 结果

		|类型|latency average(ms)|结果数量(行)|surf_wea_chn_mul_hor_tab(类型:数量)|mv_station_info(类型:数量)|china_river(类型:数量)|
		|:---|:---|:---|:---|:---|:---|
		|优化前|2635.973|10012 行|gbase外表：11689 行|分布式表：10143 行|复制表：51432 行|
		|优化后|1049.505|10012 行|gbase外表：11689 行|分布式表：10143 行|复制表：51432 行|
		
