---
February 28, 2023
---
# Systems Performance: Enterprise and the Cloud

![rw-book-cover](https://readwise-assets.s3.amazonaws.com/static/images/article2.74d541386bbf.png)

## Metadata
- Author: [[Brendan Gregg]]
- Full Title: Systems Performance: Enterprise and the Cloud
- Category: #articles
- URL: https://readwise.io/reader/document_raw_content/36993553

## Highlights
- The physical chip that plugs into a socket on the system or processor board and
  contains one or more CPUs implemented as cores or hardware threads. ([View Highlight](https://read.readwise.io/read/01gtazw9bay97vdwh4aymgx7sd))
- Processor: The physical chip that plugs into a socket on the system or processor board and
  contains one or more CPUs implemented as cores or hardware threads. ([View Highlight](https://read.readwise.io/read/01gtazwaz3707rfa3k3ba0tm6j))
- For reference, CPU-related terminology used in this chapter includes the following:
  ■
  Processor: The physical chip that plugs into a socket on the system or processor board and
  contains one or more CPUs implemented as cores or hardware threads.
  ■
  Core: An independent CPU instance on a multicore processor. The use of cores is a way to
  scale processors, called chip-level multiprocessing (CMP).
  ■
  Hardware thread: A CPU architecture that supports executing multiple threads in paral-
  lel on a single core (including Intel’s Hyper-Threading Technology), where each thread is
  an independent CPU instance. This scaling approach is called simultaneous multithreading
  (SMT).
  ■
  CPU instruction: A single CPU operation, from its instruction set. There are instructions
  for arithmetic operations, memory I/O, and control logic.
  ■
  Logical CPU: Also called a virtual processor,1 an operating system CPU instance (a sched-
  ulable CPU entity). This may be implemented by the processor as a hardware thread (in
  which case it may also be called a virtual core), a core, or a single-core processor.
  ■ Scheduler: The kernel subsystem that assigns threads to run on CPUs.
  ■
  Run queue: A queue of runnable threads that are waiting to be serviced by CPUs. Modern
  kernels may use some other data structure (e.g., a red-black tree) to store runnable threads,
  but we still often use the term run queue. ([View Highlight](https://read.readwise.io/read/01gtazz5b43xyveg98k5zmkdf2))
- Figure 6.1 shows an example CPU architecture, for a single processor with four cores and eight
  hardware threads in total. The physical architecture is pictured, along with how it is seen by the
  operating system.2 ([View Highlight](https://read.readwise.io/read/01gtazh1s5raema3h60z0cesba))
- Each hardware thread is addressable as a logical CPU, so this processor appears as eight CPUs. ([View Highlight](https://read.readwise.io/read/01gtazznxga6m4yxx0bvzn3h2p))
