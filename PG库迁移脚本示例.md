## 导出
1. 导出定义语句，存入out.ddl
	```shell
	pg_dump [connection_option] --quote-all-identifiers -C -s -F p  [database] > ddl.out
	```
2.  修改out.ddl
	a. 替换ddl.out中的database名称(默认为postgres)为新库的名称.
3. 导出数据
	```shell
	pg_dump [connection_option]  --quote-all-identifiers -a -F d   [database] -f [outdir]
	```
## 导入
1. 创建数据库，导入表定义
	```shell
	psql [connection_option] -f ddl.out
	```
2. 拓展为分布式表格
	- 指定shard_count
		```sql
		set citus.count = [num]
		```
	- 指定分布式列，创建分布式表
		```sql
		SELECT create_distributed_table('table_name','distributed_column')
		```
3. 导入数据
	```sql
	pg_restore [connection coptions] -F d  -a -d [database] [datadirs]
	```
4. ANALYZE当前库
	```psql
	psql -d [database] -c "analyze";
	```