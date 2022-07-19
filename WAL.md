# 预写式日志——WAL
- 事务日志 （**transaction log**）
	是数据库的关键组件，因为当出现系统故障时，任何数据库管理系统都不允许丢失数据。事务日志是数据库系统中所有**变更（change）**与**行为（action）**的历史记录，当诸如电源故障，或其他服务器错误导致服务器崩溃时，它被用于确保数据不会丢失。由于日志包含每个已执行事务的相关充分信息，因此当服务器崩溃时，数据库服务器应能通过重放事务日志中的变更与行为来恢复数据库集群。
- 预写式日志（**Write Ahead Log**）
	是事务日志的同义词，而且也用来指代一种将**行为**写入事务日志（WAL）的实现机制。同时还是**时间点恢复（Point-in-Time Recovery PIRT）**与**流复制（Streaming Replication, SR）**实现的基础。
## 1 概述

	
### 1.1 没有WAL的插入操作

#### Ⅰ 为了能高效访问关系表的页面，几乎所有的DBMS都实现了共享缓冲池。
>**缓冲区管理器（Buffer Manager）管**理着共享内存和持久存储之间的数据传输，对于DBMS的性能有着重要的影响。PostgreSQL的缓冲区管理器十分高效。
![[Pasted image 20220719232554.png]]
#### Ⅱ 没有WAL的插入操作
![[Pasted image 20220719232820.png]]

1.  发起第一条`INSERT`语句时，PostgreSQL从数据库集簇文件中加载表A的页面到内存中的共享缓冲池。然后向页面中插入一条元组。页面并没有立刻写回到数据库集簇文件中。正如[第8章](https://pg-internal.vonng.com/#/ch8)中提到的，被修改过的页面通常称为**脏页（dirty page）**
>当后端进程修改缓冲池中的页面时（例如向页面插入元组），这种尚未刷新到持久存储，但已被修改的页面被称为**脏页（dirty page）**。
2.  发起第二条`INSERT`语句时，PostgreSQL直接向缓冲池里的页面内添加了一条新元组。这一页仍然没有被写回到持久存储中。
3.  如果操作系统或PostgreSQL服务器因为各种原因失效（例如电源故障），所有插入的数据都会丢失。
### 1.2 带有WAL的插入操作与数据库恢复
#### Ⅰ 带有WAL的插入操作
![[Pasted image 20220719234100.png]]
1.  检查点进程是一个后台进程，周期性地执行过程。当检查点进程开始执行检查点时，它会向当前WAL段文件写入一条XLOG记录，称为**检查点（Checkpoint Record）**。这条记录包含了最新的**重做点**位置。
2.  发起第一条`INSERT`语句时，PostgreSQL从数据库集簇文件中加载表A的页面至内存中的共享缓冲池，向页面中插入一条元组，然后在`LSN_1`位置创建并写入一条相应的XLOG记录，然后将表A的LSN从`LSN_0`更新为`LSN_1`。在本例中，XLOG记录是由首部数据与**完整元组**组成的一对值。
3.  当该事务提交时，PostgreSQL向WAL缓冲区创建并写入一条关于该提交行为的XLOG记录，然后将WAL缓冲区中的所有XLOG记录刷写入WAL段文件中。
4.  发起第二条`INSERT`语句时，PostgreSQL向页面中插入一条新元组，然后在`LSN_2`位置创建并写入一条相应的XLOG记录，然后将表A的LSN从`LSN_1`更新为`LSN_2`。
5.  当这条语句的事务提交时，PostgreSQL执行同步骤3类似的操作。
6.  设想当操作系统失效发生时，尽管共享缓冲区中的所有数据都丢失了，但所有页面修改已经作为历史记录被写入WAL段文件中。
#### Ⅱ **使用WAL进行数据库恢复**
1.  PostgreSQL从相关的WAL段文件中读取第一条`INSERT`语句的XLOG记录，并从硬盘上的数据库集簇目录加载表A的页面到内存中的共享缓冲区中。
2.  在重放XLOG记录前，PostgreSQL会比较XLOG记录的LSN与相应页面的LSN。这么做的原因在第9.8节中描述。重放XLOG记录的规则如下所示：
    -   如果XLOG记录的LSN要比页面LSN大，XLOG记录中的数据部分就会被插入到页面中，并将页面的LSN更新为XLOG记录的LSN。
    -   如果XLOG记录的LSN要比页面的LSN小，那么不用做任何事情，直接读取后续的WAL数据即可。
3.  PostgreSQL按照同样的方式重放其余的XLOG记录。
PostgreSQL可以通过按时间顺序重放写在WAL段文件中的XLOG记录来自我恢复，因此，PostgreSQL的XLOG记录显然是一种**重做日志（REDO log）**。
>PostgreSQL不支持**撤销日志（UNDO log）**

#### Ⅲ 总结
1. 为了应对系统失效，PostgreSQL将所有修改作为历史数据写入持久化存储中。这份历史数据称为**XLOG记录（xlog record）** 或 **WAL数据（wal data）**。
2. 当 **插入、删除、提交**等变更动作发生时，PostgreSQL会将XLOG记录写入内存中的**WAL缓冲区（WAL Buffer）**。当事务提交或中止时，它们会被立即写入**持久存储**上的**WAL段文件（WAL segment file）**中（更精确来讲，其他场景也可能会有XLOG记录写入，细节将在5节中描述）。XLOG记录的**日志序列号（Log Sequence Number, LSN）**标识了该记录在事务日志中的位置，记录的LSN被用作XLOG记录的**唯一标识符**。
3. 数据库恢复时，就是从**重做点（REDO Point）**开始回复。重做点就是最新一个**检查点（Checkpoint）**开始时**XLOG记录**写入的位置。
### 1.3 整页写入
假设后台写入进程在写入脏页的过程中出现了操作系统故障，导致磁盘上表A的页面数据损坏。XLOG是无法在损坏的页面上重放的，我们需要其他功能来确保这一点。
>PostgreSQL默认使用8KB的页面，操作系统通常使用4KB的页面，可能出现只写入一个4KB页面的情况。

PostgreSQL支持**整页写入（full-page write）**的功能来处理这种失效。如果启用，PostgreSQL会在每次检查点之后，在每个页面第一次发生变更时，会将**整个页面**及相应首部作为一条XLOG记录写入。这个功能默认是开启的。在PostgreSQL中，这种包含完整页面的XLOG记录称为**备份区块（backup block）**，或者**整页镜像（full-page image）**。
![[Pasted image 20220719234824.png]]
1.  检查点进程开始进行检查点过程。
2.  在第一条`INSERT`语句进行插入操作时，PostgreSQL执行的操作几乎同上所述。区别在于这里的XLOG记录是当前页的**备份区块**（即，包含了完整的页面），因为这是自最近一次检查点以来，该页面的第一次写入。
3.  当事务提交时，PostgreSQL的操作同上节所述。
4.  第二条`INSERT`语句进行插入操作时，PostgreSQL的操作同上所述，这里的XLOG记录就不是备份块了。
5.  当这条语句的事务提交时，PostgreSQL的操作同上节所述。
6.  为了说明整页写入的效果，我们假设后台写入进程在向磁盘写入脏页的过程中出现了操作系统故障，导致磁盘上表A的页面数据损坏。
重启PostgreSQL即可修复损坏的集簇
![[Pasted image 20220719234933.png]]


1.  PostgreSQL读取第一条`INSERT`语句的XLOG记录，并从数据库集簇目录加载表A的页面至共享缓冲池中。在本例中，按照整页写入的规则，这条XLOG记录是一个备份区块。
    
2.  当一条XLOG记录是备份区块时，**会使用另一条重放规则：XLOG记录的数据部分会直接覆盖当前页面，无视页面或XLOG记录中的LSN，然后将页面的LSN更新为XLOG记录的LSN。**
    
    在本例中，PostgreSQL使用记录的数据部分覆写了损坏的页面，并将表A的LSN更新为`LSN_1`，通过这种方式，损坏的页面通过它自己的备份区块恢复回来了。
    
3.  因为第二条XLOG记录不是备份区块， 因此PostgreSQL的操作同上所述。
## 2. 事务日志与WAL段文件
PostgreSQL在逻辑上将XLOG记录写入事务日志，事务日志就是一个长度用8字节表示的虚拟文件（16 EB）
>单位换算：
>-   1 Terabyte (TB) = 1024 GB
>-   1 Petabyte (PB) = 1024 TB
>-   1 Exabyte (EB) = 1024 PB
>-   1 Zettabyte (ZB) = 1024 EB

PostgreSQL中的事务日志实际上默认被划分为16M大小的一系列文件，这些文件被称作**WAL段（WAL Segment）**。
![[Pasted image 20220719235602.png]]
WAL段文件的文件名是由24个十六进制数字组成的，其命名规则如下：
![[Pasted image 20220719235714.png]]
> 时间线标识(timelineId)
> PostgreSQL的WAL有**时间线标识（TimelineID，四字节无符号整数）**的概念，用于时间点恢复（PITR）**。

> WAL 文件名
> 使用内建的函数`pg_xlogfile_name`（9.6及以前的版本），或`pg_walfile_name`（10及以后的版本），我们可以找出包含特定LSN的WAL段文件。例如：
> ```sql
testdb=# SELECT pg_xlogfile_name('1/00002D3E'); -- 9.6- 
> testdb=# -- SELECT pg_walfile_name('1/00002D3E'); -- 10+ 
> 	pg_xlogfile_name 
>-------------------------
> 000000010000000100000000 
> (1 row)
> ```

## 3. WAL段文件的内部布局
一个WAL段文件大小默认为16MB，并在内部划分为大小为8192字节（8KB）的页面。第一个页包含了由`XLogLongPageHeaderData`定义的首部数据，其他的页包含了由`XLogPageHeaderData`定义的首部数据。每页在首部数据之后，紧接着就是以**降序**写入的XLOG记录。
![[Pasted image 20220720001155.png]]
```cpp
typedef struct XLogPageHeaderData 
{ 
	uint16 xlp_magic; /* 用于正确性检查的魔数 */ 
	uint16 xlp_info; /* 标记位，详情见下 */ 
	TimeLineID xlp_tli; /* 页面中第一条记录的时间线ID */ 
	XLogRecPtr xlp_pageaddr; /* 当前页的XLOG地址 */ 
	
	/* 当本页放不下一条完整记录时，我们会在下一页继续，xlp_rem_len存储了来自先前页面 
	 * 记录剩余的字节数。注意xl_rem_len包含了备份区块的数据，也就是说它会在第一个首部跟踪 
	 * xl_tot_len而不是xl_len。还要注意延续的数据不一定是对齐的。*/ 
	uint32 xlp_rem_len; /* 记录所有剩余数据的长度 */ 
} XLogPageHeaderData; 

typedef XLogPageHeaderData *XLogPageHeader; 

/* 当设置了XLP_LONG_HEADER标记位时，我们将在页首部中存储额外的字段。 
 * (通常是在XLOG文件中的第一个页面中) 额外的字段用于确保文件的正确性。 */ 

typedef struct XLogLongPageHeaderData 
{ 
	XLogPageHeaderData std; /* 标准首部 */ 
	uint64 xlp_sysid; /* 来自pg_control中的系统标识符 */ 
	uint32 xlp_seg_size; /* 交叉校验 */ 
	uint32 xlp_xlog_blcksz;/* 交叉校验 */ 
} XLogLongPageHeaderData;
```
## 4. WAL记录的内部布局
一条XLOG记录由通用的首部部分与特定的数据部分构成。
### 4.1 WAL记录首部部分
所有的XLOG记录都有一个通用的首部，由结构`XLogRecord`定义。9.5更改了首部的定义，9.4及更早版本的结构定义如下所示：
```cpp
typedef struct XLogRecord 
{ 
	uint32 xl_tot_len; /* 整条记录的全长 */ 
	TransactionId xl_xid; /* 事务ID */ 
	uint32 xl_len; /* 资源管理器的数据长度 */ 
	uint8 xl_info; /* 标记位，如下所示 */ 
	RmgrId xl_rmid; /* 本记录的资源管理器 */ 
	/* 这里有2字节的填充，初始化为0 */ 
	XLogRecPtr xl_prev; /* 在日志中指向先前记录的指针 */ 
	pg_crc32 xl_crc; /* 本记录的CRC */ 
} XLogRecord;
```
`xl_rmid`与`xl_info`都是与**资源管理器（resource manager）**相关的变量，它是一些与WAL功能（写入，重放XLOG记录）相关的操作集合。资源管理器的数目随着PostgreSQL不断增加，第10版包括这些：

|            | 资源管理器                                                         |
| ---------- | ------------------------------------------------------------------ |
| 堆元组操作 | `RM_HEAP`, `RM_HEAP2`                                              |
| 索引操作   | `RM_BTREE`, `RM_HASH`, `RM_GIN`, `RM_GIST`, `RM_SPGIST`, `RM_BRIN` |
| 序列号操作           |                                                                    |
