## local
- 第一次
	```bash
	pgbench -c 1 -j 1 -n -s 100 -T 300 -f local_test.sql -h localhost -p 5430 -U postgres
	transaction type: local_test.sql
	scaling factor: 100
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 11043
	latency average = 27.167 ms
	tps = 36.809501 (including connections establishing)
	tps = 36.809848 (excluding connections establishing)
	```
- 第二次
	```bash
	pgbench -c 1 -j 1 -n -s 100 -T 300 -f local_test.sql -h localhost -p 5430 -U postgres
	transaction type: local_test.sql
	scaling factor: 100
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 11338
	latency average = 26.462 ms
	tps = 37.790494 (including connections establishing)
	tps = 37.790875 (excluding connections establishing)
	```
- 第三次
	```bash
	pgbench -c 1 -j 1 -n -s 100 -T 300 -f local_test.sql -h localhost -p 5430 -U postgres
	transaction type: local_test.sql
	scaling factor: 100
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 11218
	latency average = 26.744 ms
	tps = 37.390894 (including connections establishing)
	tps = 37.391242 (excluding connections establishing)
	```
---
## jdbc_fdw
- 第一次
	```bash
	pgbench -c 1 -j 1 -n -s 100 -T 300 -f test_sql_2.sql -h localhost -p 5430 -U postgres
	transaction type: test_sql_2.sql
	scaling factor: 100
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 5413
	latency average = 55.426 ms
	tps = 18.042141 (including connections establishing)
	tps = 18.042317 (excluding connections establishing)
	```
- 第二次
	```bash
	pgbench -c 1 -j 1 -n -s 100 -T 300 -f test_sql_2.sql -h localhost -p 5430 -U postgres
	transaction type: test_sql_2.sql
	scaling factor: 100
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 2717
	latency average = 110.425 ms
	tps = 9.055884 (including connections establishing)-f 
	tps = 9.055964 (excluding connections establishing)
	```
- 第三次
	```bash
	pgbench -c 1 -j 1 -n -T 300 -f test_sql_2.sql -h localhost -p 5430 -U postgres
	transaction type: test_sql_2.sql
	scaling factor: 1
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 3709
	latency average = 80.906 ms
	tps = 12.360070 (including connections establishing)
	tps = 12.360178 (excluding connections establishing)
	```
- 第四次
	```bash
	pgbench -c 1 -j 1 -n -T 300 -f test_sql_2.sql -h localhost -p 5430 -U postgres
	transaction type: test_sql_2.sql
	scaling factor: 1
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 2274
	latency average = 131.984 ms
	tps = 7.576697 (including connections establishing)
	tps = 7.576765 (excluding connections establishing)
	```
- 第五次
	```bash
	pgbench -c 1 -j 1 -n -T 300 -f test_sql_2.sql -h localhost -p 5430 -U postgres
	client 0 aborted in command 8 of script 0; ERROR:  remote server returned an error
	
	transaction type: test_sql_2.sql
	scaling factor: 1
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 5706
	latency average = 51.367 ms
	tps = 19.467579 (including connections establishing)
	tps = 19.467764 (excluding connections establishing)
	```
- 第六次
	```bash
	pgbench -c 1 -j 1 -n -T 300 -f test_sql_2.sql -h localhost -p 5430 -U postgres
	transaction type: test_sql_2.sql
	scaling factor: 1
	query mode: simple
	number of clients: 1
	number of threads: 1
	duration: 300 s
	number of transactions actually processed: 5668
	latency average = 53.336 ms
	tps = 18.749051 (including connections establishing)
	tps = 18.749208 (excluding connections establishing)
	```
---

## postgres_fdw
- 本地pg
	- 第一次
		```bash
		 pgbench -c 1 -j 1 -n -s 100 -T 300 -f postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: postgres_fdw_test.sql
		scaling factor: 100
		query mode: simple
		number of clients: 1
		number of threads: 1
		duration: 300 s
		number of transactions actually processed: 10612
		latency average = 28.270 ms
		tps = 35.373131 (including connections establishing)
		tps = 35.373469 (excluding connections establishing)
		```
	- 第二次
		```bash
		pgbench -c 1 -j 1 -n -T 300 -f postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: postgres_fdw_test.sql
		scaling factor: 1
		query mode: simple
		number of clients: 1
		number of threads: 1
		duration: 300 s
		number of transactions actually processed: 10219
		latency average = 29.358 ms
		tps = 34.062320 (including connections establishing)
		tps = 34.062639 (excluding connections establishing)
		```
	- 第三次
		```bash
		pgbench -c 1 -j 1 -n -T 300 -f postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: postgres_fdw_test.sql
		scaling factor: 1
		query mode: simple
		number of clients: 1
		number of threads: 1
		duration: 300 s
		number of transactions actually processed: 10061
		latency average = 29.821 ms
		tps = 33.533834 (including connections establishing)
		tps = 33.534152 (excluding connections establishing)
		```
- 远程pg
	- 第一次
		```bash
		pgbench -c 1 -j 1 -n -s 100 -T 300 -f postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: postgres_fdw_test.sql
		scaling factor: 100
		query mode: simple
		number of clients: 1
		number of threads: 1
		duration: 300 s
		number of transactions actually processed: 2266
		latency average = 132.414 ms
		tps = 7.552055 (including connections establishing)
		tps = 7.552125 (excluding connections establishing)
		```
	- 第二次
		```bash
		pgbench -c 1 -j 1 -n -s 100 -T 300 -f postgres_fdw_test.sql -h localhost -p 5430 -U postgres
		transaction type: postgres_fdw_test.sql
		scaling factor: 100
		query mode: simple
		number of clients: 1
		number of threads: 1
		duration: 300 s
		number of transactions actually processed: 4273
		latency average = 70.212 ms
		tps = 14.242539 (including connections establishing)
		tps = 14.242674 (excluding connections establishing)
		```

|latency|local|postgres_fdw|jdbc_fdw|
|--|--|--|--|