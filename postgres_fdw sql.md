## 操作sql
```sql
create server pg_server foreign data wrapper postgres_fdw options( host '172.18.130.28' , port '5432', dbname 'postgres');
```
```sql
create user mapping for current_user server pg_server options(user 'postgres', password '123');
```
```sql
CREATE foreign table pf_tt (

 D_RETAIN_ID VARCHAR(200),

 D_DATA_ID VARCHAR(30) NOT NULL,

 D_IYMDHM timestamp DEFAULT CURRENT_TIMESTAMP,

 D_RYMDHM timestamp NOT NULL,

 D_UPDATE_TIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

 D_DATETIME timestamp NOT NULL,

 V_BBB VARCHAR(3) NOT NULL,

 V01301 VARCHAR(9) NOT NULL,

 V05001 DECIMAL(10,4) NOT NULL,

 V06001 DECIMAL(10,4) NOT NULL,

 V07001 DECIMAL(10,4),

 V02175 DECIMAL(10,4),

 V07032_03 DECIMAL(10,4),

 V08010 DECIMAL(10,4),

 V02001 DECIMAL(6,0),

 V02301 DECIMAL(6,0),

 V_ACODE DECIMAL(6,0),

 V04001 DECIMAL(4,0) NOT NULL,

 V04002 DECIMAL(2,0) NOT NULL,

 V04003 DECIMAL(2,0) NOT NULL,

 V04004 DECIMAL(2,0) NOT NULL,

 V04005 DECIMAL(2,0) NOT NULL,

 V13011 DECIMAL(10,4) NOT NULL,

 Q13011 DECIMAL(1,0),

 D_SOURCE_ID VARCHAR(100) NOT NULL

) server pg_server options(table_name 'tt');

```
---
## pgbench script
```bash
\set nbranches :scale
\set ntellers 10* :scale
\set naccounts 100000 * :scale
\set aid random(1, :naccounts)
\set bid random(1, :nbranches)
\set tid random(1, :ntellers)
\set dekta random(-5000, 5000)
BEGIN;
	select * from pf_tt t1,MV_STATION_INFO t2 
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
---
## 安装
```bash
/bin/mkdir -p '/usr/lib/spatial/postgresql-10/lib'
/bin/mkdir -p '/usr/lib/spatial/postgresql-10/share/extension'
/bin/mkdir -p '/usr/lib/spatial/postgresql-10/share/extension'
/bin/install -c -m 755  postgres_fdw.so '/usr/lib/spatial/postgresql-10/lib/postgres_fdw.so'
/bin/install -c -m 644 ./postgres_fdw.control '/usr/lib/spatial/postgresql-10/share/extension/'
/bin/install -c -m 644 ./postgres_fdw--1.0.sql  '/usr/lib/spatial/postgresql-10/share/extension/'

```