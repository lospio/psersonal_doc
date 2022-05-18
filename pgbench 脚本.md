```sql
\set nbranches :scale
\set ntellers 10* :scale
\set naccounts 100000 * :scale
\set aid random(1, :naccounts)
\set bid random(1, :nbranches)
\set tid random(1, :ntellers)
\set dekta random(-5000, 5000)
BEGIN;
	select * from gf_tt t1,MV_STATION_INFO t2 
	where t1.v01301=t2.v01301 and t2.netcode= '1'
	and t1.d_datetime> '2022-01-17'
	and t1.d_datetime <= '2023-01-17 03:00:00'
	and 
	ST_DWithin(
				t2.point,
				ST_Transform
				((select geom from china_river where china_river.nam='HAI HE'),4326),5);
END;
```

```bash
pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./test_sql_2.sql -h localhost -p 5431 -U postgres
```