
# 01. 环境准备
## mysql 编译配置
```bash
-DCMAKE_BUILD_TYPE=RelWithDebInfo # 启用优化并生成调试信息。这是默认的 MySQL 构建类型。
```
## core设置

1. 设置ulimit

	```bash
	ulimit -c unlimited
	```

2. 设置core文件名称格式、存储路径

	```bash
	mkdir -p /root/sync/corefile
	sysctl -w kernel.core_pattern="/root/sync/corefile/core.%e.%p.%s.%E"
	sysctl kernel.core_pattern
	```
## 使用sanitizer
```bash
# 查看是否含有依赖
locate asan
# CMAKE编译添加
-DCMAKE_CXX_FLAGS=-fsanitize=address
```
# 02 CORE问题
## 场景1
```text
版本：release  
并发：100  
表：16 个
数据行数：100万  
脚本：oltp_write_only.lua 
环境：机械盘 26 
mysql配置项:
binlog-transaction-dependency-tracking = WRITESET_SESSION
```

该场景下发起sysbench测试会产生core问题
core中的报错信息
```cpp
... ...
#3  0x00007f875a44c2fc in malloc_printerr (str=str@entry=0x7f875a570628 "double free or corruption (fasttop)") at malloc.c:5347
... ...
```

该问题属于内存问题，使用使用sanitizer分析内存问题，得到结果如下：
```cpp
540887==ERROR: AddressSanitizer: heap-use-after-free on address 0x604001022568 at pc 0x55f62c7b238b bp 0x7fc3c58ef870 sp 0x7fc3c58ef860
READ of size 8 at 0x604001022568 thread T100
    #0 0x55f62c7b238a in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df138a)
    ... ...

0x604001022568 is located 24 bytes inside of 48-byte region [0x604001022550,0x604001022580)
freed by thread T134 here:
    #0 0x7ff2cf84651f in operator delete(void*) ../../../../src/libsanitizer/asan/asan_new_delete.cc:165
    ... ...

previously allocated by thread T78 here:
    #0 0x7ff2cf845587 in operator new(unsigned long) ../../../../src/libsanitizer/asan/asan_new_delete.cc:104
    ... ...
... ...

SUMMARY: AddressSanitizer: heap-use-after-free (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df138a) in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*)
... ...
540887==ABORTING
```

### 结论
1. 使用writeset时，对同一个内存区域调用了两次free，具体的代码表现为:在满足条件时会清空writeset
	```cpp
	if (exceeds_capacity || !can_use_writesets) {  
	  m_writeset_history_start = sequence_number;  
	  m_writeset_history.clear();  
	}
	```
2. 该内存区域在多个线程中间共享，表明至少是一个线程共享资源
3. 由于改代码段从串行改为并行，导致线程间内存冲突
### 方法
将配置项修改为'binlog-transaction-dependency-tracking = COMMIT_ORDER'可以在不影响当前测试结果的情况下短暂规避该问题
### 补充背景 WRITESET


## 场景2
```text
版本：release  
并发：100  
表：16 个
数据行数：100万  
脚本：oltp_write_only.lua 
环境：机械盘 26 
mysql配置项:
binlog-transaction-dependency-tracking = COMMIT_ORDER
```
在场景1解决后，继续sysbench测试碰到了如下segment fault
```cpp
#0  __pthread_kill (threadid=<optimized out>, signo=signo@entry=11) at ../sysdeps/unix/sysv/linux/pthread_kill.c:56
#1  0x000056018126372f in my_write_core (sig=sig@entry=11) at /root/sync/mysql/include/my_thread.h:78
#2  0x000056017c80d66d in handle_fatal_signal (sig=11) at /root/sync/mysql/sql/signal_handler.cc:202
#3  <signal handler called>
#4  0x000056018026a635 in binlog_cache_data::flush (this=this@entry=0x619000962a60, thd=thd@entry=0x627000600900, bytes_written=bytes_written@entry=0x7f7465721290, 
    wrote_xid=wrote_xid@entry=0x7f7465721260) at /root/sync/mysql/sql/sql_class.h:4728
#5  0x000056018026ae84 in binlog_cache_mngr::flush (wrote_xid=0x7f7465721260, bytes_written=<synthetic pointer>, thd=0x627000600900, this=0x6190009628a0) at /root/sync/mysql/sql/binlog.cc:1316
#6  MYSQL_BIN_LOG::flush_thread_caches (this=this@entry=0x560185ab0480 <mysql_bin_log>, thd=thd@entry=0x627000600900) at /root/sync/mysql/sql/binlog.cc:9026
... ...
```
调试core文件打印发现，'thd->m_pending_flush_task'该指针为空
```cpp
(gdb) f 5
#5  0x000056018026ae84 in binlog_cache_mngr::flush (wrote_xid=0x7f7465721260, bytes_written=<synthetic pointer>, thd=0x627000600900, this=0x6190009628a0) at /root/sync/mysql/sql/binlog.cc:1316
1316        error = trx_cache.flush(thd, &trx_bytes, wrote_xid);
(gdb) p thd->m_pending_flush_task
$1 = (Flush_task *) 0x0
```
引发错误的代码
```cpp
if (max_parallel_flush_group > 1) {  
  assert(thd->get_flush_task() != nullptr);  
  cache = thd->get_flush_task()->cache_storage ;  // get_flush_stack()返回指针为空，进一步调用引发错误
  pos = thd->get_flush_task()->initial_end_log_pos;  
}
```
搜索代码中何处将该指针置为空值，发现只有在另外一个process_flush_task线程中存在该资源的清理情况
```cpp
for(size_t i = 0; i < flush_tasks.size(); i++) {  
  task = flush_tasks[i];  
  while(task->flush_state != FLUSHSTATE_WRITTEN) {  
    task->wait_on_state(&parallel_flush_mngr.m_wait_written_lock, &parallel_flush_mngr.m_wait_written_cond,  
                        FLUSHSTATE_WRITTEN);  
  }  if (mysql_bin_log.do_write_cache(task->cache_storage, &writer))  
    return true;  
}  
PFS_TEST_BEGIN(start);  
parallel_flush_mngr.change_task_state_vec(flush_tasks, FLUSHSTATE_FLUSHED);  
PFS_TEST_END(start,flush_thread_change_task_state_time_cnt);  
for(size_t i = 0; i < flush_tasks.size(); i++) {  
  task = flush_tasks[i];  
  PFS_TEST_BEGIN(start);  
  parallel_flush_manager_unregister_task(task->leader);         // 此处在flush完成后会将一组task置为nullptr
  PFS_TEST_END(start,flush_thread_unregister_task_time_cnt);  
}
```
正常的逻辑应该是
1. 主线程register task为group内的每个thd->m_pending_flush_task赋值，发出信号
2. process_flush_task线程收到信号完成flush工作，清理资源，发出信号可以继续下一轮工作
此时出现问题，主线程中register完成后要进一步flush binlog cache时，该指针被置空

### 怀疑项
1. flush task 中的thd比register task中的thd更多，导致并非每个thd都成功赋值
	```cpp
		// register task
		for (THD *head = thd; head; head = head->next_to_commit) {  
		  head->set_flush_task(enqueued);  
		}
		 // flush 
		for (THD *head = first_seen; head; head = head->next_to_commit) {  
		    Thd_backup_and_restore switch_thd(current_thd, head);  
		    std::pair<int, my_off_t> result = flush_thread_caches(head);  
		    total_bytes += result.second;  
		    if (flush_error == 1) flush_error = result.first;  
		#ifndef NDEBUG  
		    no_flushes++;  
		#endif  
		  }
	```
2. 并行控制逻辑出现问题
	```cpp
	parallel_flush_mngr.change_task_state_vec(flush_tasks, FLUSHSTATE_FLUSHED);  
	PFS_TEST_END(start,flush_thread_change_task_state_time_cnt);  
	for(size_t i = 0; i < flush_tasks.size(); i++) {  
	  task = flush_tasks[i];  
	  PFS_TEST_BEGIN(start);  
	  parallel_flush_manager_unregister_task(task->leader);  
	  PFS_TEST_END(start,flush_thread_unregister_task_time_cnt);  
	}
	```
### 结论
1. 针对怀疑项一，在两个阶段添加变量nums，打印输出发现个数相等
2. 针对怀疑项二，在unregister函数中注释指针置空语句，问题消失
## 场景3
```text
版本：release  
并发：100  
表：16 个
数据行数：100万  
脚本：oltp_write_only.lua 
环境：机械盘 26 
mysql配置项:
--debug=d,info
```
```cpp
(gdb) bt
#0  0x000055555b1ae6a0 in Binlog_event_writer::Binlog_event_writer (simple_writer=true, binlog_file=0x0, this=0x7fd0f3646900) at /root/sync/mysql/sql/binlog.cc:617
#1  process_flush_task (flush_tasks=...) at /root/sync/mysql/sql/binlog.cc:12646
#2  0x000055555b1afc69 in process_binlog_flush_tasks (mngr=<optimized out>) at /usr/include/c++/9/bits/stl_algobase.h:465
#3  0x000055555b1b00a6 in flush_binlog (arg=arg@entry=0x0) at /root/sync/mysql/sql/binlog.cc:12724
#4  0x000055555d78260b in pfs_spawn_thread (arg=0x61400019f060) at /root/sync/mysql/storage/perfschema/pfs.cc:2942
#5  0x00007ffff7570609 in start_thread (arg=<optimized out>) at pthread_create.c:477
#6  0x00007ffff6c30133 in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95
(gdb) f 0
#0  0x000055555b1ae6a0 in Binlog_event_writer::Binlog_event_writer (simple_writer=true, binlog_file=0x0, this=0x7fd0f3646900) at /root/sync/mysql/sql/binlog.cc:617
617	in /root/sync/mysql/sql/binlog.cc
(gdb) p binlog_file
$2 = (MYSQL_BIN_LOG::Binlog_ofile *) 0x0
```
全局搜索该指针会在binlog清理时清掉该指针，添加打印
后续复现场景发现如下日志
```bash
2024-03-07T08:25:51.005125Z 0 [ERROR] [MY-000067] [Server] unknown variable 'debug=d,info'.
2024-03-07T08:25:51.005261Z 0 [ERROR] [MY-010119] [Server] Aborting
... ...
2024-03-07T08:25:51.974087Z 0 [Note] [MY-010120] [Server] Binlog end
 MYSQL_BIN_LOG cleanup
.... ...
2024-03-07T08:25:51.977612Z 0 [Note] [MY-011944] [InnoDB] Buffer pool(s) dump completed at 240307  8:25:51
2024-03-07T08:25:51.981002Z 0 [Note] [MY-013084] [InnoDB] Log background threads are being closed...
```
在之后才发生上述情况
### 总结
--debug=d,info为debug版本可用参数，release版本不识别，导致mysqld启动退出，退出过程中清理了binlog，在这之后process_flush_task意外启动，导致core报错
# 附录
##  场景1
```cpp
```cpp
#0  __GI_raise (sig=sig@entry=6) at ../sysdeps/unix/sysv/linux/raise.c:50
#1  0x00007f875a3d9859 in __GI_abort () at abort.c:79
#2  0x00007f875a44426e in __libc_message (action=action@entry=do_abort, fmt=fmt@entry=0x7f875a56e298 "%s\n") at ../sysdeps/posix/libc_fatal.c:155
#3  0x00007f875a44c2fc in malloc_printerr (str=str@entry=0x7f875a570628 "double free or corruption (fasttop)") at malloc.c:5347
#4  0x00007f875a44dc65 in _int_free (av=0x7f7604000020, p=0x7f76041cf970, have_lock=0) at malloc.c:4266
#5  0x000055fc1065a6ce in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#6  0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#7  0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#8  0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#9  0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#10 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#11 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#12 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#13 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#14 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#15 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#16 0x000055fc1065a6c2 in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) ()
#17 0x000055fc106bdeb0 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) ()
#18 0x000055fc106be0f7 in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) ()
#19 0x000055fc1066c1f1 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) ()
#20 0x000055fc1066c772 in binlog_cache_data::flush(THD*, unsigned long long*, bool*) ()
#21 0x000055fc1066c887 in MYSQL_BIN_LOG::flush_thread_caches(THD*) ()
#22 0x000055fc1066cbfe in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) ()
#23 0x000055fc1066ce7a in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) ()
#24 0x000055fc1066f012 in MYSQL_BIN_LOG::commit(THD*, bool) ()
#25 0x000055fc0f9e6d8c in ha_commit_trans(THD*, bool, bool) ()
#26 0x000055fc0f840ce3 in trans_commit(THD*, bool) ()
#27 0x000055fc0f70ba90 in mysql_execute_command(THD*, bool) ()
#28 0x000055fc0f73e250 in Prepared_statement::execute(String*, bool) ()
#29 0x000055fc0f742b3e in Prepared_statement::execute_loop(String*, bool) ()
#30 0x000055fc0f743261 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) ()
#31 0x000055fc0f7110c0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) ()
#32 0x000055fc0f711b77 in do_command(THD*) ()
#33 0x000055fc0f884848 in handle_connection ()
#34 0x000055fc11179e39 in pfs_spawn_thread ()
#35 0x00007f875ad33609 in start_thread (arg=<optimized out>) at pthread_create.c:477
#36 0x00007f875a4d6133 in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95
```

```cpp
540887==ERROR: AddressSanitizer: heap-use-after-free on address 0x604001022568 at pc 0x55f62c7b238b bp 0x7fc3c58ef870 sp 0x7fc3c58ef860
READ of size 8 at 0x604001022568 thread T100
    #0 0x55f62c7b238a in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df138a)
    #1 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #2 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #3 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #4 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #5 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #6 0x55f62c91a360 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59360)
    #7 0x55f62c91af8f in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59f8f)
    #8 0x55f62c7f0d11 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e2fd11)
    #9 0x55f62c7f1fdf in binlog_cache_data::flush(THD*, unsigned long long*, bool*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e30fdf)
    #10 0x55f62c7f2513 in MYSQL_BIN_LOG::flush_thread_caches(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e31513)
    #11 0x55f62c7f32db in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e322db)
    #12 0x55f62c7f3fd5 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e32fd5)
    #13 0x55f62c7fa1dd in MYSQL_BIN_LOG::commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e391dd)
    #14 0x55f62914efc0 in ha_commit_trans(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x278dfc0)
    #15 0x55f628b89c12 in trans_commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x21c8c12)
    #16 0x55f6286e9c59 in mysql_execute_command(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d28c59)
    #17 0x55f62879379d in Prepared_statement::execute(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1dd279d)
    #18 0x55f6287a3f47 in Prepared_statement::execute_loop(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de2f47)
    #19 0x55f6287a5487 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de4487)
    #20 0x55f6286f6fc0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d35fc0)
    #21 0x55f6286ff569 in do_command(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d3e569)
    #22 0x55f628c731d7 in handle_connection (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b21d7)
    #23 0x55f62ef8b380 in pfs_spawn_thread (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85ca380)
    #24 0x7ff2cf711608 in start_thread /build/glibc-BHL3KM/glibc-2.31/nptl/pthread_create.c:477
    #25 0x7ff2cedc0132 in __clone (/lib/x86_64-linux-gnu/libc.so.6+0x11f132)

0x604001022568 is located 24 bytes inside of 48-byte region [0x604001022550,0x604001022580)
freed by thread T134 here:
    #0 0x7ff2cf84651f in operator delete(void*) ../../../../src/libsanitizer/asan/asan_new_delete.cc:165
    #1 0x55f62c7b235f in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df135f)
    #2 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #3 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #4 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #5 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #6 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #7 0x55f62c91a360 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59360)
    #8 0x55f62c91af8f in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59f8f)
    #9 0x55f62c7f0d11 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e2fd11)
    #10 0x55f62c7f1fdf in binlog_cache_data::flush(THD*, unsigned long long*, bool*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e30fdf)
    #11 0x55f62c7f2513 in MYSQL_BIN_LOG::flush_thread_caches(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e31513)
    #12 0x55f62c7f32db in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e322db)
    #13 0x55f62c7f3fd5 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e32fd5)
    #14 0x55f62c7fa1dd in MYSQL_BIN_LOG::commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e391dd)
    #15 0x55f62914efc0 in ha_commit_trans(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x278dfc0)
    #16 0x55f628b89c12 in trans_commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x21c8c12)
    #17 0x55f6286e9c59 in mysql_execute_command(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d28c59)
    #18 0x55f62879379d in Prepared_statement::execute(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1dd279d)
    #19 0x55f6287a3f47 in Prepared_statement::execute_loop(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de2f47)
    #20 0x55f6287a5487 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de4487)
    #21 0x55f6286f6fc0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d35fc0)
    #22 0x55f6286ff569 in do_command(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d3e569)
    #23 0x55f628c731d7 in handle_connection (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b21d7)
    #24 0x55f62ef8b380 in pfs_spawn_thread (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85ca380)
    #25 0x7ff2cf711608 in start_thread /build/glibc-BHL3KM/glibc-2.31/nptl/pthread_create.c:477

previously allocated by thread T78 here:
    #0 0x7ff2cf845587 in operator new(unsigned long) ../../../../src/libsanitizer/asan/asan_new_delete.cc:104
    #1 0x55f62c9198ed in std::pair<std::_Rb_tree_iterator<std::pair<unsigned long const, long> >, bool> std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_emplace_unique<std::pair<unsigned long, long> >(std::pair<unsigned long, long>&&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f588ed)
    #2 0x55f62c91ac45 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59c45)
    #3 0x55f62c91af8f in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59f8f)
    #4 0x55f62c7f0d11 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e2fd11)
    #5 0x55f62c7f1fdf in binlog_cache_data::flush(THD*, unsigned long long*, bool*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e30fdf)
    #6 0x55f62c7f2513 in MYSQL_BIN_LOG::flush_thread_caches(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e31513)
    #7 0x55f62c7f32db in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e322db)
    #8 0x55f62c7f3fd5 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e32fd5)
    #9 0x55f62c7fa1dd in MYSQL_BIN_LOG::commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e391dd)
    #10 0x55f62914efc0 in ha_commit_trans(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x278dfc0)
    #11 0x55f628b89c12 in trans_commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x21c8c12)
    #12 0x55f6286e9c59 in mysql_execute_command(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d28c59)
    #13 0x55f62879379d in Prepared_statement::execute(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1dd279d)
    #14 0x55f6287a3f47 in Prepared_statement::execute_loop(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de2f47)
    #15 0x55f6287a5487 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de4487)
    #16 0x55f6286f6fc0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d35fc0)
    #17 0x55f6286ff569 in do_command(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d3e569)
    #18 0x55f628c731d7 in handle_connection (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b21d7)
    #19 0x55f62ef8b380 in pfs_spawn_thread (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85ca380)
    #20 0x7ff2cf711608 in start_thread /build/glibc-BHL3KM/glibc-2.31/nptl/pthread_create.c:477

Thread T100 created by T0 here:
    #0 0x7ff2cf770815 in __interceptor_pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cc:208
    #1 0x55f62ef7552a in pfs_spawn_thread_vc(unsigned int, unsigned int, my_thread_handle*, pthread_attr_t const*, void* (*)(void*), void*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85b452a)
    #2 0x55f628c74274 in Per_thread_connection_handler::add_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b3274)
    #3 0x55f629030892 in Connection_handler_manager::process_new_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x266f892)
    #4 0x55f6282c01f2 in mysqld_main(int, char**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x18ff1f2)
    #5 0x7ff2cecc5082 in __libc_start_main ../csu/libc-start.c:308

Thread T134 created by T0 here:
    #0 0x7ff2cf770815 in __interceptor_pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cc:208
    #1 0x55f62ef7552a in pfs_spawn_thread_vc(unsigned int, unsigned int, my_thread_handle*, pthread_attr_t const*, void* (*)(void*), void*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85b452a)
    #2 0x55f628c74274 in Per_thread_connection_handler::add_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b3274)
    #3 0x55f629030892 in Connection_handler_manager::process_new_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x266f892)
    #4 0x55f6282c01f2 in mysqld_main(int, char**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x18ff1f2)
    #5 0x7ff2cecc5082 in __libc_start_main ../csu/libc-start.c:308

Thread T78 created by T0 here:
    #0 0x7ff2cf770815 in __interceptor_pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cc:208
    #1 0x55f62ef7552a in pfs_spawn_thread_vc(unsigned int, unsigned int, my_thread_handle*, pthread_attr_t const*, void* (*)(void*), void*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85b452a)
    #2 0x55f628c74274 in Per_thread_connection_handler::add_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b3274)
    #3 0x55f629030892 in Connection_handler_manager::process_new_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x266f892)
    #4 0x55f6282c01f2 in mysqld_main(int, char**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x18ff1f2)
    #5 0x7ff2cecc5082 in __libc_start_main ../csu/libc-start.c:308

SUMMARY: AddressSanitizer: heap-use-after-free (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df138a) in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*)
Shadow bytes around the buggy address:
  0x0c08801fc450: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc460: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c08801fc470: fa fa 00 00 00 00 00 00 fa fa 00 00 00 00 00 00
  0x0c08801fc480: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc490: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
=>0x0c08801fc4a0: fa fa fd fd fd fd fd fd fa fa fd fd fd[fd]fd fd
  0x0c08801fc4b0: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc4c0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c08801fc4d0: fa fa 00 00 00 00 00 00 fa fa 00 00 00 00 00 00
  0x0c08801fc4e0: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc4f0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
540887==ABORTING

```
## 场景2
```cpp
#0  __pthread_kill (threadid=<optimized out>, signo=signo@entry=11) at ../sysdeps/unix/sysv/linux/pthread_kill.c:56
#1  0x000056018126372f in my_write_core (sig=sig@entry=11) at /root/sync/mysql/include/my_thread.h:78
#2  0x000056017c80d66d in handle_fatal_signal (sig=11) at /root/sync/mysql/sql/signal_handler.cc:202
#3  <signal handler called>
#4  0x000056018026a635 in binlog_cache_data::flush (this=this@entry=0x619000962a60, thd=thd@entry=0x627000600900, bytes_written=bytes_written@entry=0x7f7465721290, 
    wrote_xid=wrote_xid@entry=0x7f7465721260) at /root/sync/mysql/sql/sql_class.h:4728
#5  0x000056018026ae84 in binlog_cache_mngr::flush (wrote_xid=0x7f7465721260, bytes_written=<synthetic pointer>, thd=0x627000600900, this=0x6190009628a0) at /root/sync/mysql/sql/binlog.cc:1316
#6  MYSQL_BIN_LOG::flush_thread_caches (this=this@entry=0x560185ab0480 <mysql_bin_log>, thd=thd@entry=0x627000600900) at /root/sync/mysql/sql/binlog.cc:9026
#7  0x000056018026ba49 in MYSQL_BIN_LOG::process_flush_stage_queue (this=<optimized out>, total_bytes_var=<optimized out>, rotate_var=<optimized out>, out_queue_var=<optimized out>)
    at /root/sync/mysql/sql/binlog.cc:9160
#8  0x000056018026c8a3 in MYSQL_BIN_LOG::ordered_commit (this=0x560185ab0480 <mysql_bin_log>, thd=0x62700219e900, all=<optimized out>, skip_commit=<optimized out>)
    at /root/sync/mysql/sql/binlog.cc:9688
#9  0x0000560180272a4e in MYSQL_BIN_LOG::commit (this=<optimized out>, thd=0x62700219e900, all=<optimized out>) at /root/sync/mysql/sql/binlog.cc:8967
#10 0x000056017cc76471 in ha_commit_trans (thd=thd@entry=0x62700219e900, all=all@entry=false, ignore_global_read_lock=<optimized out>) at /root/sync/mysql/sql/handler.cc:1824
#11 0x000056017c703999 in trans_commit_stmt (thd=thd@entry=0x62700219e900, ignore_global_read_lock=ignore_global_read_lock@entry=false) at /root/sync/mysql/sql/transaction.cc:540
#12 0x000056017c2a5084 in mysql_execute_command (thd=0x62700219e900, first_level=first_level@entry=true) at /root/sync/mysql/sql/sql_parse.cc:4894
#13 0x000056017c344c1e in Prepared_statement::execute (this=0x6170006c1400, expanded_query=<optimized out>, open_cursor=<optimized out>) at /root/sync/mysql/sql/sql_prepare.cc:3547
#14 0x000056017c3563d6 in Prepared_statement::execute_loop (this=this@entry=0x6170006c1400, expanded_query=expanded_query@entry=0x7f74657263f0, open_cursor=open_cursor@entry=false)
    at /root/sync/mysql/sql/sql_prepare.cc:3050
#15 0x000056017c357898 in mysqld_stmt_execute (thd=thd@entry=0x62700219e900, stmt=0x6170006c1400, has_new_types=<optimized out>, execute_flags=<optimized out>, 
    parameters=parameters@entry=0x62500b6e6930) at /root/sync/mysql/sql/sql_prepare.cc:1911
#16 0x000056017c2af11d in dispatch_command (thd=0x62700219e900, com_data=<optimized out>, command=<optimized out>) at /root/sync/mysql/sql/sql_parse.cc:1893
#17 0x000056017c2b7872 in do_command (thd=thd@entry=0x62700219e900) at /root/sync/mysql/sql/sql_parse.cc:1395
#18 0x000056017c7daf28 in handle_connection (arg=arg@entry=0x6030000d6420) at /root/sync/mysql/sql/conn_handler/connection_handler_per_thread.cc:302
#19 0x0000560182815fcb in pfs_spawn_thread (arg=0x61400008be60) at /root/sync/mysql/storage/perfschema/pfs.cc:2942
#20 0x00007fa37444a609 in start_thread (arg=<optimized out>) at pthread_create.c:477
#21 0x00007fa373b0a133 in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:9
(gdb) f 5
#5  0x000056018026ae84 in binlog_cache_mngr::flush (wrote_xid=0x7f7465721260, bytes_written=<synthetic pointer>, thd=0x627000600900, this=0x6190009628a0) at /root/sync/mysql/sql/binlog.cc:1316
1316        error = trx_cache.flush(thd, &trx_bytes, wrote_xid);
(gdb) p thd->m_pending_flush_task
$1 = (Flush_task *) 0x0
```
```
```cpp
#1  0x00007f9d02d01859 in __GI_abort () at abort.c:79
#2  0x00007f9d02d6c26e in __libc_message (action=action@entry=do_abort, fmt=fmt@entry=0x7f9d02e96298 "%s\n") at ../sysdeps/posix/libc_fatal.c:155
#3  0x00007f9d02d742fc in malloc_printerr (str=str@entry=0x7f9d02e982a8 "corrupted size vs. prev_size in fastbins") at malloc.c:5347
#4  0x00007f9d02d74acc in malloc_consolidate (av=av@entry=0x7f8ce0000020) at malloc.c:4493
#5  0x00007f9d02d76c83 in _int_malloc (av=av@entry=0x7f8ce0000020, bytes=bytes@entry=1368) at malloc.c:3699
#6  0x00007f9d02d79299 in __GI___libc_malloc (bytes=1368) at malloc.c:3066
#7  0x0000562ed7a4e4d9 in mem_heap_create_block(mem_block_info_t*, unsigned long, unsigned long) ()
#8  0x0000562ed7a4ea96 in mem_heap_add_block(mem_block_info_t*, unsigned long) ()
#9  0x0000562ed7932ded in que_fork_create(que_fork_t*, void*, unsigned long, mem_block_info_t*) ()
#10 0x0000562ed792e3ac in pars_complete_graph_for_exec(void*, trx_t*, mem_block_info_t*, row_prebuilt_t*) ()
#11 0x0000562ed7a0b5f8 in trx_set_cts_low(trx_t*) ()
#12 0x0000562ed7a35792 in trx_commit_low(trx_t*, mtr_t*) ()
#13 0x0000562ed7a36024 in trx_commit(trx_t*) ()
#14 0x0000562ed7a3a5bb in trx_commit_for_mysql(trx_t*) ()
#15 0x0000562ed77bd6ed in innobase_commit_low(trx_t*) ()
#16 0x0000562ed77eb10a in innobase_commit(handlerton*, THD*, bool) ()
#17 0x0000562ed65b638c in ha_commit_low(THD*, bool, bool) ()
#18 0x0000562ed640de7d in trx_coordinator::commit_in_engines(THD*, bool, bool) ()
#19 0x0000562ed722b2a4 in MYSQL_BIN_LOG::finish_commit(THD*) ()
#20 0x0000562ed723ce16 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) ()
#21 0x0000562ed723f012 in MYSQL_BIN_LOG::commit(THD*, bool) ()
#22 0x0000562ed65b6d8c in ha_commit_trans(THD*, bool, bool) ()
#23 0x0000562ed6410ce3 in trans_commit(THD*, bool) ()
#24 0x0000562ed62dba90 in mysql_execute_command(THD*, bool) ()
#25 0x0000562ed630e250 in Prepared_statement::execute(String*, bool) ()
#26 0x0000562ed6312b3e in Prepared_statement::execute_loop(String*, bool) ()
#27 0x0000562ed6313261 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) ()
#28 0x0000562ed62e10c0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) ()
#29 0x0000562ed62e1b77 in do_command(THD*) ()
#30 0x0000562ed6454848 in handle_connection ()
#31 0x0000562ed7d49e39 in pfs_spawn_thread ()
#32 0x00007f9d0365b609 in start_thread (arg=<optimized out>) at pthread_create.c:477
#33 0x00007f9d02dfe133 in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95
```

```cpp
#0  __GI_raise (sig=sig@entry=6) at ../sysdeps/unix/sysv/linux/raise.c:50
#1  0x00007f1b3cadb859 in __GI_abort () at abort.c:79
#2  0x00007f1b3cb4626e in __libc_message (action=action@entry=do_abort, fmt=fmt@entry=0x7f1b3cc70298 "%s\n") at ../sysdeps/posix/libc_fatal.c:155
#3  0x00007f1b3cb4e2fc in malloc_printerr (str=str@entry=0x7f1b3cc72278 "malloc_consolidate(): invalid chunk size") at malloc.c:5347
#4  0x00007f1b3cb4ead8 in malloc_consolidate (av=av@entry=0x7ee9d4000020) at malloc.c:4477
#5  0x00007f1b3cb50c83 in _int_malloc (av=av@entry=0x7ee9d4000020, bytes=bytes@entry=1160) at malloc.c:3699
#6  0x00007f1b3cb53299 in __GI___libc_malloc (bytes=1160) at malloc.c:3066
#7  0x000055d758d2d4d9 in mem_heap_create_block(mem_block_info_t*, unsigned long, unsigned long) ()
#8  0x000055d758c3a88a in row_ins_sec_index_entry(dict_index_t*, dtuple_t*, que_thr_t*, bool) ()
#9  0x000055d758c3b810 in row_ins_step(que_thr_t*) ()
#10 0x000055d758c4a072 in row_insert_for_mysql_using_ins_graph(unsigned char const*, row_prebuilt_t*) ()
#11 0x000055d758acbcd0 in ha_innobase::write_row(unsigned char*) ()
#12 0x000055d7578a0550 in handler::ha_write_row(unsigned char*) ()
#13 0x000055d757b54c7c in write_record(THD*, TABLE*, COPY_INFO*, COPY_INFO*) ()
#14 0x000055d757b56079 in Sql_cmd_insert_values::execute_inner(THD*) ()
#15 0x000055d7576212c6 in Sql_cmd_dml::execute(THD*) ()
#16 0x000055d7575b9750 in mysql_execute_command(THD*, bool) ()
#17 0x000055d7575ed250 in Prepared_statement::execute(String*, bool) ()
#18 0x000055d7575f1b3e in Prepared_statement::execute_loop(String*, bool) ()
#19 0x000055d7575f2261 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) ()
#20 0x000055d7575c00c0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) ()
#21 0x000055d7575c0b77 in do_command(THD*) ()
#22 0x000055d757733848 in handle_connection ()
#23 0x000055d759028e39 in pfs_spawn_thread ()
#24 0x00007f1b3d435609 in start_thread (arg=<optimized out>) at pthread_create.c:477
#25 0x00007f1b3cbd8133 in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95
(gdb) c
```
```cpp
540887==ERROR: AddressSanitizer: heap-use-after-free on address 0x604001022568 at pc 0x55f62c7b238b bp 0x7fc3c58ef870 sp 0x7fc3c58ef860
READ of size 8 at 0x604001022568 thread T100
    #0 0x55f62c7b238a in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df138a)
    #1 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #2 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #3 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #4 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #5 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #6 0x55f62c91a360 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59360)
    #7 0x55f62c91af8f in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59f8f)
    #8 0x55f62c7f0d11 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e2fd11)
    #9 0x55f62c7f1fdf in binlog_cache_data::flush(THD*, unsigned long long*, bool*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e30fdf)
    #10 0x55f62c7f2513 in MYSQL_BIN_LOG::flush_thread_caches(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e31513)
    #11 0x55f62c7f32db in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e322db)
    #12 0x55f62c7f3fd5 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e32fd5)
    #13 0x55f62c7fa1dd in MYSQL_BIN_LOG::commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e391dd)
    #14 0x55f62914efc0 in ha_commit_trans(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x278dfc0)
    #15 0x55f628b89c12 in trans_commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x21c8c12)
    #16 0x55f6286e9c59 in mysql_execute_command(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d28c59)
    #17 0x55f62879379d in Prepared_statement::execute(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1dd279d)
    #18 0x55f6287a3f47 in Prepared_statement::execute_loop(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de2f47)
    #19 0x55f6287a5487 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de4487)
    #20 0x55f6286f6fc0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d35fc0)
    #21 0x55f6286ff569 in do_command(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d3e569)
    #22 0x55f628c731d7 in handle_connection (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b21d7)
    #23 0x55f62ef8b380 in pfs_spawn_thread (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85ca380)
    #24 0x7ff2cf711608 in start_thread /build/glibc-BHL3KM/glibc-2.31/nptl/pthread_create.c:477
    #25 0x7ff2cedc0132 in __clone (/lib/x86_64-linux-gnu/libc.so.6+0x11f132)

0x604001022568 is located 24 bytes inside of 48-byte region [0x604001022550,0x604001022580)
freed by thread T134 here:
    #0 0x7ff2cf84651f in operator delete(void*) ../../../../src/libsanitizer/asan/asan_new_delete.cc:165
    #1 0x55f62c7b235f in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df135f)
    #2 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #3 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #4 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #5 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #6 0x55f62c7b233d in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df133d)
    #7 0x55f62c91a360 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59360)
    #8 0x55f62c91af8f in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59f8f)
    #9 0x55f62c7f0d11 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e2fd11)
    #10 0x55f62c7f1fdf in binlog_cache_data::flush(THD*, unsigned long long*, bool*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e30fdf)
    #11 0x55f62c7f2513 in MYSQL_BIN_LOG::flush_thread_caches(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e31513)
    #12 0x55f62c7f32db in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e322db)
    #13 0x55f62c7f3fd5 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e32fd5)
    #14 0x55f62c7fa1dd in MYSQL_BIN_LOG::commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e391dd)
    #15 0x55f62914efc0 in ha_commit_trans(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x278dfc0)
    #16 0x55f628b89c12 in trans_commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x21c8c12)
    #17 0x55f6286e9c59 in mysql_execute_command(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d28c59)
    #18 0x55f62879379d in Prepared_statement::execute(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1dd279d)
    #19 0x55f6287a3f47 in Prepared_statement::execute_loop(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de2f47)
    #20 0x55f6287a5487 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de4487)
    #21 0x55f6286f6fc0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d35fc0)
    #22 0x55f6286ff569 in do_command(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d3e569)
    #23 0x55f628c731d7 in handle_connection (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b21d7)
    #24 0x55f62ef8b380 in pfs_spawn_thread (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85ca380)
    #25 0x7ff2cf711608 in start_thread /build/glibc-BHL3KM/glibc-2.31/nptl/pthread_create.c:477

previously allocated by thread T78 here:
    #0 0x7ff2cf845587 in operator new(unsigned long) ../../../../src/libsanitizer/asan/asan_new_delete.cc:104
    #1 0x55f62c9198ed in std::pair<std::_Rb_tree_iterator<std::pair<unsigned long const, long> >, bool> std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_emplace_unique<std::pair<unsigned long, long> >(std::pair<unsigned long, long>&&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f588ed)
    #2 0x55f62c91ac45 in Writeset_trx_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59c45)
    #3 0x55f62c91af8f in Transaction_dependency_tracker::get_dependency(THD*, long&, long&) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5f59f8f)
    #4 0x55f62c7f0d11 in MYSQL_BIN_LOG::write_transaction(THD*, binlog_cache_data*, Binlog_event_writer*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e2fd11)
    #5 0x55f62c7f1fdf in binlog_cache_data::flush(THD*, unsigned long long*, bool*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e30fdf)
    #6 0x55f62c7f2513 in MYSQL_BIN_LOG::flush_thread_caches(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e31513)
    #7 0x55f62c7f32db in MYSQL_BIN_LOG::process_flush_stage_queue(unsigned long long*, bool*, THD**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e322db)
    #8 0x55f62c7f3fd5 in MYSQL_BIN_LOG::ordered_commit(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e32fd5)
    #9 0x55f62c7fa1dd in MYSQL_BIN_LOG::commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5e391dd)
    #10 0x55f62914efc0 in ha_commit_trans(THD*, bool, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x278dfc0)
    #11 0x55f628b89c12 in trans_commit(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x21c8c12)
    #12 0x55f6286e9c59 in mysql_execute_command(THD*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d28c59)
    #13 0x55f62879379d in Prepared_statement::execute(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1dd279d)
    #14 0x55f6287a3f47 in Prepared_statement::execute_loop(String*, bool) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de2f47)
    #15 0x55f6287a5487 in mysqld_stmt_execute(THD*, Prepared_statement*, bool, unsigned long, PS_PARAM*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1de4487)
    #16 0x55f6286f6fc0 in dispatch_command(THD*, COM_DATA const*, enum_server_command) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d35fc0)
    #17 0x55f6286ff569 in do_command(THD*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x1d3e569)
    #18 0x55f628c731d7 in handle_connection (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b21d7)
    #19 0x55f62ef8b380 in pfs_spawn_thread (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85ca380)
    #20 0x7ff2cf711608 in start_thread /build/glibc-BHL3KM/glibc-2.31/nptl/pthread_create.c:477

Thread T100 created by T0 here:
    #0 0x7ff2cf770815 in __interceptor_pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cc:208
    #1 0x55f62ef7552a in pfs_spawn_thread_vc(unsigned int, unsigned int, my_thread_handle*, pthread_attr_t const*, void* (*)(void*), void*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85b452a)
    #2 0x55f628c74274 in Per_thread_connection_handler::add_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b3274)
    #3 0x55f629030892 in Connection_handler_manager::process_new_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x266f892)
    #4 0x55f6282c01f2 in mysqld_main(int, char**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x18ff1f2)
    #5 0x7ff2cecc5082 in __libc_start_main ../csu/libc-start.c:308

Thread T134 created by T0 here:
    #0 0x7ff2cf770815 in __interceptor_pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cc:208
    #1 0x55f62ef7552a in pfs_spawn_thread_vc(unsigned int, unsigned int, my_thread_handle*, pthread_attr_t const*, void* (*)(void*), void*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85b452a)
    #2 0x55f628c74274 in Per_thread_connection_handler::add_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b3274)
    #3 0x55f629030892 in Connection_handler_manager::process_new_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x266f892)
    #4 0x55f6282c01f2 in mysqld_main(int, char**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x18ff1f2)
    #5 0x7ff2cecc5082 in __libc_start_main ../csu/libc-start.c:308

Thread T78 created by T0 here:
    #0 0x7ff2cf770815 in __interceptor_pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cc:208
    #1 0x55f62ef7552a in pfs_spawn_thread_vc(unsigned int, unsigned int, my_thread_handle*, pthread_attr_t const*, void* (*)(void*), void*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x85b452a)
    #2 0x55f628c74274 in Per_thread_connection_handler::add_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x22b3274)
    #3 0x55f629030892 in Connection_handler_manager::process_new_connection(Channel_info*) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x266f892)
    #4 0x55f6282c01f2 in mysqld_main(int, char**) (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x18ff1f2)
    #5 0x7ff2cecc5082 in __libc_start_main ../csu/libc-start.c:308

SUMMARY: AddressSanitizer: heap-use-after-free (/root/sync/mysql/dev_d/runtime_output_directory/mysqld+0x5df138a) in std::_Rb_tree<unsigned long, std::pair<unsigned long const, long>, std::_Select1st<std::pair<unsigned long const, long> >, std::less<unsigned long>, std::allocator<std::pair<unsigned long const, long> > >::_M_erase(std::_Rb_tree_node<std::pair<unsigned long const, long> >*)
Shadow bytes around the buggy address:
  0x0c08801fc450: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc460: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c08801fc470: fa fa 00 00 00 00 00 00 fa fa 00 00 00 00 00 00
  0x0c08801fc480: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc490: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
=>0x0c08801fc4a0: fa fa fd fd fd fd fd fd fa fa fd fd fd[fd]fd fd
  0x0c08801fc4b0: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc4c0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c08801fc4d0: fa fa 00 00 00 00 00 00 fa fa 00 00 00 00 00 00
  0x0c08801fc4e0: fa fa 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c08801fc4f0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
540887==ABORTING
```