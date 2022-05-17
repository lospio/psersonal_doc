1. 安装

	```shell
	yum install -y ant
	wget https://udomain.dl.sourceforge.net/project/benchmarksql/benchmarksql-5.0.zip
	unzip benchmarksql-5.0.zip
	```
2. 创建测试数据库
	```sql
	create database tpcc;
	create user tpcc superuser password 'tpcc';
	```
3. 执行ant
	```shell
	#自行修改路径
	cd {BenchmarkSqlDir}
	ant
	```
4. 修改配置文件
	```shell
	cp props.pg my_postgres.properties
	vi my_postgres.properties
	```
	参照下列文件做相应修改
	- 修改数据库连接属性
	- **修改osCollectorDevices，网卡信息查看 `ip a`**
	- 修改测试参数
		```shell
		db=postgres
		driver=org.postgresql.Driver
		conn=jdbc:postgresql://localhost:5432/tpcc
		user=tpcc
		password=tpcc

		warehouses=10
		loadWorkers=4

		terminals=35
		//To run specified transactions per terminal- runMins must equal zero
		runTxnsPerTerminal=0
		//To run for specified minutes- runTxnsPerTerminal must equal zero
		runMins=3
		//Number of total transactions per minute
		limitTxnsPerMin=300
	
		//Set to true to run in 4.x compatible mode. Set to false to use the
		//entire configured database evenly.
		terminalWarehouseFixed=true
	
		//The following five values must add up to 100
		//The default percentages of 45, 43, 4, 4 & 4 match the TPC-C spec
		newOrderWeight=45
		paymentWeight=43
		orderStatusWeight=4
		deliveryWeight=4
		stockLevelWeight=4

		// Directory name to create for collecting detailed result data.
		// Comment this out to suppress.
		resultDirectory=my_result_%tY-%tm-%td_%tH%tM%tS
		osCollectorScript=./misc/os_collector_linux.py
		osCollectorInterval=1
		//osCollectorSSHAddr=user@dbhost
		osCollectorDevices=net_ens33 blk_sda
		```
	| 参数 | 说明|
	| --- | ---|
	|db| 数据库名称，可在安装目录lib下创建文件夹，里面放置jdbc|
	|conn| 表示数据库连接信息 jdbc:postgresql://[host]/[dbname]|
	|user|用户|
	|password|密码|
	|warehouses|初始化加载数据时，需要创建多少仓库的数据。例如输入100，则创建100仓库数据，每一个数据仓库的数据量大概是 76823.04KB，可有少量的上下浮动，因为测试过程中将会插入或删除现有记录|
	|loadworker|表示加载数据时，每次提交进程数。|
	|terminals|终端数量，指同时有多少终端并发执行，表示并发程度。|
	|runTxnsPerTerminal|每分钟每个终端执行的事务数。|
	|runMins|执行多少分钟。|
	|limitTnxsPermin|每分钟执行的事务总数。|
	|terminalWarehouseFixed|用于指定终端和仓库的绑定模式，设置为true时可以运行4.x兼容模式，意思为每个终端都有一个固定的仓库。设置为false时可以均匀的使用数据库整体配置。|
	>![](https://res-img3.huaweicloud.com/content/dam/cloudbu-site/archive/china/zh-cn/support/resource/framework/v3/images/support-doc-new-note.svg)说明：
	runMins和runTxnsPerTerminal这两个参数指定了两种运行方式，前者是按照指定运行时间执行，以时间为标准；后者以指定每个终端的事务数为标准执行。两者不能同时生效，必须有一个设定为0。
1. 生成数据，执行测试
	```shell
	cd {BenchmarkSQLDir}/run
	chmod 777 *.sh
	./runDatabaseBuild.sh my_postgres.properties
	./runBenchmark.sh my_postgres.properties
	./runDatabaseDestroy.sh my_postgres.propertiess
	```
6. 参考文档
	[华为云](https://support.huaweicloud.com/tstg-kunpengdbs/kunpengbenchmarksql_06_0005.html)
	