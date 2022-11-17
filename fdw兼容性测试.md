# cassandra
#### cassandra2-fdw
#### 安装cassandra-cpp-dirver
1. [libuv](https://downloads.datastax.com/cpp-driver//centos/7/dependencies/libuv/v1.35.0/)
2. [dirver](https://downloads.datastax.com/cpp-driver/)
3. `yum localinstall libuv cassandra-cpp-driver cassandra-cpp-driver-devel cassandra-cpp-driver-debuginfo`

#### 安装cassandra2_fdw
1. `git clone https://github.com/jaiminpan/cassandra2_fdw`
2. `cd cassandra2_fdw`
3. `USE_PGXS=1 make`
4. `sudo USE_PGXS=1 make install`

#### 部署cassandra2_fdw
1. 解压文件
2. `yum localinstall libuv cassandra-cpp-driver cassandra-cpp-driver-devel cassandra-cpp-driver-debuginfo`
3. 安装，**路径如需修改，需要重新编译**
```bash
/usr/bin/mkdir -p '/usr/pgsql-10-debug/lib'
/usr/bin/mkdir -p '/usr/pgsql-10-debug/share/extension'
/usr/bin/mkdir -p '/usr/pgsql-10-debug/share/extension'
/usr/bin/install -c -m 755  cassandra2_fdw.so '/usr/pgsql-10-debug/lib/cassandra2_fdw.so'
/usr/bin/install -c -m 644 .//cassandra2_fdw.control '/usr/pgsql-10-debug/share/extension/'
/usr/bin/install -c -m 644 .//cassandra2_fdw--2.0.sql  '/usr/pgsql-10-debug/share/extension/'

```

#### 使用 
```sql
	-- Create the extension inside a database
	CREATE EXTENSION cassandra2_fdw;

	-- Create the server object
	CREATE SERVER cass_serv FOREIGN DATA WRAPPER cassandra2_fdw 
		OPTIONS(host '127.0.0.1,127.0.0.2', port '9042', protocol '2');

	-- Create a user mapping for the server
	CREATE USER MAPPING FOR public SERVER cass_serv OPTIONS(username 'test', password 'test');


	-- Create a foreign table on the server
	CREATE FOREIGN TABLE test (id int) SERVER cass_serv OPTIONS (schema_name 'example', table_name 'order');

	-- Query the foreign table
	SELECT * FROM test limit 5;
```
