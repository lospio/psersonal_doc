


- 单机pg
	- sql1
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
		- result
			
			|category|index|latency|result num|surf_wea_chn_mul_hor_tab|mv_station_info|
			|:---|:---|:---|:---|:---|:---|
			|local|1|latency average = 80990.667  ms|10056|11689|10143|
			|jdbc_fdw|1|latency average = 89371.180  ms|10056|11689|10143|
			
	- sql2
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
			                        ST_Transform
			                        ((select geom from china_river where china_river.nam='HAI HE'),4326),5);
			
				
			```
		- result
			
			|category|index|latency|result num|surf_wea_chn_mul_hor_tab|mv_station_info|
			|:---|:---|:---|:---|:---|:---|
			|local|1|latency average = 329.272 ms ms|10012|11689|10143|
			|jdbc_fdw|1|latency average =  1922.201 ms|10012|11689|10143|
			
- 分布式pg
	- 环境 
		- mv_station_info 分布式表 分布式列为*v01013*
		- china_river china_county为复制表
	- sql1
		- sql
			```sql
			with t1 as(
				select 
					* 
				from 
					gf_tt 
				where 
					d_datetime = '2022-03-21 00:00:00'
			)
			select 
				* 
			from 
				t1,
				MV_STATION_INFO t2, 
				china_county area 
			where 
				t1.v01301=t2.v01301 
				and t2.netcode = '1'
				and ST_Within(
					t2.point,
					ST_Transform
						(area.geom,4326)
					)=true and area.city_name='北京城区';
			```
		- result
			
			|category|index|latency|result num|surf_wea_chn_mul_hor_tab|mv_station_info|
			|:---|:---|:---|:---|:---|:---|
			|local|1|latency average = 6971.133  ms|10000|11689|10143|
			|jdbc_fdw|1|latency average = 8351.097  ms|10000|11689|10143|

		- plan
			```bash
			QUERY PLAN
			
			
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=7161.884..7280.332 rows=10000 loops=1)
			   Output: remote_scan.d_retain_id, remote_scan.d_data_id, remote_scan.d_iymdhm, remote_scan.d_rymdhm, remote_scan.d_update_time, remote_scan.d_datetime, remote_scan.v_bbb, remote_scan.v01301, remote_scan.v05001, remote_scan.v06001, remote_scan.v07001, remote_scan.v0
			2175, remote_scan.v07032_03, remote_scan.v08010, remote_scan.v02001, remote_scan.v02301, remote_scan.v_acode, remote_scan.v04001, remote_scan.v04002, remote_scan.v04003, remote_scan.v04004, remote_scan.v04005, remote_scan.v13011, remote_scan.q13011, remote_scan.d_sou
			rce_id, remote_scan.v01301_1, remote_scan.cname, remote_scan.countrycode, remote_scan.countryname, remote_scan.regioncode, remote_scan.v_acode_1, remote_scan.v_tcode, remote_scan.v06001_1, remote_scan.v05001_1, remote_scan.v07001_1, remote_scan.netcode, remote_scan.v
			02301_1, remote_scan.provincename, remote_scan.cityname, remote_scan.cntyname, remote_scan.townname, remote_scan.v_acode_4search, remote_scan.d_source_id_1, remote_scan.point, remote_scan.gid, remote_scan.county_nam, remote_scan.county_adc, remote_scan.county_cit, re
			mote_scan.city_name, remote_scan.city_adcod, remote_scan.city_cityc, remote_scan.province_n, remote_scan.province_a, remote_scan.province_c, remote_scan.center, remote_scan.geom
			   ->  Distributed Subplan 2_1
			         ->  Foreign Scan on public.gf_tt  (cost=100.00..111.00 rows=1 width=1022) (actual time=0.110..352.907 rows=11689 loops=1)
			               Output: d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id
			               Remote SQL: SELECT d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id FRO
			M "SURF_WEA_CHN_MUL_HOR_TAB" WHERE ((d_datetime = '2022-03-21 00:00:00'))
			 Planning time: 0.000 ms
			 Execution time: 2086.948 ms
			   Task Count: 32
			   Tasks Shown: One of 32
			   ->  Task
			         Node: host=172.16.3.123 port=5100 dbname=postgres
			         ->  Hash Join  (cost=925.81..1570.79 rows=5 width=24911) (actual time=2262.349..2266.477 rows=311 loops=1)
			               Output: intermediate_result.d_retain_id, intermediate_result.d_data_id, intermediate_result.d_iymdhm, intermediate_result.d_rymdhm, intermediate_result.d_update_time, intermediate_result.d_datetime, intermediate_result.v_bbb, intermediate_result.v01301
			, intermediate_result.v05001, intermediate_result.v06001, intermediate_result.v07001, intermediate_result.v02175, intermediate_result.v07032_03, intermediate_result.v08010, intermediate_result.v02001, intermediate_result.v02301, intermediate_result.v_acode, intermedi
			ate_result.v04001, intermediate_result.v04002, intermediate_result.v04003, intermediate_result.v04004, intermediate_result.v04005, intermediate_result.v13011, intermediate_result.q13011, intermediate_result.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.country
			name, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, are
			a.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
			               Hash Cond: ((intermediate_result.v01301)::text = (t2.v01301)::text)
			               ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..632.89 rows=3169 width=1022) (actual time=65.937..66.931 rows=11689 loops=1)
			                     Output: intermediate_result.d_retain_id, intermediate_result.d_data_id, intermediate_result.d_iymdhm, intermediate_result.d_rymdhm, intermediate_result.d_update_time, intermediate_result.d_datetime, intermediate_result.v_bbb, intermediate_result.
			v01301, intermediate_result.v05001, intermediate_result.v06001, intermediate_result.v07001, intermediate_result.v02175, intermediate_result.v07032_03, intermediate_result.v08010, intermediate_result.v02001, intermediate_result.v02301, intermediate_result.v_acode, int
			ermediate_result.v04001, intermediate_result.v04002, intermediate_result.v04003, intermediate_result.v04004, intermediate_result.v04005, intermediate_result.v13011, intermediate_result.q13011, intermediate_result.d_source_id
			                     Function Call: read_intermediate_result('2_1'::text, 'binary'::citus_copy_format)
			               ->  Hash  (cost=925.79..925.79 rows=2 width=23889) (actual time=2196.384..2196.385 rows=311 loops=1)
			                     Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id
			, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
			                     Buckets: 1024  Batches: 1  Memory Usage: 69kB
			                     ->  Nested Loop  (cost=0.00..925.79 rows=2 width=23889) (actual time=36.848..2195.851 rows=311 loops=1)
			                           Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_sou
			rce_id, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
			                           Join Filter: ((st_transform(area.geom, 4326) ~ t2.point) AND _st_contains(st_transform(area.geom, 4326), t2.point))
			                           Rows Removed by Join Filter: 4713
			                           ->  Seq Scan on public.mv_station_info_102136 t2  (cost=0.00..6.93 rows=314 width=449) (actual time=0.023..0.265 rows=314 loops=1)
			                                 Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2
			.d_source_id, t2.point
			                                 Filter: ((t2.netcode)::text = '1'::text)
			                           ->  Materialize  (cost=0.00..466.74 rows=16 width=23440) (actual time=0.001..0.007 rows=16 loops=314)
			                                 Output: area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
			                                 ->  Seq Scan on public.china_county_102168 area  (cost=0.00..466.66 rows=16 width=23440) (actual time=0.175..1.399 rows=16 loops=1)
			                                       Output: area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
			                                       Filter: ((area.city_name)::text = '北京城区'::text)
			                                       Rows Removed by Filter: 2837
			             Planning time: 0.732 ms
			             Execution time: 2267.184 ms
			 Planning time: 16.293 ms
			 Execution time: 7377.591 ms
			(38 rows)
	
			```
	- sql2
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
			                        ST_Transform
			                        ((select geom from china_river where china_river.nam='HAI HE'),4326),5);
			
				
			```
		- result
			
			|category|index|latency|result num|surf_wea_chn_mul_hor_tab|mv_station_info|
			|:---|:---|:---|:---|:---|:---|
			|local|1|latency average = 613.542  ms ms|10012|11689|10143|
			|jdbc_fdw|1|latency average =  2635.973 ms|10012|11689|10143|

		- plan
			```bash
			QUERY PLAN

			
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=2193.880..2195.252 rows=10012 loops=1)
			   Output: remote_scan.d_retain_id, remote_scan.d_data_id, remote_scan.d_iymdhm, remote_scan.d_rymdhm, remote_scan.d_update_time, remote_scan.d_datetime, remote_scan.v_bbb, remote_scan.v01301, remote_scan.v05001, remote_scan.v06001, remote_scan.v07001, remote_scan.
			v02175, remote_scan.v07032_03, remote_scan.v08010, remote_scan.v02001, remote_scan.v02301, remote_scan.v_acode, remote_scan.v04001, remote_scan.v04002, remote_scan.v04003, remote_scan.v04004, remote_scan.v04005, remote_scan.v13011, remote_scan.q13011, remote_scan.d
			_source_id, remote_scan.v01301_1, remote_scan.cname, remote_scan.countrycode, remote_scan.countryname, remote_scan.regioncode, remote_scan.v_acode_1, remote_scan.v_tcode, remote_scan.v06001_1, remote_scan.v05001_1, remote_scan.v07001_1, remote_scan.netcode, remote_
			scan.v02301_1, remote_scan.provincename, remote_scan.cityname, remote_scan.cntyname, remote_scan.townname, remote_scan.v_acode_4search, remote_scan.d_source_id_1, remote_scan.point
			   ->  Distributed Subplan 1_1
			         ->  Foreign Scan on public.gf_tt  (cost=100.00..111.19 rows=1 width=1022) (actual time=0.114..406.688 rows=11689 loops=1)
			               Output: d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id
			               Remote SQL: SELECT d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id F
			ROM "SURF_WEA_CHN_MUL_HOR_TAB" WHERE ((d_datetime > '2022-01-17 00:00:00')) AND ((d_datetime <= '2023-01-17 03:00:00'))
			 Planning time: 0.000 ms
			 Execution time: 619.096 ms
			   Task Count: 32
			   Tasks Shown: One of 32
			   ->  Task
			         Node: host=172.16.3.123 port=5100 dbname=postgres
			         ->  Hash Join  (cost=4491.49..5132.81 rows=334 width=1471) (actual time=98.754..102.397 rows=312 loops=1)
			               Output: intermediate_result.d_retain_id, intermediate_result.d_data_id, intermediate_result.d_iymdhm, intermediate_result.d_rymdhm, intermediate_result.d_update_time, intermediate_result.d_datetime, intermediate_result.v_bbb, intermediate_result.v013
			01, intermediate_result.v05001, intermediate_result.v06001, intermediate_result.v07001, intermediate_result.v02175, intermediate_result.v07032_03, intermediate_result.v08010, intermediate_result.v02001, intermediate_result.v02301, intermediate_result.v_acode, inter
			mediate_result.v04001, intermediate_result.v04002, intermediate_result.v04003, intermediate_result.v04004, intermediate_result.v04005, intermediate_result.v13011, intermediate_result.q13011, intermediate_result.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.c
			ountryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
			               Inner Unique: true
			               Hash Cond: ((intermediate_result.v01301)::text = (t2.v01301)::text)
			               InitPlan 1 (returns $0)
			                 ->  Seq Scan on public.china_river_102169 china_river  (cost=0.00..4396.90 rows=9 width=521) (actual time=11.202..16.965 rows=1 loops=1)
			                       Output: china_river.geom
			                       Filter: ((china_river.nam)::text = 'HAI HE'::text)
			                       Rows Removed by Filter: 51431
			               ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..632.89 rows=3169 width=1022) (actual time=68.281..69.300 rows=11689 loops=1)
			                     Output: intermediate_result.d_retain_id, intermediate_result.d_data_id, intermediate_result.d_iymdhm, intermediate_result.d_rymdhm, intermediate_result.d_update_time, intermediate_result.d_datetime, intermediate_result.v_bbb, intermediate_resul
			t.v01301, intermediate_result.v05001, intermediate_result.v06001, intermediate_result.v07001, intermediate_result.v02175, intermediate_result.v07032_03, intermediate_result.v08010, intermediate_result.v02001, intermediate_result.v02301, intermediate_result.v_acode,
			 intermediate_result.v04001, intermediate_result.v04002, intermediate_result.v04003, intermediate_result.v04004, intermediate_result.v04005, intermediate_result.v13011, intermediate_result.q13011, intermediate_result.d_source_id
			                     Function Call: read_intermediate_result('1_1'::text, 'binary'::citus_copy_format)
			               ->  Hash  (cost=93.28..93.28 rows=105 width=449) (actual time=29.823..29.824 rows=312 loops=1)
			                     Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_
			id, t2.point
			                     Buckets: 1024  Batches: 1  Memory Usage: 32kB
			                     ->  Seq Scan on public.mv_station_info_102136 t2  (cost=0.00..93.28 rows=105 width=449) (actual time=23.328..29.669 rows=312 loops=1)
			                           Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_s
			ource_id, t2.point
			                           Filter: (((t2.netcode)::text = '1'::text) AND st_dwithin(t2.point, st_transform($0, 4326), '5'::double precision))
			                           Rows Removed by Filter: 2
			             Planning time: 0.594 ms
			             Execution time: 102.969 ms
			 Planning time: 473.723 ms
			 Execution time: 2196.739 ms
			(35 rows)
			
			```
	