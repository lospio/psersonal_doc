- pg_dump工具
	- 恢复数据
		- psql 执行pg_dump导出文件
			- `<` 重定向
			- option `-f` 指定执行文件
			- 变量ON_ERROR_STOP,遇到错误停止执行
				```sql
				psql --set ON_ERROR_STOP=on _`dbname`_ < _`dumpfile`_
				```
		- pg_restore
	- pg_dump
		- 单个database
		- 单个表
		- 需要创建database
			>The database _`dbname`_ will not be created by this command, so you must create it yourself from `template0` before executing psql
		
	- pg_dumpall
		- cluster