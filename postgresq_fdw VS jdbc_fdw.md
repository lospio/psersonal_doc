- jdbc_fdw
	1. 第一次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./test_sql_2.sql -h localhost -p 5430 -U postgres
		transaction type: ./test_sql_2.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 108630
		latency average = 354.750 ms
		tps = 360.817478 (including connections establishing)
		tps = 360.874034 (excluding connections establishing)
		
		```
	1. 第二次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./test_sql_2.sql -h localhost -p 5430 -U postgres
		transaction type: ./test_sql_2.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 105822
		latency average = 363.998 ms
		tps = 351.650199 (including connections establishing)
		tps = 351.690993 (excluding connections establishing)
		
		```
	1. 第三次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./test_sql_2.sql -h localhost -p 5430 -U postgres
		transaction type: ./test_sql_2.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 106863
		latency average = 360.612 ms
		tps = 354.952080 (including connections establishing)
		tps = 354.998093 (excluding connections establishing)
		```

---
- postgres_fdw
	1. 第一次
		```shell
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: ./postgres_fdw_test.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 105339
		latency average = 364.869 ms
		tps = 350.810887 (including connections establishing)
		tps = 350.868976 (excluding connections establishing)
		```
	2. 第二次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: ./postgres_fdw_test.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 107121
		latency average = 359.981 ms
		tps = 355.573859 (including connections establishing)
		tps = 355.629090 (excluding connections establishing)
		
		```
	3. 第三次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: ./postgres_fdw_test.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 106032
		latency average = 363.326 ms
		tps = 352.300409 (including connections establishing)
		tps = 352.333643 (excluding connections establishing)
		
		```
---
- local
	1. 第一次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./local_test.sql -h localhost -p 5430 -U postgres
		transaction type: ./local_test.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 149543
		latency average = 256.941 ms
		tps = 498.168114 (including connections establishing)
		tps = 498.219185 (excluding connections establishing)
		```
	2. 第二次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./local_test.sql -h localhost -p 5430 -U postgres
		transaction type: ./local_test.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 149723
		latency average = 256.633 ms
		tps = 498.766203 (including connections establishing)
		tps = 498.815206 (excluding connections establishing)

		```
	3. 第三次
		```bash
		pgbench -c 128 -j 1024 -n -s 500 -T 300 -f ./local_test.sql -h localhost -p 5430 -U postgres
		transaction type: ./local_test.sql
		scaling factor: 500
		query mode: simple
		number of clients: 128
		number of threads: 128
		duration: 300 s
		number of transactions actually processed: 149999
		latency average = 256.151 ms
		tps = 499.705966 (including connections establishing)
		tps = 499.747125 (excluding connections establishing)

		```