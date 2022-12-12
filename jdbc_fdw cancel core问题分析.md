# 01:问题现象
查询jdbc_fdw外表时，取消查询，大概率会导致pg server 挂掉，重启
# 02: 定位日志
1. 直接down掉
	![[Pasted image 20221206154700.png]]
2. 正确取消
	![[Pasted image 20221206154737.png]]
3. 时间长一点的查询
	![[Pasted image 20221206164653.png]]
4. GDB调试追踪
![[Pasted image 20221207121349.png]]
5. 出现问题的调用栈
	```bash
	Program received signal SIGINT, Interrupt.
	
	Program received signal SIGABRT, Aborted.
	[Switching to Thread 0x7eff57b4c700 (LWP 38528)]
	0x00007effcc268387 in raise () from /lib64/libc.so.6
	(gdb) bt
	#0  0x00007effcc268387 in raise () from /lib64/libc.so.6
	#1  0x00007effcc269a78 in abort () from /lib64/libc.so.6
	#2  0x00007effc977ba95 in __gnu_cxx::__verbose_terminate_handler() () from /lib64/libstdc++.so.6
	#3  0x00007effc9779a06 in ?? () from /lib64/libstdc++.so.6
	#4  0x00007effc9779a33 in std::terminate() () from /lib64/libstdc++.so.6
	#5  0x00007effc977a59f in __cxa_pure_virtual () from /lib64/libstdc++.so.6
	#6  0x00007effbc79e1b9 in outputStream::print_cr(char const*, ...) () from /lib64/libjvm.so
	#7  0x00007effbc9b2597 in VMError::report(outputStream*) () from /lib64/libjvm.so
	#8  0x00007effbc9b3fdd in VMError::report_and_die() () from /lib64/libjvm.so
	#9  0x00007effbc797a25 in JVM_handle_linux_signal () from /lib64/libjvm.so
	#10 0x00007effbc78a888 in signalHandler(int, siginfo_t*, void*) () from /lib64/libjvm.so
	#11 <signal handler called>
	#12 0x00007effbc4f0967 in java_lang_Thread::threadGroup(oopDesc*) () from /lib64/libjvm.so
	#13 0x00007effbc95b2b1 in JavaThread::exit(bool, JavaThread::ExitType) () from /lib64/libjvm.so
	#14 0x00007effbc54b955 in jni_DetachCurrentThread () from /lib64/libjvm.so
	#15 0x00007effbd14ab85 in jdbcfdw_xact_callback (event=XACT_EVENT_ABORT, arg=<optimized out>) at connection.c:569
	#16 0x00000000004eb9dc in CallXactCallbacks (event=XACT_EVENT_ABORT) at xact.c:3397
	#17 AbortTransaction () at xact.c:2641
	#18 0x00000000004ec2ed in AbortOutOfAnyTransaction () at xact.c:4317
	#19 0x0000000000810339 in ShutdownPostgres (code=<optimized out>, arg=<optimized out>) at postinit.c:1148
	#20 0x00000000006ea0fd in shmem_exit (code=code@entry=-1) at ipc.c:228
	#21 0x00000000006ea1de in proc_exit_prepare (code=-1) at ipc.c:185
	#22 0x00007effcc26bce9 in __run_exit_handlers () from /lib64/libc.so.6
	#23 0x00007effcc26bd37 in exit () from /lib64/libc.so.6
	#24 0x00007effbc4e718c in vm_direct_exit(int) () from /lib64/libjvm.so
	#25 0x00007effbc9bb195 in VM_Operation::evaluate() () from /lib64/libjvm.so
	#26 0x00007effbc9b915a in VMThread::evaluate_operation(VM_Operation*) () from /lib64/libjvm.so
	#27 0x00007effbc9b95c9 in VMThread::loop() () from /lib64/libjvm.so
	#28 0x00007effbc9b9a85 in VMThread::run() () from /lib64/libjvm.so
	#29 0x00007effbc78c782 in java_start(Thread*) () from /lib64/libjvm.so
	#30 0x00007effce7aeea5 in start_thread () from /lib64/libpthread.so.0
	#31 0x00007effcc330b0d in clone () from /lib64/libc.so.6
	
	```
6. 某次成功的代码路径
	```bash
	
	Program received signal SIGINT, Interrupt.
	
	Breakpoint 1, StatementCancelHandler (postgres_signal_arg=2) at postgres.c:2678
	2678    {
	(gdb) n
	2679            int                     save_errno = errno;
	(gdb) n
	2684            if (!proc_exit_inprogress)
	(gdb) n
	2679            int                     save_errno = errno;
	(gdb) n
	2684            if (!proc_exit_inprogress)
	(gdb) n
	2686                    InterruptPending = true;
	(gdb) p proc_exit_inprocess
	No symbol "proc_exit_inprocess" in current context.
	(gdb) n
	2687                    QueryCancelPending = true;
	(gdb) n
	2691            SetLatch(MyLatch);
	(gdb) n
	2693            errno = save_errno;
	(gdb) n
	2694    }
	(gdb) n
	0x00007effcc3310c3 in __epoll_wait_nocancel () from /lib64/libc.so.6
	(gdb) n
	Single stepping until exit from function __epoll_wait_nocancel,
	which has no line number information.
	0x00007effcc3310ff in epoll_wait () from /lib64/libc.so.6
	(gdb) n
	Single stepping until exit from function epoll_wait,
	which has no line number information.
	WaitEventSetWaitBlock (nevents=1, occurred_events=0x7ffc0653b370, cur_timeout=-1, set=0x28a6828) at latch.c:1052
	1052            if (rc < 0)
	(gdb) n
	1055                    if (errno != EINTR)
	(gdb) n
	WaitEventSetWait (set=0x28a6828, timeout=timeout@entry=-1, occurred_events=occurred_events@entry=0x7ffc0653b370, nevents=nevents@entry=1, wait_event_info=wait_event_info@entry=100663296) at latch.c:1009
	1009                    if (returned_events == 0 && timeout >= 0)
	(gdb) n
	982                     if (set->latch && set->latch->is_set)
	(gdb) n
	984                             occurred_events->fd = PGINVALID_SOCKET;
	(gdb) n
	990                             returned_events++;
	(gdb) n
	984                             occurred_events->fd = PGINVALID_SOCKET;
	(gdb) n
	985                             occurred_events->pos = set->latch_pos;
	(gdb) n
	987                                     set->events[set->latch_pos].user_data;
	(gdb) n
	988                             occurred_events->events = WL_LATCH_SET;
	(gdb) n
	986                             occurred_events->user_data =
	(gdb) n
	992                             break;
	(gdb) n
	1022            pgstat_report_wait_end();
	(gdb) n
	1019            waiting = false;
	(gdb) n
	1022            pgstat_report_wait_end();
	(gdb) n
	1025    }
	(gdb) n
	secure_read (port=0x28cdc00, ptr=0xc9b6e0 <PqRecvBuffer>, len=8192) at be-secure.c:189
	189                     if (event.events & WL_POSTMASTER_DEATH)
	(gdb) n
	195                     if (event.events & WL_LATCH_SET)
	(gdb) n
	197                             ResetLatch(MyLatch);
	(gdb) n
	198                             ProcessClientReadInterrupt(true);
	(gdb) n
	149             if (port->ssl_in_use)
	(gdb) n
	148             waitfor = 0;
	(gdb) n
	149             if (port->ssl_in_use)
	(gdb) n
	156                     n = secure_raw_read(port, ptr, len);
	(gdb) n
	157                     waitfor = WL_SOCKET_READABLE;
	(gdb) n
	161             if (n < 0 && !port->noblock && (errno == EWOULDBLOCK || errno == EAGAIN))
	(gdb) n
	213             ProcessClientReadInterrupt(false);
	(gdb) n
	216     }
	(gdb) n
	pq_recvbuf () at pqcomm.c:966
	966                     if (r < 0)
	(gdb) n
	981                     if (r == 0)
	(gdb) n
	990                     PqRecvLength += r;
	(gdb) n
	991                     return 0;
	(gdb) n
	993     }
	(gdb) n
	pq_getbyte () at pqcomm.c:1004
	1004            while (PqRecvPointer >= PqRecvLength)
	(gdb) n
	1009            return (unsigned char) PqRecvBuffer[PqRecvPointer++];
	(gdb) n
	1010    }
	(gdb) n
	SocketBackend (inBuf=0x7ffc0653b4e0) at postgres.c:330
	330             if (qtype == EOF)                       /* frontend disconnected */
	(gdb) n
	328             qtype = pq_getbyte();
	(gdb) n
	330             if (qtype == EOF)                       /* frontend disconnected */
	(gdb) n
	359             switch (qtype)
	(gdb) n
	363                             if (PG_PROTOCOL_MAJOR(FrontendProtocol) < 3)
	(gdb) n
	362                             doing_extended_query_message = false;
	(gdb) n
	363                             if (PG_PROTOCOL_MAJOR(FrontendProtocol) < 3)
	(gdb) n
	478                     if (pq_getmessage(inBuf, 0))
	(gdb) n
	483             RESUME_CANCEL_INTERRUPTS();
	(gdb) n
	PostgresMain (argc=<optimized out>, argv=argv@entry=0x28d3478, dbname=0x28d3358 "postgres", username=<optimized out>) at postgres.c:4089
	4089                    if (disable_idle_in_transaction_timeout)
	(gdb) n
	4104                    CHECK_FOR_INTERRUPTS();
	(gdb) n
	4111                    if (ConfigReloadPending)
	(gdb) n
	4105                    DoingCommandRead = false;
	(gdb) n
	4111                    if (ConfigReloadPending)
	(gdb) n
	4121                    if (ignore_till_sync && firstchar != EOF)
	(gdb) n
	4124                    switch (firstchar)
	(gdb) n
	4131                                            SetCurrentStatementStartTimestamp();
	(gdb) n
	4133                                            query_string = pq_getmsgstring(&input_message);
	(gdb) n
	4134                                            pq_getmsgend(&input_message);
	(gdb) n
	4133                                            query_string = pq_getmsgstring(&input_message);
	(gdb) n
	4134                                            pq_getmsgend(&input_message);
	(gdb) n
	4136                                            if (am_walsender)
	(gdb) n
	4138                                                    if (!exec_replication_command(query_string))
	(gdb) n
	4136                                            if (am_walsender)
	(gdb) n
	4142                                                    exec_simple_query(query_string);
	(gdb) nn
	Undefined command: "nn".  Try "help".
	(gdb) n
	n
	3977                    send_ready_for_query = true;    /* initially, or after error */
	(gdb) n
	3995                    MemoryContextSwitchTo(MessageContext);
	(gdb) n
	3989                    doing_extended_query_message = false;
	(gdb) n
	3995                    MemoryContextSwitchTo(MessageContext);
	(gdb) n
	3996                    MemoryContextResetAndDeleteChildren(MessageContext);
	(gdb) n
	3998                    initStringInfo(&input_message);
	(gdb) n
	4004                    InvalidateCatalogSnapshotConditionally();
	(gdb) n
	4019                    if (send_ready_for_query)
	(gdb) n
	4021                            if (IsAbortedTransactionBlockState())
	(gdb) n
	4034                            else if (IsTransactionOrTransactionBlock())
	(gdb) n
	4050                                    ProcessCompletedNotifies();
	(gdb) n
	4058                                    if (notifyInterruptPending)
	(gdb) n
	4061                                    pgstat_report_stat(false);
	(gdb) n
	4063                                    set_ps_display("idle", false);
	(gdb) n
	4064                                    pgstat_report_activity(STATE_IDLE, NULL);
	(gdb) n
	4067                            ReadyForQuery(whereToSendOutput);
	(gdb) n
	4082                    firstchar = ReadCommand(&input_message);
	(gdb) n
	4068                            send_ready_for_query = false;
	(gdb) n
	4077                    DoingCommandRead = true;
	(gdb) n
	4082                    firstchar = ReadCommand(&input_message);
	
	```
# 03: 解决方法
# 04: 根因分析 
> 分析导致问题的根因
# 05: 扩展
1. jvm crash with SIGSEGV `SIGINT is an _asynchronous signal_; it can occur between any two machine instructions unless blocked.`
	- [参考：](https://stackoverflow.com/questions/12433751/handling-signals-in-native-code-with-jvm-crash-with-sigsegv-in-terminal)
	- [解决：](https://docs.oracle.com/javase/7/docs/technotes/guides/vm/signal-chaining.html)
2. GDB调试相关
	[[gdb]]
3. linux中 jvm处理信号的办法
>	The approach usually used for handling `SIGINT` is to have a loop somewhere which checks a flag variable (of type `sig_atomic_t`). When you get a `SIGINT`, set the flag and return. The loop will come around and execute the rest of the handler in a safe, synchronous fashion.
# 06: 总结

#参考
# 07: 操作步骤
```sql
-- 建表 生成数据
create table tt03

(

    D_RECORD_ID serial not null,

    D_DATA_ID char(50),

    D_IYMDHM date,

    D_RYMDHM date,

    D_UPDATE_TIME timestamp,

    D_DATETIME numeric,

    D_DATETIME_MET timestamp,

    V_EVN numeric,

    D_FORETIME numeric,

    D_FORETIME_MET timestamp,

    V_LEVEL numeric,

    V_LATEND numeric,

    V_LATSTART numeric,

    V_LONEND numeric,

    V_LONSTART numeric,

    V_ELE_CODE char(50),

    V_DATA geometry,

    GEOM geometry

);

insert into

    tt03

select

    id,

    '12312312',

    current_date,

    current_date,

    current_timestamp,

    1990010100+id,

    current_timestamp,

    1990010100+id,

    1990010100+id,

    current_timestamp,

    id,

    id,

    id,

    id,

    id,

    case

     when id % 2 = 1 then 'tmp'

     else 'ttt'

    end,

    st_point(116.19485438405336,40.137772093515686),

    st_point(116.19485438405336,40.137772093515686)

  
from

    generate_series(1,1000000) as id;
```

```sql
-- jdbc_fdw操作
CREATE SERVER  pg_server FOREIGN DATA WRAPPER jdbc_fdw OPTIONS(
	drivername 'org.postgresql.Driver',
	url 'jdbc:postgresql://172.16.3.124:5001/postgres',
	querytimeout '5000',
	jarfile '/home/postgres/postgresql-42.5.1.jar',
	maxheapsize '3000'
);

CREATE USER MAPPING FOR CURRENT_USER SERVER pg_server OPTIONS(username 'postgres',password '');

create  foreign table f_tt03
(
    D_RECORD_ID serial not null,

    D_DATA_ID char(50),

    D_IYMDHM date,

    D_RYMDHM date,

    D_UPDATE_TIME timestamp,

    D_DATETIME numeric,

    D_DATETIME_MET timestamp,

    V_EVN numeric,

    D_FORETIME numeric,

    D_FORETIME_MET timestamp,

    V_LEVEL numeric,

    V_LATEND numeric,

    V_LATSTART numeric,

    V_LONEND numeric,

    V_LONSTART numeric,

    V_ELE_CODE char(50),

    V_DATA geometry,

    GEOM geometry

)  SERVER pg_server options(table_name 'tt03');
```
```bash
# gdb 调试
b StatementCancelHandler
b jdbcfdw_xact_callback
```