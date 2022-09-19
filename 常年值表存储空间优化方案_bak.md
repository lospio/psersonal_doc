---
ctime: 2022-08-04 17:27
tags: simlpe card
author: lche
alias: 
---
todo
- [ ] nafp_cfsv2_glb_mul_hh_tab shards == 3?
- [ ] test 单机表的计划
- [ ] surf_bcccpsv3_glb_mul_hh_tab大小? 谁来创建? 能否设计成复制表.
- [ ] 常年值表符合查询条件的tuple个数?
# 01: 背景
## 问题: 常年值表占用存储空间大
常年值表当前设计为复制表, 在每个Worker节点中保存一份表的完整数据.
当前集群Worker节点存储空间约为11T. 实际已使用空间中, 常年值表占用了多数存储空间.常年值表大小统计:
| 常年值表                           | 大小(GB) |
| ---------------------------------- | -------- |
| const_surf_bcccpsv3_glb_mul_hh_tab | 4552     |
| const_nafp_cfsv2_glb_mul_hh_tab    | 1368     |
|       const_nafp_derf2_glb_mul_hh_tab                             |  448        |
## 常年值表关联查询分析
在优化前首先分析常年值表关联的查询.
#### CONST_NAFP_CFSV2_GLB_MUL_HH_TAB查询模式
- 查询模式
	依据简巨给出的查询, CONST_NAFP_CFSV2_GLB_MUL_HH_TAB关联的大多数查询(仅考虑底层join)匹配到如下模式:
	- `a join b on a.time%1000000 = b.time%1000000 AND a.validTime%10000 = b.validTime%10000 AND a.ensNo = b.ensNo`
	- 详细SQL:
	
		```sql
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
		
		WHERE v_ele_code = 'h500'
		
		AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_datetime >= 2022060620 AND nafp_cfsv2_glb_mul_hh_tab.d_datetime <= 2022060620 ) )
		
		AND ( ( nafp_cfsv2_glb_mul_hh_tab.d_foretime >= 20220607 AND nafp_cfsv2_glb_mul_hh_tab.d_foretime <= 20220717 ) )
		
		AND ( ( nafp_cfsv2_glb_mul_hh_tab.V_EVN >= -1 AND nafp_cfsv2_glb_mul_hh_tab.V_EVN <= -1 ) )
		
		) AS a, (
		
		SELECT CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_DATA AS V_DATA
		
		,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_DATETIME AS time
		
		,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.D_FORETIME AS validTime
		
		,CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN AS ensNo
		
		FROM CONST_NAFP_CFSV2_GLB_MUL_HH_TAB
		
		WHERE v_ele_code = 'h500'
		
		AND const_type = 1
		
		AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime >= 1984060620 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_datetime <= 1984060620 ) )
		
		AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime >= 19840607 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.d_foretime <= 19840717 ) )
		
		AND ( ( CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN >= -1 AND CONST_NAFP_CFSV2_GLB_MUL_HH_TAB.V_EVN <= -1 ) )) AS b
		
		WHERE a.time%1000000 = b.time%1000000
		
		AND a.validTime%10000 = b.validTime%10000
		
		AND a.ensNo = b.ensNo
		```

查询中关联的表:
| 表名称                          | 大小(GB) | 属性   |
| ------------------------------- | -------- | ------ |
| CONST_NAFP_CFSV2_GLB_MUL_HH_TAB | 1368     | 复制表 |
|              nafp_cfsv2_glb_mul_hh_tab                   |     675     |    分布式表    |
- 查询计划分析. 
	Join可以下推到Worker并行执行, 无需数据重分布, 查询性能好. 查询计划:
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
	```

综合上述查询和业务情况, 有如下结论:
- 目前给出的查询SQL主要是表`const_nafp_cfsv2_glb_mul_hh_tab`关联的查询、后述的查询分析都基于该表.
- `const_surf_bcccpsv3_glb_mul_hh_tab`业务尚未上线, 查询模式与`const_nafp_cfsv2_glb_mul_hh_tab`一致, 对后者的优化同样适用于前者.
# 02: 目标
空间最优和性能最优不能兼得, 只能在两者之间找一个平衡点.
优化前的表结构是一个查询性能优的方案, 采用空间换性能的策略,如果在此基础上优化空间,性能会有下降.
**本方案目标是在可接受的查询性能下降范围内, 降低常年值存储空间占用.**

**基本策略:优先降低存储占用空间最高的表.**
# 03: 详细方案
## const_nafp_cfsv2_glb_mul_hh_tab 优化方案
#### 基本方案
- 方法
	将复制表const_nafp_cfsv2_glb_mul_hh_tab重构为分布式表.
- 约束
	- 要求表`const_surf_bcccpsv2_glb_mul_hh_tab`在重构期间不能修改数据.
- 效果
	单个worker存储空间:

| 优化前 | 优化后 |
| :----: | :----: |
| 1368G  |  80GB  |
- 影响(风险点)
	- `const_nafp_cfsv2_glb_mul_hh_tab`相关的查询业务(已上线)性能下降.下降程度与查询中`const_nafp_cfsv2_glb_mul_hh_tab`表需要重分布的数据量正相关.
	- 具体的性能损失需重构后进一步benchmark测试, 对比重构前后结果.

#### 备选方案
上文描述了1个基本方案, 下文描述2个备选方案. 备选方案是对其他可能方案的探索, 综合考量基本方案优于备选方案, 备选方案仅供参考.
1. const_nafp_cfsv2_glb_mul_hh_tab重构为分布式表,  nafp_cfsv2_glb_mul_hh_tab重构为复制表.
	- 效果
		- 减少一部分空间占用、查询性能影响小.
	- 影响(风险点)
		- nafp_cfsv2_glb_mul_hh_tab表已经比较大(650G),  整体空间优化收益一般.
		- nafp_cfsv2_glb_mul_hh_tab表持续有数据更新, 重构要求操作期间停止写业务.
2. const_nafp_cfsv2_glb_mul_hh_tab重构为单机表(CN上).
	- 效果
		- 减少基本方案中, 数据重分布时的数据汇总代价.
	- 影响(风险点)
		- CN增加1368G数据存储.
		- CN成为热点.

#### 结论
上文列举了1个基本方案和2个备选方案, 3个方案在优化存储、性能方面各有优劣和风险.
基于如下原因==不建议对const_nafp_cfsv2_glb_mul_hh_tab表进行空间优化==:
1. 单worker优化空间收益不高.
2. 重构已上线业务基表风险高(查询性能下降).

## const_surf_bcccpsv3_glb_mul_hh_tab 优化方案
const_surf_bcccpsv3_glb_mul_hh_tab表分布、查询模式与const_nafp_cfsv2_glb_mul_hh_tab表基本一致, 优化思路基本一致.
#### 基本方案
- 方法
	重构const_surf_bcccpsv3_glb_mul_hh_tab为分布式表.
- 约束
	- const_surf_bcccpsv3_glb_mul_hh_tab在重构期间不能修改数据.
- 效果
| 优化前 | 优化后 |
| :----: | :----: |
| 4552G  |  267GB  |
- 影响(风险点)
	- `const_surf_bcccpsv3_glb_mul_hh_tab`相关的查询业务(已上线)性能下降.下降程度与查询中`const_surf_bcccpsv3_glb_mul_hh_tab`表需要重分布的数据量正相关.
#### 备选方案
备选方案类似const_nafp_cfsv2_glb_mul_hh_tab表, 不再详述.

#### 总结
- 
# 04: 实施计划
从业务改造风险角度考虑, 现阶段建议仅优化const_surf_bcccpsv3_glb_mul_hh_tab表.

## const_surf_bcccpsv3_glb_mul_hh_tab优化实施
#### 计划
1. 测试方案, 评估可行性, 重点评估性能下降程度.
2. 实施方案.
#### 实施步骤
1. 准备工作
	- [ ] 备份表const_surf_bcccpsv3_glb_mul_hh_tab数据到nas.
	- [ ] 确认各节点存储空间.
	- [ ] 估算重分布是否会使单个节点disk full.

1. 创建一个原表的分布式备份表.
	- 定义分布式dist_const_surf_bcccpsv3_glb_mul_hh_tab.
		- 选择分布列.
	- `copy dist_const_surf_bcccpsv3_glb_mul_hh_tab from nas`.
	- 比较数据量. 分布式表、与复制表.
2. test sql
	- 在原表表上测试查询.
	- 在分布式备份表上测试查询.
	- 对比查询性能.
3. switch name




