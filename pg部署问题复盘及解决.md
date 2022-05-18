1. 替换postgres可执行文件后，patroni重启节点报错
	- 关注postgres文件调用的动态链接库是否正常，`ldd postgres'
		- 一般缺少libicuxxx.so
	- 缺少libpq.so
		- 添加环境变量 LD_LIBRARY_PATH=/{postgresql_dir}/lib
2. patronictl restart报错
	1. 查看pg日志报错信息
	2. 查看patroni日志报错信息
	3. 如果没有相应的信息，可以手动运行`patroni .yml` 或者手动运行pg