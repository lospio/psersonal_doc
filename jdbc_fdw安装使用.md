# 1. 部署
```bash
cp JDBCDriverLoader.class {pg_dir}/lib
cp *.class {pg_dir}/lib
cp JDBCUtils.class {pg_dir}/lib
/bin/mkdir -p {pg_dir}/lib
/bin/mkdir -p {pg_dir}/share/extension
/bin/install -c -m 755 jdbc_fdw.so {pg_dir}/lib/jdbc_fdw.so
/bin/install -c -m 644 jdbc_fdw.control {pg_dir}/share/extension/
/bin/install -c -m 644 jdbc_fdw--1.0.sql {pg_dir}/share/extension/
```
# 2. 配置
```bash
# 将jdbc驱动jar包放入classpath环境变量下
```
# 3. 使用
## 1. 创建jdbc_fdw,server,user mapping
```sql
CREATE EXTENSION jdbc_fdw;
```
## 2. 创建 Server，按照实际修改参数，url,jarfile
```sql
-- 按照实际情况修改url，jarfile,
CREATE SERVER  gbase_server1 FOREIGN DATA WRAPPER jdbc_fdw OPTIONS(
drivername 'com.gbase.jdbc.Driver',
url 'jdbc:gbase://172.18.130.28:5258/test',
querytimeout '100',
jarfile '/share/lib/gbase-connector-java-8.3.81.53-build55.4.1-bin.jar',
maxheapsize '6000'
);
```
## 3. 创建user mapping
```
-- 按照实际修改
CREATE USER MAPPING FOR CURRENT_USER SERVER gbase_server1 OPTIONS(username 'root',password '123');
```
## 4. 创建外表，表定义需要跟gbase保持一致
```sql
CREATE foreign table gf_tt (

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
-- 修改server名称和对应的外部表格名称
) server gbase_server1 options(table_name 'SURF_WEA_CHN_MUL_HOR_TAB');

```