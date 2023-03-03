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
# 2. 