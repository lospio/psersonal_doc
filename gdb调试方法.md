- gdb attach pid
	```shell
	psql -U postgres -h shiva04 -p 5432 -d ads
	ps -efw
	gdb attach $pid
	#执行sql
	#gdb上出现segment fault 
	gdb$ bt
	``` 
- gdb {可执行程序postgres}
	```shll
	gdb postgres
	run -D $PGDATA
	##执行正常操作
	```
- gdb执行shell 进入gdb后，命令前加shell
- gdb 设置执行程序参数
	1. gdb --args
		```shell
		gdb --args ./a.out a b c
		```
	2. gdb 里面设置
		```shell
		(gdb) set args a b c
		(gdb) show args
		```