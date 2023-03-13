# 0. CPU（**C**entral **P**rocessing **U**nit）
中央处理器，是计算机主要组件之一。[冯·诺依曼](https://baike.baidu.com/item/%E5%86%AF%C2%B7%E8%AF%BA%E4%BE%9D%E6%9B%BC/388909?fromModule=lemma_inlink)提出了计算机制造的三个[基本原则](https://baike.baidu.com/item/%E5%9F%BA%E6%9C%AC%E5%8E%9F%E5%88%99/11025484?fromModule=lemma_inlink)，即采用[二进制](https://baike.baidu.com/item/%E4%BA%8C%E8%BF%9B%E5%88%B6/361457?fromModule=lemma_inlink)逻辑、程序存储执行以及计算机由五个部分组成（[运算器](https://baike.baidu.com/item/%E8%BF%90%E7%AE%97%E5%99%A8/2667320?fromModule=lemma_inlink)、控制器、[存储器](https://baike.baidu.com/item/%E5%AD%98%E5%82%A8%E5%99%A8/1583185?fromModule=lemma_inlink)、[输入设备](https://baike.baidu.com/item/%E8%BE%93%E5%85%A5%E8%AE%BE%E5%A4%87/10823368?fromModule=lemma_inlink)、[输出设备](https://baike.baidu.com/item/%E8%BE%93%E5%87%BA%E8%AE%BE%E5%A4%87/10823333?fromModule=lemma_inlink)），这套理论被称为冯·诺依曼体系结构。
# 1. 结构
## A. 示例
![[1677805167762.png]]
- 48个逻辑核，24个物理核
- 频率 2200MHz
- [NUMA(Non-Uniform Memory Access)](https://en.wikipedia.org/wiki/Non-uniform_memory_access)非均匀内存访问架构是指多处理器系统中，内存的访问时间是依赖于处理器和内存之间的相对位置的。 这种设计里存在和处理器相对近的内存，通常被称作本地内存；还有和处理器相对远的内存， 通常被称为非本地内存。一个NUMA Node内部是由一个**物理CPU**和它所有的**本地内存(Local Memory)** 组成的。广义得讲， 一个NUMA Node内部还包含**本地IO资源**，对大多数Intel x86 NUMA平台来说，主要是PCIe总线资源。 ACPI规范就是这么抽象一个NUMA Node的。
![[Pasted image 20230303090933.png]]
## B. 名词
- **Processor**: The physical chip that plugs into a socket on the system or processor board and contains one or more CPUs implemented as cores or hardware threads. ([View Highlight](https://read.readwise.io/read/01gtb08407zy7051ezsa9myz4m))
- [**Core**](#glo_035): An independent CPU instance on a _multicore processor_. The use of cores is a way to scale processors, called _chip-level multiprocessing_ (CMP). ([View Highlight](https://read.readwise.io/read/01gtb0873vpxhzhrxd0vz34pva))
- **Hardware thread**: A CPU architecture that supports executing multiple threads in parallel on a single core (including Intel’s Hyper-Threading Technology), where each thread is an independent CPU instance. This scaling approach is called _simultaneous multithreading_ (SMT). ([View Highlight](https://read.readwise.io/read/01gtb089e6fappk36cvny32jq4))
- **Logical CPU**: Also called a _virtual processor,_[1](#ch06fn1) an operating system CPU instance (a schedulable CPU entity). This may be implemented by the processor as a hardware thread (in which case it may also be called a _virtual core_), a core, or a single-core processor. ([View Highlight](https://read.readwise.io/read/01gtb08bkxry9j1jha1ytsasvs))
- **CPU instruction**: A single CPU operation, from its _instruction set_. There are instructions for arithmetic operations, memory I/O, and control logic. ([View Highlight](https://read.readwise.io/read/01gtb08drxe0wh7d7nsrgp23sq))
- **Scheduler**: The kernel subsystem that assigns threads to run on CPUs. ([View Highlight](https://read.readwise.io/read/01gtb08ne4cp7hz3v0209aegdm))
- [**Run queue**](#glo_141): A queue of runnable threads that are waiting to be serviced by CPUs. Modern kernels may use some other data structure (e.g., a red-black tree) to store runnable threads, but we still often use the term run queue. ([View Highlight](https://read.readwise.io/read/01gtb08qrtebr2qeb7j8sx0vp7))
## C. 架构
![[Pasted image 20230303091313.png]]
**每个HThread都是可以访问地址的逻辑CPU**
# 2. 功能
CPU 是对计算机的所有硬件资源（如存储器、输入输出单元） 进行控制调配、执行通用运算的核心硬件单元。CPU 是计算机的运算和控制核心。计算机系统中所有软件层的操作，最终都将通过指令集映射为CPU的操作。
## instructions
CPUs execute instructions chosen from their instruction set. An instruction includes the following steps, each processed by a component of the CPU called a _functional unit_: ([View Highlight](https://read.readwise.io/read/01gtb1tm3xgf7bb8fr999zeh9j))
- Instruction fetch ([View Highlight](https://read.readwise.io/read/01gtb1tsgaz3rhkbwr8wne1hpa))
- Instruction decode ([View Highlight](https://read.readwise.io/read/01gtb211ysnhcnsmtd79bd7wr2))
- Execute ([View Highlight](https://read.readwise.io/read/01gtb2183nasgyrx8vr69xyqd2))
- Memory access ([View Highlight](https://read.readwise.io/read/01gtb21egsd76f2srzg1rfgztk))
- Register write-back ([View Highlight](https://read.readwise.io/read/01gtb254axy275y999za4swd25))
# 3. 工作模式
## A. CPU Memory Caches 
![[Pasted image 20230303102143.png]]
- 速度从上到下依次减慢，容量增加
- 一二级缓存一般位于processor上面，三级缓存属于共享缓存
## B.  CPU Run Queues ([View Highlight](https://read.readwise.io/read/01gtb0ervpb80atcnffm1d8yr9))
![[Pasted image 20230303102440.png]]
- 获取其他所需资源，等待CPU资源的Thread会存储在队列里。队列的大小被称为Run Queue Latency。
- 每个CPU 都有独立的Run Queue。
- 可能存储在红黑树当中。
# 4. 主要性能参数
## A. Clock Rate 
The clock is a digital signal that drives all processor logic. Each CPU instruction may take one or more cycles of the clock (called _CPU cycles_) to execute. CPUs execute at a particular clock rate; for example, a 4 GHz CPU performs 4 billion clock cycles per second. ([View Highlight](https://read.readwise.io/read/01gtb1pg0yr7y8whfyebd8cwqh))
主频可以用来量化CPU执行速率的快慢，不可以用来量化执行效率。后者还取决于所做的工作。**每秒钟能完成多少Cycle**
## B. IPC(PCI)
每个cycle可以完成多少instructions
- [Instructions Per Cycle](<_Instructions per cycle_ (IPC) is an important high-level metric for describing how a CPU is spending its clock cycles and for understanding the nature of CPU utilization. This metric may also be expressed as _cycles per instruction_ (CPI), the inverse of IPC ([View Highlight](https://read.readwise.io/read/01gtbapt5nzsf5ey7zm00fm7b9))>)
- A low IPC indicates that CPUs are often stalled, typically for memory access. A high IPC indicates that CPUs are often not stalled and have a high instruction throughput. These metrics suggest where performance tuning efforts may be best spent. ([View Highlight](https://read.readwise.io/read/01gtbaswjrstcrs0kznh3fkatb))
- It should be noted that IPC shows the efficiency of instruction _processing_, but not of the instructions themselves. Consider a software change that added an inefficient software loop, which operates mostly on CPU registers (no stall cycles): such a change may result in a higher overall IPC, but also higher CPU usage and utilization. ([View Highlight](https://read.readwise.io/read/01gtbb1098rdh62kk678v106g1))
- todo_不通cpu比较 同一个cpu
## C. Utilization
CPU utilization is measured by the time a CPU instance is busy performing work during an interval, expressed as a percentage. 百分比，一个时间间隔内CPU的使用率。
- It can be measured as the time a CPU is not running the kernel idle thread but is instead running user-level application threads or other kernel threads, or processing interrupts. ([View Highlight](https://read.readwise.io/read/01gtbdjan70zxag4zkztc53x4z))
- The measure of CPU utilization spans all clock cycles for eligible activities, including memory stall cycles. This can be misleading: a CPU may be highly utilized because it is often stalled waiting for memory I/O, not just executing instructions, as described in the previous section. ([View Highlight](https://read.readwise.io/read/01gtbdpsyhgqd9541qtvfw6rwx))
- 用户态 内核态
## D. User Time/Kernel Time
- The CPU time spent executing user-level software is called _user time.
- The CPU time spent executing kernel-level software is _kernel time_.
- Kernel time includes time during system calls, kernel threads, and interrupts.
- Applications that are computation-intensive may spend almost all their time executing user-level code and have a user/kernel ratio approaching 99/1. Examples include image processing, machine learning, genomics, and data analysis. ([View Highlight](https://read.readwise.io/read/01gtbeztwcveczqjbetcgesdjs))
- Applications that are I/O-intensive have a high rate of system calls, which execute kernel code to perform the I/O. For example, a web server performing network I/O may have a user/kernel ratio of around 70/30. ([View Highlight](https://read.readwise.io/read/01gtbf005jwbeyss0q4fte2d8q))
## E. Saturation
- A CPU at 100% utilization is _saturated_, and threads will encounter **_scheduler latency_** as they wait to run on-CPU, decreasing overall performance.
- This latency is the time spent waiting on the CPU run queue or other structure used to manage threads.
- 相比于其他资源，例如磁盘，CPU达到100%是一个轻微一些的问题，高优先级的线程可以通过抢占，插队的方法优先获取CPU资源。
- Priority Inversion。
	- Thread A是一个低优先级的进程，他持有了高优先级 Thread C所需的资源。 Thread B比A优先级高，低于C。
	- A先运行，B启动后，会抢占CPU资源，B开始运行。
	- Thread C在等待I/O，陷入沉睡，被阻塞。I/O结束后，回到runnable 状态，获取CPU控制权。
	- C缺少资源，该资源被A持有，释放了CPU，执行下一个最高优先级Thread B。
	-  此时C被低优先级进程B阻塞，Priority inheritance  会将C的优先级赋予A，直至A释放了C所需的资源，这时C可以继续运行。
# 5. Hardware
![[Pasted image 20230303111208.png]]
- MMU 映射虚拟地址至物理地址。先在TLB中查找，没有命中缓存需要一级一级的查找pages。
- TLB 高速缓存，存储虚拟地址到物理地址的映射。
- Control Unit  performing instruction fetch, decoding, managing execution, and storing results. 
- CPU Caches
![[Pasted image 20230303111950.png]]
- **Level 1 instruction cache** (I$) ([View Highlight](https://read.readwise.io/read/01gtbhbp63mt1shpr2eafssm29))
- **Level 1 data cache** (D$) ([View Highlight](https://read.readwise.io/read/01gtbhc55zj6p3q97yd4nn42gx))
- **Translation lookaside buffer** (TLB) ([View Highlight](https://read.readwise.io/read/01gtbhcn10jn01rjhn3t0rer78))
- **Level 2 cache** (E$)
- **Level 3 cache** (optional) ([View Highlight](https://read.readwise.io/read/01gtbhd2zvgvd4xqhyrs1888g3))
- The access time for the Level 1 cache is typically a few CPU clock cycles, and for the larger Level 2 cache around a dozen clock cycles. Main memory access can take around 60 ns (around 240 cycles for a 4 GHz processor), and address translation by the MMU also adds latency
# 6. Tools
## A. uptime

![[Pasted image 20230303112755.png]]
显示运行时间，load average：1 分钟 5 分钟 15分钟
## **Load Averages**
- The load averages indicate **the demand for system resources:** higher means more demand
- 包括正在运行的和等待使用的资源
- 数值表示正在使用的个数
## B. PSI
The average shows the percent of time something was stalled on a resource (saturation only).
![[Pasted image 20230303141420.png]]
- **some** 指标说明一个或多个任务由于等待资源而被停顿的时间百分比.
- **full** 指标表示所有的任务由于等待资源而被停顿的时间百分比.
## C. vmstat
![[Pasted image 20230303120218.png]]
- **Procs**
	- r: The number of processes waiting for run time.
	- b: The number of processes in uninterruptible sleep.
- **Memory**
	- swpd: the amount of virtual memory used.
	- free: the amount of idle memory.
	- buff: the amount of memory used as buffers.
	- cache: the amount of memory used as cache.
	- inact: the amount of inactive memory. (-a option)
	- active: the amount of active memory. (-a option)
- **Swap**
	- si: Amount of memory swapped in from disk (/s).
	- so: Amount of memory swapped to disk (/s).
- **IO**
	- bi: Blocks received from a block device (blocks/s).
	- bo: Blocks sent to a block device (blocks/s).
- **System**
	- in: The number of interrupts per second, including the clock.
	- cs: The number of context switches per second.
- **CPU**
 These are percentages of total CPU time.
	- us: Time spent running non-kernel code. (user time, including nice time)
	- sy: Time spent running kernel code. (system time)
	- id: Time spent idle. Prior to Linux 2.5.41, this includes IO-wait time.
	- wa: Time spent waiting for IO. Prior to Linux 2.5.41, included in idle.
	- st: Time stolen from a virtual machine. Prior to Linux 2.6.11, unknown.(Stolen percent, which for virtualized environments shows CPU time spent servicing other tenant)
## D. top
![[Pasted image 20230303115211.png]]
## E. 容器内外对比
- top
	![[Pasted image 20230303115316.png]]
- uptime
	![[Pasted image 20230303115430.png]]
- vmstat
	![[Pasted image 20230303120552.png]]
# 7. 参考
- 《Systems Performance, 2nd Edition》
- [# 使用 PSI（Pressure Stall Information）监控服务器资源](https://xie.infoq.cn/article/931eee27dabb0de906869ba05)
- [# Pressure Stall Information on CentOS7](https://dev.to/aws-heroes/pressure-stall-information-on-centos7-1700)
- [# 理解NUMA架构](https://izsk.me/2022/06/02/System-Understanding-NUMA-Architecture/)
- [# TLB原理](https://zhuanlan.zhihu.com/p/108425561)
- [# Central processing unit](https://en.wikipedia.org/wiki/Central_processing_unit)

# TODO
- [ ] 三级缓存 
- [ ] ipc
- [ ] 