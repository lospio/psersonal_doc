# query 1
- ## A query
	```sql
	SELECT ST_grid_pixeltype_int(V_DATA) AS pixeltype  
	FROM CONST_NAFP_CFSV2_GLB_MUL_HH_TAB  
	WHERE V_ELE_CODE = 'pre'  
	LIMIT 1
	```
- ## B plan
	```sql
	  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=56.614..56.615 rows=1 loops=1)
	   Output: remote_scan.pixeltype
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=192.168.80.157 port=5432 dbname=babj_pgdb
	         ->  Limit  (cost=0.00..1.21 rows=1 width=4) (actual time=0.403..0.404 rows=1 loops=1)
	               Output: (st_grid_pixeltype_int(v_data))
	               ->  Seq Scan on public.const_nafp_cfsv2_glb_mul_hh_tab_114213 const_nafp_cfsv2_glb_mul_hh_tab  (cost=0.00..329691.12 rows=273448 width=4) (actual time=0.402..0.402 rows=1 loops=1)
	                     Output: st_grid_pixeltype_int(v_data)
	                     Filter: (const_nafp_cfsv2_glb_mul_hh_tab.v_ele_code = 'pre'::bpchar)
	                     Rows Removed by Filter: 136
	             Planning time: 0.080 ms
	             Execution time: 0.425 ms
	 Planning time: 2.439 ms
	 Execution time: 56.656 ms
	(16 行记录)
	```
- ## C 分析
	-  单表查询
	- 扫描列v_DATA ，做postgis计算
	- 筛选条件 
		1. V_ELE_CODE = ‘pre'
		2. limit 1
- ## D 影响：
	扫描耗时在0.4ms，56ms用来完成计算，换成分布式表，如果还限制limit1没有优势，不限制limit1会加快查询速度
# query2
- ## A query
	```sql
	SELECT	
	    st_gridasnetcdf(st_grid_average(d.v_data), 'pre') AS netcdf	
	FROM
	    (
	        SELECT
	            st_grid_average(d.v_data) AS v_data,
	            time
	        FROM
	            (
	                SELECT
	                    st_grid_SUM(c.v_data) AS v_data,
	                    time,
	                    ensNo
	                FROM
	                    (
	                        (
	                            SELECT
	                                st_grid_multi_value(CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA, 21600) AS v_data,
	                                CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time,
	                                CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime,
	                                CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo
	                            FROM
	                                CONST_NAFP_CFSV2_GLB_MUL_HH_TAB
	                            WHERE
	                                v_ele_code = 'pre'
	                                AND const_type = 1
	                                AND (
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984060520
	                                    AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984060520
	                                )
	                                AND (
	                                    (
	                                        CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840606
	                                        AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840716
	                                    )
	                                )
	                                AND (
	                                    (
	                                        CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1
	                                        AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1
	                                    )
	                                )
	                        )
	                    ) AS c
	                GROUP BY
	                    time,
	                    ensNo
	            ) AS d
	        GROUP BY
	            time
	    ) AS d
	```
- ## B plan
	```sql
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=1035.300..1035.301 rows=1 loops=1)
	   Output: remote_scan.netcdf
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=192.168.80.157 port=5432 dbname=babj_pgdb
	         ->  Aggregate  (cost=8.67..8.68 rows=1 width=32) (actual time=879.080..879.082 rows=1 loops=1)
	               Output: st_gridasnetcdf(st_grid_average((st_grid_average((st_grid_sum(st_grid_multi_value(const_nafp_cfsv2_glb_mul_hh_tab.v_data, '21600'::double precision)))))), 'pre'::cstring)
	               ->  GroupAggregate  (cost=8.60..8.66 rows=1 width=41) (actual time=849.388..849.389 rows=1 loops=1)
	                     Output: st_grid_average((st_grid_sum(st_grid_multi_value(const_nafp_cfsv2_glb_mul_hh_tab.v_data, '21600'::double precision)))), const_nafp_cfsv2_glb_mul_hh_tab.d_datetime
	                     Group Key: const_nafp_cfsv2_glb_mul_hh_tab.d_datetime
	                     ->  GroupAggregate  (cost=8.60..8.63 rows=1 width=46) (actual time=820.985..820.986 rows=1 loops=1)
	                           Output: st_grid_sum(st_grid_multi_value(const_nafp_cfsv2_glb_mul_hh_tab.v_data, '21600'::double precision)), const_nafp_cfsv2_glb_mul_hh_tab.d_datetime, const_nafp_cfsv2_glb_mul_hh_tab.v_evn
	                           Group Key: const_nafp_cfsv2_glb_mul_hh_tab.d_datetime, const_nafp_cfsv2_glb_mul_hh_tab.v_evn
	                           ->  Sort  (cost=8.60..8.61 rows=1 width=32) (actual time=0.490..0.511 rows=41 loops=1)
	                                 Output: const_nafp_cfsv2_glb_mul_hh_tab.d_datetime, const_nafp_cfsv2_glb_mul_hh_tab.v_evn, const_nafp_cfsv2_glb_mul_hh_tab.v_data
	                                 Sort Key: const_nafp_cfsv2_glb_mul_hh_tab.d_datetime, const_nafp_cfsv2_glb_mul_hh_tab.v_evn
	                                 Sort Method: quicksort  Memory: 28kB
	                                 ->  Index Scan using const_nafp_cfsv2_glb_mul_hh_tab_bkp_index_114213 on public.const_nafp_cfsv2_glb_mul_hh_tab_114213 const_nafp_cfsv2_glb_mul_hh_tab  (cost=0.56..8.59 rows=1 width=32) (actual time=0.063..0.443 rows=41 loops=1)
	                                       Output: const_nafp_cfsv2_glb_mul_hh_tab.d_datetime, const_nafp_cfsv2_glb_mul_hh_tab.v_evn, const_nafp_cfsv2_glb_mul_hh_tab.v_data
	                                       Index Cond: ((const_nafp_cfsv2_glb_mul_hh_tab.d_datetime >= '1984060520'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.d_datetime <= '1984060520'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.v_ele_code = 'pre'::bpchar) AND (const_nafp_cfsv2_glb_mul_hh_tab.v_evn >= '-1'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.v_evn <= '-1'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.d_foretime >= '19840606'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.d_foretime <= '19840716'::numeric))
	                                       Filter: (const_nafp_cfsv2_glb_mul_hh_tab.const_type = 1)
	             Planning time: 0.511 ms
	             Execution time: 879.181 ms
	 Planning time: 1.204 ms
	 Execution time: 1035.350 ms
	(26 行记录)
	```
- ## C 分析
	单表扫描处理，性能瓶颈在于计算。
 - 单表查询
 - 扫描列 v_data,d_datatime, d_foretime, v_evn
 - 筛选条件
	 1. v_ele_code 等值判断
	 2. const_type 等值判断
	 3. d_datetime 范围判断
	 4. d_foretime 范围判断
	 5. V_EVN 等值判断 (>=1 && <=-1)
	 6. group by
- ## D 影响
	1. 分布式扫描
	2. `group by time,ensno`
	3.  主要耗时在`st_grid_sum(st_grid_multi_value(const_nafp_cfsv2_glb_mul_hh_tab.v_data, '21600'::double precision))`,单个节点可以计算该sum和count，汇总数据到CN计算average，所以分布式表对该查询可能存在性能优化。
	4. 可能可以提高扫描效率，但是无法提升太多，扫描耗时只占一小部分
	5. 参照query3，三个子任务的计算性能大概提升有三倍。
# query3
- ## A query
	```sql
	SELECT
	    st_gridasnetcdf(st_grid_average(d.v_data), 'h500') AS netcdf
	FROM
	    (
	        SELECT
	            st_grid_average(d.v_data) AS v_data,
	            time
	        FROM
	            (
	                SELECT
	                    st_grid_average(c.v_data) AS v_data,
	                    time,
	                    ensNo
	                FROM
	                    (
	                        SELECT
	                            st_grid_sub_grid(a.V_DATA, b.V_DATA) AS v_data,
	                            a.time,
	                            a.validTime,
	                            a.ensNo
	                        FROM
	                            (
	                                SELECT
	                                    nafp_cfsv2_glb_mul_hh_tab.V_DATA AS V_DATA,
	                                    nafp_cfsv2_glb_mul_hh_tab.D_DATETIME AS time,
	                                    nafp_cfsv2_glb_mul_hh_tab.D_FORETIME AS validTime,
	                                    nafp_cfsv2_glb_mul_hh_tab.V_EVN AS ensNo
	                                FROM
	                                    nafp_cfsv2_glb_mul_hh_tab
	                                WHERE
	                                    v_ele_code = 'h500'
	                                    AND (
	                                        (
	                                            nafp_cfsv2_glb_mul_hh_tab.d_datetime >= 2022060620
	                                            AND nafp_cfsv2_glb_mul_hh_tab.d_datetime <= 2022060620
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            nafp_cfsv2_glb_mul_hh_tab.d_foretime >= 20220607
	                                            AND nafp_cfsv2_glb_mul_hh_tab.d_foretime <= 20220717
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            nafp_cfsv2_glb_mul_hh_tab.V_EVN >= -1
	                                            AND nafp_cfsv2_glb_mul_hh_tab.V_EVN <= -1
	                                        )
	                                    )
	                            ) AS a,
	                            (
	                                SELECT
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA AS V_DATA,
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time,
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime,
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo
	                                FROM
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB
	                                WHERE
	                                    v_ele_code = 'h500'
	                                    AND const_type = 1
	                                    AND (
	                                        (
	                                            CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984060620
	                                            AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984060620
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840607
	                                            AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840717
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1
	                                            AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1
	                                        )
	                                    )
	                            ) AS b
	                        WHERE
	                            a.time % 1000000 = b.time % 1000000
	                            AND a.validTime % 10000 = b.validTime % 10000
	                            AND a.ensNo = b.ensNo
	                    ) AS c
	                GROUP BY
	                    time,
	                    ensNo
	            ) AS d
	        GROUP BY
	            time
	    ) AS d
	```
- ## B plan
	```sql
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=2211.990..2211.991 rows=1 loops=1)
	   Output: remote_scan.netcdf
	   ->  Distributed Subplan 3_1
	         ->  HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=975.633..975.634 rows=1 loops=1)
	               Output: st_grid_div_grid(st_grid_sum(remote_scan.v_data), st_grid_sum(remote_scan.v_data_1)), remote_scan."time", remote_scan.ensno
	               Group Key: remote_scan."time", remote_scan.ensno
	               ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=929.767..929.770 rows=3 loops=1)
	                     Output: remote_scan.v_data, remote_scan.v_data_1, remote_scan."time", remote_scan.ensno
	                     Task Count: 3
	                     Tasks Shown: One of 3
	                     ->  Task
	                           Node: host=192.168.80.141 port=5432 dbname=babj_pgdb
	                           ->  GroupAggregate  (cost=17.21..17.25 rows=1 width=78) (actual time=363.444..363.456 rows=1 loops=1)
	                                 Output: st_grid_sum(st_grid_sub_grid(nafp_cfsv2_glb_mul_hh_tab.v_data, const_nafp_cfsv2_glb_mul_hh_tab.v_data)), st_grid_count_not_nodata(st_grid_sub_grid(nafp_cfsv2_glb_mul_hh_tab.v_data, const_nafp_cfsv2_glb_mul_hh_tab.v_data)), nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn
	                                 Group Key: nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn
	                                 ->  Sort  (cost=17.21..17.22 rows=1 width=50) (actual time=4.540..4.559 rows=8 loops=1)
	                                       Output: nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn, nafp_cfsv2_glb_mul_hh_tab.v_data, const_nafp_cfsv2_glb_mul_hh_tab.v_data
	                                       Sort Key: nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn
	                                       Sort Method: quicksort  Memory: 26kB
	                                       ->  Nested Loop  (cost=1.10..17.20 rows=1 width=50) (actual time=0.287..4.524 rows=8 loops=1)
	                                             Output: nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn, nafp_cfsv2_glb_mul_hh_tab.v_data, const_nafp_cfsv2_glb_mul_hh_tab.v_data
	                                             Join Filter: ((nafp_cfsv2_glb_mul_hh_tab.v_evn = const_nafp_cfsv2_glb_mul_hh_tab.v_evn) AND ((nafp_cfsv2_glb_mul_hh_tab.d_datetime % '1000000'::numeric) = (const_nafp_cfsv2_glb_mul_hh_tab.d_datetime % '1000000'::numeric)) AND ((nafp_cfsv2_glb_mul_hh_tab.d_foretime % '10000'::numeric) = (const_nafp_cfsv2_glb_mul_hh_tab.d_foretime % '10000'::numeric)))
	                                             Rows Removed by Join Filter: 320
	                                             ->  Append  (cost=0.55..8.58 rows=1 width=39) (actual time=0.049..0.184 rows=8 loops=1)
	                                                   ->  Index Scan using nafp_cfsv2_glb_mul_hh_tab_index_33_109516 on public.nafp_cfsv2_glb_mul_hh_tab_33_109516 nafp_cfsv2_glb_mul_hh_tab  (cost=0.55..8.58 rows=1 width=39) (actual time=0.049..0.180 rows=8 loops=1)
	                                                         Output: nafp_cfsv2_glb_mul_hh_tab.v_data, nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn, nafp_cfsv2_glb_mul_hh_tab.d_foretime
	                                                         Index Cond: ((nafp_cfsv2_glb_mul_hh_tab.d_datetime >= '2022060620'::numeric) AND (nafp_cfsv2_glb_mul_hh_tab.d_datetime <= '2022060620'::numeric) AND (nafp_cfsv2_glb_mul_hh_tab.v_ele_code = 'h500'::bpchar) AND (nafp_cfsv2_glb_mul_hh_tab.v_evn >= '-1'::numeric) AND (nafp_cfsv2_glb_mul_hh_tab.v_evn <= '-1'::numeric))
	                                                         Filter: ((nafp_cfsv2_glb_mul_hh_tab.d_foretime >= '20220607'::numeric) AND (nafp_cfsv2_glb_mul_hh_tab.d_foretime <= '20220717'::numeric))
	                                             ->  Index Scan using const_nafp_cfsv2_glb_mul_hh_tab_bkp_index_114213 on public.const_nafp_cfsv2_glb_mul_hh_tab_114213 const_nafp_cfsv2_glb_mul_hh_tab  (cost=0.56..8.59 rows=1 width=39) (actual time=0.051..0.427 rows=41 loops=8)
	                                                   Output: const_nafp_cfsv2_glb_mul_hh_tab.d_record_id, const_nafp_cfsv2_glb_mul_hh_tab.d_data_id, const_nafp_cfsv2_glb_mul_hh_tab.const_type, const_nafp_cfsv2_glb_mul_hh_tab.d_iymdhm, const_nafp_cfsv2_glb_mul_hh_tab.d_rymdhm, const_nafp_cfsv2_glb_mul_hh_tab.d_update_time, const_nafp_cfsv2_glb_mul_hh_tab.d_datetime, const_nafp_cfsv2_glb_mul_hh_tab.d_datetime_met, const_nafp_cfsv2_glb_mul_hh_tab.v_evn, const_nafp_cfsv2_glb_mul_hh_tab.d_foretime, const_nafp_cfsv2_glb_mul_hh_tab.d_foretime_met, const_nafp_cfsv2_glb_mul_hh_tab.v_level, const_nafp_cfsv2_glb_mul_hh_tab.v_latend, const_nafp_cfsv2_glb_mul_hh_tab.v_latstart, const_nafp_cfsv2_glb_mul_hh_tab.v_lonend, const_nafp_cfsv2_glb_mul_hh_tab.v_lonstart, const_nafp_cfsv2_glb_mul_hh_tab.v_ele_code, const_nafp_cfsv2_glb_mul_hh_tab.v_data, const_nafp_cfsv2_glb_mul_hh_tab.geom
	                                                   Index Cond: ((const_nafp_cfsv2_glb_mul_hh_tab.d_datetime >= '1984060620'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.d_datetime <= '1984060620'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.v_ele_code = 'h500'::bpchar) AND (const_nafp_cfsv2_glb_mul_hh_tab.v_evn >= '-1'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.v_evn <= '-1'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.d_foretime >= '19840607'::numeric) AND (const_nafp_cfsv2_glb_mul_hh_tab.d_foretime <= '19840717'::numeric))
	                                                   Filter: (const_nafp_cfsv2_glb_mul_hh_tab.const_type = 1)
	                               Planning time: 3.957 ms
	                               Execution time: 363.799 ms
	 Planning time: 0.000 ms
	 Execution time: 975.693 ms
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=192.168.80.156 port=5432 dbname=babj_pgdb
	         ->  Aggregate  (cost=78.62..78.63 rows=1 width=32) (actual time=50.673..50.674 rows=1 loops=1)
	               Output: st_gridasnetcdf(st_grid_average((st_grid_average(intermediate_result.v_data))), 'h500'::cstring)
	               ->  HashAggregate  (cost=73.61..76.11 rows=200 width=64) (actual time=24.989..24.991 rows=1 loops=1)
	                     Output: st_grid_average(intermediate_result.v_data), intermediate_result."time"
	                     Group Key: intermediate_result."time"
	                     ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..56.90 rows=3343 width=64) (actual time=0.200..0.202 rows=1 loops=1)
	                           Output: intermediate_result.v_data, intermediate_result."time", intermediate_result.ensno
	                           Function Call: read_intermediate_result('3_1'::text, 'binary'::citus_copy_format)
	             Planning time: 0.105 ms
	             Execution time: 50.747 ms
	 Planning time: 2.385 ms
	 Execution time: 2212.005 ms
	(52 行记录)
	```
- ## C 分析
	该查询先是在单个worker上将非常值表和常值表进行join，拿到的结果分组计算加和和数量，CN汇集所有worker返回数据后，再做average处理，耗时主要出现在对数据的处理（sum，average）上，扫描并不构成性能瓶颈。
	- 单表查询
	- 扫描列 v_data, d_datetime, d_foretime, v_evn
	- 筛选列
		1. v_ele_code 等值判断
		2. d_datetime 所属区间判断
		3. v_evn 等值判断
		4. 两个不同时间段的查询结果 等值连接
		5. 结果汇总分组
- ## D 影响
	 扫描并不构成性能瓶颈，优化的部分与网络传输汇总数据的性能损耗部分，差别无法估量。从当前例子来看，扫描的数据量并不大，提升可以忽略不计，但是发送remote_scan到远端执行的时间暂时不明朗，多一些网络传输的损耗。剩下的部分，分布式与复制表行为没有太大差异
# query
- ## A query
	```sql
	SELECT
	    st_gridasnetcdf(st_grid_average(d.v_data), 'tmp') AS netcdf
	FROM
	    (
	        SELECT
	            st_grid_average(d.v_data) AS v_data,
	            time
	        FROM
	            (
	                SELECT
	                    st_grid_average(c.v_data) AS v_data,
	                    time,
	                    ensNo
	                FROM
	                    (
	                        SELECT
	                            st_grid_sub_grid(a.V_DATA, b.V_DATA) AS v_data,
	                            a.time,
	                            a.validTime,
	                            a.ensNo
	                        FROM
	                            (
	                                SELECT
	                                    st_grid_sub_value(NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA, 273.15) AS V_DATA,
	                                    NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time,
	                                    NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime,
	                                    NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo
	                                FROM
	                                    NAFP_CFSV2_GLB_MUL_HH_TAB
	                                WHERE
	                                    v_ele_code = 'tmp'
	                                    AND (
	                                        (
	                                            NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 20220520
	                                            AND NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 20220520
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 20220601
	                                            AND NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 20220831
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1
	                                            AND NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1
	                                        )
	                                    )
	                            ) AS a,
	                            (
	                                SELECT
	                                    st_grid_sub_value(CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA, 273.15) AS V_DATA,
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time,
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime,
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo
	                                FROM
	                                    CONST_NAFP_CFSV2_GLB_MUL_HH_TAB
	                                WHERE
	                                    v_ele_code = 'tmp'
	                                    AND const_type = 1
	                                    AND (
	                                        (
	                                            CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 19840520
	                                            AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 19840520
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840601
	                                            AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840831
	                                        )
	                                    )
	                                    AND (
	                                        (
	                                            CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1
	                                            AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1
	                                        )
	                                    )
	                            ) AS b
	                        WHERE
	                            a.time % 10000 = b.time % 10000
	                            AND a.validTime % 10000 = b.validTime % 10000
	                            AND a.ensNo = b.ensNo
	                    ) AS c
	                GROUP BY
	                    time,
	                    ensNo
	            ) AS d
	        GROUP BY
	            time
	    ) AS d
	```
- ## B plan
	```sql
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=114.403..114.404 rows=1 loops=1)
	   Output: remote_scan.netcdf
	   ->  Distributed Subplan 5_1
	         ->  HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=4.786..4.786 rows=0 loops=1)
	               Output: st_grid_div_grid(st_grid_sum(remote_scan.v_data), st_grid_sum(remote_scan.v_data_1)), remote_scan."time", remote_scan.ensno
	               Group Key: remote_scan."time", remote_scan.ensno
	               ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=4.785..4.785 rows=0 loops=1)
	                     Output: remote_scan.v_data, remote_scan.v_data_1, remote_scan."time", remote_scan.ensno
	                     Task Count: 3
	                     Tasks Shown: One of 3
	                     ->  Task
	                           Node: host=192.168.80.141 port=5432 dbname=babj_pgdb
	                           ->  HashAggregate  (cost=0.00..0.01 rows=1 width=128) (actual time=0.001..0.001 rows=0 loops=1)
	                                 Output: st_grid_sum(st_grid_sub_grid(st_grid_sub_value(nafp_cfsv2_glb_mul_hh_tab.v_data, '273.15'::double precision), st_grid_sub_value(const_nafp_cfsv2_glb_mul_hh_tab.v_data, '273.15'::double precision))), st_grid_count_not_nodata(st_grid_sub_grid(st_grid_sub_value(nafp_cfsv2_glb_mul_hh_tab.v_data, '273.15'::double precision), st_grid_sub_value(const_nafp_cfsv2_glb_mul_hh_tab.v_data, '273.15'::double precision))), nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn
	                                 Group Key: nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn
	                                 ->  Result  (cost=0.00..0.00 rows=0 width=114) (actual time=0.000..0.001 rows=0 loops=1)
	                                       Output: nafp_cfsv2_glb_mul_hh_tab.d_datetime, nafp_cfsv2_glb_mul_hh_tab.v_evn, nafp_cfsv2_glb_mul_hh_tab.v_data, const_nafp_cfsv2_glb_mul_hh_tab.v_data
	                                       One-Time Filter: false
	                               Planning time: 3.212 ms
	                               Execution time: 0.069 ms
	 Planning time: 0.000 ms
	 Execution time: 4.817 ms
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=192.168.80.157 port=5432 dbname=babj_pgdb
	         ->  Aggregate  (cost=0.04..0.05 rows=1 width=32) (actual time=0.040..0.041 rows=1 loops=1)
	               Output: st_gridasnetcdf(st_grid_average((st_grid_average(intermediate_result.v_data))), 'tmp'::cstring)
	               ->  HashAggregate  (cost=0.01..0.03 rows=1 width=64) (actual time=0.039..0.039 rows=0 loops=1)
	                     Output: st_grid_average(intermediate_result.v_data), intermediate_result."time"
	                     Group Key: intermediate_result."time"
	                     ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..0.01 rows=1 width=64) (actual time=0.038..0.038 rows=0 loops=1)
	                           Output: intermediate_result.v_data, intermediate_result."time", intermediate_result.ensno
	                           Function Call: read_intermediate_result('5_1'::text, 'binary'::citus_copy_format)
	             Planning time: 0.089 ms
	             Execution time: 0.086 ms
	 Planning time: 1.737 ms
	 Execution time: 114.416 ms
	(38 行记录)
	```
- ## C 分析
	执行过程同query3， 但是数据量更小，无法看到更多有效信息.还是在分组求平均的时候，在单一节点先分组计算加和和数量，汇总数据后同意分组求average。
	- 单表查询
	- 扫描列 v_data, d_datetime, d_foretime, v_evn
	- 筛选列
		1. v_ele_code 等值判断
		2. d_datetime 所属区间判断
		3. v_evn 等值判断
		4. 两个不同时间段的查询结果 等值连接
		5. 结果汇总分组
- ## D 影响
	1. 分布式扫描
	2. 单个节点扫描后，获取数据汇集到cn，两个结果集再做连接，结果在group by，与复制表作比较，扫描性能有所提升，结果汇总有些微的耗时
	3. 扫描步骤效率有所提升，st_grid_sub_value计算会在各个node完成，效率有所提升
	4. 结果集连接的过滤条件无法下推到单一节点，需要查询全部数据，最后在筛选数据，效率有待确认
# query5
- ## A query 
	```sql
	SELECT st_gridasnetcdf(st_grid_average(d.v_data ),'slp') AS netcdf  
	FROM  
	(  
	SELECT st_grid_average(d.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_average(c.v_data ) AS v_data  
	,time  
	,ensNo  
	FROM  
	(  
	SELECT st_grid_sub_grid(a.V_DATA,b.V_DATA) AS v_data  
	,a.time  
	,a.validTime  
	,a.ensNo  
	FROM  
	(  
	SELECT st_grid_multi_value( nafp_cfsv2_glb_mul_hh_tab.V_DATA ,0.01) AS V_DATA  
	,nafp_cfsv2_glb_mul_hh_tab.D_DATETIME AS time  
	,nafp_cfsv2_glb_mul_hh_tab.D_FORETIME AS validTime  
	,nafp_cfsv2_glb_mul_hh_tab.V_EVN AS ensNo  
	FROM nafp_cfsv2_glb_mul_hh_tab  
	WHERE v_ele_code = 'slp'  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_datetime >= 2022071120 AND nafp_cfsv2_glb_mul_hh_tab.d_datetime <= 2022071120 ) )  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_foretime >= 20220712 AND nafp_cfsv2_glb_mul_hh_tab.d_foretime <= 20220816 ) )  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.V_EVN >= -1 AND nafp_cfsv2_glb_mul_hh_tab.V_EVN <= -1 ) )  
	) AS a, (  
	SELECT st_grid_multi_value( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA ,0.01) AS V_DATA  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo  
	FROM CONST_NAFP_CFSV2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'slp'  
	AND const_type = 1  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984071120 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984071120 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840712 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840816 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1 ) )) AS b  
	WHERE a.time%1000000 = b.time%1000000  
	AND a.validTime%10000 = b.validTime%10000  
	AND a.ensNo = b.ensNo  
	) AS c  
	GROUP BY time  
	,ensNo  
	) AS d  
	GROUP BY time  
	) AS d
	```
- ## B 分析
	- 同query4，最下层扫描结果函数不一样
# query6
- ## A query
	```sql
	SELECT st_gridasnetcdf(st_grid_average(d.v_data ),'h500') AS netcdf  
	FROM  
	(  
	SELECT st_grid_average(d.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_average(c.v_data ) AS v_data  
	,time  
	,ensNo  
	FROM  
	(  
	SELECT st_grid_sub_grid(a.V_DATA,b.V_DATA) AS v_data  
	,a.time  
	,a.validTime  
	,a.ensNo  
	FROM  
	(  
	SELECT st_grid_clip_with_col_row( nafp_cfsv2_glb_mul_hh_tab.V_DATA ,0,0,180,90) AS V_DATA  
	,nafp_cfsv2_glb_mul_hh_tab.D_DATETIME AS time  
	,nafp_cfsv2_glb_mul_hh_tab.D_FORETIME AS validTime  
	,nafp_cfsv2_glb_mul_hh_tab.V_EVN AS ensNo  
	FROM nafp_cfsv2_glb_mul_hh_tab  
	WHERE v_ele_code = 'h500'  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_datetime >= 2022072220 AND nafp_cfsv2_glb_mul_hh_tab.d_datetime <= 2022072220 ) )  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_foretime >= 20220805 AND nafp_cfsv2_glb_mul_hh_tab.d_foretime <= 20220805 ) )  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.V_EVN >= -1 AND nafp_cfsv2_glb_mul_hh_tab.V_EVN <= -1 ) )  
	) AS a, (  
	SELECT st_grid_clip_with_col_row( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA ,0,0,180,90) AS V_DATA  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo  
	FROM CONST_NAFP_CFSV2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'h500'  
	AND const_type = 1  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984072220 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984072220 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840805 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840805 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1 ) )) AS b  
	WHERE a.time%1000000 = b.time%1000000  
	AND a.validTime%10000 = b.validTime%10000  
	AND a.ensNo = b.ensNo  
	) AS c  
	GROUP BY time  
	,ensNo  
	) AS d  
	GROUP BY time  
	) AS d
	```
- ## B 分析
	- 同query4，最下层扫描结果函数不一样
# query7
- ## A query
	```sql
	SELECT st_gridasnetcdf(st_grid_average(d.v_data ),'tmp') AS netcdf  
	FROM  
	(  
	SELECT st_grid_average(d.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_average(c.v_data ) AS v_data  
	,time  
	,ensNo  
	FROM  
	(  
	SELECT st_grid_sub_grid(a.V_DATA,b.V_DATA) AS v_data  
	,a.time  
	,a.validTime  
	,a.ensNo  
	FROM  
	(  
	SELECT st_grid_sub_value( st_grid_clip_with_col_row( NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA ,75,31,150,84),273.15) AS V_DATA  
	,NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	,NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo  
	FROM NAFP_CFSV2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'tmp'  
	AND ( ( NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 2022080320 AND NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 2022080320 ) )  
	AND ( ( NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 20220804 AND NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 20220913 ) )  
	AND ( ( NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1 AND NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1 ) )  
	) AS a, (  
	SELECT st_grid_sub_value( st_grid_clip_with_col_row( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA ,75,31,150,84),273.15) AS V_DATA  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo  
	FROM CONST_NAFP_CFSV2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'tmp'  
	AND const_type = 1  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984080320 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984080320 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840804 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840913 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1 ) )) AS b  
	WHERE a.time%10000 = b.time%10000  
	AND a.validTime%10000 = b.validTime%10000  
	AND a.ensNo = b.ensNo  
	) AS c  
	GROUP BY time  
	,ensNo  
	) AS d  
	GROUP BY time  
	) AS d
	```
- ## B 分析
	- 执行结果同query4，最下层扫描，结果处理函数不一样
# query8
- ## A query
	```sql
	SELECT st_gridasnetcdf(st_grid_average(d.v_data ),'tmp') AS netcdf  
	FROM  
	(  
	SELECT st_grid_average(d.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_average(c.v_data ) AS v_data  
	,time  
	,ensNo  
	FROM  
	(  
	SELECT st_grid_sub_grid(a.V_DATA,b.V_DATA) AS v_data  
	,a.time  
	,a.validTime  
	,a.ensNo  
	FROM  
	(  
	SELECT nafp_cfsv2_glb_mul_hh_tab.V_DATA AS V_DATA  
	,nafp_cfsv2_glb_mul_hh_tab.D_DATETIME AS time  
	,nafp_cfsv2_glb_mul_hh_tab.D_FORETIME AS validTime  
	,nafp_cfsv2_glb_mul_hh_tab.V_EVN AS ensNo  
	FROM nafp_cfsv2_glb_mul_hh_tab  
	WHERE v_ele_code = 'tmp'  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_datetime >= 2022071320 AND nafp_cfsv2_glb_mul_hh_tab.d_datetime <= 2022071320 ) )  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_foretime >= 20220810 AND nafp_cfsv2_glb_mul_hh_tab.d_foretime <= 20220810 ) )  
	AND ( ( nafp_cfsv2_glb_mul_hh_tab.V_EVN >= -1 AND nafp_cfsv2_glb_mul_hh_tab.V_EVN <= -1 ) )  
	) AS a, (  
	SELECT CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA AS V_DATA  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo  
	FROM CONST_NAFP_CFSV2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'tmp'  
	AND const_type = 1  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984071320 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984071320 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840810 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840810 ) )  
	AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1 ) )) AS b  
	WHERE a.time%1000000 = b.time%1000000  
	AND a.validTime%10000 = b.validTime%10000  
	AND a.ensNo = b.ensNo  
	) AS c  
	GROUP BY time  
	,ensNo  
	) AS d  
	GROUP BY time  
	) AS d
	```
- ## B 分析
	- 执行结果同query3
# query9
- ## A query
	```sql
	SELECT

	    ST_grid_pixeltype_int(V_DATA) AS pixeltype
	
	FROM
	
	    CONST_NAFP_DERF2_GLB_MUL_HH_TAB
	
	WHERE
	
	    V_ELE_CODE = 'pre'
	
	LIMIT
	
	    1
	```
- ## 分析
	- 同query1，不同表
# query10
- ## query
	```sql
	SELECT

    st_gridasnetcdf(st_grid_average(d.v_data), 'pre') AS netcdf

FROM

    (

        SELECT

            st_grid_average(d.v_data) AS v_data,

            time

        FROM

            (

                SELECT

                    st_grid_SUM(c.v_data) AS v_data,

                    time

                FROM

                    (

                        (

                            SELECT

                                CONST_NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA AS v_data,

                                CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time,

                                CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime

                            FROM

                                CONST_NAFP_DERF2_GLB_MUL_HH_TAB

                            WHERE

                                v_ele_code = 'pre'

                                AND const_type = 1

                                AND (

                                    CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 1984061020

                                    AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 1984061020

                                )

                                AND (

                                    (

                                        CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 19840701

                                        AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 19840710

                                    )

                                )

                        )

                    ) AS c

                GROUP BY

                    time

            ) AS d

        GROUP BY

            time

    ) AS d
	```
- ## B plan
	```sql
	  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=281.978..281.979 rows=1 loops=1)
	   Output: remote_scan.netcdf
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=192.168.80.157 port=5432 dbname=babj_pgdb
	         ->  Aggregate  (cost=8.64..8.65 rows=1 width=32) (actual time=170.823..170.824 rows=1 loops=1)
	               Output: st_gridasnetcdf(st_grid_average((st_grid_average((st_grid_sum(const_nafp_derf2_glb_mul_hh_tab.v_data))))), 'pre'::cstring)
	               ->  GroupAggregate  (cost=0.55..8.63 rows=1 width=41) (actual time=145.331..145.332 rows=1 loops=1)
	                     Output: st_grid_average((st_grid_sum(const_nafp_derf2_glb_mul_hh_tab.v_data))), const_nafp_derf2_glb_mul_hh_tab.d_datetime
	                     Group Key: const_nafp_derf2_glb_mul_hh_tab.d_datetime
	                     ->  GroupAggregate  (cost=0.55..8.60 rows=1 width=41) (actual time=120.501..120.501 rows=1 loops=1)
	                           Output: st_grid_sum(const_nafp_derf2_glb_mul_hh_tab.v_data), const_nafp_derf2_glb_mul_hh_tab.d_datetime
	                           Group Key: const_nafp_derf2_glb_mul_hh_tab.d_datetime
	                           ->  Index Scan using const_nafp_derf2_glb_mul_hh_tab_bkp_index_112154 on public.const_nafp_derf2_glb_mul_hh_tab_112154 const_nafp_derf2_glb_mul_hh_tab  (cost=0.55..8.58 rows=1 width=27) (actual time=0.046..0.433 rows=10 loops=1)
	                                 Output: const_nafp_derf2_glb_mul_hh_tab.d_record_id, const_nafp_derf2_glb_mul_hh_tab.d_data_id, const_nafp_derf2_glb_mul_hh_tab.const_type, const_nafp_derf2_glb_mul_hh_tab.d_iymdhm, const_nafp_derf2_glb_mul_hh_tab.d_rymdhm, const_nafp_derf2_glb_mul_hh_tab.d_update_time, const_nafp_derf2_glb_mul_hh_tab.d_datetime, const_nafp_derf2_glb_mul_hh_tab.d_datetime_met, const_nafp_derf2_glb_mul_hh_tab.v_evn, const_nafp_derf2_glb_mul_hh_tab.d_foretime, const_nafp_derf2_glb_mul_hh_tab.d_foretime_met, const_nafp_derf2_glb_mul_hh_tab.v_level, const_nafp_derf2_glb_mul_hh_tab.v_latend, const_nafp_derf2_glb_mul_hh_tab.v_latstart, const_nafp_derf2_glb_mul_hh_tab.v_lonend, const_nafp_derf2_glb_mul_hh_tab.v_lonstart, const_nafp_derf2_glb_mul_hh_tab.v_ele_code, const_nafp_derf2_glb_mul_hh_tab.v_data, const_nafp_derf2_glb_mul_hh_tab.geom
	                                 Index Cond: ((const_nafp_derf2_glb_mul_hh_tab.d_datetime >= '1984061020'::numeric) AND (const_nafp_derf2_glb_mul_hh_tab.d_datetime <= '1984061020'::numeric) AND (const_nafp_derf2_glb_mul_hh_tab.v_ele_code = 'pre'::bpchar) AND (const_nafp_derf2_glb_mul_hh_tab.d_foretime >= '19840701'::numeric) AND (const_nafp_derf2_glb_mul_hh_tab.d_foretime <= '19840710'::numeric))
	                                 Filter: (const_nafp_derf2_glb_mul_hh_tab.const_type = 1)
	             Planning time: 0.333 ms
	             Execution time: 170.888 ms
	 Planning time: 0.494 ms
	 Execution time: 281.995 ms
	```
- ## C 分析
	plan同query2，
	- 单表查询
	- 扫描列 v_data, d_datetime, d_foretime
	- 筛选列 
		1. v_ele_code 等值
		2. const_type 等值
		3. d_datetime 范围
		4. d_foretime 范围
		5. group by 汇总
- ## D 影响
	1. 分布式扫描
	2. 性能瓶颈可能存在与sum和average的计算，分布式表可能提高性能
# query11
- ## query
	```sql
	SELECT
	
	    st_gridasnetcdf(st_grid_average(d.v_data), 'h500') AS netcdf
	
	FROM
	
	    (
	
	        SELECT
	
	            st_grid_average(d.v_data) AS v_data,
	
	            time
	
	        FROM
	
	            (
	
	                SELECT
	
	                    st_grid_average(c.v_data) AS v_data,
	
	                    time
	
	                FROM
	
	                    (
	
	                        SELECT
	
	                            st_grid_sub_grid(a.V_DATA, b.V_DATA) AS v_data,
	
	                            a.time,
	
	                            a.validTime
	
	                        FROM
	
	                            (
	
	                                SELECT
	
	                                    NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA AS V_DATA,
	
	                                    NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time,
	
	                                    NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime
	
	                                FROM
	
	                                    NAFP_DERF2_GLB_MUL_HH_TAB
	
	                                WHERE
	
	                                    v_ele_code = 'h500'
	
	                                    AND (
	
	                                        (
	
	                                            NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 2022060620
	
	                                            AND NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 2022060620
	
	                                        )
	
	                                    )
	
	                                    AND (
	
	                                        (
	
	                                            NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 20220607
	
	                                            AND NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 20220717
	
	                                        )
	
	                                    )
	
	                            ) AS a,
	
	                            (
	
	                                SELECT
	
	                                    CONST_NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA AS V_DATA,
	
	                                    CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time,
	
	                                    CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime
	
	                                FROM
	
	                                    CONST_NAFP_DERF2_GLB_MUL_HH_TAB
	
	                                WHERE
	
	                                    v_ele_code = 'h500'
	
	                                    AND const_type = 1
	
	                                    AND (
	
	                                        (
	
	                                            CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 1984060620
	
	                                            AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 1984060620
	
	                                        )
	
	                                    )
	
	                                    AND (
	
	                                        (
	
	                                            CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 19840607
	
	                                            AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 19840717
	
	                                        )
	
	                                    )
	
	                            ) AS b
	
	                        WHERE
	
	                            a.time % 1000000 = b.time % 1000000
	
	                            AND a.validTime % 10000 = b.validTime % 10000
	
	                    ) AS c
	
	                GROUP BY
	
	                    time
	
	            ) AS d
	
	        GROUP BY
	
	            time
	
	    ) AS d
	```
- ## B plan
	```sql
	Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=1339.389..1339.390 rows=1 loops=1)
	   Output: remote_scan.netcdf
	   ->  Distributed Subplan 8_1
	         ->  HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=534.467..534.469 rows=1 loops=1)
	               Output: st_grid_div_grid(st_grid_sum(remote_scan.v_data), st_grid_sum(remote_scan.v_data_1)), remote_scan."time"
	               Group Key: remote_scan."time"
	               ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=512.593..512.596 rows=3 loops=1)
	                     Output: remote_scan.v_data, remote_scan.v_data_1, remote_scan."time"
	                     Task Count: 3
	                     Tasks Shown: One of 3
	                     ->  Task
	                           Node: host=192.168.80.141 port=5432 dbname=babj_pgdb
	                           ->  GroupAggregate  (cost=1.11..17.23 rows=1 width=73) (actual time=430.895..430.897 rows=1 loops=1)
	                                 Output: st_grid_sum(st_grid_sub_grid(nafp_derf2_glb_mul_hh_tab.v_data, const_nafp_derf2_glb_mul_hh_tab.v_data)), st_grid_count_not_nodata(st_grid_sub_grid(nafp_derf2_glb_mul_hh_tab.v_data, const_nafp_derf2_glb_mul_hh_tab.v_data)), nafp_derf2_glb_mul_hh_tab.d_datetime
	                                 Group Key: nafp_derf2_glb_mul_hh_tab.d_datetime
	                                 ->  Nested Loop  (cost=1.11..17.20 rows=1 width=45) (actual time=0.227..9.494 rows=15 loops=1)
	                                       Output: nafp_derf2_glb_mul_hh_tab.d_datetime, nafp_derf2_glb_mul_hh_tab.v_data, const_nafp_derf2_glb_mul_hh_tab.v_data
	                                       Join Filter: (((nafp_derf2_glb_mul_hh_tab.d_datetime % '1000000'::numeric) = (const_nafp_derf2_glb_mul_hh_tab.d_datetime % '1000000'::numeric)) AND ((nafp_derf2_glb_mul_hh_tab.d_foretime % '10000'::numeric) = (const_nafp_derf2_glb_mul_hh_tab.d_foretime % '10000'::numeric)))
	                                       Rows Removed by Join Filter: 600
	                                       ->  Merge Append  (cost=0.56..8.59 rows=1 width=34) (actual time=0.045..0.429 rows=15 loops=1)
	                                             Sort Key: nafp_derf2_glb_mul_hh_tab.d_datetime
	                                             ->  Index Scan using nafp_derf2_glb_mul_hh_tab_index_33_109661 on public.nafp_derf2_glb_mul_hh_tab_33_109661 nafp_derf2_glb_mul_hh_tab  (cost=0.55..8.57 rows=1 width=34) (actual time=0.044..0.421 rows=15 loops=1)
	                                                   Output: nafp_derf2_glb_mul_hh_tab.v_data, nafp_derf2_glb_mul_hh_tab.d_datetime, nafp_derf2_glb_mul_hh_tab.d_foretime
	                                                   Index Cond: ((nafp_derf2_glb_mul_hh_tab.d_datetime >= '2022060620'::numeric) AND (nafp_derf2_glb_mul_hh_tab.d_datetime <= '2022060620'::numeric) AND (nafp_derf2_glb_mul_hh_tab.v_ele_code = 'h500'::bpchar))
	                                                   Filter: ((nafp_derf2_glb_mul_hh_tab.d_foretime >= '20220607'::numeric) AND (nafp_derf2_glb_mul_hh_tab.d_foretime <= '20220717'::numeric))
	                                                   Rows Removed by Filter: 3
	                                       ->  Index Scan using const_nafp_derf2_glb_mul_hh_tab_bkp_index_112154 on public.const_nafp_derf2_glb_mul_hh_tab_112154 const_nafp_derf2_glb_mul_hh_tab  (cost=0.55..8.58 rows=1 width=34) (actual time=0.018..0.489 rows=41 loops=15)
	                                             Output: const_nafp_derf2_glb_mul_hh_tab.d_record_id, const_nafp_derf2_glb_mul_hh_tab.d_data_id, const_nafp_derf2_glb_mul_hh_tab.const_type, const_nafp_derf2_glb_mul_hh_tab.d_iymdhm, const_nafp_derf2_glb_mul_hh_tab.d_rymdhm, const_nafp_derf2_glb_mul_hh_tab.d_update_time, const_nafp_derf2_glb_mul_hh_tab.d_datetime, const_nafp_derf2_glb_mul_hh_tab.d_datetime_met, const_nafp_derf2_glb_mul_hh_tab.v_evn, const_nafp_derf2_glb_mul_hh_tab.d_foretime, const_nafp_derf2_glb_mul_hh_tab.d_foretime_met, const_nafp_derf2_glb_mul_hh_tab.v_level, const_nafp_derf2_glb_mul_hh_tab.v_latend, const_nafp_derf2_glb_mul_hh_tab.v_latstart, const_nafp_derf2_glb_mul_hh_tab.v_lonend, const_nafp_derf2_glb_mul_hh_tab.v_lonstart, const_nafp_derf2_glb_mul_hh_tab.v_ele_code, const_nafp_derf2_glb_mul_hh_tab.v_data, const_nafp_derf2_glb_mul_hh_tab.geom
	                                             Index Cond: ((const_nafp_derf2_glb_mul_hh_tab.d_datetime >= '1984060620'::numeric) AND (const_nafp_derf2_glb_mul_hh_tab.d_datetime <= '1984060620'::numeric) AND (const_nafp_derf2_glb_mul_hh_tab.v_ele_code = 'h500'::bpchar) AND (const_nafp_derf2_glb_mul_hh_tab.d_foretime >= '19840607'::numeric) AND (const_nafp_derf2_glb_mul_hh_tab.d_foretime <= '19840717'::numeric))
	                                             Filter: (const_nafp_derf2_glb_mul_hh_tab.const_type = 1)
	                               Planning time: 3.355 ms
	                               Execution time: 431.005 ms
	 Planning time: 0.000 ms
	 Execution time: 534.538 ms
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=192.168.80.145 port=5432 dbname=babj_pgdb
	         ->  Aggregate  (cost=72.06..72.07 rows=1 width=32) (actual time=13.289..13.290 rows=1 loops=1)
	               Output: st_gridasnetcdf(st_grid_average((st_grid_average(intermediate_result.v_data))), 'h500'::cstring)
	               ->  HashAggregate  (cost=67.06..69.56 rows=200 width=64) (actual time=6.390..6.392 rows=1 loops=1)
	                     Output: st_grid_average(intermediate_result.v_data), intermediate_result."time"
	                     Group Key: intermediate_result."time"
	                     ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..49.44 rows=3523 width=64) (actual time=0.163..0.165 rows=1 loops=1)
	                           Output: intermediate_result.v_data, intermediate_result."time"
	                           Function Call: read_intermediate_result('8_1'::text, 'binary'::citus_copy_format)
	             Planning time: 0.095 ms
	             Execution time: 13.347 ms
	 Planning time: 1.365 ms
	 Execution time: 1339.405 ms
	(50 行记录)
		
		
	```
- ## C 分析
	执行过程类似query3
	- 单表查询
	- 扫描列 v_data, d_datetime, d_foretime
	- 筛选列
		1. v_ele_code 等值判断
		2. d_datetime 所属区间判断
		3. 两个不同时间段的查询结果 等值连接
		4. 结果汇总分组
- ## D 影响

# query12
- ## query
	```sql
	SELECT st_gridasnetcdf(st_grid_average(d.v_data ),'tmp') AS netcdf  
	FROM  
	(  
	SELECT st_grid_average(d.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_average(c.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_sub_grid(a.V_DATA,b.V_DATA) AS v_data  
	,a.time  
	,a.validTime  
	FROM  
	(  
	SELECT st_grid_sub_value( NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA ,273.15) AS V_DATA  
	,NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	FROM NAFP_DERF2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'tmp'  
	AND ( ( NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 2022060620 AND NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 2022060620 ) )  
	AND ( ( NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 20220607 AND NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 20220717 ) )  
	) AS a, (  
	SELECT st_grid_sub_value( CONST_NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA ,273.15) AS V_DATA  
	,CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	FROM CONST_NAFP_DERF2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'tmp'  
	AND const_type = 1  
	AND ( ( CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 1984060620 AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 1984060620 ) )  
	AND ( ( CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 19840607 AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 19840717 ) )) AS b  
	WHERE a.time%1000000 = b.time%1000000  
	AND a.validTime%10000 = b.validTime%10000  
	) AS c  
	GROUP BY time  
	) AS d  
	GROUP BY time  
	) AS d
	```
- ## 分析
	- 执行过程同query11，最下层扫描，结果处理函数不一样，分布式表可以进一步优化性能
# query13
- ## A query
	```sql
	SELECT st_gridasnetcdf(st_grid_average(d.v_data ),'slp') AS netcdf  
	FROM  
	(  
	SELECT st_grid_average(d.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_average(c.v_data ) AS v_data  
	,time  
	FROM  
	(  
	SELECT st_grid_sub_grid(a.V_DATA,b.V_DATA) AS v_data  
	,a.time  
	,a.validTime  
	FROM  
	(  
	SELECT st_grid_multi_value( NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA ,0.01) AS V_DATA  
	,NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	FROM NAFP_DERF2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'slp'  
	AND ( ( NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 2022072220 AND NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 2022072220 ) )  
	AND ( ( NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 20220723 AND NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 20220901 ) )  
	) AS a, (  
	SELECT st_grid_multi_value( CONST_NAFP_DERF2_GLB_MUL_HH_TAB.V_DATA ,0.01) AS V_DATA  
	,CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_DATETIME AS time  
	,CONST_NAFP_DERF2_GLB_MUL_HH_TAB.D_FORETIME AS validTime  
	FROM CONST_NAFP_DERF2_GLB_MUL_HH_TAB  
	WHERE v_ele_code = 'slp'  
	AND const_type = 1  
	AND ( ( CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime >= 1984072220 AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_datetime <= 1984072220 ) )  
	AND ( ( CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime >= 19840723 AND CONST_NAFP_DERF2_GLB_MUL_HH_TAB.d_foretime <= 19840901 ) )) AS b  
	WHERE a.time%1000000 = b.time%1000000  
	AND a.validTime%10000 = b.validTime%10000  
	) AS c  
	GROUP BY time  
	) AS d  
	GROUP BY time  
	) AS d
	```
- ## 分析
	- 执行过程同query12