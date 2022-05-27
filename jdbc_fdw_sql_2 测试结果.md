- 第一次
	```bash
	transaction type: ./test_sql_2.sql
	scaling factor: 500
	query mode: simple
	number of clients: 128
	number of threads: 128
	duration: 300 s
	number of transactions actually processed: 5092
	latency average = 7635.004 ms
	tps = 16.764890 (including connections establishing)
	tps = 16.767102 (excluding connections establishing)
	```
- 第二次
	```bash
	transaction type: ./test_sql_2.sql
	scaling factor: 500
	query mode: simple
	number of clients: 128
	number of threads: 128
	duration: 300 s
	number of transactions actually processed: 4886
	latency average = 7964.678 ms
	tps = 16.070957 (including connections establishing)
	tps = 16.074616 (excluding connections establishing)
	```
- 第三次
	```bash
	transaction type: ./test_sql_2.sql
	scaling factor: 500
	query mode: simple
	number of clients: 128
	number of threads: 128
	duration: 300 s
	number of transactions actually processed: 4894
	latency average = 7954.411 ms
	tps = 16.091701 (including connections establishing)
	tps = 16.095855 (excluding connections establishing)
	```