---
February 28, 2023
---
# Systems Performance

![rw-book-cover](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/cover-cover.xhtml)

## Metadata
- Author: [[Brendan Gregg]]
- Full Title: Systems Performance
- Category: #books

## Highlights
- For reference, CPU-related terminology used in this chapter includes the following: ([View Highlight](https://read.readwise.io/read/01gtb081qynsv6ee7g1pgebz27))
- **Processor**: The physical chip that plugs into a socket on the system or processor board and contains one or more CPUs implemented as cores or hardware threads. ([View Highlight](https://read.readwise.io/read/01gtb08407zy7051ezsa9myz4m))
- **[Core](#glo_035)**: An independent CPU instance on a *multicore processor*. The use of cores is a way to scale processors, called *chip-level multiprocessing* (CMP). ([View Highlight](https://read.readwise.io/read/01gtb0873vpxhzhrxd0vz34pva))
- **Hardware thread**: A CPU architecture that supports executing multiple threads in parallel on a single core (including Intel’s Hyper-Threading Technology), where each thread is an independent CPU instance. This scaling approach is called *simultaneous multithreading* (SMT). ([View Highlight](https://read.readwise.io/read/01gtb089e6fappk36cvny32jq4))
- **CPU instruction**: A single CPU operation, from its *instruction set*. There are instructions for arithmetic operations, memory I/O, and control logic. ([View Highlight](https://read.readwise.io/read/01gtb08drxe0wh7d7nsrgp23sq))
- **Logical CPU**: Also called a *virtual processor,*[1](#ch06fn1) an operating system CPU instance (a schedulable CPU entity). This may be implemented by the processor as a hardware thread (in which case it may also be called a *virtual core*), a core, or a single-core processor. ([View Highlight](https://read.readwise.io/read/01gtb08bkxry9j1jha1ytsasvs))
- **Scheduler**: The kernel subsystem that assigns threads to run on CPUs. ([View Highlight](https://read.readwise.io/read/01gtb08ne4cp7hz3v0209aegdm))
- **[Run queue](#glo_141)**: A queue of runnable threads that are waiting to be serviced by CPUs. Modern kernels may use some other data structure (e.g., a red-black tree) to store runnable threads, but we still often use the term run queue. ([View Highlight](https://read.readwise.io/read/01gtb08qrtebr2qeb7j8sx0vp7))
- 6.2.1 CPU Architecture ([View Highlight](https://read.readwise.io/read/01gtb0e4cvgkbznq3msfvsts2s))
- [Figure 6.1](#ch06fig01) shows an example CPU architecture, for a single processor with four cores and eight hardware threads in total. The physical architecture is pictured, along with how it is seen by the operating system.[2](#ch06fn2) ([View Highlight](https://read.readwise.io/read/01gtb099nxwjdhwjrs0cs3bq4y))
- ![](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig01-06fig01.jpg) ([View Highlight](https://read.readwise.io/read/01gtb0cyj081brmb0e9ahh9rz1))
- Figure 6.1 CPU architecture ([View Highlight](https://read.readwise.io/read/01gtb0d5hyv1cv99gxvzs33n06))
- Each hardware thread is addressable as a *logical CPU*, so this processor appears as eight CPUs. ([View Highlight](https://read.readwise.io/read/01gtb0dh725yf50k24a1k9d857))
- 6.2.2 CPU Memory Caches ([View Highlight](https://read.readwise.io/read/01gtb0dwnmz0zzjdb1gpw7zeh1))
- ![](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig02-06fig02.jpg) ([View Highlight](https://read.readwise.io/read/01gtb0ef3zer14971pj5d28q7d))
- Figure 6.2 CPU cache sizes ([View Highlight](https://read.readwise.io/read/01gtb0ejkwfd121rwx210748hw))
- 6.2.3 CPU Run Queues ([View Highlight](https://read.readwise.io/read/01gtb0ervpb80atcnffm1d8yr9))
- ![](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig03-06fig03.jpg) ([View Highlight](https://read.readwise.io/read/01gtb0exaeh0vejjc3056s1z73))
- The number of software threads that are queued and ready to run is an important performance metric indicating CPU saturation. In this figure (at this instant) there are four, with an additional thread running on-CPU. The time spent waiting on a CPU run queue is sometimes called *run-queue latency* or *dispatcher-queue latency*. ([View Highlight](https://read.readwise.io/read/01gtb0fef50xwbzm16jpyhwn4q))
- For multiprocessor systems, the kernel typically provides a run queue for each CPU, and aims to keep threads on the same run queue. This means that threads are more likely to keep running on the same CPUs where the CPU caches have cached their data. These caches are described as having *[cache warmth](#glo_029)*, and this strategy to keep threads running on the same CPUs is called *CPU affinity*. On NUMA systems, per-CPU run queues also improve *memory locality*. This improves performance by keeping threads running on the same memory node (as described in [Chapter 7](#ch07), [Memory](#ch07)), and avoids the cost of thread synchronization (mutex locks) for queue operations, which would hurt scalability if the run queue was global and shared among all CPUs ([View Highlight](https://read.readwise.io/read/01gtb1n4g0faffc2qspycmhbrh))
- 6.3.1 Clock Rate ([View Highlight](https://read.readwise.io/read/01gtb1nt437k2mq1hjneecz6tp))
- The clock is a digital signal that drives all processor logic. Each CPU instruction may take one or more cycles of the clock (called *CPU cycles*) to execute. CPUs execute at a particular clock rate; for example, a 4 GHz CPU performs 4 billion clock cycles per second. ([View Highlight](https://read.readwise.io/read/01gtb1pg0yr7y8whfyebd8cwqh))
- Clock rate is often marketed as the primary feature of a processor, but this can be a little misleading. Even if the CPU in your system appears to be fully utilized (a bottleneck), a faster clock rate may not speed up performance—it depends on what those fast CPU cycles are actually doing. If they are mostly stall cycles while waiting on memory access, executing them more quickly doesn’t actually increase the CPU instruction rate or workload throughput. ([View Highlight](https://read.readwise.io/read/01gtb1t64n42hsk0jn9ahdz6pt))
- 6.3.2 Instructions ([View Highlight](https://read.readwise.io/read/01gtb1teaejp28nkdy9dyc1x9v))
- CPUs execute instructions chosen from their instruction set. An instruction includes the following steps, each processed by a component of the CPU called a *functional unit*: ([View Highlight](https://read.readwise.io/read/01gtb1tm3xgf7bb8fr999zeh9j))
- Instruction fetch ([View Highlight](https://read.readwise.io/read/01gtb1tsgaz3rhkbwr8wne1hpa))
- Instruction decode ([View Highlight](https://read.readwise.io/read/01gtb211ysnhcnsmtd79bd7wr2))
- Execute ([View Highlight](https://read.readwise.io/read/01gtb2183nasgyrx8vr69xyqd2))
- Memory access ([View Highlight](https://read.readwise.io/read/01gtb21egsd76f2srzg1rfgztk))
- Register write-back ([View Highlight](https://read.readwise.io/read/01gtb254axy275y999za4swd25))
- Each of these steps takes at least a single clock cycle to be executed. Memory access is often the slowest, as it may take dozens of clock cycles to read or write to main memory, during which instruction execution has *stalled* (and these cycles while stalled are called *stall cycles*) ([View Highlight](https://read.readwise.io/read/01gtb25c864x9t220c9jje2wdt))
- 6.3.3 Instruction Pipeline ([View Highlight](https://read.readwise.io/read/01gtb25nmnyfxkzztkbtrqy4vy))
- The instruction pipeline is a CPU architecture that can execute multiple instructions in parallel by executing different components of different instructions at the same time. It is similar to a factory assembly line, where stages of production can be executed in parallel, increasing throughput. ([View Highlight](https://read.readwise.io/read/01gtb26nv5we86rmqxdz9139rk))
- By use of pipelining, multiple functional units can be active at the same time, processing different instructions in the pipeline. Ideally, the processor can then complete one instruction with every clock cycle. ([View Highlight](https://read.readwise.io/read/01gtb275b6jnpje0xgvqtttvqy))
- Instruction pipelining may involve breaking down an instruction into multiple simple steps for execution in parallel ([View Highlight](https://read.readwise.io/read/01gtb29sd9nye9xj13a0swfr7m))
- Branch Prediction ([View Highlight](https://read.readwise.io/read/01gtb2b2m1qd8c5gzqfz1k42f0))
- Modern processors can perform out-of-order execution of the pipeline, where later instructions can be completed while earlier instructions are stalled, improving instruction throughput. ([View Highlight](https://read.readwise.io/read/01gtb2cqhpbg5s5jawbh56djcq))
- However, conditional branch instructions pose a problem. Branch instructions jump execution to a different instruction, and conditional branches do so based on a test. ([View Highlight](https://read.readwise.io/read/01gtb2de8qknrjkhk7w23bv1wh))
- With conditional branches, the processor does not know what the later instructions will be. As an optimization, processors often implement *branch prediction*, where they will guess the outcome of the test and begin processing the outcome instructions. If the guess later proves to be wrong, the progress in the instruction pipeline must be discarded, hurting performance. To improve the chances of guessing correctly, programmers can place hints in the code (e.g., likely() and unlikely() macros in the Linux Kernel sources). ([View Highlight](https://read.readwise.io/read/01gtb2fysm26xgfgxfcqvaffj6))
- 6.3.4 Instruction Width ([View Highlight](https://read.readwise.io/read/01gtb2gev7agf6mefmncf6m1hc))
- Multiple functional units of the same type can be included, so that even more instructions can make forward progress with each clock cycle. This CPU architecture is called *superscalar* and is typically used with pipelining to achieve a high instruction throughput. ([View Highlight](https://read.readwise.io/read/01gtbacsp97g5v2q6b3abpyvrg))
- The instruction *width* describes the target number of instructions to process in parallel. Modern processors are *3-wide* or *4-wide*, meaning they can complete up to three or four instructions per cycle. ([View Highlight](https://read.readwise.io/read/01gtbadeqa5tsvbrqm4gxt0p5f))
- 6.3.5 Instruction Size ([View Highlight](https://read.readwise.io/read/01gtbae45bcna9wnfs312vr3g4))
- Another instruction characteristic is the instruction *size*: for some processor architectures it is variable: For example, x86, which is classified as a *complex instruction set computer* (CISC), allows up to 15-byte instructions. ARM, which is a *reduced instruction set computer* (RISC), has 4 byte instructions with 4-byte alignment for AArch32/A32, and 2- or 4-byte instructions for ARM Thumb. ([View Highlight](https://read.readwise.io/read/01gtbag8h76x156vdr3jbnjdg2))
- 6.3.6 SMT ([View Highlight](https://read.readwise.io/read/01gtbafjkmz0wnr7afcj4yscqe))
- Simultaneous multithreading makes use of a superscalar architecture and hardware multithreading support (by the processor) to improve parallelism. It allows a CPU core to run more than one thread, effectively scheduling between them during instructions, e.g., when one instruction stalls on memory I/O. The kernel presents these hardware threads as virtual CPUs, and schedules threads and processes on them as usual ([View Highlight](https://read.readwise.io/read/01gtbakfk8wtmkxnjrb22c8r1e))
- The performance of each hardware thread is not the same as a separate CPU core, and depends on the workload. To avoid performance problems, kernels may spread out CPU load across cores so that only one hardware thread on each core is busy, avoiding hardware thread contention. Workloads that are stall cycle-heavy (low IPC) may also have better performance than those that are instruction-heavy (high IPC) because stall cycles reduce core contention. ([View Highlight](https://read.readwise.io/read/01gtbamnjdzkv7chaz0rbf3bya))
- 6.3.7 IPC, CPI ([View Highlight](https://read.readwise.io/read/01gtbancqnfc9tyqrb6f3zfwf4))
- *Instructions per cycle* (IPC) is an important high-level metric for describing how a CPU is spending its clock cycles and for understanding the nature of CPU utilization. This metric may also be expressed as *cycles per instruction* (CPI), the inverse of IPC ([View Highlight](https://read.readwise.io/read/01gtbapt5nzsf5ey7zm00fm7b9))
- A low IPC indicates that CPUs are often stalled, typically for memory access. A high IPC indicates that CPUs are often not stalled and have a high instruction throughput. These metrics suggest where performance tuning efforts may be best spent. ([View Highlight](https://read.readwise.io/read/01gtbaswjrstcrs0kznh3fkatb))
- Memory-intensive workloads, for example, may be improved by installing faster memory (DRAM), improving memory locality (software configuration), or reducing the amount of memory I/O. Installing CPUs with a higher clock rate may not improve performance to the degree expected, as the CPUs may need to wait the same amount of time for memory I/O to complete. Put differently, a faster CPU may mean more stall cycles but the same rate of completed instructions per second. ([View Highlight](https://read.readwise.io/read/01gtbaxa0t9v9zwdrbq95qjhgd))
- The actual values for high or low IPC are dependent on the processor and processor features and can be determined experimentally by running known workloads. As an example, you may find that low-IPC workloads run with an IPC at 0.2 or lower, and high IPC workloads run with an IPC of over 1.0 (which is possible due to instruction pipelining and width, described earlier) ([View Highlight](https://read.readwise.io/read/01gtbay3nk80bzpvfsw7gxc232))
- It should be noted that IPC shows the efficiency of instruction *processing*, but not of the instructions themselves. Consider a software change that added an inefficient software loop, which operates mostly on CPU registers (no stall cycles): such a change may result in a higher overall IPC, but also higher CPU usage and utilization. ([View Highlight](https://read.readwise.io/read/01gtbb1098rdh62kk678v106g1))
- High CPU utilization may not necessarily be a problem, but rather a sign that the system is doing work. Some people also consider this a return of investment (ROI) indicator: a highly utilized system is considered to have good ROI, whereas an idle system is considered wasted. ([View Highlight](https://read.readwise.io/read/01gtbdmrs1cwvecy5b1zrrbj8t))
- 6.3.8 Utilization ([View Highlight](https://read.readwise.io/read/01gtbb2cx2cvpzmjtba44rbxw9))
- CPU utilization is measured by the time a CPU instance is busy performing work during an interval, expressed as a percentage. It can be measured as the time a CPU is not running the kernel idle thread but is instead running user-level application threads or other kernel threads, or processing interrupts. ([View Highlight](https://read.readwise.io/read/01gtbdjan70zxag4zkztc53x4z))
- The measure of CPU utilization spans all clock cycles for eligible activities, including memory stall cycles. This can be misleading: a CPU may be highly utilized because it is often stalled waiting for memory I/O, not just executing instructions, as described in the previous section. ([View Highlight](https://read.readwise.io/read/01gtbdpsyhgqd9541qtvfw6rwx))
- CPU utilization is often split into separate kernel- and user-time metrics. ([View Highlight](https://read.readwise.io/read/01gtbdr2yqjmmr5y9nj3e74v3q))
- 6.3.9 User Time/Kernel Time ([View Highlight](https://read.readwise.io/read/01gtbeyznjnc31dg6q92ysmfw6))
- The CPU time spent executing user-level software is called *user time*, and kernel-level software is *kernel time*. Kernel time includes time during system calls, kernel threads, and interrupts. When measured across the entire system, the user time/kernel time ratio indicates the type of workload performed. ([View Highlight](https://read.readwise.io/read/01gtbezc5e44mmtr8t9v73r704))
- Applications that are computation-intensive may spend almost all their time executing user-level code and have a user/kernel ratio approaching 99/1. Examples include image processing, machine learning, genomics, and data analysis. ([View Highlight](https://read.readwise.io/read/01gtbeztwcveczqjbetcgesdjs))
- Applications that are I/O-intensive have a high rate of system calls, which execute kernel code to perform the I/O. For example, a web server performing network I/O may have a user/kernel ratio of around 70/30. ([View Highlight](https://read.readwise.io/read/01gtbf005jwbeyss0q4fte2d8q))
- 6.3.10 Saturation ([View Highlight](https://read.readwise.io/read/01gtbf0h1h8jc587e0yzvqc94r))
- A CPU at 100% utilization is *saturated*, and threads will encounter *scheduler latency* as they wait to run on-CPU, decreasing overall performance. This latency is the time spent waiting on the CPU run queue or other structure used to manage threads. ([View Highlight](https://read.readwise.io/read/01gtbf0ysp6pxjdy5xpmymkeq0))
- Another form of CPU saturation involves CPU resource controls, as may be imposed in a multi-tenant cloud computing environment. ([View Highlight](https://read.readwise.io/read/01gtbf20jhb7s0my0n8t6z2b2k))
- A CPU running at saturation is less of a problem than other resource types, as higher-priority work can preempt the current thread. ([View Highlight](https://read.readwise.io/read/01gtbf1tsrwjkzfvk8gkmdje06))
- Preemption, introduced in [Chapter 3](#ch03), [Operating Systems](#ch03), allows a higher-priority thread to preempt the currently running thread and begin its own execution instead. This eliminates the run-queue latency for higher-priority work, improving its performance. ([View Highlight](https://read.readwise.io/read/01gtbf2mv4517fqkxqg1e3fqnc))
- 6.3.12 Priority Inversion ([View Highlight](https://read.readwise.io/read/01gtbf31818h8v67v2pbxn43c0))
- Priority inversion occurs when a lower-priority thread holds a resource and blocks a higher-priority thread from running. This reduces the performance of the higher-priority work, as it is blocked waiting.
  This can be solved using a *priority inheritance* scheme. Here is an example of how this can work (based on a real-world case):
  1. Thread A performs monitoring and has a low priority. It acquires an address space lock for a production database, to check memory usage.
  2. Thread B, a routine task to perform compression of system logs, begins running.
  3. There is insufficient CPU to run both. Thread B preempts A and runs.
  4. Thread C is from the production database, has a high priority, and has been sleeping waiting for I/O. This I/O now completes, putting thread C back into the runnable state.
  5. Thread C preempts B, runs, but then blocks on the address space lock held by thread A. Thread C leaves CPU.
  6. The scheduler picks the next-highest-priority thread to run: B.
  7. With thread B running, a high-priority thread, C, is effectively blocked on a lower-priority thread, B. This is priority inversion.
  8. Priority inheritance gives thread A thread C’s high priority, preempting B, until it releases the lock. Thread C can now run. ([View Highlight](https://read.readwise.io/read/01gtbf3jprjj0mdfeyeyb12sjn))
- 6.3.13 Multiprocess, Multithreading ([View Highlight](https://read.readwise.io/read/01gtbf3zx00zxq3d9174jempbq))
- Most processors provide multiple CPUs of some form. For an application to make use of them, it needs separate threads of execution so that it can run in parallel. For a 64-CPU system, ([View Highlight](https://read.readwise.io/read/01gtbf5pk0q9p27tw2dq67evxz))
- The two techniques to scale applications across CPUs are *multiprocess* and *multithreading*, which are pictured in [Figure 6.4](#ch06fig04). ([View Highlight](https://read.readwise.io/read/01gtbf63vywm78690msd5q4czb))
- ![](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig04-06fig04.jpg) ([View Highlight](https://read.readwise.io/read/01gtbf6f4b2r0tdhbfpczrfy4f))
- On Linux both the multiprocess and multithread models may be used, and both are implemented by tasks. ([View Highlight](https://read.readwise.io/read/01gtbf78mqws04ess5ke232vsn))
- Table 6.1 **Multiprocess and multithreading attributes**
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
- Whichever technique is used, it is important that enough processes or threads be created to span the desired number of CPUs—which, for maximum performance, may be all of the CPUs available. Some applications may perform better when running on fewer CPUs, when the cost of thread synchronization and reduced memory locality (NUMA) outweighs the benefit of running across more CPUs. ([View Highlight](https://read.readwise.io/read/01gtbf967pxpjvtvf3d0frpykn))
- 6.3.14 Word Size ([View Highlight](https://read.readwise.io/read/01gtbf9s3g51f9gnqwwdhxnhrs))
- Processors are designed around a maximum *word size*—32-bit or 64-bit—which is the integer size and register size. Word size is also commonly used, depending on the processor, for the address space size and data path width (where it is sometimes called the *bit width*). ([View Highlight](https://read.readwise.io/read/01gtbfazt466c5wygxb75t1g8y))
- Larger sizes can mean better performance, although it’s not as simple as it sounds. Larger sizes may cause memory overheads for unused bits in some data types. The data footprint also increases when the size of pointers (word size) increases, which can require more memory I/O. For the x86 64-bit architecture, these overheads are compensated by an increase in registers and a more efficient register calling convention, so 64-bit applications will likely be faster than their 32-bit versions. ([View Highlight](https://read.readwise.io/read/01gtbfc7qczmhh4753v9c4rakf))
- Processors and operating systems can support multiple word sizes and can run applications compiled for different word sizes simultaneously. If software has been compiled for the smaller word size, it may execute successfully but perform relatively poorly. ([View Highlight](https://read.readwise.io/read/01gtbfcve1dhncvyy583by5bt5))
- 6.3.15 Compiler Optimization ([View Highlight](https://read.readwise.io/read/01gtbfdh0y1tfmm8r3aqb5j3n9))
- 6.3.15 Compiler Optimization ([View Highlight](https://read.readwise.io/read/01gtbff59k2v9p1r3217pka6ch))
- The CPU runtime of applications can be significantly improved through compiler options (including setting the word size) and optimizations. Compilers are also frequently updated to take advantage of the latest CPU instruction sets and to implement other optimizations. Sometimes application performance can be significantly improved simply by using a newer compiler. ([View Highlight](https://read.readwise.io/read/01gtbfgc242dt887caxps1afk6))
- 6.4 Architecture ([View Highlight](https://read.readwise.io/read/01gtbfhgrdw084gxmksz4xbxe1))
- 6.4.1 Hardware ([View Highlight](https://read.readwise.io/read/01gtbfq3zt8a15g47qasm30y95))
- CPU hardware includes the processor and its subsystems, and the CPU interconnect for multiprocessor systems. ([View Highlight](https://read.readwise.io/read/01gtbfqfcjg89r70yzjstr2f8v))
- ![](https://readwise-assets.s3.amazonaws.com/media/reader/parsed_document_assets/36998897/img_06fig05-06fig05.jpg) ([View Highlight](https://read.readwise.io/read/01gtbfqpqqjw0czywtzgddfwx9))
- The *control unit* is the heart of the CPU, performing instruction fetch, decoding, managing execution, and storing results. ([View Highlight](https://read.readwise.io/read/01gtbfr0erjfne49evr61ataqb))
- This example processor depicts a shared floating-point unit and (optional) shared Level 3 cache. The actual components in your processor will vary depending on its type and model. Other performance-related components that may be present include: ([View Highlight](https://read.readwise.io/read/01gtbfr99nves5ak4eax0tg65g))
- • **P-cache**: Prefetch cache (per CPU core)
  • **W-cache**: Write cache (per CPU core)
  • **Clock**: Signal generator for the CPU clock (or provided externally)
  • **Timestamp counter**: For high-resolution time, incremented by the clock
  • **Microcode ROM**: Quickly converts instructions to circuit signals
  • **Temperature sensors**: For thermal monitoring
  • **Network interfaces**: If present on-chip (for high performance) ([View Highlight](https://read.readwise.io/read/01gtbfrkmxbdd8qt80fe9517c6))
- The *advanced configuration and power interface* (ACPI) standard, in use by Intel processors, defines *processor performance states* (P-states) and *processor power states* (C-states) [[ACPI 17]](#ch06ref19). ([View Highlight](https://read.readwise.io/read/01gtbftgpg3bjj34hze7s5hgfz))
- P-states provide different levels of performance during normal execution by varying the CPU frequency: P0 is the highest frequency (for some Intel CPUs this is the highest “turbo boost” level) and P1...N are lower-frequency states. These states can be controlled by both hardware (e.g., based on the processor temperature) or via software (e.g., kernel power saving modes). The current operating frequency and available states can be observed using model-specific registers (MSRs) (e.g., using the showboost(8) tool in [Section 6.6.10](#ch06lev6sec10), [showboost](#ch06lev6sec10)). ([View Highlight](https://read.readwise.io/read/01gtbfv4v6a5388esqnjv1kwdj))
- C-states provide different idle states for when execution is halted, saving power. The C-states are shown in [Table 6.2](#ch06tab02): C0 is for normal operation, and C1 and above are for idle states: the higher the number, the deeper the state. ([View Highlight](https://read.readwise.io/read/01gtbfvf7r0np273cpx3gy4jyc))
- Table 6.2 **Processor power states (C-states)**
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
