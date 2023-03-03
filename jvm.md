## Thread
A thread is a thread of execution in a program. The JVM allows an application to have multiple threads of execution running concurrently. In the Hotspot JVM there is a direct mapping between a Java Thread and a native operating system Thread. After preparing all of the state for a Java thread such as thread-local storage, allocation buffers, synchronization objects, stacks and the program counter, the native thread is created. The native thread is reclaimed once the Java thread terminates. The operating system is therefore responsible for scheduling all threads and dispatching them to any available CPU. Once the native thread has initialized it invokes the run() method in the Java thread. When the run() method returns, uncaught exceptions are handled, then the native thread confirms if the JVM needs to be terminated as a result of the thread terminating (i.e. is it the last non-deamon thread). When the thread terminates all resources for both the native and Java thread are released.

### VM thread
This thread waits for operations to appear that require the JVM to reach a safe-point. The reason these operations have to happen on a separate thread is because they all require the JVM to be at a safe point where modifications to the heap can not occur. The type of operations performed by this thread are "stop-the-world" garbage collections, thread stack dumps, thread suspension and biased locking revocation. 
## VM thread
这个线程就比较牛b了，是jvm里面的线程母体，根据hotspot源码（vmThread.hpp）里面的注释，它是一个单例的对象（最原始的线程）会产生或触发所有其他的线程，这个单个的VM线程是会被其他线程所使用来做一些VM操作（如，清扫垃圾等）。在 VMThread的结构体里有一个VMOperationQueue列队，所有的VM线程操作(vm_operation)都会被保存到这个列队当中，VMThread本身就是一个线程，它的线程负责执行一个自轮询的loop函数(具体可以参考：VMThread.cpp里面的void VMThread::loop())，该loop函数从VMOperationQueue列队中按照优先级取出当前需要执行的操作对象(VM_Operation)，并且调用VM_Operation->evaluate函数去执行该操作类型本身的业务逻辑。ps：VM操作类型被定义在vm_operations.hpp文件内，列举几个：ThreadStop、ThreadDump、PrintThreads、GenCollectFull、GenCollectFullConcurrent、CMS_Initial_Mark、CMS_Final_Remark…..有兴趣的同学，可以自己去查看源文件。

### stop the world

说到GC，这里要先提到VMThread，在jvm里有这么一个线程不断轮询它的队列，这个队列里主要是存一些VM_operation的动作，比如最常见的就是内存分配失败要求做GC操作的请求等，在对gc这些操作执行的时候会先将其他业务线程都进入到安全点，也就是这些线程从此不再执行任何字节码指令，只有当出了安全点的时候才让他们继续执行原来的指令，因此这其实就是我们说的stop the world(STW)，整个进程相当于静止了

```c++ 
void before_exit(JavaThread * thread) {

  #define BEFORE_EXIT_NOT_RUN 0

  #define BEFORE_EXIT_RUNNING 1

  #define BEFORE_EXIT_DONE    2

  static jint volatile _before_exit_status = BEFORE_EXIT_NOT_RUN;

  

  // Note: don't use a Mutex to guard the entire before_exit(), as

  // JVMTI post_thread_end_event and post_vm_death_event will run native code.

  // A CAS or OSMutex would work just fine but then we need to manipulate

  // thread state for Safepoint. Here we use Monitor wait() and notify_all()

  // for synchronization.

  { MutexLocker ml(BeforeExit_lock);

    switch (_before_exit_status) {

    case BEFORE_EXIT_NOT_RUN:

      _before_exit_status = BEFORE_EXIT_RUNNING;

      break;

    case BEFORE_EXIT_RUNNING:

      while (_before_exit_status == BEFORE_EXIT_RUNNING) {

        BeforeExit_lock->wait();

      }

      assert(_before_exit_status == BEFORE_EXIT_DONE, "invalid state");

      return;

    case BEFORE_EXIT_DONE:

      return;

    }

  }

  

  // The only difference between this and Win32's _onexit procs is that

  // this version is invoked before any threads get killed.

  ExitProc* current = exit_procs;

  while (current != NULL) {

    ExitProc* next = current->next();

    current->evaluate();

    delete current;

    current = next;

  }

  

  // Hang forever on exit if we're reporting an error.

  if (ShowMessageBoxOnError && is_error_reported()) {

    os::infinite_sleep();

  }

  

  // Terminate watcher thread - must before disenrolling any periodic task

  if (PeriodicTask::num_tasks() > 0)

    WatcherThread::stop();

  

  // Print statistics gathered (profiling ...)

  if (Arguments::has_profile()) {

    FlatProfiler::disengage();

    FlatProfiler::print(10);

  }

  

  // shut down the StatSampler task

  StatSampler::disengage();

  StatSampler::destroy();

  

  // Stop concurrent GC threads

  Universe::heap()->stop();

  

  // Print GC/heap related information.

  if (PrintGCDetails) {

    Universe::print();

    AdaptiveSizePolicyOutput(0);

    if (Verbose) {

      ClassLoaderDataGraph::dump_on(gclog_or_tty);

    }

  }

  

  if (PrintBytecodeHistogram) {

    BytecodeHistogram::print();

  }

  

  if (JvmtiExport::should_post_thread_life()) {

    JvmtiExport::post_thread_end(thread);

  }

  
  

  EventThreadEnd event;

  if (event.should_commit()) {

    event.set_thread(JFR_THREAD_ID(thread));

    event.commit();

  }

  

  JFR_ONLY(Jfr::on_vm_shutdown();)

  

  // Always call even when there are not JVMTI environments yet, since environments

  // may be attached late and JVMTI must track phases of VM execution

  JvmtiExport::post_vm_death();

  Threads::shutdown_vm_agents();

  

  // Terminate the signal thread

  // Note: we don't wait until it actually dies.

  os::terminate_signal_thread();

  

  print_statistics();

  Universe::heap()->print_tracing_info();

  

  { MutexLocker ml(BeforeExit_lock);

    _before_exit_status = BEFORE_EXIT_DONE;

    BeforeExit_lock->notify_all();

  }

  

  if (VerifyStringTableAtExit) {

    int fail_cnt = 0;

    {

      MutexLocker ml(StringTable_lock);

      fail_cnt = StringTable::verify_and_compare_entries();

    }

  

    if (fail_cnt != 0) {

      tty->print_cr("ERROR: fail_cnt=%d", fail_cnt);

      guarantee(fail_cnt == 0, "unexpected StringTable verification failures");

    }

  }

  

  #undef BEFORE_EXIT_NOT_RUN

  #undef BEFORE_EXIT_RUNNING

  #undef BEFORE_EXIT_DONE

}
```
### 堆栈信息
```bash
# 总量 
jhsdb jmap --heap --pid 5554
# 分量
jmap  -histo:live 4706|head -n 23
```

# 0. 参考
- [JVM Internals](https://blog.jamesdbloom.com/JVMInternals.html)
- [从JDK源码看System.exit](https://juejin.cn/post/6844903503811330055)
- [JVM 内部运行线程介绍](https://developer.aliyun.com/article/89104)
- [JVM Life Cycle](https://stackoverflow.com/questions/2129044/java-heap-terminology-young-old-and-permanent-generations)