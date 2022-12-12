## 需求
- 空间查询：
	- 北京区域某个时间的小时数据。
		```sql
		select * from xugu.SURF_WEA_CHN_MUL_HOR_TAB t1,
		MV_STATION_INFO t2, area where t1.v01301=t2.v01301 and t2.netcode=’01’ 
		and t1.d_datetime=’2022-01-17’
		and ST_Within(t2.point,area.shap)=true and area.name=’北京’;
		```
	
	- 查询海河流域5公里范围内某个时间段的小时数据。
		```sql
		select * from xugu.SURF_WEA_CHN_MUL_HOR_TAB t1,
		MV_STATION_INFO t2 where t1.v01301=t2.v01301 and t2.netcode=’地面’ 
		and t1.d_datetime>’2022-01-17 ’ and  t1.d_datetime<=’2022-01-17 03:00:00’
		and ST_DWithin(t2.point,ST_Transform((select geom from river where river.name=‘海河’),3857),5)) ;
		```
## 仿真测试
- 北京区域某个时间的小时数据。
	```sql
	select * from gf_surf_wea_chn_mul_hor_tab_1 t1,
	MV_STATION_INFO_2 t2, china_city area where t1.v01301=t2.v01301 and
	t2.netcode='0001'
	and t1.d_datetime='2021-12-10 09:00:00'
	and ST_Within(
	t2.point,
	ST_Transform
	(area.geom,4326)
	)=true and area.city_name='北京城区';
	```
- 查询海河流域5公里范围内某个时间段的小时数据。
	```sql
	select t1.* from gf_surf_wea_chn_mul_hor_tab_1 t1,MV_STATION_INFO_2 t2
	where t1.v01301=t2.v01301 and t2.netcode= '0001'
	and t1.D_DATETIME > '2022-01-17 23:00:00' and t1.D_DATETIME <= '2022-01-18 00:00:00'
	and
	ST_DWithin(
	t2.point,
	ST_Transform
	((select geom from china_river where
	china_river.nam='HAI HE'),4326),5);
	```