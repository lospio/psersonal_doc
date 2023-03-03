# Systems Performance

For reference, CPU-related terminology used in this chapter includes the following: ([View Highlight](https://read.readwise.io/read/01gtb081qynsv6ee7g1pgebz27))

**Processor**: The physical chip that plugs into a socket on the system or processor board and contains one or more CPUs implemented as cores or hardware threads. ([View Highlight](https://read.readwise.io/read/01gtb08407zy7051ezsa9myz4m))

[**Core**](#glo_035): An independent CPU instance on a _multicore processor_. The use of cores is a way to scale processors, called _chip-level multiprocessing_ (CMP). ([View Highlight](https://read.readwise.io/read/01gtb0873vpxhzhrxd0vz34pva))

**Hardware thread**: A CPU architecture that supports executing multiple threads in parallel on a single core (including Intel’s Hyper-Threading Technology), where each thread is an independent CPU instance. This scaling approach is called _simultaneous multithreading_ (SMT). ([View Highlight](https://read.readwise.io/read/01gtb089e6fappk36cvny32jq4))

**CPU instruction**: A single CPU operation, from its _instruction set_. There are instructions for arithmetic operations, memory I/O, and control logic. ([View Highlight](https://read.readwise.io/read/01gtb08drxe0wh7d7nsrgp23sq))

**Logical CPU**: Also called a _virtual processor,_[1](#ch06fn1) an operating system CPU instance (a schedulable CPU entity). This may be implemented by the processor as a hardware thread (in which case it may also be called a _virtual core_), a core, or a single-core processor. ([View Highlight](https://read.readwise.io/read/01gtb08bkxry9j1jha1ytsasvs))

**Scheduler**: The kernel subsystem that assigns threads to run on CPUs. ([View Highlight](https://read.readwise.io/read/01gtb08ne4cp7hz3v0209aegdm))

[**Run queue**](#glo_141): A queue of runnable threads that are waiting to be serviced by CPUs. Modern kernels may use some other data structure (e.g., a red-black tree) to store runnable threads, but we still often use the term run queue. ([View Highlight](https://read.readwise.io/read/01gtb08qrtebr2qeb7j8sx0vp7))

6.2.1 CPU Architecture ([View Highlight](https://read.readwise.io/read/01gtb0e4cvgkbznq3msfvsts2s))

[Figure 6.1](#ch06fig01) shows an example CPU architecture, for a single processor with four cores and eight hardware threads in total. The physical architecture is pictured, along with how it is seen by the operating system.[2](#ch06fn2) ([View Highlight](https://read.readwise.io/read/01gtb099nxwjdhwjrs0cs3bq4y))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig01-06fig01.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig01-06fig01.jpg)

([View Highlight](https://read.readwise.io/read/01gtb0cyj081brmb0e9ahh9rz1))

Figure 6.1 CPU architecture ([View Highlight](https://read.readwise.io/read/01gtb0d5hyv1cv99gxvzs33n06))

Each hardware thread is addressable as a _logical CPU_, so this processor appears as eight CPUs. ([View Highlight](https://read.readwise.io/read/01gtb0dh725yf50k24a1k9d857))

6.2.2 CPU Memory Caches ([View Highlight](https://read.readwise.io/read/01gtb0dwnmz0zzjdb1gpw7zeh1))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig02-06fig02.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig02-06fig02.jpg)

([View Highlight](https://read.readwise.io/read/01gtb0ef3zer14971pj5d28q7d))

Figure 6.2 CPU cache sizes ([View Highlight](https://read.readwise.io/read/01gtb0ejkwfd121rwx210748hw))

6.2.3 CPU Run Queues ([View Highlight](https://read.readwise.io/read/01gtb0ervpb80atcnffm1d8yr9))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig03-06fig03.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig03-06fig03.jpg)

([View Highlight](https://read.readwise.io/read/01gtb0exaeh0vejjc3056s1z73))

The number of software threads that are queued and ready to run is an important performance metric indicating CPU saturation. In this figure (at this instant) there are four, with an additional thread running on-CPU. The time spent waiting on a CPU run queue is sometimes called _run-queue latency_ or _dispatcher-queue latency_. ([View Highlight](https://read.readwise.io/read/01gtb0fef50xwbzm16jpyhwn4q))

For multiprocessor systems, the kernel typically provides a run queue for each CPU, and aims to keep threads on the same run queue. This means that threads are more likely to keep running on the same CPUs where the CPU caches have cached their data. These caches are described as having [_cache warmth_](#glo_029), and this strategy to keep threads running on the same CPUs is called _CPU affinity_. On NUMA systems, per-CPU run queues also improve _memory locality_. This improves performance by keeping threads running on the same memory node (as described in [Chapter 7](#ch07), [Memory](#ch07)), and avoids the cost of thread synchronization (mutex locks) for queue operations, which would hurt scalability if the run queue was global and shared among all CPUs ([View Highlight](https://read.readwise.io/read/01gtb1n4g0faffc2qspycmhbrh))

6.3.1 Clock Rate ([View Highlight](https://read.readwise.io/read/01gtb1nt437k2mq1hjneecz6tp))

The clock is a digital signal that drives all processor logic. Each CPU instruction may take one or more cycles of the clock (called _CPU cycles_) to execute. CPUs execute at a particular clock rate; for example, a 4 GHz CPU performs 4 billion clock cycles per second. ([View Highlight](https://read.readwise.io/read/01gtb1pg0yr7y8whfyebd8cwqh))

Clock rate is often marketed as the primary feature of a processor, but this can be a little misleading. Even if the CPU in your system appears to be fully utilized (a bottleneck), a faster clock rate may not speed up performance—it depends on what those fast CPU cycles are actually doing. If they are mostly stall cycles while waiting on memory access, executing them more quickly doesn’t actually increase the CPU instruction rate or workload throughput. ([View Highlight](https://read.readwise.io/read/01gtb1t64n42hsk0jn9ahdz6pt))

6.3.2 Instructions ([View Highlight](https://read.readwise.io/read/01gtb1teaejp28nkdy9dyc1x9v))

CPUs execute instructions chosen from their instruction set. An instruction includes the following steps, each processed by a component of the CPU called a _functional unit_: ([View Highlight](https://read.readwise.io/read/01gtb1tm3xgf7bb8fr999zeh9j))

Instruction fetch ([View Highlight](https://read.readwise.io/read/01gtb1tsgaz3rhkbwr8wne1hpa))

Instruction decode ([View Highlight](https://read.readwise.io/read/01gtb211ysnhcnsmtd79bd7wr2))

Execute ([View Highlight](https://read.readwise.io/read/01gtb2183nasgyrx8vr69xyqd2))

Memory access ([View Highlight](https://read.readwise.io/read/01gtb21egsd76f2srzg1rfgztk))

Register write-back ([View Highlight](https://read.readwise.io/read/01gtb254axy275y999za4swd25))

Each of these steps takes at least a single clock cycle to be executed. Memory access is often the slowest, as it may take dozens of clock cycles to read or write to main memory, during which instruction execution has _stalled_ (and these cycles while stalled are called _stall cycles_) ([View Highlight](https://read.readwise.io/read/01gtb25c864x9t220c9jje2wdt))

6.3.3 Instruction Pipeline ([View Highlight](https://read.readwise.io/read/01gtb25nmnyfxkzztkbtrqy4vy))

The instruction pipeline is a CPU architecture that can execute multiple instructions in parallel by executing different components of different instructions at the same time. It is similar to a factory assembly line, where stages of production can be executed in parallel, increasing throughput. ([View Highlight](https://read.readwise.io/read/01gtb26nv5we86rmqxdz9139rk))

By use of pipelining, multiple functional units can be active at the same time, processing different instructions in the pipeline. Ideally, the processor can then complete one instruction with every clock cycle. ([View Highlight](https://read.readwise.io/read/01gtb275b6jnpje0xgvqtttvqy))

Instruction pipelining may involve breaking down an instruction into multiple simple steps for execution in parallel ([View Highlight](https://read.readwise.io/read/01gtb29sd9nye9xj13a0swfr7m))

Branch Prediction ([View Highlight](https://read.readwise.io/read/01gtb2b2m1qd8c5gzqfz1k42f0))

Modern processors can perform out-of-order execution of the pipeline, where later instructions can be completed while earlier instructions are stalled, improving instruction throughput. ([View Highlight](https://read.readwise.io/read/01gtb2cqhpbg5s5jawbh56djcq))

However, conditional branch instructions pose a problem. Branch instructions jump execution to a different instruction, and conditional branches do so based on a test. ([View Highlight](https://read.readwise.io/read/01gtb2de8qknrjkhk7w23bv1wh))

With conditional branches, the processor does not know what the later instructions will be. As an optimization, processors often implement _branch prediction_, where they will guess the outcome of the test and begin processing the outcome instructions. If the guess later proves to be wrong, the progress in the instruction pipeline must be discarded, hurting performance. To improve the chances of guessing correctly, programmers can place hints in the code (e.g., likely() and unlikely() macros in the Linux Kernel sources). ([View Highlight](https://read.readwise.io/read/01gtb2fysm26xgfgxfcqvaffj6))

6.3.4 Instruction Width ([View Highlight](https://read.readwise.io/read/01gtb2gev7agf6mefmncf6m1hc))

Multiple functional units of the same type can be included, so that even more instructions can make forward progress with each clock cycle. This CPU architecture is called _superscalar_ and is typically used with pipelining to achieve a high instruction throughput. ([View Highlight](https://read.readwise.io/read/01gtbacsp97g5v2q6b3abpyvrg))

The instruction _width_ describes the target number of instructions to process in parallel. Modern processors are _3-wide_ or _4-wide_, meaning they can complete up to three or four instructions per cycle. ([View Highlight](https://read.readwise.io/read/01gtbadeqa5tsvbrqm4gxt0p5f))

6.3.5 Instruction Size ([View Highlight](https://read.readwise.io/read/01gtbae45bcna9wnfs312vr3g4))

Another instruction characteristic is the instruction _size_: for some processor architectures it is variable: For example, x86, which is classified as a _complex instruction set computer_ (CISC), allows up to 15-byte instructions. ARM, which is a _reduced instruction set computer_ (RISC), has 4 byte instructions with 4-byte alignment for AArch32/A32, and 2- or 4-byte instructions for ARM Thumb. ([View Highlight](https://read.readwise.io/read/01gtbag8h76x156vdr3jbnjdg2))

6.3.6 SMT ([View Highlight](https://read.readwise.io/read/01gtbafjkmz0wnr7afcj4yscqe))

Simultaneous multithreading makes use of a superscalar architecture and hardware multithreading support (by the processor) to improve parallelism. It allows a CPU core to run more than one thread, effectively scheduling between them during instructions, e.g., when one instruction stalls on memory I/O. The kernel presents these hardware threads as virtual CPUs, and schedules threads and processes on them as usual ([View Highlight](https://read.readwise.io/read/01gtbakfk8wtmkxnjrb22c8r1e))

The performance of each hardware thread is not the same as a separate CPU core, and depends on the workload. To avoid performance problems, kernels may spread out CPU load across cores so that only one hardware thread on each core is busy, avoiding hardware thread contention. Workloads that are stall cycle-heavy (low IPC) may also have better performance than those that are instruction-heavy (high IPC) because stall cycles reduce core contention. ([View Highlight](https://read.readwise.io/read/01gtbamnjdzkv7chaz0rbf3bya))

6.3.7 IPC, CPI ([View Highlight](https://read.readwise.io/read/01gtbancqnfc9tyqrb6f3zfwf4))

_Instructions per cycle_ (IPC) is an important high-level metric for describing how a CPU is spending its clock cycles and for understanding the nature of CPU utilization. This metric may also be expressed as _cycles per instruction_ (CPI), the inverse of IPC ([View Highlight](https://read.readwise.io/read/01gtbapt5nzsf5ey7zm00fm7b9))

A low IPC indicates that CPUs are often stalled, typically for memory access. A high IPC indicates that CPUs are often not stalled and have a high instruction throughput. These metrics suggest where performance tuning efforts may be best spent. ([View Highlight](https://read.readwise.io/read/01gtbaswjrstcrs0kznh3fkatb))

Memory-intensive workloads, for example, may be improved by installing faster memory (DRAM), improving memory locality (software configuration), or reducing the amount of memory I/O. Installing CPUs with a higher clock rate may not improve performance to the degree expected, as the CPUs may need to wait the same amount of time for memory I/O to complete. Put differently, a faster CPU may mean more stall cycles but the same rate of completed instructions per second. ([View Highlight](https://read.readwise.io/read/01gtbaxa0t9v9zwdrbq95qjhgd))

The actual values for high or low IPC are dependent on the processor and processor features and can be determined experimentally by running known workloads. As an example, you may find that low-IPC workloads run with an IPC at 0.2 or lower, and high IPC workloads run with an IPC of over 1.0 (which is possible due to instruction pipelining and width, described earlier) ([View Highlight](https://read.readwise.io/read/01gtbay3nk80bzpvfsw7gxc232))

It should be noted that IPC shows the efficiency of instruction _processing_, but not of the instructions themselves. Consider a software change that added an inefficient software loop, which operates mostly on CPU registers (no stall cycles): such a change may result in a higher overall IPC, but also higher CPU usage and utilization. ([View Highlight](https://read.readwise.io/read/01gtbb1098rdh62kk678v106g1))

High CPU utilization may not necessarily be a problem, but rather a sign that the system is doing work. Some people also consider this a return of investment (ROI) indicator: a highly utilized system is considered to have good ROI, whereas an idle system is considered wasted. ([View Highlight](https://read.readwise.io/read/01gtbdmrs1cwvecy5b1zrrbj8t))

6.3.8 Utilization ([View Highlight](https://read.readwise.io/read/01gtbb2cx2cvpzmjtba44rbxw9))

CPU utilization is measured by the time a CPU instance is busy performing work during an interval, expressed as a percentage. It can be measured as the time a CPU is not running the kernel idle thread but is instead running user-level application threads or other kernel threads, or processing interrupts. ([View Highlight](https://read.readwise.io/read/01gtbdjan70zxag4zkztc53x4z))

The measure of CPU utilization spans all clock cycles for eligible activities, including memory stall cycles. This can be misleading: a CPU may be highly utilized because it is often stalled waiting for memory I/O, not just executing instructions, as described in the previous section. ([View Highlight](https://read.readwise.io/read/01gtbdpsyhgqd9541qtvfw6rwx))

CPU utilization is often split into separate kernel- and user-time metrics. ([View Highlight](https://read.readwise.io/read/01gtbdr2yqjmmr5y9nj3e74v3q))

6.3.9 User Time/Kernel Time ([View Highlight](https://read.readwise.io/read/01gtbeyznjnc31dg6q92ysmfw6))

The CPU time spent executing user-level software is called _user time_, and kernel-level software is _kernel time_. Kernel time includes time during system calls, kernel threads, and interrupts. When measured across the entire system, the user time/kernel time ratio indicates the type of workload performed. ([View Highlight](https://read.readwise.io/read/01gtbezc5e44mmtr8t9v73r704))

Applications that are computation-intensive may spend almost all their time executing user-level code and have a user/kernel ratio approaching 99/1. Examples include image processing, machine learning, genomics, and data analysis. ([View Highlight](https://read.readwise.io/read/01gtbeztwcveczqjbetcgesdjs))

Applications that are I/O-intensive have a high rate of system calls, which execute kernel code to perform the I/O. For example, a web server performing network I/O may have a user/kernel ratio of around 70/30. ([View Highlight](https://read.readwise.io/read/01gtbf005jwbeyss0q4fte2d8q))

6.3.10 Saturation ([View Highlight](https://read.readwise.io/read/01gtbf0h1h8jc587e0yzvqc94r))

A CPU at 100% utilization is _saturated_, and threads will encounter _scheduler latency_ as they wait to run on-CPU, decreasing overall performance. This latency is the time spent waiting on the CPU run queue or other structure used to manage threads. ([View Highlight](https://read.readwise.io/read/01gtbf0ysp6pxjdy5xpmymkeq0))

Another form of CPU saturation involves CPU resource controls, as may be imposed in a multi-tenant cloud computing environment. ([View Highlight](https://read.readwise.io/read/01gtbf20jhb7s0my0n8t6z2b2k))

A CPU running at saturation is less of a problem than other resource types, as higher-priority work can preempt the current thread. ([View Highlight](https://read.readwise.io/read/01gtbf1tsrwjkzfvk8gkmdje06))

Preemption, introduced in [Chapter 3](#ch03), [Operating Systems](#ch03), allows a higher-priority thread to preempt the currently running thread and begin its own execution instead. This eliminates the run-queue latency for higher-priority work, improving its performance. ([View Highlight](https://read.readwise.io/read/01gtbf2mv4517fqkxqg1e3fqnc))

6.3.12 Priority Inversion ([View Highlight](https://read.readwise.io/read/01gtbf31818h8v67v2pbxn43c0))

Priority inversion occurs when a lower-priority thread holds a resource and blocks a higher-priority thread from running. This reduces the performance of the higher-priority work, as it is blocked waiting.

This can be solved using a _priority inheritance_ scheme. Here is an example of how this can work (based on a real-world case):

Thread A performs monitoring and has a low priority. It acquires an address space lock for a production database, to check memory usage.

Thread B, a routine task to perform compression of system logs, begins running.

There is insufficient CPU to run both. Thread B preempts A and runs.

Thread C is from the production database, has a high priority, and has been sleeping waiting for I/O. This I/O now completes, putting thread C back into the runnable state.

Thread C preempts B, runs, but then blocks on the address space lock held by thread A. Thread C leaves CPU.

The scheduler picks the next-highest-priority thread to run: B.

With thread B running, a high-priority thread, C, is effectively blocked on a lower-priority thread, B. This is priority inversion.

Priority inheritance gives thread A thread C’s high priority, preempting B, until it releases the lock. Thread C can now run. ([View Highlight](https://read.readwise.io/read/01gtbf3jprjj0mdfeyeyb12sjn))

6.3.13 Multiprocess, Multithreading ([View Highlight](https://read.readwise.io/read/01gtbf3zx00zxq3d9174jempbq))

Most processors provide multiple CPUs of some form. For an application to make use of them, it needs separate threads of execution so that it can run in parallel. For a 64-CPU system, ([View Highlight](https://read.readwise.io/read/01gtbf5pk0q9p27tw2dq67evxz))

The two techniques to scale applications across CPUs are _multiprocess_ and _multithreading_, which are pictured in [Figure 6.4](#ch06fig04). ([View Highlight](https://read.readwise.io/read/01gtbf63vywm78690msd5q4czb))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig04-06fig04.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig04-06fig04.jpg)

([View Highlight](https://read.readwise.io/read/01gtbf6f4b2r0tdhbfpczrfy4f))

On Linux both the multiprocess and multithread models may be used, and both are implemented by tasks. ([View Highlight](https://read.readwise.io/read/01gtbf78mqws04ess5ke232vsn))

Table 6.1 **Multiprocess and multithreading attributes**

**Attribute**

**Multiprocess**

**Multithreading**

Development

Can be easier. Use of fork(2) or clone(2).

Use of threads API (pthreads).

Memory overhead

Separate address space per process consumes some memory resources (reduced to some degree by page- level copy-on-write).

Small. Requires only extra stack and register space, and space for thread-local data.

CPU overhead

Cost of fork(2)/clone(2)/exit(2), which includes MMU work to manage address spaces.

Small. API calls.

Communication

Via IPC. This incurs CPU cost including context switching for moving data between address spaces, unless shared memory regions are used.

Fastest. Direct access to shared memory. Integrity via synchronization primitives (e.g., mutex locks).

Crash resilience

High, processes are independent.

Low, any bug can crash the entire application.

Memory Usage

While some memory may be duplicated, separate processes can exit(2) and return all memory back to the system.

Via system allocator. This may incur some CPU contention from multiple threads, and fragmentation before memory is reused. ([View Highlight](https://read.readwise.io/read/01gtbf7tzrc68dsfq1s9vtektt))

Whichever technique is used, it is important that enough processes or threads be created to span the desired number of CPUs—which, for maximum performance, may be all of the CPUs available. Some applications may perform better when running on fewer CPUs, when the cost of thread synchronization and reduced memory locality (NUMA) outweighs the benefit of running across more CPUs. ([View Highlight](https://read.readwise.io/read/01gtbf967pxpjvtvf3d0frpykn))

6.3.14 Word Size ([View Highlight](https://read.readwise.io/read/01gtbf9s3g51f9gnqwwdhxnhrs))

Processors are designed around a maximum _word size_—32-bit or 64-bit—which is the integer size and register size. Word size is also commonly used, depending on the processor, for the address space size and data path width (where it is sometimes called the _bit width_). ([View Highlight](https://read.readwise.io/read/01gtbfazt466c5wygxb75t1g8y))

Larger sizes can mean better performance, although it’s not as simple as it sounds. Larger sizes may cause memory overheads for unused bits in some data types. The data footprint also increases when the size of pointers (word size) increases, which can require more memory I/O. For the x86 64-bit architecture, these overheads are compensated by an increase in registers and a more efficient register calling convention, so 64-bit applications will likely be faster than their 32-bit versions. ([View Highlight](https://read.readwise.io/read/01gtbfc7qczmhh4753v9c4rakf))

Processors and operating systems can support multiple word sizes and can run applications compiled for different word sizes simultaneously. If software has been compiled for the smaller word size, it may execute successfully but perform relatively poorly. ([View Highlight](https://read.readwise.io/read/01gtbfcve1dhncvyy583by5bt5))

6.3.15 Compiler Optimization ([View Highlight](https://read.readwise.io/read/01gtbfdh0y1tfmm8r3aqb5j3n9))

6.3.15 Compiler Optimization ([View Highlight](https://read.readwise.io/read/01gtbff59k2v9p1r3217pka6ch))

The CPU runtime of applications can be significantly improved through compiler options (including setting the word size) and optimizations. Compilers are also frequently updated to take advantage of the latest CPU instruction sets and to implement other optimizations. Sometimes application performance can be significantly improved simply by using a newer compiler. ([View Highlight](https://read.readwise.io/read/01gtbfgc242dt887caxps1afk6))

6.4 Architecture ([View Highlight](https://read.readwise.io/read/01gtbfhgrdw084gxmksz4xbxe1))

6.4.1 Hardware ([View Highlight](https://read.readwise.io/read/01gtbfq3zt8a15g47qasm30y95))

CPU hardware includes the processor and its subsystems, and the CPU interconnect for multiprocessor systems. ([View Highlight](https://read.readwise.io/read/01gtbfqfcjg89r70yzjstr2f8v))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig05-06fig05.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig05-06fig05.jpg)

([View Highlight](https://read.readwise.io/read/01gtbfqpqqjw0czywtzgddfwx9))

The _control unit_ is the heart of the CPU, performing instruction fetch, decoding, managing execution, and storing results. ([View Highlight](https://read.readwise.io/read/01gtbfr0erjfne49evr61ataqb))

This example processor depicts a shared floating-point unit and (optional) shared Level 3 cache. The actual components in your processor will vary depending on its type and model. Other performance-related components that may be present include: ([View Highlight](https://read.readwise.io/read/01gtbfr99nves5ak4eax0tg65g))

• **P-cache**: Prefetch cache (per CPU core)

• **W-cache**: Write cache (per CPU core)

• **Clock**: Signal generator for the CPU clock (or provided externally)

• **Timestamp counter**: For high-resolution time, incremented by the clock

• **Microcode ROM**: Quickly converts instructions to circuit signals

• **Temperature sensors**: For thermal monitoring

• **Network interfaces**: If present on-chip (for high performance) ([View Highlight](https://read.readwise.io/read/01gtbfrkmxbdd8qt80fe9517c6))

The _advanced configuration and power interface_ (ACPI) standard, in use by Intel processors, defines _processor performance states_ (P-states) and _processor power states_ (C-states) [[ACPI 17]](#ch06ref19). ([View Highlight](https://read.readwise.io/read/01gtbftgpg3bjj34hze7s5hgfz))

P-states provide different levels of performance during normal execution by varying the CPU frequency: P0 is the highest frequency (for some Intel CPUs this is the highest “turbo boost” level) and P1...N are lower-frequency states. These states can be controlled by both hardware (e.g., based on the processor temperature) or via software (e.g., kernel power saving modes). The current operating frequency and available states can be observed using model-specific registers (MSRs) (e.g., using the showboost(8) tool in [Section 6.6.10](#ch06lev6sec10), [showboost](#ch06lev6sec10)). ([View Highlight](https://read.readwise.io/read/01gtbfv4v6a5388esqnjv1kwdj))

C-states provide different idle states for when execution is halted, saving power. The C-states are shown in [Table 6.2](#ch06tab02): C0 is for normal operation, and C1 and above are for idle states: the higher the number, the deeper the state. ([View Highlight](https://read.readwise.io/read/01gtbfvf7r0np273cpx3gy4jyc))

Table 6.2 **Processor power states (C-states)**

**C-state**

**Description**

C0

Executing. The CPU is fully on, processing instructions.

C1

Halts execution. Entered by the hlt instruction. Caches are maintained. Wakeup latency is the lowest from this state.

C1E

Enhanced halt with lower power consumption (supported by some processors).

C2

Halts execution. Entered by a hardware signal. This is a deeper sleep state with higher wakeup latency.

C3

A deeper sleep state with improved power savings over C1 and C2. The caches may maintain state, but stop snooping (cache coherency), deferring it to the OS. ([View Highlight](https://read.readwise.io/read/01gtbfvrzp3rejpwzqcp15gr7z))

CPU Caches ([View Highlight](https://read.readwise.io/read/01gtbh57d9a95ys9agpm4hne5s))

Various hardware caches are usually included in the processor (where they are referred to as _on-chip_, _on-die_, _embedded_, or _integrated_) or with the processor (_external_). ([View Highlight](https://read.readwise.io/read/01gtbh9w8ryj1m6mxzj03wdzys))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig06-06fig06.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig06-06fig06.jpg)

([View Highlight](https://read.readwise.io/read/01gtbhakqrxwt2335bm2dtm39f))

They include: ([View Highlight](https://read.readwise.io/read/01gtbhb60p5gk91e3znrr08cxj))

**Level 1 instruction cache** (I$) ([View Highlight](https://read.readwise.io/read/01gtbhbp63mt1shpr2eafssm29))

**Level 1 data cache** (D$) ([View Highlight](https://read.readwise.io/read/01gtbhc55zj6p3q97yd4nn42gx))

**Translation lookaside buffer** (TLB) ([View Highlight](https://read.readwise.io/read/01gtbhcn10jn01rjhn3t0rer78))

• **Level 2 cache** (E$)

• **Level 3 cache** (optional) ([View Highlight](https://read.readwise.io/read/01gtbhd2zvgvd4xqhyrs1888g3))

Intel uses the term _last-level cache_ (LLC) for this, also described as the _longest-latency cache_. ([View Highlight](https://read.readwise.io/read/01gtbhdran5gjn1c5fkrgxzt3s))

For multicore and multithreading processors, some caches may be shared between cores and threads. ([View Highlight](https://read.readwise.io/read/01gtbhevn8c2vfq8hmyrtxxdeg))

Multiple levels of cache are used to deliver the optimum configuration of size and latency. The access time for the Level 1 cache is typically a few CPU clock cycles, and for the larger Level 2 cache around a dozen clock cycles. Main memory access can take around 60 ns (around 240 cycles for a 4 GHz processor), and address translation by the MMU also adds latency. ([View Highlight](https://read.readwise.io/read/01gtbhhb5w4p53ck5mww716e2w))

The CPU cache latency characteristics for your processor can be determined experimentally using micro-benchmarking ([View Highlight](https://read.readwise.io/read/01gtbhnv4e1dygpd6k28prh9hf))

Associativity is a cache characteristic describing a constraint for locating new entries in the cache. Types are: ([View Highlight](https://read.readwise.io/read/01gtbhqmfaw1p1hzxn79tr2v34))

• **Fully associative**: The cache can locate new entries anywhere. For example, a least recently used (LRU) algorithm could be used for eviction across the entire cache.

• **Direct mapped**: Each entry has only one valid location in the cache, for example, a hash of the memory address, using a subset of the address bits to form an address in the cache.

• **Set associative**: A subset of the cache is identified by mapping (e.g., hashing) from within which another algorithm (e.g., LRU) may be performed. It is described in terms of the subset size; for example, _four-way set associative_ maps an address to four possible locations, and then picks the best from those four (e.g., the least recently used location). ([View Highlight](https://read.readwise.io/read/01gtbhrzaqc9q9szate9gw4x1r))

Cache Line ([View Highlight](https://read.readwise.io/read/01gtbj4s1t1avfrr8wkasvy91c))

Another characteristic of CPU caches is their _cache line_ size. This is a range of bytes that are stored and transferred as a unit, improving memory throughput. A typical cache line size for x86 processors is 64 bytes ([View Highlight](https://read.readwise.io/read/01gtbj5txcmgt95g87knxhefs6))

Cache Coherency

Memory may be cached in multiple CPU caches on different processors at the same time. When one CPU modifies memory, all caches need to be aware that their cached copy is now _stale_ and should be discarded, so that any future reads will retrieve the newly modified copy. This process, called _cache coherency_, ensures that CPUs are always accessing the correct state of memory. ([View Highlight](https://read.readwise.io/read/01gtbj7618em06j2gfzg3sdpb0))

One of the effects of cache coherency is LLC access penalties. The following examples are provided as a rough guide (these are from [[Levinthal 09]](#ch06ref12)):

• LLC hit, line unshared: ~40 CPU cycles

• LLC hit, line shared in another core: ~65 CPU cycles

• LLC hit, line modified in another core: ~75 CPU cycles ([View Highlight](https://read.readwise.io/read/01gtbjethjs1kxtwvrdkx6ph5t))

F ([View Highlight](https://read.readwise.io/read/01gtbka361a9fr24s3760sfb0q))

or multiprocessor architectures, processors are connected using either a shared system bus or a dedicated interconnect ([View Highlight](https://read.readwise.io/read/01gtbk0azqparea4cpksv0c77n))

A shared system bus, called the _front-side bus_, used by earlier Intel processors is illustrated by the four-processor example in [Figure 6.9](#ch06fig09). ([View Highlight](https://read.readwise.io/read/01gtbkc0620ck201cj4wvdtd9x))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig09-06fig09.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig09-06fig09.jpg)

([View Highlight](https://read.readwise.io/read/01gtbkfava9pxxdnfbrtw2t5cy))

The use of a system bus has scalability problems when the processor count is increased, due to contention for the shared bus resource. Modern servers are typically multiprocessor, NUMA, and use a CPU interconnect instead. ([View Highlight](https://read.readwise.io/read/01gtbkj52zfz2ppdy9w8zh6bq9))

Interconnects can connect components other than processors, such as I/O controllers. Example interconnects include Intel’s Quick Path Interconnect (QPI), Intel’s Ultra Path Interconnect (UPI), AMD’s HyperTransport (HT), ARM’s CoreLink Interconnects (there are three different types), and IBM’s Coherent Accelerator Processor Interface (CAPI). An example Intel QPI architecture for a four-processor system is shown in [Figure 6.10](#ch06fig10). ([View Highlight](https://read.readwise.io/read/01gtbkhxyks8c5jqpy7x4kxcqr))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig10-06fig10.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig10-06fig10.jpg)

([View Highlight](https://read.readwise.io/read/01gtbkjddqb7677t561vmvrbj0))

Table 6.4 **Intel CPU interconnect example bandwidths**

**Intel**

**Transfer Rate**

**Width**

[**Bandwidth**](#glo_017)

FSB (2007)

1.6 GT/s

8 bytes

12.8 Gbytes/s

QPI (2008)

6.4 GT/s

2 bytes

25.6 Gbytes/s

UPI (2017)

10.4 GT/s

2 bytes

41.6 Gbytes/s ([View Highlight](https://read.readwise.io/read/01gtbkk422nacmkt27bwfgpyd1))

To explain how transfer rates can relate to bandwidth, I will explain the QPI example, which is for a 3.2 GHz clock. QPI is _double-pumped_, performing a data transfer on both rising and falling edges of the clock.[4](#ch06fn4) This doubles the transfer rate (3.2 GHz × 2 = 6.4 GT/s). The final bandwidth of 25.6 Gbytes/s is for both send and receive directions (6.4 GT/s × 2 byte width × 2 directions = 25.6 Gbytes/s). ([View Highlight](https://read.readwise.io/read/01gtbkkdhe843n8hgydqwvetvp))

[4](#ch06fn4a)There is also _quad-pumped_, where data is transferred on the rising edge, peak, falling edge, and trough of the clock cycle. Quad pumping is used by the Intel FSB. ([View Highlight](https://read.readwise.io/read/01gtbkknyb67qbvgb10zjdmtbb))

An interesting detail of QPI is that its cache coherency mode could be tuned in the BIOS, with options including Home Snoop to optimize for memory bandwidth, Early Snoop to optimize for memory latency, and Directory Snoop to improve scalability (it involves tracking what is shared). UPI, which is replacing QPI, only supports Directory Snoop. ([View Highlight](https://read.readwise.io/read/01gtbknbm1vbgfs7p019vxwrjh))

Interconnects are typically designed for high bandwidth, so that they do not become a systemic bottleneck. If they do, performance will degrade as CPU instructions encounter stall cycles for operations that involve the interconnect, such as remote memory I/O. A key indicator for this is a drop in IPC. CPU instructions, cycles, IPC, stall cycles, and memory I/O can be analyzed using CPU performance counters. ([View Highlight](https://read.readwise.io/read/01gtbkp12883t0rxz1kz2wennh))

Hardware Counters (PMCs) ([View Highlight](https://read.readwise.io/read/01gtbkpctrdke7k2q5r4df9amt))

Performance monitoring counters (PMCs) were summarized as a source of observability statistics in [Chapter 4](#ch04), [Observability Tools](#ch04), [Section 4.3.9](#ch04lev3sec9), [Hardware Counters (PMCs)](#ch04lev3sec9). This section describes their CPU implementation in more detail, and provides additional examples. ([View Highlight](https://read.readwise.io/read/01gtbkq25k9keeemjatvwa1c3n))

PMCs are processor registers implemented in hardware that can be programmed to count low-level CPU activity. They typically include counters for the following: ([View Highlight](https://read.readwise.io/read/01gtbkqgrq6s74t1vren68b9tq))

**CPU cycles**: Including stall cycles and types of stall cycles ([View Highlight](https://read.readwise.io/read/01gtbkqsy8s1v85kyfnedtjpap))

• **CPU instructions**: Retired (executed)

• **Level 1, 2, 3 cache accesses**: Hits, misses

• **Floating-point unit**: Operations

• **Memory I/O**: Reads, writes, stall cycles

• **Resource I/O**: Reads, writes, stall cycles ([View Highlight](https://read.readwise.io/read/01gtbkr25xnvgcy3j2hv5gj8mn))

As a relatively simple example, the Intel P6 family of processors provide performance counters via four model-specific registers (MSRs). Two MSRs are the counters and are read-only. The other two MSRs, called _event-select_ MSRs, are used to program the counters and are read-write. The performance counters are 40-bit registers, and the event-select MSRs are 32-bit. The format of the event-select MSRs is shown in [Figure 6.11](#ch06fig11). ([View Highlight](https://read.readwise.io/read/01gtbktv48m38vybx5jqehswba))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig11-06fig11.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig11-06fig11.jpg)

([View Highlight](https://read.readwise.io/read/01gtbkva69k9d7wx0yedz3nx7m))

The counter is identified by the event select and the UMASK. The event select identifies the type of event to count, and the UMASK identifies subtypes or groups of subtypes. The OS and USR bits can be set so that the counter is incremented only while in kernel mode (OS) or user mode (USR), based on the processor protection rings. The CMASK can be set to a threshold of events that must be reached before the counter is incremented. ([View Highlight](https://read.readwise.io/read/01gtbkw3farngrmf6hydrqx0rt))

Table 6.5 **Selected examples of Intel CPU performance counters**

**Event Select**

**UMASK**

**Unit**

**Name**

**Description**

0x43

0x00

Data cache

DATA_MEM_REFS

All loads from any memory type. All stores to any memory type. Each part of a split is counted separately. ... Does not include I/O accesses or other non-memory accesses.

0x48

0x00

Data cache

DCU_MISS_ OUTSTANDING

Weighted number of cycles while a DCU miss is outstanding, incremented by the number of outstanding cache misses at any particular time. Cacheable read requests only are considered. ...

0x80

0x00

Instruction fetch unit

IFU_IFETCH

Number of instruction fetches, both cacheable and noncacheable, including UC (uncacheable) fetches.

0x28

0x0F

L2 cache

L2_IFETCH

Number of L2 instruction fetches. ...

0xC1

0x00

Floating- point unit

FLOPS

Number of computational floating-point operations retired. ...

0x7E

0x00

External bus logic

BUS_SNOOP_ STALL

Number of clock cycles during which the bus is snoop stalled.

0xC0

0x00

Instruction decoding and retirement

INST_RETIRED

Number of instructions retired.

0xC8

0x00

Interrupts

HW_INT_RX

Number of hardware interrupts received.

0xC5

0x00

Branches

BR_MISS_PRED_ RETIRED

Number of mis-predicted branches retired.

0xA2

0x00

Stalls

RESOURCE_ STALLS

Incremented by one during every cycle for which there is a resource-related stall. ...

0x79

0x00

Clocks

CPU_CLK_UNHALTED

Number of cycles during which the processor is not halted. ([View Highlight](https://read.readwise.io/read/01gtbkxhh1dswd0h2nc8zqan8h))

GPUs ([View Highlight](https://read.readwise.io/read/01gtbkyd4vthvewsf932enrhbk))

Graphics processing units (GPUs) were created to support graphical displays, and are now finding use in other workloads including artificial intelligence, machine learning, analytics, image processing, and cryptocurrency mining. For servers and cloud instances, a GPU is a processor-like resource that can execute a portion of a workload, called the _compute kernel_, that is suited to highly parallel data processing such as matrix transformations. General-purpose GPUs from Nvidia using its Compute Unified Device Architecture (CUDA) have seen widespread adoption. CUDA provides APIs and software libraries for using Nvidia GPUs. ([View Highlight](https://read.readwise.io/read/01gtbkz3g02fkm54tpab29s6es))

While a processor (CPU) may contain a dozen cores, a GPU may contain hundreds or thousands of smaller cores called _streaming processors_ (SPs),[5](#ch06fn5) which each can execute a thread*.* Since GPU workloads are highly parallel, threads that can execute in parallel are grouped into _thread blocks,_ where they may cooperate among themselves. These thread blocks may be executed by groups of SPs called _streaming multiprocessors_ (SMs) that also provide other resources including a memory cache. [Table 6.6](#ch06tab06) further compares processors (CPUs) with GPUs [[Ather 19]](#ch06ref24). ([View Highlight](https://read.readwise.io/read/01gtbkzztehahg7xjw9381ngzy))

Table 6.6 **CPUs versus GPUs**

**Attribute**

**CPU**

[**GPU**](#glo_069)

Package

A processor package plugs into a socket on the system board, connected directly to the system bus or CPU interconnect.

A GPU is typically provided as an expansion card and connected via an expansion bus (e.g., PCIe). They may also be embedded on a system board or in a processor package (on-chip).

Package scalability

Multi-socket configurations, connected via a CPU interconnect (e.g., Intel UPI).

Multi-GPU configurations are possible, connected via a GPU-to-GPU interconnect (e.g., NVIDIA's NVLink).

Cores

A typical processor of today contains 2 to 64 cores.

A GPU may have a similar number of streaming multiprocessors (SMs).

Threads

A typical core may execute two hardware threads (or more, depending on the processor).

An SM may contain dozens or hundreds of streaming processors (SPs). Each SP can only execute one thread.

Caches

Each core has L2 and L2 caches, and may share an L3 cache.

Each SM has a cache, and may share an L2 cache between them.

Clock

High (e.g., 3.4 GHz).

Relatively lower (e.g., 1.0 GHz). ([View Highlight](https://read.readwise.io/read/01gtbm0exaxt41328f2ykhcegc))

Other Accelerators ([View Highlight](https://read.readwise.io/read/01gtbm14d3879scsb1abjk31y4))

Apart from GPUs, be aware that other accelerators may exist for offloading CPU work to faster application-specific integrated circuits. These include field-programmable gate arrays (FPGAs) and tensor processing units (TPUs). ([View Highlight](https://read.readwise.io/read/01gtbm1ft6azbx2tzg2070ngrw))

GPUs and FPGAs are used to improve the performance of cryptocurrency mining. ([View Highlight](https://read.readwise.io/read/01gtbm1zz5ra8b1vzap8a04vt5))

6.4.2 Software ([View Highlight](https://read.readwise.io/read/01gtbmbx8jsa31gf1tmv6tve8t))

Kernel software to support CPUs includes the scheduler, scheduling classes, and the idle thread. ([View Highlight](https://read.readwise.io/read/01gtbmd0zhn7v3ekvb9wecm95e))

Scheduler ([View Highlight](https://read.readwise.io/read/01gtbmdk46vrvbk4nsrjtmcft7))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig12-06fig12.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig12-06fig12.jpg)

([View Highlight](https://read.readwise.io/read/01gtbme8yrfm3gwg6vw5kq45yx))

**Time sharing**: Multitasking between runnable threads, executing those with the highest priority first. ([View Highlight](https://read.readwise.io/read/01gtbmzezbdv1vrd3v4gvn12hv))

**Preemption**: For threads that have become runnable at a high priority, the scheduler can preempt the currently running thread, so that execution of the higher-priority thread can begin immediately. ([View Highlight](https://read.readwise.io/read/01gtbn4nqvnbe68hjzs3s221j7))

**Load balancing**: Moving runnable threads to the run queues of idle or less-busy CPUs. ([View Highlight](https://read.readwise.io/read/01gtbn7mf5bb67b7jc1w2jht84))

[Figure 6.12](#ch06fig12) shows run queues, which is how scheduling was originally implemented. The term and mental model are still used to describe waiting tasks. However, the Linux CFS scheduler actually uses a red/black tree of future task execution. ([View Highlight](https://read.readwise.io/read/01gtbn9aksrjbmq0a9tbapk3ch))

In Linux, time sharing is driven by the system timer interrupt by calling scheduler_tick(), which calls scheduler class functions to manage priorities and the expiration of units of CPU time called _time slices_. Preemption is triggered when threads become runnable and the scheduler class check_preempt_curr() function is called. Thread switching is managed by __schedule(), which selects the highest-priority thread via pick_next_task() for running. Load balancing is performed by the load_balance() function. ([View Highlight](https://read.readwise.io/read/01gtbnckgr8ztwsjzke2svef5p))

The Linux scheduler also uses logic to avoid migrations when the cost is expected to exceed the benefit, preferring to leave busy threads running on the same CPU where the CPU caches should still be warm (CPU affinity). ([View Highlight](https://read.readwise.io/read/01gtbndj9rty3xg0j7wa1rmknh))

Scheduling Classes ([View Highlight](https://read.readwise.io/read/01gtbnez29ffy85njq6sr5k8fg))

Scheduling classes manage the behavior of runnable threads, specifically their priorities, whether their on-CPU time is _time-sliced_, and the duration of those _time slices_ (also known as _time quanta_). ([View Highlight](https://read.readwise.io/read/01gtbnf9v1z83rthffz1dmf12e))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig13-06fig13.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig13-06fig13.jpg)

([View Highlight](https://read.readwise.io/read/01gtbngfv9np8skvwn3gn9cd3h))

For Linux kernels, the scheduling classes are: ([View Highlight](https://read.readwise.io/read/01gtbntwfzbmtpp4nnq5gqrfrp))

**RT**: Provides fixed and high priorities for real-time workloads. The kernel supports both user- and kernel-level preemption, allowing RT tasks to be dispatched with low latency. The priority range is 0–99 (MAX_RT_PRIO-1). ([View Highlight](https://read.readwise.io/read/01gtbnxsn45t84yh2qn573yzvr))

• **O(1)**: The O(1) scheduler was introduced in Linux 2.6 as the default time-sharing scheduler for user processes. The name comes from the algorithm complexity of O(1) (see [Chapter 5](#ch05), [Applications](#ch05), for a summary of big O notation). The prior scheduler contained routines that iterated over all tasks, making it O(n), which became a scalability issue. The O(1) scheduler dynamically improved the priority of I/O-bound over CPU-bound workloads, to reduce the latency of interactive and I/O workloads.

• **CFS**: Completely fair scheduling was added to the Linux 2.6.23 kernel as the default time-sharing scheduler for user processes. The scheduler manages tasks on a red-black tree keyed from the task CPU time, instead of traditional run queues. This allows low CPU consumers to be easily found and executed in preference to CPU-bound workloads, improving the performance of interactive and I/O-bound workloads.

• **Idle**: Runs threads with the lowest possible priority.

• **Deadline**: Added to Linux 3.14, applies earliest deadline first (EDF) scheduling using three parameters: _runtime_, _period_, and _deadline_. A task should receive runtime microseconds of CPU time every period microseconds, and do so within the deadline. ([View Highlight](https://read.readwise.io/read/01gtbp1578898hr3bwy5d2gqjn))

Scheduler policies are:

• **RR**: SCHED_RR is round-robin scheduling. Once a thread has used its time quantum, it is moved to the end of the run queue for that priority level, allowing others of the same priority to run. Uses the RT scheduling class.

• **FIFO**: SCHED_FIFO is first-in, first-out scheduling, which continues running the thread at the head of the run queue until it voluntarily leaves, or until a higher-priority thread arrives. The thread continues to run, even if other threads of the same priority are on the run queue. Uses the RT class.

• **NORMAL**: SCHED_NORMAL (previously known as SCHED_OTHER) is time-sharing scheduling and is the default for user processes. The scheduler dynamically adjusts priority based on the scheduling class. For O(1), the time slice duration is set based on the static priority: longer durations for higher-priority work. For CFS, the time slice is dynamic. Uses the CFS scheduling class.

• **BATCH**: SCHED_BATCH is similar to SCHED_NORMAL, but with the expectation that the thread will be CPU-bound and should not be scheduled to interrupt other I/O-bound interactive work. Uses the CFS scheduling class.

• **IDLE**: SCHED_IDLE uses the Idle scheduling class.

• **DEADLINE**: SCHED_DEADLINE uses the Deadline scheduling class ([View Highlight](https://read.readwise.io/read/01gtbp1grbek0zxn7aa7hpndxs))

Idle Thread ([View Highlight](https://read.readwise.io/read/01gtbp3ftwh5cxa0fy21mpea4h))

the kernel “idle” thread (or _idle task_) runs on-CPU when there is no other runnable thread and has the lowest possible priority. It is usually programmed to inform the processor that CPU execution may either be halted (halt instruction) or throttled down to conserve power. The CPU will wake up on the next hardware interrupt. ([View Highlight](https://read.readwise.io/read/01gtbp9k9rw5vzb3x0x3x67ek0))

NUMA Grouping

Performance on NUMA systems can be significantly improved by making the kernel _NUMA-aware_, so that it can make better scheduling and memory placement decisions. This can automatically detect and create groups of localized CPU and memory resources and organize them in a topology to reflect the NUMA architecture. This topology allows the cost of any memory access to be estimated.

On Linux systems, these are called _scheduling domains_, which are in a topology beginning with the _root domain_.

A manual form of grouping can be performed by the system administrator, either by binding processes to run on one or more CPUs only, or by creating an exclusive set of CPUs for processes to run on. See [Section 6.5.10](#ch06lev5sec10), [CPU Binding](#ch06lev5sec10). ([View Highlight](https://read.readwise.io/read/01gtbpav0vfcjynv9rxjg4s3rz))

Processor Resource-Aware ([View Highlight](https://read.readwise.io/read/01gtbpyh990h33weh40xgwznry))

6.5 Methodology ([View Highlight](https://read.readwise.io/read/01gtbq0vwa8s13cg5kpqx4d78r))

Table 6.7 **CPU performance methodologies**

**Section**

**Methodology**

**Types**

[6.5.1](#ch06lev5sec1)

Tools method

Observational analysis

[6.5.2](#ch06lev5sec2)

USE method

Observational analysis

[6.5.3](#ch06lev5sec3)

Workload characterization

Observational analysis, capacity planning

[6.5.4](#ch06lev5sec4)

Profiling

Observational analysis

[6.5.5](#ch06lev5sec5)

Cycle analysis

Observational analysis

[6.5.6](#ch06lev5sec6)

Performance monitoring

Observational analysis, capacity planning

[6.5.7](#ch06lev5sec7)

Static performance tuning

Observational analysis, capacity planning

[6.5.8](#ch06lev5sec8)

Priority tuning

Tuning

[6.5.9](#ch06lev5sec9)

Resource controls

Tuning

[6.5.10](#ch06lev5sec10)

CPU binding

Tuning

[6.5.11](#ch06lev5sec11)

Micro-benchmarking

Experimental analysis ([View Highlight](https://read.readwise.io/read/01gtbq29247we2c2p7800790vb))

6.5.1 Tools Method ([View Highlight](https://read.readwise.io/read/01gtbq9he9kjgjfht27t067mzn))

For CPUs, the tools method can involve checking the following (Linux):

• **`uptime/top`**: Check the load averages to see if load is increasing or decreasing over time. Bear this in mind when using the following tools, as load may be changing during your analysis.

• **`vmstat`**: Run vmstat(1) with a one-second interval and check the system-wide CPU utilization (“us” + “sy”). Utilization approaching 100% increases the likelihood of scheduler latency.

• **`mpstat`**: Examine statistics per-CPU and check for individual hot (busy) CPUs, identifying a possible thread scalability problem.

• **`top`**: See which processes and users are the top CPU consumers.

• **`pidstat`**: Break down the top CPU consumers into user- and system-time.

• **`perf/profile`**: Profile CPU usage stack traces for both user- or kernel-time, to identify why the CPUs are in use.

• **`perf`**: Measure IPC as an indicator of cycle-based inefficiencies.

• **`showboost/turboboost`**: Check the current CPU clock rates, in case they are unusually low.

• **`dmesg`**: Check for CPU temperature stall messages (“cpu clock throttled”). ([View Highlight](https://read.readwise.io/read/01gtbqcrz96hh38rwv483cnytt))

6.5.2 USE Method ([View Highlight](https://read.readwise.io/read/01gtbqhr3fjh03ckbcmb3mefnq))

The USE method can be used to identify bottlenecks and errors across all components early in a performance investigation, before trying deeper and more time-consuming strategies. ([View Highlight](https://read.readwise.io/read/01gtbqj9wtgw0jfq63zr279rv8))

For each CPU, check for: ([View Highlight](https://read.readwise.io/read/01gtbqj2f4e3ya5tpzepvs5271))

• **Utilization**: The time the CPU was busy (not in the idle thread)

• **Saturation**: The degree to which runnable threads are queued waiting their turn on-CPU

• **Errors**: CPU errors, including correctable errors ([View Highlight](https://read.readwise.io/read/01gtbqjjmbp99z8hp1p5nr2ks3))

You can check errors first since they are typically quick to check and the easiest to interpret. Some processors and operating systems will sense an increase in correctable errors (error-correction code, ECC) and will offline a CPU as a precaution, before an uncorrectable error causes a CPU failure. Checking for these errors can be a matter of checking that all CPUs are still online. ([View Highlight](https://read.readwise.io/read/01gtbqkdern1cxa3b5ess56p8k))

Utilization is usually readily available from operating system tools as _percent busy_. This metric should be examined per CPU, to check for scalability issues. High CPU and core utilization can be understood by using profiling and cycle analysis. ([View Highlight](https://read.readwise.io/read/01gtbqqw3c8f5795da84jh8hte))

For environments that implement CPU limits or quotas (resource controls; e.g., Linux tasksets and cgroups), as is common in cloud computing environments, CPU utilization should be measured in terms of the imposed limit, in addition to the physical limit ([View Highlight](https://read.readwise.io/read/01gtbqrre1smhxa7gsc5yqjg79))

Saturation metrics are commonly provided system-wide, including as part of load averages. This metric quantifies the degree to which the CPUs are overloaded, or a CPU quota, if present, is used up. ([View Highlight](https://read.readwise.io/read/01gtbqsd1rzpxsfz7gwgx0zhzs))

6.5.3 Workload Characterization ([View Highlight](https://read.readwise.io/read/01gtg79023aw115hncsn0119g2))

Basic attributes for characterizing CPU workload are:

• CPU load averages (utilization + saturation)

• User-time to system-time ratio

• Syscall rate ([View Highlight](https://read.readwise.io/read/01gtg7a2p3vy2gyg02ds76dxwq))

• Voluntary context switch rate

• Interrupt rate ([View Highlight](https://read.readwise.io/read/01gtg7wcp2b2hrbre7mrnbvfx4))

The user-time to system-time ratio shows the type of load applied ([View Highlight](https://read.readwise.io/read/01gtg7ygxh9amsrb2pjkax6gbd))

High user time rates are due to applications spending time performing their own compute. High system time shows time spent in the kernel instead, which may be further understood by the syscall and interrupt rate. I/O-bound workloads have higher system time, syscalls, and higher voluntary context switches than CPU-bound workloads as threads block waiting for I/O. ([View Highlight](https://read.readwise.io/read/01gtg7yytwcs6d6mphrvp410jf))

Here is an example workload description, designed to show how these attributes can be expressed together:

On an average 48-CPU application server, the load average varies between 30 and 40 during the day. The user/system ratio is 95/5, as this is a CPU-intensive workload. There are around 325 K syscalls/s, and around 80 K voluntary context switches/s. ([View Highlight](https://read.readwise.io/read/01gtg81pca8ffym5bh0hj98pnh))

Advanced Workload Characterization/Checklist ([View Highlight](https://read.readwise.io/read/01gtg83e799zj36phqxyek91jy))

Additional details may be included to characterize the workload. These are listed here as questions for consideration, which may also serve as a checklist when studying CPU issues thoroughly:

• What is the CPU utilization system-wide? Per CPU? Per core?

• How parallel is the CPU load? Is it single-threaded? How many threads?

• Which applications or users are using the CPUs? How much?

• Which kernel threads are using the CPUs? How much?

• What is the CPU usage of interrupts?

• What is the CPU interconnect utilization?

• Why are the CPUs being used (user- and kernel-level call paths)?

• What types of stall cycles are encountered? ([View Highlight](https://read.readwise.io/read/01gtg84c28yxgq73wg9s8fpdp9))

See [Chapter 2](#ch02), [Methodologies](#ch02), for a higher-level summary of this methodology and the characteristics to measure (who, why, what, how). ([View Highlight](https://read.readwise.io/read/01gtg850ytyza7p1hcxdznag64))

6.5.4 Profiling ([View Highlight](https://read.readwise.io/read/01gtg862ne0gkrfzvn1jqhnptd))

• **Timer-based sampling**: Collecting timer-based samples of the currently running function or stack trace. A typical rate used is 99 Hertz (samples per second) per CPU. This provides a coarse view of CPU usage, with enough detail for large and small issues. 99 is used to avoid lock-step sampling that may occur at 100 Hertz, which would produce a skewed profile. If needed, the timer rate can be lowered and the time span enlarged until the overhead is negligible and suitable for production use.

• **Function tracing**: Instrumenting all or some function calls to measure their duration. This provides a fine-level view, but the overhead can be prohibitive for production use, often 10% or more, because function tracing adds instrumentation to every function call. ([View Highlight](https://read.readwise.io/read/01gtg86tvhc8kk05v47t2a6y3m))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig14-06fig14.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig14-06fig14.jpg)

([View Highlight](https://read.readwise.io/read/01gtg8a0v9y9h4fw4ctd7ph5x8))

[Figure 6.14](#ch06fig14) shows how samples are only collected when the process is on-CPU: two samples show function A() on-CPU, and two samples show function B() on-CPU called by A(). The time off-CPU during a syscall was not sampled. Also, the short-lived function C() was entirely missed by sampling. ([View Highlight](https://read.readwise.io/read/01gtg8b8h2h6m04v40z04rpknw))

Kernels typically maintain two stack traces for processes: a user-level stack and a kernel stack when in kernel context (e.g., syscalls). For a complete CPU profile, the profiler must record both stacks when available. ([View Highlight](https://read.readwise.io/read/01gtg8dbdch3npf3bxgmfdv4hh))

Sample Processing ([View Highlight](https://read.readwise.io/read/01gtg8e6jewt9r6t3483w1pdz4))

• **Storage I/O**: Profilers typically write samples to a profile file, which can then be read and examined in different ways. However, writing so many samples to the file system can generate storage I/O that perturbs the performance of the production application. The BPF-based profile(8) tool solves the storage I/O problem by summarizing the samples in kernel memory, and only emitting the summary. No intermediate profile file is used.

• **Comprehension**: It is impractical to read 47,040 multi-line stack traces one by one: summaries and visualizations must be used to make sense of the profile. A commonly used stack trace visualization is _flame graphs_, some examples of which are shown in earlier chapters ([1](#ch01) and [5](#ch05)); and there are more examples in this chapter. ([View Highlight](https://read.readwise.io/read/01gtg8hyxz6kff9gd3h299bd40))

[Figure 6.15](#ch06fig15) shows the overall steps to generate CPU flame graphs from perf(1) and profile, solving the comprehension problem. It also shows how the storage I/O problem is solved: profile(8) does not use an intermediate file, saving overhead. The exact commands used are listed in [Section 6.6.13](#ch06lev6sec13), [perf](#ch13). ([View Highlight](https://read.readwise.io/read/01gtg8g5eg1nn37gtdrn98d9t9))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig15-06fig15.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig15-06fig15.jpg)

([View Highlight](https://read.readwise.io/read/01gtg8ha3n5543twht41m30rt6))

While the BPF-based approach has lower overhead, the perf(1) approach saves the raw samples (with timestamps), which can be reprocessed using different tools, including FlameScope ([Section 6.7.4](#ch06lev7sec4)). ([View Highlight](https://read.readwise.io/read/01gtg8jyg39vyvz41rnjkc5959))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig16-06fig16.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig16-06fig16.jpg)

([View Highlight](https://read.readwise.io/read/01gtg8mzy5wxtcd9f5ga3057x6))

My method for finding performance wins in a CPU flame graphs is as follows:

Look top-down (leaf to root) for large “plateaus.” These show that a single function is on-CPU during many samples, and can lead to some quick wins. In [Figure 6.16](#ch06fig16), there are two plateaus on the right, in unmap_page_range() and page_remove_rmap(), both related to memory pages. Perhaps a quick win is to switch the application to use large pages.

Look bottom-up to understand the code hierarchy. In this example, the bash(1) shell was calling the execve(2) syscall, which eventually called the page functions. Perhaps an even bigger win is to avoid execve(2) somehow, such as by using bash builtins instead of external processes, or switching to another language.

Look more carefully top-down for scattered but common CPU usage. Perhaps there are many small frames related to the same problem, such as lock contention. Inverting the merge order of flame graphs so that they are merged from leaf to root and become _icicle graphs_ can help reveal these cases. ([View Highlight](https://read.readwise.io/read/01gtg8ndzrr3b55jrapma5kmn7))

6.5.5 Cycle Analysis ([View Highlight](https://read.readwise.io/read/01gtg8pxbrbbcv7bhb8mmetz29))

You can use Performance Monitoring Counters (PMCs) to understand CPU utilization at the cycle level. This may reveal that cycles are spent stalled on Level 1, 2, or 3 cache misses, memory or resource I/O, or spent on floating-point operations or other activity. This information may show performance wins you can achieve by adjusting compiler options or changing the code. ([View Highlight](https://read.readwise.io/read/01gtgevz63a3qayhn3smx77b85))

egin cycle analysis by measuring IPC (inverse of CPI). If IPC is low, continue to investigate types of stall cycles. If IPC is high, look for ways in the code to reduce instructions performed. The values for “high” or “low” IPC depend on your processor: low could be less than 0.2, and high could be greater than 1. ([View Highlight](https://read.readwise.io/read/01gtgtxtbhfyt8qrbhcjyrxa3e))

You can get a sense of these values by performing known workloads that are either memory I/O-intensive or instruction-intensive, and measuring the resulting IPC for each. ([View Highlight](https://read.readwise.io/read/01gtgty2wy8edw6adw318xm0zq))

Apart from measuring counter values, PMCs can be configured to interrupt the kernel on the overflow of a given value. For example, at every 10,000 Level 3 cache misses, the kernel could be interrupted to gather a stack backtrace. Over time, the kernel builds a profile of the code paths that are causing Level 3 cache misses, without the prohibitive overhead of measuring every single miss. This is typically used by integrated developer environment (IDE) software, to annotate code with the locations that are causing memory I/O and stall cycles. ([View Highlight](https://read.readwise.io/read/01gtgtzqy2vpz3t7zyqmy755me))

6.5.6 Performance Monitoring ([View Highlight](https://read.readwise.io/read/01gtgv2b9dj011tgh2d5737qjw))

Performance monitoring can identify active issues and patterns of behavior over time. Key metrics for CPUs are:

• **Utilization**: Percent busy

• **Saturation**: Either run-queue length or scheduler latency ([View Highlight](https://read.readwise.io/read/01gtgv302th1gann0w8h9reb5m))

Utilization should be monitored on a per-CPU basis to identify thread scalability issues. ([View Highlight](https://read.readwise.io/read/01gtgv6g739thzf2eb2s9heg3x))

Choosing the right interval to measure and archive is a challenge in monitoring CPU usage. Some monitoring tools use five-minute intervals, which can hide the existence of shorter bursts of CPU utilization. Per-second measurements are preferable, but you should be aware that there can be bursts even within one second. These can be identified from saturation, and examined using FlameScope ([Section 6.7.4](#ch06lev7sec4)), which was created for subsecond analysis. ([View Highlight](https://read.readwise.io/read/01gtgv7jsxb08sqdn73385kq8b))

6.5.7 Static Performance Tuning ([View Highlight](https://read.readwise.io/read/01gtgv93yk3q39h4051fazy9x5))

Static performance tuning focuses on issues of the configured environment. For CPU performance, examine the following aspects of the static configuration ([View Highlight](https://read.readwise.io/read/01gtgvanxy6tbrph3fh5b3e7ms))

• How many CPUs are available for use? Are they cores? Hardware threads?

• Are GPUs or other accelerators available and in use?

• Is the CPU architecture single- or multiprocessor?

• What is the size of the CPU caches? Are they shared?

• What is the CPU clock speed? Is it dynamic (e.g., Intel Turbo Boost and SpeedStep)? Are those dynamic features enabled in the BIOS?

• What other CPU-related features are enabled or disabled in the BIOS? E.g., turboboost, bus settings, power saving settings?

• Are there performance issues (bugs) with this processor model? Are they listed in the processor errata sheet?

• What is the microcode version? Does it include performance-impacting mitigations for security vulnerabilities (e.g., Spectre/Meltdown)?

• Are there performance issues (bugs) with this BIOS firmware version?

• Are there software-imposed CPU usage limits (resource controls) present? What are they? ([View Highlight](https://read.readwise.io/read/01gtgvbeqv7vpna7qvewzsezhf))

6.5.8 Priority Tuning ([View Highlight](https://read.readwise.io/read/01gtgvejvwwy8tmdhj0mdet071))

Unix has always provided a nice(2) system call for adjusting process priority, which sets a nice-ness value. Positive nice values result in lower process priority (nicer), and negative values—which can be set only by the superuser (root)[7](#ch06fn7)—result in higher priority. A nice(1) command became available to launch programs with nice values, and a renice(1M) command was later added (in BSD) to adjust the nice value of already running processes ([View Highlight](https://read.readwise.io/read/01gtgvgycmqct4vwafyf08p528))

[7](#ch06fn7a)Since Linux 2.6.12, a “nice ceiling” can be modified per process, allowing non-root processes to have lower nice values. E.g., using: prlimit `--nice=-19 -p PID.` ([View Highlight](https://read.readwise.io/read/01gtgvhsd6fff0szkanaep0rg2))

The value of 16 is recommended to users who wish to execute long-running programs without flak from the administration. ([View Highlight](https://read.readwise.io/read/01gtgvkqaktcn2bh40qsjpnt26))

The nice value is still useful today for adjusting process priority. This is most effective when there is contention for CPUs, causing scheduler latency for high-priority work. Your task is to identify low-priority work, which may include monitoring agents and scheduled backups, that can be modified to start with a nice valu ([View Highlight](https://read.readwise.io/read/01gtgvmwvx9rgw64vf7t1q7edy))

e. Analysis may also be performed to check that the tuning is effective, and tha ([View Highlight](https://read.readwise.io/read/01gtgvned90s4a9rghrzs3xv5x))

t the scheduler latency remains low for high-priority work. ([View Highlight](https://read.readwise.io/read/01gtgvnqzwaekpsb6pkdhfjk7e))

Linux includes a _real-time scheduling class_, which can allow processes to preempt all other work. While this can eliminate scheduler latency (other than for other real-time processes and interrupts), make sure that you understand the consequences. If the real-time application encounters a bug where multiple threads enter an infinite loop, it can cause all CPUs to become unavailable for all other work—including the administrative shell required to manually fix the problem.[8](#ch06fn8) ([View Highlight](https://read.readwise.io/read/01gtgvprghfx88twvbnhrqq749))

6.5.9 Resource Controls

The operating system may provide fine-grained controls for allocating CPU cycles to processes or groups of processes. ([View Highlight](https://read.readwise.io/read/01gtgvrmajztc5sk0aawy8tzct))

6.5.10 CPU Binding ([View Highlight](https://read.readwise.io/read/01gtgw03h2dqrxy7b2prhxksr3))

Another way to tune CPU performance involves binding processes and threads to individual CPUs, or collections of CPUs. This can increase CPU cache warmth for the process, improving its memory I/O performance. For NUMA systems it also improves memory locality, further improving performance. ([View Highlight](https://read.readwise.io/read/01gtgw0vbm6q8azv65fdjwdkj1))

There are generally two ways this is performed:

• **CPU binding**: Configuring a process to run only on a single CPU, or only on one CPU from a defined set.

• **Exclusive CPU sets**: Partitioning a set of CPUs that can be used only by the process(es) assigned to them. This can further improve CPU cache warmth, as when the process is idle other processes cannot use those CPUs. ([View Highlight](https://read.readwise.io/read/01gtgw1580hxn5jvzd3r4j7zsm))

6.5.11 Micro-Benchmarking ([View Highlight](https://read.readwise.io/read/01gtgwnbbxj32c5mh0c5ndd9zd))

Tools for CPU micro-benchmarking typically measure the time taken to perform a simple operation many times. The operation may be based on:

• **CPU instructions**: Integer arithmetic, floating-point operations, memory loads and stores, branch and other instructions

• **Memory access**: To investigate latency of different CPU caches and main memory throughput

• **Higher-level languages**: Similar to CPU instruction testing, but written in a higher-level interpreted or compiled language

• **Operating system operations**: Testing system library and system call functions that are CPU-bound, such as getpid(2) and process creation ([View Highlight](https://read.readwise.io/read/01gtgwpgp3bknqwy2sckepsr11))

6.6 Observability Tools ([View Highlight](https://read.readwise.io/read/01gtgwwpmya28089g0t5954der))

Table 6.8 **Linux CPU observability tools**

**Section**

**Tool**

**Description**

[6.6.1](#ch06lev6sec1)

uptime

Load averages

[6.6.2](#ch06lev6sec2)

vmstat

Includes system-wide CPU averages

[6.6.3](#ch06lev6sec3)

mpstat

Per-CPU statistics

[6.6.4](#ch06lev6sec4)

sar

Historical statistics

[6.6.5](#ch06lev6sec5)

ps

Process status

[6.6.6](#ch06lev6sec6)

top

Monitor per-process/thread CPU usage

[6.6.7](#ch06lev6sec7)

pidstat

Per-process/thread CPU breakdowns

[6.6.8](#ch06lev6sec8)

time, ptime

Time a command, with CPU breakdowns

[6.6.9](#ch06lev6sec9)

turboboost

Show CPU clock rate and other states

[6.6.10](#ch06lev6sec10)

showboost

Show CPU clock rate and turbo boost

[6.6.11](#ch06lev6sec11)

pmcarch

Show high-level CPU cycle usage

[6.6.12](#ch06lev6sec12)

tlbstat

Summarize TLB cycles

6.6.13

perf

CPU profiling and PMC analysis

[6.6.14](#ch06lev6sec14)

profile

Sample CPU stack traces

[6.6.15](#ch06lev6sec15)

cpudist

Summarize on-CPU time

[6.6.16](#ch06lev6sec16)

runqlat

Summarize CPU run queue latency

[6.6.17](#ch06lev6sec17)

runqlen

Summarize CPU run queue length

[6.6.18](#ch06lev6sec18)

softirqs

Summarize soft interrupt time

[6.6.19](#ch06lev6sec19)

hardirqs

Summarize hard interrupt time

[6.6.20](#ch06lev6sec20)

bpftrace

Tracing programs for CPU analysis ([View Highlight](https://read.readwise.io/read/01gtgwyyt9xsshkwcjdz4zcqvs))

6.6.1 uptime ([View Highlight](https://read.readwise.io/read/01gtgx1m2qa5kydwc1fc4ax0zg))

$ **uptime** 9:04pm up 268 day(s), 10:16, 2 users, **load average: 7.76, 8.32, 8.60** ([View Highlight](https://read.readwise.io/read/01gtgx3tt13p8z1y8jym71x1p6))

The last three numbers are the 1-, 5-, and 15-minute load averages. By comparing the three numbers, you can determine if the load is increasing, decreasing, or steady during the last 15 minutes (or so). T ([View Highlight](https://read.readwise.io/read/01gtgx4py53bwmhwazzmazv54c))

Load Averages ([View Highlight](https://read.readwise.io/read/01gtgx7ay8fs9wq4p3x7eq0scn))

The _load_ is measured as the current resource usage (utilization) plus queued requests (saturation). Imagine a car toll plaza: you could measure the load at various points during the day by counting how many cars were being serviced (utilization) plus how many cars were queued (saturation). ([View Highlight](https://read.readwise.io/read/01gtgx9173qs4bnwh2vh9pj7s3))

The _average_ is an exponentially damped moving average, which reflects load beyond the 1-, 5-, and 15-minute times (the times are actually constants used in the exponential moving sum [[Myer 73]](#ch06ref3)) ([View Highlight](https://read.readwise.io/read/01gtgxaza5bafmw7mq7pqjxfqf))

![https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig17-06fig17.jpg](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig17-06fig17.jpg)

([View Highlight](https://read.readwise.io/read/01gtgxdehvmza33d5nfmm7nmxh))