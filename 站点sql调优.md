## ddl
```sql
CREATE TABLE t_msis_aws_min_pt(
  station_id_c text ,
  station_name text ,
  prs float ,
  prs_sea float ,
  win_s_gust_max float ,
  win_d_gust_max float ,
  win_d_inst float ,
  win_s_inst float ,
  win_d_avg_1mi float ,
  win_s_avg_1mi float ,
  win_d_avg_2mi float ,
  win_s_avg_2mi float ,
  win_d_avg_10mi float ,
  win_s_avg_10mi float ,
  win_d_s_max float ,
  tem float ,
  dpt float ,
  gst_5cm float ,
  gst_10cm float ,
  gst_15cm float ,
  gst_20cm float ,
  gst_40cm float ,
  gst_80cm float ,
  gst_160cm float ,
  gst_320cm float ,
  gst float ,
  lgst float ,
  rhu float ,
  vap float ,
  snow_depth float ,
  evp_big float ,
  vis_hor_1mi float ,
  vis_hor_10mi float ,
  clo_cov float ,
  clo_height_lom float ,
  datetime timestamp
) partition by range (datetime);

create table t_msis_aws_min_pt_202101 partition of t_msis_aws_min_pt
for values from ('2021-01-01 00:00:00') to ('2021-07-01 00:00:00');


create table t_msis_aws_min_pt_202102 partition of t_msis_aws_min_pt
for values from ('2021-07-01 00:00:00') to ('2022-01-01 00:00:00');


create table t_msis_aws_min_pt_202201 partition of t_msis_aws_min_pt
for values from ('2022-01-01 00:00:00') to ('2022-07-01 00:00:00');


create table t_msis_aws_min_pt_202202 partition of t_msis_aws_min_pt
for values from ('2022-07-01 00:00:00') to ('2023-01-01 00:00:00');

set citus.shard = 3;
select create_distributed_table('t_msis_aws_min_pt', 'station_id_c');

create index idx_t_msis_aws_min_pt_202101_datetime on t_msis_aws_min_pt_202101 using btree(datetime);
create index idx_t_msis_aws_min_pt_202102_datetime on t_msis_aws_min_pt_202102 using btree(datetime);
create index idx_t_msis_aws_min_pt_202201_datetime on t_msis_aws_min_pt_202201 using btree(datetime);
create index idx_t_msis_aws_min_pt_202202_datetime on t_msis_aws_min_pt_202202 using btree(datetime);

create index idx_t_msis_aws_min_pt_202101_station_id_c on t_msis_aws_min_pt_202101 using btree(station_id_c);
create index idx_t_msis_aws_min_pt_202102_station_id_c on t_msis_aws_min_pt_202102 using btree(station_id_c);
create index idx_t_msis_aws_min_pt_202201_station_id_c on t_msis_aws_min_pt_202201 using btree(station_id_c);
create index idx_t_msis_aws_min_pt_202202_station_id_c on t_msis_aws_min_pt_202202 using btree(station_id_c);

```

```sql
CREATE TABLE t_msis_cd_station_ref (
  station_id_c text ,
  station_name text ,
  admin_code_chn text ,
  country text ,
  province text ,
  city text ,
  town text ,
  lat float ,
  lon float ,
  alti numeric(10,4)
)

select create_reference_table('t_msis_cd_station_ref');
```
---
## Query

- q2_3hours
	- sql
		```sql
		select * from t_msis_aws_min_pt where datetime > '2022-02-06 07:00:00' and datetime < '2022-02-06 10:00:00';

		```
	- pgbench
		```bash
		q2-3hour.sql
		scaling factor: 1
		query mode: simple
		number of clients: 1
		number of threads: 1
		duration: 300 s
		number of transactions actually processed: 77
		latency average = 3927.752 ms
		tps = 0.254599 (including connections establishing)
		tps = 0.254604 (excluding connections establishing)
		
		```
	- plan
		```bash
		#q2_3hours
		explain analyze verbose select * from shards60.t_msis_aws_min_pt where datetime > '2022-02-06 07:00:00' and datetime < '2022-02-06 10:00:00';


		                                                                                                                        QUERY PLAN
		
		
		
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------
		 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=1245.079..1277.245 rows=95130 loops=1)
		   Output: remote_scan.station_id_c, remote_scan.station_name, remote_scan.prs, remote_scan.prs_sea, remote_scan.win_s_gust_max, remote_scan.win_d_gust_max, remote_scan.win_d_inst, remote_scan.win_s_inst, r
		emote_scan.win_d_avg_1mi, remote_scan.win_s_avg_1mi, remote_scan.win_d_avg_2mi, remote_scan.win_s_avg_2mi, remote_scan.win_d_avg_10mi, remote_scan.win_s_avg_10mi, remote_scan.win_d_s_max, remote_scan.tem, r
		emote_scan.dpt, remote_scan.gst_5cm, remote_scan.gst_10cm, remote_scan.gst_15cm, remote_scan.gst_20cm, remote_scan.gst_40cm, remote_scan.gst_80cm, remote_scan.gst_160cm, remote_scan.gst_320cm, remote_scan.g
		st, remote_scan.lgst, remote_scan.rhu, remote_scan.vap, remote_scan.snow_depth, remote_scan.evp_big, remote_scan.vis_hor_1mi, remote_scan.vis_hor_10mi, remote_scan.clo_cov, remote_scan.clo_height_lom, remot
		e_scan.datetime
		   Task Count: 60
		   Tasks Shown: One of 60
		   ->  Task
		         Node: host=njqa09 port=15432 dbname=weather_station
		         ->  Append  (cost=4.72..118.45 rows=29 width=289) (actual time=0.382..1.201 rows=1680 loops=1)
		               ->  Bitmap Heap Scan on shards60.t_msis_aws_min_pt_202201_103218 t_msis_aws_min_pt  (cost=4.72..118.45 rows=29 width=289) (actual time=0.381..1.028 rows=1680 loops=1)
		                     Output: t_msis_aws_min_pt.station_id_c, t_msis_aws_min_pt.station_name, t_msis_aws_min_pt.prs, t_msis_aws_min_pt.prs_sea, t_msis_aws_min_pt.win_s_gust_max, t_msis_aws_min_pt.win_d_gust_
		max, t_msis_aws_min_pt.win_d_inst, t_msis_aws_min_pt.win_s_inst, t_msis_aws_min_pt.win_d_avg_1mi, t_msis_aws_min_pt.win_s_avg_1mi, t_msis_aws_min_pt.win_d_avg_2mi, t_msis_aws_min_pt.win_s_avg_2mi, t_msis_aw
		s_min_pt.win_d_avg_10mi, t_msis_aws_min_pt.win_s_avg_10mi, t_msis_aws_min_pt.win_d_s_max, t_msis_aws_min_pt.tem, t_msis_aws_min_pt.dpt, t_msis_aws_min_pt.gst_5cm, t_msis_aws_min_pt.gst_10cm, t_msis_aws_min_
		pt.gst_15cm, t_msis_aws_min_pt.gst_20cm, t_msis_aws_min_pt.gst_40cm, t_msis_aws_min_pt.gst_80cm, t_msis_aws_min_pt.gst_160cm, t_msis_aws_min_pt.gst_320cm, t_msis_aws_min_pt.gst, t_msis_aws_min_pt.lgst, t_ms
		is_aws_min_pt.rhu, t_msis_aws_min_pt.vap, t_msis_aws_min_pt.snow_depth, t_msis_aws_min_pt.evp_big, t_msis_aws_min_pt.vis_hor_1mi, t_msis_aws_min_pt.vis_hor_10mi, t_msis_aws_min_pt.clo_cov, t_msis_aws_min_pt
		.clo_height_lom, t_msis_aws_min_pt.datetime
		                     Recheck Cond: ((t_msis_aws_min_pt.datetime > '2022-02-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt.datetime < '2022-02-06 10:00:00'::timestamp without time zone))
		                     Heap Blocks: exact=122
		                     ->  Bitmap Index Scan on idx_t_msis_aws_min_pt_202201_datetime_103218  (cost=0.00..4.71 rows=29 width=0) (actual time=0.343..0.343 rows=1680 loops=1)
		                           Index Cond: ((t_msis_aws_min_pt.datetime > '2022-02-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt.datetime < '2022-02-06 10:00:00'::timestamp without time zone
		))
		             Planning time: 0.818 ms
		             Execution time: 1.385 ms
		 Planning time: 4.617 ms
		 Execution time: 1289.176 ms
		(17 rows)
		
		Time: 1308.936 ms (00:01.309)

		```
	- 火焰图
		![[q2-3-tune.svg]]
	- 分析点
		- explain 和非explain执行时间差异
			- explain analyze选项会实际执行查询，但是不会显示select 查询返回的结果
			- It's also important to realize that the cost only reflects things that the planner cares about. In particular, the cost does not consider the time spent transmitting result rows to the client, which could be an important factor in the real elapsed time;[链接](https://www.postgresql.org/docs/10/using-explain.html#:~:text=It%27s%20also%20important%20to%20realize%20that%20the%20cost%20only%20reflects%20things%20that%20the%20planner%20cares%20about.%20In%20particular%2C%20the%20cost%20does%20not%20consider%20the%20time%20spent%20transmitting%20result%20rows%20to%20the%20client%2C%20which%20could%20be%20an%20important%20factor%20in%20the%20real%20elapsed%20time%3B)
				- 猜想：将结果推送到client端，消耗时间
				- 实验：测试结果集比较大的query，查看explain和非explain执行时间  
		- `\timing`执行时间  不包括print result
			```cpp
			{
	
				/* Default fetch-it-all-and-print mode */
		
				instr_time  before,
		
							after;
		
		  
		
				if (pset.timing)
		
					INSTR_TIME_SET_CURRENT(before);
		
		  
		
				results = PQexec(pset.db, query);
		
		  
		
				/* these operations are included in the timing result: */
		
				ResetCancelConn();
		
				OK = ProcessResult(&results);
		
		  
		
				if (pset.timing)
		
				{
		
					INSTR_TIME_SET_CURRENT(after);
		
					INSTR_TIME_SUBTRACT(after, before);
		
					elapsed_msec = INSTR_TIME_GET_MILLISEC(after);
		
				}
		
		  
		
				/* but printing results isn't: */
		
				if (OK && results)
		
					OK = PrintQueryResults(results);
		
			}
			```
		- jemeter
			- **Average:**  :  [It's an average response time for a particular http request. This response time is in millisecond, and an average for 5 loops in two iteration for 100 users. Total = Average of total average of samples, means add all averages for all samples and divide by number of samples](https://automation-performance.blogspot.com/2015/08/jmeterunderstanding-summary-report.html#:~:text=%3A%20%C2%A0It%27s%20an%20average%20response%20time%20for%20a%20particular%20http%20request.%20This%20response%20time%20is%20in%20millisecond%2C%20and%20an%20average%20for%205%20loops%20in%20two%20iteration%20for%20100%20users.%20Total%20%3D%20Average%20of%20total%20average%20of%20samples%2C%20means%20add%20all%20averages%20for%20all%20samples%20and%20divide%20by%20number%20of%20samples)
			- [Summary Report](https://jmeter.apache.org/usermanual/component_reference.html#:~:text=%5E-,Summary%20Report,Times%20are%20in%20milliseconds.,-Screenshot%20of%20Control)

				The summary report creates a table row for each differently named request in your test. This is similar to the [Aggregate Report](https://jmeter.apache.org/usermanual/component_reference.html#Summary_Report../usermanual/component_reference.html#Aggregate_Report) , except that it uses less memory.
				
				The throughput is calculated from the point of view of the sampler target (e.g. the remote server in the case of HTTP samples). JMeter takes into account the total time over which the requests have been generated. If other samplers and timers are in the same thread, these will increase the total time, and therefore reduce the throughput value. So two identical samplers with different names will have half the throughput of two samplers with the same name. It is important to choose the sampler labels correctly to get the best results from the Report.
				
				-   Label - The label of the sample. If "Include group name in label?" is selected, then the name of the thread group is added as a prefix. This allows identical labels from different thread groups to be collated separately if required.
				-   \# Samples - The number of samples with the same label
				-   Average - The average elapsed time of a set of results
				-   Min - The lowest elapsed time for the samples with the same label
				-   Max - The longest elapsed time for the samples with the same label
				-   Std. Dev. - the [Standard Deviation](https://jmeter.apache.org/usermanual/component_reference.html#Summary_Reportglossary.html#StandardDeviation) of the sample elapsed time
				-   Error % - Percent of requests with errors
				-   Throughput - the [Throughput](https://jmeter.apache.org/usermanual/component_reference.html#Summary_Reportglossary.html#Throughput) is measured in requests per second/minute/hour. The time unit is chosen so that the displayed rate is at least 1.0. When the throughput is saved to a CSV file, it is expressed in requests/second, i.e. 30.0 requests/minute is saved as 0.5.
				-   Received KB/sec - The throughput measured in Kilobytes per second
				-   Sent KB/sec - The throughput measured in Kilobytes per second
				-   Avg. Bytes - average size of the sample response in bytes.
				
				Times are in milliseconds.
			- Glossary[¶](https://jmeter.apache.org/usermanual/glossary.html#glossary "Link to here")

				**Elapsed time**. JMeter measures the elapsed time from just before sending the request to just after the last response has been received. JMeter does not include the time needed to render the response, nor does JMeter process any client code, for example Javascript.
				
				**Latency**. JMeter measures the latency from just before sending the request to just after the first response has been received. Thus the time includes all the processing needed to assemble the request as well as assembling the first part of the response, which in general will be longer than one byte. Protocol analysers (such as Wireshark) measure the time when bytes are actually sent/received over the interface. The JMeter time should be closer to that which is experienced by a browser or other application client.
				
				**Connect Time**. JMeter measures the time it took to establish the connection, including SSL handshake. Note that connect time is not automatically subtracted from [latency](https://jmeter.apache.org/usermanual/glossary.html#Latency). In case of connection error, the metric will be equal to the time it took to face the error, for example in case of Timeout, it should be equal to connection timeout.
				
				>As of JMeter 3.1, this metric is only computed for TCP Sampler, HTTP Request and JDBC Request.
				
				**Median** is a number which divides the samples into two equal halves. Half of the samples are smaller than the median, and half are larger. \[Some samples may equal the median.\] This is a standard statistical measure. See, for example: [Median](http://en.wikipedia.org/wiki/Median) entry at Wikipedia. The Median is the same as the 50th Percentile
				
				**90% Line (90th Percentile)** is the value below which 90% of the samples fall. The remaining samples too at least as long as the value. This is a standard statistical measure. See, for example: [Percentile](http://en.wikipedia.org/wiki/Percentile) entry at Wikipedia.
				
				**Standard Deviation** is a measure of the variability of a data set. This is a standard statistical measure. See, for example: [Standard Deviation](http://en.wikipedia.org/wiki/Standard_deviation) entry at Wikipedia. JMeter calculates the population standard deviation (e.g. STDEVP function in spreadsheets), not the sample standard deviation (e.g. STDEV).
		- printtup
			>  printtup --- print a tuple in protocol 3.0
		    Routines to print out tuples to the destination (both frontend clients and standalone backends are supported here).
		
		- ExcutePlan 
			```cpp
			static void
			ExecutePlan()
			{
			    
				TupleTableSlot *slot;
			
				for (;;)
				{
			    
					/*  Call the lower function to get a tuple , The result is a  slot */
					slot = ExecProcNode(planstate);
					
					/*  If  slot  It's empty , It means that all tuples have been obtained , Out of the loop  */
					if (TupIsNull(slot))
						break;
						
					/*  Mark the tuple to be sent , For example, send to  psql  client  */
					if (sendTuples)
					{
			    
						/*  The function pointer will call  printtup  function , and  printtup  Will take this.  slot  adopt  libpq  Send to  psql  client  */
						if (!dest->receiveSlot(slot, dest))
							break;
					}
				}
			
			}
			```
- q2_6hours
	```bash
	#q2_6hours
	explain analyze verbose 
	select * 
	from 
		t_msis_aws_min_pt where datetime > '2022-02-06 07:00:00' 
			and datetime < '2022-02-06 13:00:00';
	
	                                                                                                                                                                                                                                                    QUERY PLAN
	
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=2704.632..2788.602 rows=209286 loops=1)
	   Output: remote_scan.station_id_c, remote_scan.station_name, remote_scan.prs, remote_scan.prs_sea, remote_scan.win_s_gust_max, remote_scan.win_d_gust_max, remote_scan.win_d_inst, remote_scan.win_s_inst, remote_scan.win_d_avg_1mi, remote_scan.win_s_avg_1mi, remote_scan.win_d_avg_2mi, re
	mote_scan.win_s_avg_2mi, remote_scan.win_d_avg_10mi, remote_scan.win_s_avg_10mi, remote_scan.win_d_s_max, remote_scan.tem, remote_scan.dpt, remote_scan.gst_5cm, remote_scan.gst_10cm, remote_scan.gst_15cm, remote_scan.gst_20cm, remote_scan.gst_40cm, remote_scan.gst_80cm, remote_scan.gst_1
	60cm, remote_scan.gst_320cm, remote_scan.gst, remote_scan.lgst, remote_scan.rhu, remote_scan.vap, remote_scan.snow_depth, remote_scan.evp_big, remote_scan.vis_hor_1mi, remote_scan.vis_hor_10mi, remote_scan.clo_cov, remote_scan.clo_height_lom, remote_scan.datetime
	   Task Count: 3
	   Tasks Shown: One of 3
	   ->  Task
	         Node: host=njqa09 port=15432 dbname=weather_station
	         ->  Append  (cost=27.86..4355.34 rows=1115 width=289) (actual time=19.655..49.657 rows=72798 loops=1)
	               ->  Bitmap Heap Scan on public.t_msis_aws_min_pt_202201_102720 t_msis_aws_min_pt  (cost=27.86..4355.34 rows=1115 width=289) (actual time=19.655..42.334 rows=72798 loops=1)
	                     Output: t_msis_aws_min_pt.station_id_c, t_msis_aws_min_pt.station_name, t_msis_aws_min_pt.prs, t_msis_aws_min_pt.prs_sea, t_msis_aws_min_pt.win_s_gust_max, t_msis_aws_min_pt.win_d_gust_max, t_msis_aws_min_pt.win_d_inst, t_msis_aws_min_pt.win_s_inst, t_msis_aws_min_pt
	.win_d_avg_1mi, t_msis_aws_min_pt.win_s_avg_1mi, t_msis_aws_min_pt.win_d_avg_2mi, t_msis_aws_min_pt.win_s_avg_2mi, t_msis_aws_min_pt.win_d_avg_10mi, t_msis_aws_min_pt.win_s_avg_10mi, t_msis_aws_min_pt.win_d_s_max, t_msis_aws_min_pt.tem, t_msis_aws_min_pt.dpt, t_msis_aws_min_pt.gst_5cm, t
	_msis_aws_min_pt.gst_10cm, t_msis_aws_min_pt.gst_15cm, t_msis_aws_min_pt.gst_20cm, t_msis_aws_min_pt.gst_40cm, t_msis_aws_min_pt.gst_80cm, t_msis_aws_min_pt.gst_160cm, t_msis_aws_min_pt.gst_320cm, t_msis_aws_min_pt.gst, t_msis_aws_min_pt.lgst, t_msis_aws_min_pt.rhu, t_msis_aws_min_pt.vap
	, t_msis_aws_min_pt.snow_depth, t_msis_aws_min_pt.evp_big, t_msis_aws_min_pt.vis_hor_1mi, t_msis_aws_min_pt.vis_hor_10mi, t_msis_aws_min_pt.clo_cov, t_msis_aws_min_pt.clo_height_lom, t_msis_aws_min_pt.datetime
	                     Recheck Cond: ((t_msis_aws_min_pt.datetime > '2022-02-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt.datetime < '2022-02-06 13:00:00'::timestamp without time zone))
	                     Heap Blocks: exact=3778
	                     ->  Bitmap Index Scan on idx_t_msis_aws_min_pt_202201_datetime_102720  (cost=0.00..27.58 rows=1115 width=0) (actual time=18.595..18.595 rows=72798 loops=1)
	                           Index Cond: ((t_msis_aws_min_pt.datetime > '2022-02-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt.datetime < '2022-02-06 13:00:00'::timestamp without time zone))
	             Planning time: 0.753 ms
	             Execution time: 53.894 ms
	 Planning time: 0.809 ms
	 Execution time: 2819.324 ms
	(17 rows)

	```
- q3_1month
	```bash
	#q3_1month
	explain analyze verbose 
	select station_id_c, max(prs) from t_msis_aws_min_pt
	where 
		datetime > '2022-02-06 07:00:00' 
			and datetime < '2022-03-07 07:00:00'
	group by station_id_c;
	                                                                                                             QUERY PLAN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=6638.385..6639.470 rows=3171 loops=1)
	   Output: remote_scan.station_id_c, max(remote_scan.max)
	   Group Key: remote_scan.station_id_c
	   ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=6635.388..6635.701 rows=3171 loops=1)
	         Output: remote_scan.station_id_c, remote_scan.max
	         Task Count: 3
	         Tasks Shown: One of 3
	         ->  Task
	               Node: host=njqa09 port=15432 dbname=weather_station
	               ->  Finalize GroupAggregate  (cost=700037.95..700042.95 rows=200 width=14) (actual time=6964.924..7043.173 rows=1103 loops=1)
	                     Output: t_msis_aws_min_pt.station_id_c, max(t_msis_aws_min_pt.prs)
	                     Group Key: t_msis_aws_min_pt.station_id_c
	                     ->  Sort  (cost=700037.95..700038.95 rows=400 width=14) (actual time=6964.914..7041.712 rows=3309 loops=1)
	                           Output: t_msis_aws_min_pt.station_id_c, (PARTIAL max(t_msis_aws_min_pt.prs))
	                           Sort Key: t_msis_aws_min_pt.station_id_c
	                           Sort Method: quicksort  Memory: 252kB
	                           ->  Gather  (cost=699978.66..700020.66 rows=400 width=14) (actual time=6956.121..7035.175 rows=3309 loops=1)
	                                 Output: t_msis_aws_min_pt.station_id_c, (PARTIAL max(t_msis_aws_min_pt.prs))
	                                 Workers Planned: 2
	                                 Workers Launched: 2
	                                 ->  Partial HashAggregate  (cost=698978.66..698980.66 rows=200 width=14) (actual time=6952.533..6953.039 rows=1103 loops=3)
	                                       Output: t_msis_aws_min_pt.station_id_c, PARTIAL max(t_msis_aws_min_pt.prs)
	                                       Group Key: t_msis_aws_min_pt.station_id_c
	                                       Worker 0: actual time=6950.902..6951.397 rows=1103 loops=1
	                                       Worker 1: actual time=6950.926..6951.459 rows=1103 loops=1
	                                       ->  Append  (cost=0.00..681484.71 rows=3498791 width=14) (actual time=0.045..5328.231 rows=2862653 loops=3)
	                                             Worker 0: actual time=0.026..5350.122 rows=2795512 loops=1
	                                             Worker 1: actual time=0.027..5351.269 rows=2824786 loops=1
	                                             ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202201_102720 t_msis_aws_min_pt  (cost=0.00..681484.71 rows=3498791 width=14) (actual time=0.044..5013.454 rows=2862653 loops=3)
	                                                   Output: t_msis_aws_min_pt.station_id_c, t_msis_aws_min_pt.prs
	                                                   Filter: ((t_msis_aws_min_pt.datetime > '2022-02-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt.datetime < '2022-03-07 07:00:00'::timestamp without time zone))
	                                                   Rows Removed by Filter: 2036138
	                                                   Worker 0: actual time=0.024..5037.343 rows=2795512 loops=1
	                                                   Worker 1: actual time=0.024..5033.871 rows=2824786 loops=1
	                   Planning time: 0.732 ms
	                   Execution time: 7043.354 ms
	 Planning time: 0.734 ms
	 Execution time: 6639.855 ms
	(38 rows)

	```
- q3_1year
	```bash
	#q3_1year
	explain analyze verbose 
	select station_id_c, max(prs) from t_msis_aws_min_pt
	where 
		datetime > '2021-07-06 07:00:00' 
			and datetime < '2022-07-07 07:00:00'
	group by station_id_c;
	                                                                                                                            QUERY PLAN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=8534.695..8535.657 rows=3171 loops=1)
	   Output: remote_scan.station_id_c, max(remote_scan.max)
	   Group Key: remote_scan.station_id_c
	   ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=8531.877..8532.183 rows=3171 loops=1)
	         Output: remote_scan.station_id_c, remote_scan.max
	         Task Count: 3
	         Tasks Shown: One of 3
	         ->  Task
	               Node: host=njqa09 port=15432 dbname=weather_station
	               ->  Finalize GroupAggregate  (cost=796526.33..796531.33 rows=200 width=14) (actual time=9438.155..9520.171 rows=1103 loops=1)
	                     Output: t_msis_aws_min_pt.station_id_c, max(t_msis_aws_min_pt.prs)
	                     Group Key: t_msis_aws_min_pt.station_id_c
	                     ->  Sort  (cost=796526.33..796527.33 rows=400 width=14) (actual time=9438.148..9518.710 rows=3309 loops=1)
	                           Output: t_msis_aws_min_pt.station_id_c, (PARTIAL max(t_msis_aws_min_pt.prs))
	                           Sort Key: t_msis_aws_min_pt.station_id_c
	                           Sort Method: quicksort  Memory: 252kB
	                           ->  Gather  (cost=796467.05..796509.05 rows=400 width=14) (actual time=9429.961..9512.269 rows=3309 loops=1)
	                                 Output: t_msis_aws_min_pt.station_id_c, (PARTIAL max(t_msis_aws_min_pt.prs))
	                                 Workers Planned: 2
	                                 Workers Launched: 2
	                                 ->  Partial HashAggregate  (cost=795467.05..795469.05 rows=200 width=14) (actual time=9425.636..9426.121 rows=1103 loops=3)
	                                       Output: t_msis_aws_min_pt.station_id_c, PARTIAL max(t_msis_aws_min_pt.prs)
	                                       Group Key: t_msis_aws_min_pt.station_id_c
	                                       Worker 0: actual time=9423.997..9424.488 rows=1103 loops=1
	                                       Worker 1: actual time=9423.588..9424.123 rows=1103 loops=1
	                                       ->  Append  (cost=0.00..761292.93 rows=6834824 width=14) (actual time=0.024..6383.087 rows=5472351 loops=3)
	                                             Worker 0: actual time=0.027..6460.998 rows=5346688 loops=1
	                                             Worker 1: actual time=0.033..6483.134 rows=5213436 loops=1
	                                             ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202102_102717 t_msis_aws_min_pt  (cost=0.00..79799.64 rows=716976 width=14) (actual time=0.022..627.492 rows=573560 loops=3)
	                                                   Output: t_msis_aws_min_pt.station_id_c, t_msis_aws_min_pt.prs
	                                                   Filter: ((t_msis_aws_min_pt.datetime > '2021-07-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt.datetime < '2022-07-07 07:00:00'::timestamp without time zone))
	                                                   Worker 0: actual time=0.026..630.301 rows=566843 loops=1
	                                                   Worker 1: actual time=0.031..634.001 rows=554830 loops=1
	                                             ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202201_102720 t_msis_aws_min_pt_1  (cost=0.00..681484.71 rows=6117847 width=14) (actual time=0.032..5172.289 rows=4898791 loops=3)
	                                                   Output: t_msis_aws_min_pt_1.station_id_c, t_msis_aws_min_pt_1.prs
	                                                   Filter: ((t_msis_aws_min_pt_1.datetime > '2021-07-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt_1.datetime < '2022-07-07 07:00:00'::timestamp without time zone))
	                                                   Worker 0: actual time=0.057..5267.480 rows=4779845 loops=1
	                                                   Worker 1: actual time=0.025..5294.584 rows=4658606 loops=1
	                                             ->  Parallel Index Scan using idx_t_msis_aws_min_pt_202202_datetime_102723 on public.t_msis_aws_min_pt_202202_102723 t_msis_aws_min_pt_2  (cost=0.57..8.58 rows=1 width=14) (actual time=0.062..0.062 rows=0 loops=3)
	                                                   Output: t_msis_aws_min_pt_2.station_id_c, t_msis_aws_min_pt_2.prs
	                                                   Index Cond: ((t_msis_aws_min_pt_2.datetime > '2021-07-06 07:00:00'::timestamp without time zone) AND (t_msis_aws_min_pt_2.datetime < '2022-07-07 07:00:00'::timestamp without time zone))
	                                                   Worker 0: actual time=0.058..0.058 rows=0 loops=1
	                                                   Worker 1: actual time=0.074..0.074 rows=0 loops=1
	                   Planning time: 1.347 ms
	                   Execution time: 9520.409 ms
	 Planning time: 0.559 ms
	 Execution time: 8535.990 ms
	(47 rows)
	```
- q8_1month
	```bash
	#q8_1month
	explain analyze verbose 
	select a.station_id_c, max(a.prs), min(a.prs), avg(a.tem)
	from 
		t_msis_aws_min_pt a 
	left join t_msis_cd_station_ref b 
		on a.station_id_c = b.station_id_c
	where 
		datetime > '2022-02-06 08:00:00' and datetime < '2022-03-07 08:00:00'
			and a.prs < 10000 and a.tem < 100 and b.city = '石家庄市'
	group by a.station_id_c;
	                                                                                                                                       QUERY PLAN
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=5335.855..5335.911 rows=56 loops=1)
	   Output: remote_scan.station_id_c, max(remote_scan.max), min(remote_scan.min), (sum(remote_scan.avg) / (pg_catalog.sum(remote_scan.avg_1))::double precision)
	   Group Key: remote_scan.station_id_c
	   ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=5335.733..5335.746 rows=56 loops=1)
	         Output: remote_scan.station_id_c, remote_scan.max, remote_scan.min, remote_scan.avg, remote_scan.avg_1
	         Task Count: 3
	         Tasks Shown: One of 3
	         ->  Task
	               Node: host=njqa09 port=15432 dbname=weather_station
	               ->  Finalize GroupAggregate  (cost=719882.80..719890.80 rows=200 width=38) (actual time=5373.515..5447.579 rows=18 loops=1)
	                     Output: a.station_id_c, max(a.prs), min(a.prs), sum(a.tem), count(a.tem)
	                     Group Key: a.station_id_c
	                     ->  Sort  (cost=719882.80..719883.80 rows=400 width=38) (actual time=5373.499..5447.526 rows=54 loops=1)
	                           Output: a.station_id_c, (PARTIAL max(a.prs)), (PARTIAL min(a.prs)), (PARTIAL sum(a.tem)), (PARTIAL count(a.tem))
	                           Sort Key: a.station_id_c
	                           Sort Method: quicksort  Memory: 29kB
	                           ->  Gather  (cost=719823.51..719865.51 rows=400 width=38) (actual time=5372.973..5447.400 rows=54 loops=1)
	                                 Output: a.station_id_c, (PARTIAL max(a.prs)), (PARTIAL min(a.prs)), (PARTIAL sum(a.tem)), (PARTIAL count(a.tem))
	                                 Workers Planned: 2
	                                 Workers Launched: 2
	                                 ->  Partial HashAggregate  (cost=718823.51..718825.51 rows=200 width=38) (actual time=5368.939..5368.966 rows=18 loops=3)
	                                       Output: a.station_id_c, PARTIAL max(a.prs), PARTIAL min(a.prs), PARTIAL sum(a.tem), PARTIAL count(a.tem)
	                                       Group Key: a.station_id_c
	                                       Worker 0: actual time=5367.143..5367.171 rows=18 loops=1
	                                       Worker 1: actual time=5367.241..5367.273 rows=18 loops=1
	                                       ->  Hash Join  (cost=104.64..717330.18 rows=119466 width=22) (actual time=10.800..5331.085 rows=46746 loops=3)
	                                             Output: a.station_id_c, a.prs, a.tem
	                                             Hash Cond: (a.station_id_c = b.station_id_c)
	                                             Worker 0: actual time=8.988..5329.620 rows=46112 loops=1
	                                             Worker 1: actual time=9.104..5329.773 rows=45328 loops=1
	                                             ->  Append  (cost=0.00..712073.94 rows=1055185 width=22) (actual time=2.709..5110.782 rows=1033606 loops=3)
	                                                   Worker 0: actual time=0.895..5115.021 rows=1011726 loops=1
	                                                   Worker 1: actual time=1.028..5113.715 rows=1006148 loops=1
	                                                   ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202201_102720 a  (cost=0.00..712073.94 rows=1055185 width=22) (actual time=2.708..5000.828 rows=1033606 loops=3)
	                                                         Output: a.station_id_c, a.prs, a.tem
	                                                         Filter: ((a.datetime > '2022-02-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-03-07 08:00:00'::timestamp without time zone) AND (a.prs < '10000'::double precision) AND 
	                                                         (a.tem < '100'::double precision))
	                                                         Rows Removed by Filter: 3865185
	                                                         Worker 0: actual time=0.894..5007.396 rows=1011726 loops=1
	                                                         Worker 1: actual time=1.027..5006.451 rows=1006148 loops=1
	                                             ->  Hash  (cost=99.49..99.49 rows=412 width=5) (actual time=1.560..1.566 rows=412 loops=3)
	                                                   Output: b.station_id_c
	                                                   Buckets: 1024  Batches: 1  Memory Usage: 24kB
	                                                   Worker 0: actual time=1.641..1.647 rows=412 loops=1
	                                                   Worker 1: actual time=1.634..1.645 rows=412 loops=1
	                                                   ->  Seq Scan on public.t_msis_cd_station_ref_102360 b  (cost=0.00..99.49 rows=412 width=5) (actual time=0.023..1.409 rows=412 loops=3)
	                                                         Output: b.station_id_c
	                                                         Filter: (b.city = '石家庄市'::text)
	                                                         Rows Removed by Filter: 3227
	                                                         Worker 0: actual time=0.031..1.490 rows=412 loops=1
	                                                         Worker 1: actual time=0.029..1.480 rows=412 loops=1
	                   Planning time: 1.027 ms
	                   Execution time: 5447.757 ms
	 Planning time: 4.499 ms
	 Execution time: 5336.048 ms
	(54 rows)


	```
- q8_1year
	```bash
	#q8_1year
	explain analyze verbose 
	select a.station_id_c, max(a.prs), min(a.prs), avg(a.tem)
	from 
		t_msis_aws_min_pt a 
	left join t_msis_cd_station_ref b 
		on a.station_id_c = b.station_id_c
	where 
		datetime > '2021-06-06 08:00:00' and datetime < '2022-06-06 08:00:00'
			and a.prs < 10000 and a.tem < 100 and b.city = '石家庄市'
	group by a.station_id_c;
	                                                                                                                                           QUERY PLAN
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-
	 HashAggregate  (cost=0.00..0.00 rows=0 width=0) (actual time=6162.992..6163.049 rows=56 loops=1)
	   Output: remote_scan.station_id_c, max(remote_scan.max), min(remote_scan.min), (sum(remote_scan.avg) / (pg_catalog.sum(remote_scan.avg_1))::double precision)
	   Group Key: remote_scan.station_id_c
	   ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=6162.895..6162.902 rows=56 loops=1)
	         Output: remote_scan.station_id_c, remote_scan.max, remote_scan.min, remote_scan.avg, remote_scan.avg_1
	         Task Count: 3
	         Tasks Shown: One of 3
	         ->  Task
	               Node: host=njqa09 port=15432 dbname=weather_station
	               ->  Finalize GroupAggregate  (cost=809582.11..809590.11 rows=200 width=38) (actual time=6343.191..6416.704 rows=18 loops=1)
	                     Output: a.station_id_c, max(a.prs), min(a.prs), sum(a.tem), count(a.tem)
	                     Group Key: a.station_id_c
	                     ->  Sort  (cost=809582.11..809583.11 rows=400 width=38) (actual time=6343.175..6416.651 rows=54 loops=1)
	                           Output: a.station_id_c, (PARTIAL max(a.prs)), (PARTIAL min(a.prs)), (PARTIAL sum(a.tem)), (PARTIAL count(a.tem))
	                           Sort Key: a.station_id_c
	                           Sort Method: quicksort  Memory: 29kB
	                           ->  Gather  (cost=809522.83..809564.83 rows=400 width=38) (actual time=6342.651..6416.543 rows=54 loops=1)
	                                 Output: a.station_id_c, (PARTIAL max(a.prs)), (PARTIAL min(a.prs)), (PARTIAL sum(a.tem)), (PARTIAL count(a.tem))
	                                 Workers Planned: 2
	                                 Workers Launched: 2
	                                 ->  Partial HashAggregate  (cost=808522.83..808524.83 rows=200 width=38) (actual time=6338.532..6338.555 rows=18 loops=3)
	                                       Output: a.station_id_c, PARTIAL max(a.prs), PARTIAL min(a.prs), PARTIAL sum(a.tem), PARTIAL count(a.tem)
	                                       Group Key: a.station_id_c
	                                       Worker 0: actual time=6336.751..6336.783 rows=18 loops=1
	                                       Worker 1: actual time=6336.752..6336.770 rows=18 loops=1
	                                       ->  Hash Join  (cost=104.78..805612.20 rows=232850 width=22) (actual time=3.270..6267.772 rows=88926 loops=3)
	                                             Output: a.station_id_c, a.prs, a.tem
	                                             Hash Cond: (a.station_id_c = b.station_id_c)
	                                             Worker 0: actual time=1.860..6267.500 rows=86197 loops=1
	                                             Worker 1: actual time=1.857..6268.490 rows=85307 loops=1
	                                             ->  Append  (cost=0.14..795466.62 rows=2056651 width=22) (actual time=0.180..5851.689 rows=1966253 loops=3)
	                                                   Worker 0: actual time=0.032..5863.147 rows=1900029 loops=1
	                                                   Worker 1: actual time=0.033..5874.446 rows=1865722 loops=1
	                                                   ->  Parallel Index Scan using idx_t_msis_aws_min_pt_202101_datetime_102714 on public.t_msis_aws_min_pt_202101_102714 a  (cost=0.14..8.16 rows=1 width=48) (actual time=0.003..0.003 rows=0 loops=3)
	                                                         Output: a.station_id_c, a.prs, a.tem
	                                                         Index Cond: ((a.datetime > '2021-06-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-06-06 08:00:00'::timestamp without time zone))
	                                                         Filter: ((a.prs < '10000'::double precision) AND (a.tem < '100'::double precision))
	                                                         Worker 0: actual time=0.002..0.002 rows=0 loops=1
	                                                         Worker 1: actual time=0.002..0.002 rows=0 loops=1
	                                                   ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202102_102717 a_1  (cost=0.00..83384.52 rows=217325 width=22) (actual time=0.176..624.699 rows=206960 loops=3)
	                                                         Output: a_1.station_id_c, a_1.prs, a_1.tem
	                                                         Filter: ((a_1.datetime > '2021-06-06 08:00:00'::timestamp without time zone) AND (a_1.datetime < '2022-06-06 08:00:00'::timestamp without time zone) AND (a_1.prs < '10000'::double precision) 
	                                                         AND (a_1.tem < '100'::double precision))
	                                                         Rows Removed by Filter: 366600
	                                                         Worker 0: actual time=0.029..625.194 rows=199265 loops=1
	                                                         Worker 1: actual time=0.030..625.009 rows=198762 loops=1
	                                                   ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202201_102720 a_2  (cost=0.00..712073.94 rows=1839325 width=22) (actual time=0.017..5018.677 rows=1759293 loops=3)
	                                                         Output: a_2.station_id_c, a_2.prs, a_2.tem
	                                                         Filter: ((a_2.datetime > '2021-06-06 08:00:00'::timestamp without time zone) AND (a_2.datetime < '2022-06-06 08:00:00'::timestamp without time zone) AND (a_2.prs < '10000'::double precision) 
	                                                         AND (a_2.tem < '100'::double precision))
	                                                         Rows Removed by Filter: 3139498
	                                                         Worker 0: actual time=0.022..5035.732 rows=1700764 loops=1
	                                                         Worker 1: actual time=0.021..5051.363 rows=1666960 loops=1
	                                             ->  Hash  (cost=99.49..99.49 rows=412 width=5) (actual time=1.630..1.631 rows=412 loops=3)
	                                                   Output: b.station_id_c
	                                                   Buckets: 1024  Batches: 1  Memory Usage: 24kB
	                                                   Worker 0: actual time=1.733..1.734 rows=412 loops=1
	                                                   Worker 1: actual time=1.734..1.734 rows=412 loops=1
	                                                   ->  Seq Scan on public.t_msis_cd_station_ref_102360 b  (cost=0.00..99.49 rows=412 width=5) (actual time=0.023..1.479 rows=412 loops=3)
	                                                         Output: b.station_id_c
	                                                         Filter: (b.city = '石家庄市'::text)
	                                                         Rows Removed by Filter: 3227
	                                                         Worker 0: actual time=0.033..1.575 rows=412 loops=1
	                                                         Worker 1: actual time=0.029..1.586 rows=412 loops=1
	                   Planning time: 1.231 ms
	                   Execution time: 6416.934 ms
	 Planning time: 1.300 ms
	 Execution time: 6163.132 ms
	(66 rows)

	```
- q9_1month
	```bash
	#q9_1month
	explain analyze verbose 
	select 
		station_id_c, datetime, tem
	from (
			select row_number() over (partition by c.station_id_c order by c.tem desc) as rn, c.station_id_c, c.tem, c.datetime
			from (
					select a.station_id_c, a.datetime, a.tem
					from 
						t_msis_aws_min_pt a left join t_msis_cd_station_ref b on a.station_id_c = b.station_id_c
					where 
						datetime > '2022-02-06 08:00:00' and datetime < '2022-03-07 08:00:00'
							and a.tem < 100 and b.city = '石家庄市'
				)c
		) t where rn = 1;
		                                                                                                                QUERY PLAN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=7266.864..7266.897 rows=270 loops=1)
	   Output: remote_scan.station_id_c, remote_scan.datetime, remote_scan.tem
	   Task Count: 3
	   Tasks Shown: One of 3
	   ->  Task
	         Node: host=njqa09 port=15432 dbname=weather_station
	         ->  Subquery Scan on t  (cost=888253.12..914406.07 rows=4024 width=22) (actual time=6610.884..7727.456 rows=97 loops=1)
	               Output: t.station_id_c, t.datetime, t.tem
	               Filter: (t.rn = 1)
	               Rows Removed by Filter: 755630
	               ->  WindowAgg  (cost=888253.12..904347.24 rows=804706 width=30) (actual time=6610.881..7626.131 rows=755727 loops=1)
	                     Output: row_number() OVER (?), a.station_id_c, a.tem, a.datetime
	                     ->  Sort  (cost=888253.12..890264.89 rows=804706 width=22) (actual time=6610.869..7025.615 rows=755727 loops=1)
	                           Output: a.station_id_c, a.tem, a.datetime
	                           Sort Key: a.station_id_c, a.tem DESC
	                           Sort Method: external merge  Disk: 25160kB
	                           ->  Gather  (cost=1104.64..792813.10 rows=804706 width=22) (actual time=15.385..5745.193 rows=755727 loops=1)
	                                 Output: a.station_id_c, a.tem, a.datetime
	                                 Workers Planned: 2
	                                 Workers Launched: 2
	                                 ->  Hash Join  (cost=104.64..711342.50 rows=335294 width=22) (actual time=11.855..5859.724 rows=251909 loops=3)
	                                       Output: a.station_id_c, a.tem, a.datetime
	                                       Hash Cond: (a.station_id_c = b.station_id_c)
	                                       Worker 0: actual time=10.250..6160.318 rows=329769 loops=1
	                                       Worker 1: actual time=10.324..6116.437 rows=319319 loops=1
	                                       ->  Append  (cost=0.00..696779.32 rows=2961493 width=22) (actual time=1.853..5283.183 rows=2407419 loops=3)
	                                             Worker 0: actual time=0.252..5537.904 rows=2517270 loops=1
	                                             Worker 1: actual time=0.313..5501.890 rows=2505637 loops=1
	                                             ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202201_102720 a  (cost=0.00..696779.32 rows=2961493 width=22) (actual time=1.851..5027.528 rows=2407419 loops=3)
	                                                   Output: a.station_id_c, a.tem, a.datetime
	                                                   Filter: ((a.datetime > '2022-02-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-03-07 08:00:00'::timestamp without time zone) AND (a.tem < '100'::double precision))
	                                                   Rows Removed by Filter: 2491372
	                                                   Worker 0: actual time=0.250..5269.096 rows=2517270 loops=1
	                                                   Worker 1: actual time=0.310..5235.830 rows=2505637 loops=1
	                                       ->  Hash  (cost=99.49..99.49 rows=412 width=5) (actual time=1.655..1.656 rows=412 loops=3)
	                                             Output: b.station_id_c
	                                             Buckets: 1024  Batches: 1  Memory Usage: 24kB
	                                             Worker 0: actual time=1.602..1.603 rows=412 loops=1
	                                             Worker 1: actual time=1.855..1.855 rows=412 loops=1
	                                             ->  Seq Scan on public.t_msis_cd_station_ref_102360 b  (cost=0.00..99.49 rows=412 width=5) (actual time=0.022..1.507 rows=412 loops=3)
	                                                   Output: b.station_id_c
	                                                   Filter: (b.city = '石家庄市'::text)
	                                                   Rows Removed by Filter: 3227
	                                                   Worker 0: actual time=0.025..1.452 rows=412 loops=1
	                                                   Worker 1: actual time=0.031..1.697 rows=412 loops=1
	             Planning time: 1.056 ms
	             Execution time: 7734.465 ms
	 Planning time: 4.397 ms
	 Execution time: 7266.989 ms
	(49 rows)

	```
- q9_1year
	```bash
	#q8_1year
	explain analyze verbose 
	select station_id_c, datetime, tem
	from (
		select row_number() over (partition by c.station_id_c order by c.tem desc) as rn, c.station_id_c, c.tem, c.datetime
	    from (
			    select a.station_id_c, a.datetime, a.tem
				from 
					t_msis_aws_min_pt a left join t_msis_cd_station_ref b on a.station_id_c = b.station_id_c
		        where 
			        datetime > '2021-06-06 08:00:00' and datetime < '2022-06-07 08:00:00'
					    and a.tem < 100 and b.city = '石家庄市'
	    )c
	   ) t where rn = 1;
	                                                                                                                   QUERY PLAN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=10200.744..10200.775 rows=270 loops=1)
	   Output: remote_scan.station_id_c, remote_scan.datetime, remote_scan.tem
	   Task Count: 3
	   Tasks Shown: One of 3
	   ->  Task
	         Node: host=njqa09 port=15432 dbname=weather_station
	         ->  Subquery Scan on t  (cost=1189835.29..1240760.09 rows=7835 width=22) (actual time=8995.103..11111.575 rows=97 loops=1)
	               Output: t.station_id_c, t.datetime, t.tem
	               Filter: (t.rn = 1)
	               Rows Removed by Filter: 1437540
	               ->  WindowAgg  (cost=1189835.29..1221173.63 rows=1566917 width=30) (actual time=8995.100..10914.442 rows=1437637 loops=1)
	                     Output: row_number() OVER (?), a.station_id_c, a.tem, a.datetime
	                     ->  Sort  (cost=1189835.29..1193752.58 rows=1566917 width=22) (actual time=8995.087..9735.068 rows=1437637 loops=1)
	                           Output: a.station_id_c, a.tem, a.datetime
	                           Sort Key: a.station_id_c, a.tem DESC
	                           Sort Method: external merge  Disk: 47864kB
	                           ->  Gather  (cost=1104.78..964329.47 rows=1566917 width=22) (actual time=5.341..7293.095 rows=1437637 loops=1)
	                                 Output: a.station_id_c, a.tem, a.datetime
	                                 Workers Planned: 2
	                                 Workers Launched: 2
	                                 ->  Hash Join  (cost=104.78..806637.77 rows=652882 width=22) (actual time=3.049..7393.739 rows=479212 loops=3)
	                                       Output: a.station_id_c, a.tem, a.datetime
	                                       Hash Cond: (a.station_id_c = b.station_id_c)
	                                       Worker 0: actual time=2.134..7829.353 rows=604878 loops=1
	                                       Worker 1: actual time=2.165..7830.374 rows=604695 loops=1
	                                       ->  Append  (cost=0.14..778379.56 rows=5766599 width=22) (actual time=0.033..6308.998 rows=4579689 loops=3)
	                                             Worker 0: actual time=0.042..6684.411 rows=4715767 loops=1
	                                             Worker 1: actual time=0.042..6690.874 rows=4687509 loops=1
	                                             ->  Parallel Index Scan using idx_t_msis_aws_min_pt_202101_datetime_102714 on public.t_msis_aws_min_pt_202101_102714 a  (cost=0.14..8.16 rows=1 width=48) (actual time=0.003..0.003 rows=0 loops=3)
	                                                   Output: a.station_id_c, a.tem, a.datetime
	                                                   Index Cond: ((a.datetime > '2021-06-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-06-07 08:00:00'::timestamp without time zone))
	                                                   Filter: (a.tem < '100'::double precision)
	                                                   Worker 0: actual time=0.001..0.002 rows=0 loops=1
	                                                   Worker 1: actual time=0.002..0.002 rows=0 loops=1
	                                             ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202102_102717 a_1  (cost=0.00..81592.08 rows=603567 width=22) (actual time=0.029..642.029 rows=482040 loops=3)
	                                                   Output: a_1.station_id_c, a_1.tem, a_1.datetime
	                                                   Filter: ((a_1.datetime > '2021-06-06 08:00:00'::timestamp without time zone) AND (a_1.datetime < '2022-06-07 08:00:00'::timestamp without time zone) AND (a_1.tem < '100'::double precision))
	                                                   Rows Removed by Filter: 91520
	                                                   Worker 0: actual time=0.039..719.078 rows=534826 loops=1
	                                                   Worker 1: actual time=0.038..725.959 rows=529718 loops=1
	                                             ->  Parallel Seq Scan on public.t_msis_aws_min_pt_202201_102720 a_2  (cost=0.00..696779.32 rows=5163031 width=22) (actual time=0.016..5181.516 rows=4097649 loops=3)
	                                                   Output: a_2.station_id_c, a_2.tem, a_2.datetime
	                                                   Filter: ((a_2.datetime > '2021-06-06 08:00:00'::timestamp without time zone) AND (a_2.datetime < '2022-06-07 08:00:00'::timestamp without time zone) AND (a_2.tem < '100'::double precision))
	                                                   Rows Removed by Filter: 801142
	                                                   Worker 0: actual time=0.019..5464.951 rows=4180941 loops=1
	                                                   Worker 1: actual time=0.021..5466.283 rows=4157791 loops=1
	                                       ->  Hash  (cost=99.49..99.49 rows=412 width=5) (actual time=1.691..1.695 rows=412 loops=3)
	                                             Output: b.station_id_c
	                                             Buckets: 1024  Batches: 1  Memory Usage: 24kB
	                                             Worker 0: actual time=1.796..1.801 rows=412 loops=1
	                                             Worker 1: actual time=1.796..1.801 rows=412 loops=1
	                                             ->  Seq Scan on public.t_msis_cd_station_ref_102360 b  (cost=0.00..99.49 rows=412 width=5) (actual time=0.024..1.546 rows=412 loops=3)
	                                                   Output: b.station_id_c
	                                                   Filter: (b.city = '石家庄市'::text)
	                                                   Rows Removed by Filter: 3227
	                                                   Worker 0: actual time=0.030..1.647 rows=412 loops=1
	                                                   Worker 1: actual time=0.031..1.649 rows=412 loops=1
	             Planning time: 1.349 ms
	             Execution time: 11123.968 ms
	 Planning time: 1.441 ms
	 Execution time: 10200.835 ms
	(61 rows)

	```
- q10_12hour
	```bash
	#q10_12hour
	explain analyze verbose 
	with c as (
		select a.station_id_c, a.datetime, a.tem, b.city
		from 
			t_msis_aws_min_pt a 
		left join 
			t_msis_cd_station_ref b 
				on a.station_id_c = b.station_id_c
		where 
			datetime > '2022-02-06 08:00:00' and datetime < '2022-02-06 20:00:00'
				and a.tem < 100
	)
	select station_id_c, datetime, tem, city
	from (
	    select row_number() over (partition by c.city order by c.tem desc) as rn, c.station_id_c, c.tem, c.datetime, c.city
	    from c
	   ) t where rn = 1;
	                                                                                              QUERY PLAN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=4222.552..4222.560 rows=14 loops=1)
	   Output: remote_scan.station_id_c, remote_scan.datetime, remote_scan.tem, remote_scan.city
	   ->  Distributed Subplan 4_1
	         ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=1107.731..1203.847 rows=383669 loops=1)
	               Output: remote_scan.station_id_c, remote_scan.datetime, remote_scan.tem, remote_scan.city
	               Task Count: 3
	               Tasks Shown: One of 3
	               ->  Task
	                     Node: host=njqa09 port=15432 dbname=weather_station
	                     ->  Hash Left Join  (cost=1262.65..143461.45 rows=38923 width=32) (actual time=45.765..278.939 rows=132561 loops=1)
	                           Output: a.station_id_c, a.datetime, a.tem, b.city
	                           Hash Cond: (a.station_id_c = b.station_id_c)
	                           ->  Append  (cost=1126.78..142790.38 rows=38923 width=22) (actual time=43.011..207.227 rows=132561 loops=1)
	                                 ->  Bitmap Heap Scan on public.t_msis_aws_min_pt_202201_102720 a  (cost=1126.78..142790.38 rows=38923 width=22) (actual time=43.010..193.222 rows=132561 loops=1)
	                                       Output: a.station_id_c, a.datetime, a.tem
	                                       Recheck Cond: ((a.datetime > '2022-02-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-02-06 20:00:00'::timestamp without time zone))
	                                       Filter: (a.tem < '100'::double precision)
	                                       Rows Removed by Filter: 25168
	                                       Heap Blocks: exact=7291
	                                       ->  Bitmap Index Scan on idx_t_msis_aws_min_pt_202201_datetime_102720  (cost=0.00..1117.05 rows=46061 width=0) (actual time=40.696..40.696 rows=157729 loops=1)
	                                             Index Cond: ((a.datetime > '2022-02-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-02-06 20:00:00'::timestamp without time zone))
	                           ->  Hash  (cost=90.39..90.39 rows=3639 width=15) (actual time=2.686..2.687 rows=3639 loops=1)
	                                 Output: b.city, b.station_id_c
	                                 Buckets: 4096  Batches: 1  Memory Usage: 206kB
	                                 ->  Seq Scan on public.t_msis_cd_station_ref_102360 b  (cost=0.00..90.39 rows=3639 width=15) (actual time=0.014..1.442 rows=3639 loops=1)
	                                       Output: b.city, b.station_id_c
	                         Planning time: 0.794 ms
	                         Execution time: 286.883 ms
	 Planning time: 0.000 ms
	 Execution time: 1229.847 ms
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=njqa09 port=15432 dbname=weather_station
	         ->  Subquery Scan on t  (cost=28807.66..34888.01 rows=935 width=80) (actual time=1605.507..2133.768 rows=14 loops=1)
	               Output: t.station_id_c, t.datetime, t.tem, t.city
	               Filter: (t.rn = 1)
	               Rows Removed by Filter: 383655
	               ->  WindowAgg  (cost=28807.66..32549.42 rows=187088 width=88) (actual time=1605.503..2081.921 rows=383669 loops=1)
	                     Output: row_number() OVER (?), intermediate_result.station_id_c, intermediate_result.tem, intermediate_result.datetime, intermediate_result.city
	                     ->  Sort  (cost=28807.66..29275.38 rows=187088 width=80) (actual time=1605.495..1760.754 rows=383669 loops=1)
	                           Output: intermediate_result.tem, intermediate_result.city, intermediate_result.station_id_c, intermediate_result.datetime
	                           Sort Key: intermediate_result.city, intermediate_result.tem DESC
	                           Sort Method: external merge  Disk: 16272kB
	                           ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..4108.99 rows=187088 width=80) (actual time=620.173..792.174 rows=383669 loops=1)
	                                 Output: intermediate_result.tem, intermediate_result.city, intermediate_result.station_id_c, intermediate_result.datetime
	                                 Function Call: read_intermediate_result('4_1'::text, 'binary'::citus_copy_format)
	             Planning time: 0.205 ms
	             Execution time: 2143.378 ms
	 Planning time: 1.724 ms
	 Execution time: 4222.590 ms
	(51 rows)

	```
- q10_1day
	```bash
	#q10_1day
	explain analyze verbose 
	with c as (
		select a.station_id_c, a.datetime, a.tem, b.city
		from 
			t_msis_aws_min_pt a left join t_msis_cd_station_ref b on a.station_id_c = b.station_id_c
		where 
			datetime > '2022-02-06 08:00:00' and datetime < '2022-02-07 08:00:00'
				and a.tem < 100
	)
	select station_id_c, datetime, tem, city
	from (
	    select row_number() over (partition by c.city order by c.tem desc) as rn, c.station_id_c, c.tem, c.datetime, c.city
	    from c
	   ) t where rn = 1;
	                                                                                               QUERY PLAN
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=7935.177..7935.180 rows=14 loops=1)
	   Output: remote_scan.station_id_c, remote_scan.datetime, remote_scan.tem, remote_scan.city
	   ->  Distributed Subplan 6_1
	         ->  Custom Scan (Citus Adaptive)  (cost=0.00..0.00 rows=0 width=0) (actual time=2262.117..2472.114 rows=770021 loops=1)
	               Output: remote_scan.station_id_c, remote_scan.datetime, remote_scan.tem, remote_scan.city
	               Task Count: 3
	               Tasks Shown: One of 3
	               ->  Task
	                     Node: host=njqa09 port=15432 dbname=weather_station
	                     ->  Hash Left Join  (cost=5093.07..422639.27 rows=171860 width=32) (actual time=88.805..554.447 rows=266049 loops=1)
	                           Output: a.station_id_c, a.datetime, a.tem, b.city
	                           Hash Cond: (a.station_id_c = b.station_id_c)
	                           ->  Append  (cost=4957.19..420140.31 rows=171860 width=22) (actual time=86.030..414.803 rows=266049 loops=1)
	                                 ->  Bitmap Heap Scan on public.t_msis_aws_min_pt_202201_102720 a  (cost=4957.19..420140.31 rows=171860 width=22) (actual time=86.029..386.561 rows=266049 loops=1)
	                                       Output: a.station_id_c, a.datetime, a.tem
	                                       Recheck Cond: ((a.datetime > '2022-02-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-02-07 08:00:00'::timestamp without time zone))
	                                       Filter: (a.tem < '100'::double precision)
	                                       Rows Removed by Filter: 50512
	                                       Heap Blocks: exact=13838
	                                       ->  Bitmap Index Scan on idx_t_msis_aws_min_pt_202201_datetime_102720  (cost=0.00..4914.23 rows=203379 width=0) (actual time=81.411..81.412 rows=316561 loops=1)
	                                             Index Cond: ((a.datetime > '2022-02-06 08:00:00'::timestamp without time zone) AND (a.datetime < '2022-02-07 08:00:00'::timestamp without time zone))
	                           ->  Hash  (cost=90.39..90.39 rows=3639 width=15) (actual time=2.749..2.749 rows=3639 loops=1)
	                                 Output: b.city, b.station_id_c
	                                 Buckets: 4096  Batches: 1  Memory Usage: 206kB
	                                 ->  Seq Scan on public.t_msis_cd_station_ref_102360 b  (cost=0.00..90.39 rows=3639 width=15) (actual time=0.014..1.492 rows=3639 loops=1)
	                                       Output: b.city, b.station_id_c
	                         Planning time: 0.802 ms
	                         Execution time: 570.558 ms
	 Planning time: 0.000 ms
	 Execution time: 2528.831 ms
	   Task Count: 1
	   Tasks Shown: All
	   ->  Task
	         Node: host=njqa12 port=15432 dbname=weather_station
	         ->  Subquery Scan on t  (cost=59698.00..71901.22 rows=1877 width=80) (actual time=2882.739..3924.208 rows=14 loops=1)
	               Output: t.station_id_c, t.datetime, t.tem, t.city
	               Filter: (t.rn = 1)
	               Rows Removed by Filter: 770007
	               ->  WindowAgg  (cost=59698.00..67207.67 rows=375484 width=88) (actual time=2882.736..3820.764 rows=770021 loops=1)
	                     Output: row_number() OVER (?), intermediate_result.station_id_c, intermediate_result.tem, intermediate_result.datetime, intermediate_result.city
	                     ->  Sort  (cost=59698.00..60636.71 rows=375484 width=80) (actual time=2882.727..3190.704 rows=770021 loops=1)
	                           Output: intermediate_result.tem, intermediate_result.city, intermediate_result.station_id_c, intermediate_result.datetime
	                           Sort Key: intermediate_result.city, intermediate_result.tem DESC
	                           Sort Method: external merge  Disk: 32648kB
	                           ->  Function Scan on pg_catalog.read_intermediate_result intermediate_result  (cost=0.00..8246.71 rows=375484 width=80) (actual time=1198.868..1525.185 rows=770021 loops=1)
	                                 Output: intermediate_result.tem, intermediate_result.city, intermediate_result.station_id_c, intermediate_result.datetime
	                                 Function Call: read_intermediate_result('6_1'::text, 'binary'::citus_copy_format)
	             Planning time: 0.239 ms
	             Execution time: 3939.397 ms
	 Planning time: 1.819 ms
	 Execution time: 7935.219 ms
	(51 rows)

	```
