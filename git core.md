# log
```text
2024-05-15 08:44:48.854 UTC [1] LOG:  database system is ready to accept connections
2024-05-15 08:46:10.667 UTC [1] LOG:  server process (PID 269) was terminated by signal 11: Segmentation fault
2024-05-15 08:46:10.667 UTC [1] DETAIL:  Failed process was running: /*application:sidekiq,correlation_id:0a8014f206ba9195812665d75b7061ff,jid:7f65b378cd8ad146b55878ae,endpoint_id:LooseForeignKeys::CleanupWorker,db_config_name:main*/ DELETE FROM "ci_pipelines" WHERE ("ci_pipelines"."id") IN (SELECT "ci_pipelines"."id" FROM "ci_pipelines" WHERE "ci_pipelines"."merge_request_id" IN (220006, 218919, 219455, 219460, 219485, 218572, 218367, 218374, 218494, 219336, 219156, 219546, 219874, 220044, 220222, 245823) LIMIT 1000 FOR UPDATE SKIP LOCKED)
2024-05-15 08:46:10.667 UTC [1] LOG:  terminating any other active server processes
```
# core
```cpp
#0  0x00007f83eb2b98d8 in execute_attr_map_slot ()
#1  0x00007f83eb42d618 in ?? ()
#2  0x00007f83eb433295 in ExecARDeleteTriggers ()
#3  0x00007f83eb47629d in ?? ()
#4  0x00007f83eb477e5d in ?? ()
#5  0x00007f83eb4512ed in standard_ExecutorRun ()
#6  0x00007f83eb487a82 in ?? ()
#7  0x00007f83eb4882ed in SPI_execute_snapshot ()
#8  0x00007f83eb66d3f0 in ?? ()
#9  0x00007f83eb66ec21 in RI_FKey_cascade_del ()
#10 0x00007f83eb42ce87 in ?? ()
#11 0x00007f83eb42e5cd in ?? ()
#12 0x00007f83eb434318 in AfterTriggerEndQuery ()
#13 0x00007f83eb451573 in standard_ExecutorFinish ()
#14 0x00007f83eb5ae2a0 in ?? ()
#15 0x00007f83eb5ae493 in ?? ()
#16 0x00007f83eb5af08f in PortalRun ()
#17 0x00007f83eb5aadef in ?? ()
#18 0x00007f83eb5acf90 in PostgresMain ()
#19 0x00007f83eb53329d in ?? ()
#20 0x00007f83eb53426b in PostmasterMain ()
#21 0x00007f83eb2aafd6 in main ()
```