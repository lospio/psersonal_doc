


- 对比
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
			|local|1|latency average = 75360.844 ms|10000|11689|10143|
			|jdbc_fdw|1|latency average = 79903.454 ms|10000|11689|10143|
			
		- analyze
			- local
				- plan
					```bash
						 QUERY PLAN                                                                                                                                                                                               
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					 Nested Loop  (cost=100.28..587.36 rows=1 width=24909) (actual time=91.404..82932.553 rows=10000 loops=1)
					   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
					   Join Filter: ((st_transform(area.geom, 4326) ~ t2.point) AND _st_contains(st_transform(area.geom, 4326), t2.point))
					   Rows Removed by Join Filter: 150896
					   ->  Nested Loop  (cost=100.28..119.30 rows=1 width=1469) (actual time=58.876..889.265 rows=10056 loops=1)
							 Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
							 Inner Unique: true
							 ->  Foreign Scan on public.gf_tt t1  (cost=100.00..111.00 rows=1 width=1022) (actual time=58.805..744.882 rows=11689 loops=1)
								   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id
								   Remote SQL: SELECT d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id FROM "SURF_WEA_CHN_MUL_HOR_TAB" WHERE ((d_datetime = '2022-03-21 00:00:00'))
							 ->  Index Scan using mv_station_info_pk on public.mv_station_info t2  (cost=0.29..8.30 rows=1 width=447) (actual time=0.009..0.009 rows=1 loops=11689)
								   Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
								   Index Cond: (((t2.v01301)::text = (t1.v01301)::text) AND ((t2.netcode)::text = '1'::text))
					   ->  Seq Scan on public.china_county area  (cost=0.00..466.66 rows=16 width=23440) (actual time=0.133..0.949 rows=16 loops=10056)
							 Output: area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
							 Filter: ((area.city_name)::text = '北京城区'::text)
							 Rows Removed by Filter: 2837
					 Planning time: 392.769 ms
					 Execution time: 83235.672 ms
					(19 rows)
					
					```
				- sql
					```sql
					 select * from tt t1,
					   MV_STATION_INFO t2, china_county area where t1.v01301=t2.v01301 and t2.netcode='1'
					   and t1.d_datetime='2022-03-21 00:00:00'
					   and ST_Within(
					   t2.point,
					   ST_Transform
							   (area.geom,4326)
					   )=true and area.city_name='北京城区';
				
					```
				- flame graph
					![[local_sql1_test1.svg]]
			- jdbc_fdw
				- plan
					```bash
							QUERY PLAN                                                                                                                                                                                               
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					 Nested Loop  (cost=100.28..587.36 rows=1 width=24909) (actual time=91.404..82932.553 rows=10000 loops=1)
					   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
					   Join Filter: ((st_transform(area.geom, 4326) ~ t2.point) AND _st_contains(st_transform(area.geom, 4326), t2.point))
					   Rows Removed by Join Filter: 150896
					   ->  Nested Loop  (cost=100.28..119.30 rows=1 width=1469) (actual time=58.876..889.265 rows=10056 loops=1)
							 Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
							 Inner Unique: true
							 ->  Foreign Scan on public.gf_tt t1  (cost=100.00..111.00 rows=1 width=1022) (actual time=58.805..744.882 rows=11689 loops=1)
								   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id
								   Remote SQL: SELECT d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id FROM "SURF_WEA_CHN_MUL_HOR_TAB" WHERE ((d_datetime = '2022-03-21 00:00:00'))
							 ->  Index Scan using mv_station_info_pk on public.mv_station_info t2  (cost=0.29..8.30 rows=1 width=447) (actual time=0.009..0.009 rows=1 loops=11689)
								   Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
								   Index Cond: (((t2.v01301)::text = (t1.v01301)::text) AND ((t2.netcode)::text = '1'::text))
					   ->  Seq Scan on public.china_county area  (cost=0.00..466.66 rows=16 width=23440) (actual time=0.133..0.949 rows=16 loops=10056)
							 Output: area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
							 Filter: ((area.city_name)::text = '北京城区'::text)
							 Rows Removed by Filter: 2837
					 Planning time: 392.769 ms
					 Execution time: 83235.672 ms
					(19 rows)
					```
				- sql
					```sql
					select * from gf_tt t1,
					MV_STATION_INFO t2, china_county area where t1.v01301=t2.v01301 and t2.netcode='1'
					and t1.d_datetime='2022-03-21 00:00:00'
					and ST_Within(
							t2.point,
							ST_Transform
									(area.geom,4326)
							)=true and area.city_name='北京城区';
					```
				- flame graph
					![[jdbc_fdw_sql1_test1.svg]]
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
			|local|1|latency average = 75360.844 ms|10012|11689|10143|
			|jdbc_fdw|1|latency average =  1922.201 ms|10012|11689|10143|
			
		- analyze
			- local
				- plan
					```bash
						 QUERY PLAN                                                                                                                                                                                               
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					 Nested Loop  (cost=100.28..587.36 rows=1 width=24909) (actual time=91.404..82932.553 rows=10000 loops=1)
					   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
					   Join Filter: ((st_transform(area.geom, 4326) ~ t2.point) AND _st_contains(st_transform(area.geom, 4326), t2.point))
					   Rows Removed by Join Filter: 150896
					   ->  Nested Loop  (cost=100.28..119.30 rows=1 width=1469) (actual time=58.876..889.265 rows=10056 loops=1)
							 Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
							 Inner Unique: true
							 ->  Foreign Scan on public.gf_tt t1  (cost=100.00..111.00 rows=1 width=1022) (actual time=58.805..744.882 rows=11689 loops=1)
								   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id
								   Remote SQL: SELECT d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id FROM "SURF_WEA_CHN_MUL_HOR_TAB" WHERE ((d_datetime = '2022-03-21 00:00:00'))
							 ->  Index Scan using mv_station_info_pk on public.mv_station_info t2  (cost=0.29..8.30 rows=1 width=447) (actual time=0.009..0.009 rows=1 loops=11689)
								   Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
								   Index Cond: (((t2.v01301)::text = (t1.v01301)::text) AND ((t2.netcode)::text = '1'::text))
					   ->  Seq Scan on public.china_county area  (cost=0.00..466.66 rows=16 width=23440) (actual time=0.133..0.949 rows=16 loops=10056)
							 Output: area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
							 Filter: ((area.city_name)::text = '北京城区'::text)
							 Rows Removed by Filter: 2837
					 Planning time: 392.769 ms
					 Execution time: 83235.672 ms
					(19 rows)
					
					```
				- sql
					```sql
					 select * from tt t1,
					   MV_STATION_INFO t2, china_county area where t1.v01301=t2.v01301 and t2.netcode='1'
					   and t1.d_datetime='2022-03-21 00:00:00'
					   and ST_Within(
					   t2.point,
					   ST_Transform
							   (area.geom,4326)
					   )=true and area.city_name='北京城区';
				
					```
				- flame graph
					![[local_sql1_test1.svg]]
			- jdbc_fdw
				- plan
					```bash
							QUERY PLAN                                                                                                                                                                                               
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					 Nested Loop  (cost=100.28..587.36 rows=1 width=24909) (actual time=91.404..82932.553 rows=10000 loops=1)
					   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point, area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
					   Join Filter: ((st_transform(area.geom, 4326) ~ t2.point) AND _st_contains(st_transform(area.geom, 4326), t2.point))
					   Rows Removed by Join Filter: 150896
					   ->  Nested Loop  (cost=100.28..119.30 rows=1 width=1469) (actual time=58.876..889.265 rows=10056 loops=1)
							 Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id, t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
							 Inner Unique: true
							 ->  Foreign Scan on public.gf_tt t1  (cost=100.00..111.00 rows=1 width=1022) (actual time=58.805..744.882 rows=11689 loops=1)
								   Output: t1.d_retain_id, t1.d_data_id, t1.d_iymdhm, t1.d_rymdhm, t1.d_update_time, t1.d_datetime, t1.v_bbb, t1.v01301, t1.v05001, t1.v06001, t1.v07001, t1.v02175, t1.v07032_03, t1.v08010, t1.v02001, t1.v02301, t1.v_acode, t1.v04001, t1.v04002, t1.v04003, t1.v04004, t1.v04005, t1.v13011, t1.q13011, t1.d_source_id
								   Remote SQL: SELECT d_retain_id, d_data_id, d_iymdhm, d_rymdhm, d_update_time, d_datetime, v_bbb, v01301, v05001, v06001, v07001, v02175, v07032_03, v08010, v02001, v02301, v_acode, v04001, v04002, v04003, v04004, v04005, v13011, q13011, d_source_id FROM "SURF_WEA_CHN_MUL_HOR_TAB" WHERE ((d_datetime = '2022-03-21 00:00:00'))
							 ->  Index Scan using mv_station_info_pk on public.mv_station_info t2  (cost=0.29..8.30 rows=1 width=447) (actual time=0.009..0.009 rows=1 loops=11689)
								   Output: t2.v01301, t2.cname, t2.countrycode, t2.countryname, t2.regioncode, t2.v_acode, t2.v_tcode, t2.v06001, t2.v05001, t2.v07001, t2.netcode, t2.v02301, t2.provincename, t2.cityname, t2.cntyname, t2.townname, t2.v_acode_4search, t2.d_source_id, t2.point
								   Index Cond: (((t2.v01301)::text = (t1.v01301)::text) AND ((t2.netcode)::text = '1'::text))
					   ->  Seq Scan on public.china_county area  (cost=0.00..466.66 rows=16 width=23440) (actual time=0.133..0.949 rows=16 loops=10056)
							 Output: area.gid, area.county_nam, area.county_adc, area.county_cit, area.city_name, area.city_adcod, area.city_cityc, area.province_n, area.province_a, area.province_c, area.center, area.geom
							 Filter: ((area.city_name)::text = '北京城区'::text)
							 Rows Removed by Filter: 2837
					 Planning time: 392.769 ms
					 Execution time: 83235.672 ms
					(19 rows)
					```
				- sql
					```sql
					select * from gf_tt t1,
					MV_STATION_INFO t2, china_county area where t1.v01301=t2.v01301 and t2.netcode='1'
					and t1.d_datetime='2022-03-21 00:00:00'
					and ST_Within(
							t2.point,
							ST_Transform
									(area.geom,4326)
							)=true and area.city_name='北京城区';
					```
				- flame graph
					![[jdbc_fdw_sql1_test1.svg]]
	