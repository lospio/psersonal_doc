# 00: TODO
- [ ] 系统表数据结构，存储
- [ ] template1最原始的系统表什么样子
# 01：整体结构
![[Pasted image 20230406145221.png]]
- 连接管理系统：接受外部操作请求，对操作请求进行预处理和分发，起逻辑控制作用
- 编译执行系统：完成操作请求在数据库中的分析处理和转化工作，最终<mark style="background: #FF5582A6;">实现物理存储介质中数据的操作</mark>
- 存储管理系统：负责存储和管理物理数据，提供对编译执行系统的支持
- 事务系统：日志管理器和事务管理器完成对操作请求处理的<mark style="background: #FF5582A6;">事务一致性支持</mark>，锁管理器和并发控制提供对<mark style="background: #FF5582A6;">并发访问数据的一致性支持</mark>
- 系统表：系统表是 PostgreSQL 数据库的<mark style="background: #FF5582A6;">元信息管理中心</mark>，包括数据库对象信息和数据库管理控制信息
# 02：系统表
关系型数据库中，必须提供数据<mark style="background: #FF5582A6;">字典功能</mark>。在PG中系统表扮演了这个角色。
#### 数据字典
存储了各种对象的<mark style="background: #FF5582A6;">描述信息</mark>和<mark style="background: #FF5582A6;">细节信息</mark>，从内容来看，数据字典包含数据库系统中<mark style="background: #FF5582A6;">所有对象及其属性的描述信息</mark>、<mark style="background: #FF5582A6;">对象之间关系的描述信息</mark>、<mark style="background: #FF5582A6;">对象属性的自然语言含义</mark>以及<mark style="background: #FF5582A6;">数据字典变化的历史</mark>(即数据库的状态信息)。
#### 系统表
- 系统表是 PostgreSQL 数据库存放<mark style="background: #FF5582A6;">结构元数据</mark>的地方，它在 PostgreSQL中<mark style="background: #FF5582A6;">表现为存放有系统信息的普通表或者视图</mark>
- 正常情况下不应该由用户手工修改系统表，而是由 SQL 命令关联的系统表操作自动维护系统表信息
- 两类：多个数据库共享和单个数据库独有
- 访问频繁，在内存中建立了共享的<mark style="background: #FF5582A6;">系统表CACHE</mark>
![[1680765494180.jpg]]
## 主要系统表功能及依赖关系
- `pg_namespace`用于存储命名空间。
	- PostgreSQL的名字空间层次是<mark style="background: #FF5582A6;">数据库.模式.表.属性</mark>
	- 每个元组对应一个namespace，就是通常说的schema
	![[Pasted image 20230406154454.png]]
- `pg_tablespace`用于存储表空间信息
	- 每个元组对应一个存储表空间
	- 将表放置在不同的表空间有助于<mark style="background: #FF5582A6;">优化磁盘文件布局</mark>
		- 当前磁盘快要用尽
		- 某个磁盘性能非常优异
	- 所有数据库共享
	- ![[Pasted image 20230406155015.png]]
- `pg_database` 用于存储数据库信息
	- 每个元组表示Database Cluster中的一个数据库
	- 所有数据库共享
	- ![[Pasted image 20230406155137.png]]
- `pg_class` <mark style="background: #FF5582A6;">存储表</mark>及与<mark style="background: #FF5582A6;">表类似的结构的数据库对象信息</mark>
	- 每一个元组表示一个数据库对象
	- 包含序列，索引，视图，复合数据类型，TOAST表等
	- ![[1680767812411.png]]
- `pg_type` 存储数据类型
	- 每一个元组对应一个数据类型
	- 基本数据类型和枚类型由 CREATE TYPE 创建，域类型由 CREATE DOMAIN创建，复合数据类型在表创建时自动创建
	- ![[1680768152848.png]]
- `pg_attribute` 存储表的属性信息
	- 每个元组对应数据库中表的每个属性（列）
	- ![[1680768316324.png]]
- `pg_index`存储索引的具体信息
	- ![[Pasted image 20230406160731.png]]
- 关键系统表之间的依赖关系
![[Pasted image 20230406160759.png]]

| 数据库概念 | 系统表        | 与表的关联方式                            |
| ---------- | ------------- | ----------------------------------------- |
| schema     | pg_namespaces | pg_class.relnamespace = pg_namespaces.oid |
| table      | pg_class      |                                           |
| column     | pg_attribute  | pg_class.oid = pg_attribute.attrelid      |
| index      | pg_index      | pg_class.oid = pg_index.indrelid          |
| constraint | pg_constraint | pg_class.oid = pg_constraint.conrelid     |


[[show create table 实现]]
## 系统视图
![[Pasted image 20230406162249.png]]
# 03：数据库集簇初始化
PostgreSQL 安装完成 ，必须先使用 <mark style="background: #FF5582A6;">initdb 程序初始化磁盘上的数据存储区</mark>，即数据集簇，是一组数据库（database）的集合，由一个PostgreSQL服务器管理
## 初始化过程
- 创建包含数据库系统所有数据的数据目录
- 创建<mark style="background: #FF5582A6;">共享的</mark>系统表
- 创建其他的配置文件和控制文件
	![[Pasted image 20230406163728.png]]
- 创建 三个模板数据库 template1、template0、默认的用户数据库postgres
	- 以后创建数据库时，template1 数据库里的所有内容(包括系统表文件)都会拷贝过来。 
	- template0,postgres 都是通过拷贝 template1创建的
- postgres使用bootstrap模式创建数据库集簇，并读取后端接口<mark style="background: #FF5582A6;">postgres.bki</mark>文件来创建模板数据库
	- BKI 文件是一些用特殊语言写的脚本
	- 定义 CATALOG 宏，用于以统一的模式去定义系统表的结构以及用以描述系统表的数据结构
	- 通过宏 DATA (x)和 DESCR (x) 来定义 insert 操作，用于定义系统表中的初始数据
	- 允许在<mark style="background: #FF5582A6;">不存在系统表的零初始条件下</mark>执行数据库函数，普通的SQL命令要求系统表必须存在
	- 模板数据库<mark style="background: #FF5582A6;"> template1 </mark>是通过运行在 bootstrap 模式的 postgres 程序读取postgres.bki 文件创建的
#### postgres.bki
- `create[ bootstrapJ [shared_relation ] [ without_ Oids] tablename tableOid (namel = type1[, name2 = type2 , ... ])`
- 指定了bootstrap选项，只创建表不向里面插入任何记录，此时无法被普通的SQL操作访问，直到系统标的初始记录用硬方法（BKI的 insert方法）插入。这个选项用于创建诸如 pg_class 等核心的系统表
- shared_relation 整个数据库集簇共享
- 命令
	- `open table_name` 打开一个名为table_name的表，准备插入数据。在BKI被执行时，<mark style="background: #FF5582A6;">任意时刻只有一个表被打开</mark>，因此使用open命令时，<mark style="background: #FF5582A6;">任何当前已经打开的表都被关闭</mark>
	- `insert [ OID = Oid_value ] (valuel value2.. . )`
	- `close [tablename]`
	- `declare [ unique ] index indexname indexoid on tahlename using amename( opclassl name1[， ... ])`在名为 tablename 表上用 amname 访问方法创建一个 OID indexOid 且名为 indexname索引。<mark style="background: #FF5582A6;">该命令仅创建索引结构</mark>
	- `declare toast toasttableOid toastindexOid on tablename`为名为 tablename 的表创建一个 TOAST表。该命令仅创建索引结构
	- `build indices`对declare两种命令创建的内容进行填充
	- 在有一些基本的系统表(关键表)被创建并初始化其数据之前，不能使用open 命令打开非关键系统表。其中关键表包括: <mark style="background: #FFB8EBA6;">pg_class</mark>,<mark style="background: #FFB8EBA6;">pg_attribute</mark>,<mark style="background: #FFB8EBA6;">pg_proc</mark>和<mark style="background: #FFB8EBA6;">pg_type</mark>
	- 在源代码被编译时，调用genbki.sh,读取每一个`pg_*.h`，转换成BKI命令，写入postgres.bki
		- 创建多个关键表
			- `create bootstrap` 创建关键表
			- `insert`插入数据
			- `close`
		- 创建多个非关键表
			- `create`创建非关键表
			- `open`
			- `insert`
			- `close`
		- 创建index
			- `declare index`
			- `build indices`
#### initdb执行过程
执行initdb程序时，将从initdb.c中的main函数开始
1. 设置系统编码
2. 设置环境变量(pg_data等),获取系统配置文件的源文件路径，并检查该路径下各文件的可用性
3. 设置中断信号处理函数，屏蔽中断的SIGHUP，SIGINT，SIGQUIT，SIGTERM，SIGPIPE等信号
4. 创建文件目录
5. 测试当前服务器性能，根据结果配置参数（max_connections,shared_buffers,timezone)
6. bootstrap模式创建数据库template1
7. 创建系统视图，系统表，创建template0和postgres
![[Pasted image 20230406175941.png]]
#### 系统数据库
- template1 通过BKI生成的，是数据库默认模板，可修改，修改后所有数据库都能继承这些修改
- template0，从template1复制而来
- postgres，从template1复制而来
上述系统数据库都是可以删除的，但是两个模板数据库在删除之前必须将其在 pg_database元组的 datistemplate 属性改为FALSE ，否则删除时会提示"不能删除模板数据库"。
# 04：PostgreSQL进程结构
PostgreSQL 是一种专用<mark style="background: #FF5582A6;">服务器进程体系结构</mark>。最主要的两个进程守护进程Postmaster和服务进程Postgres。
- PostgreSQL 采用 C/S 模式，系统为每个客户端分配一个服务进程
- 守护进程 Postmaster 负责整个系统的启动和关闭；<mark style="background: #FF5582A6;">监听</mark>并接受客户端的连接请求，为其<mark style="background: #FF5582A6;">分配</mark>服务进程Postgres。
- Postgres服务进程<mark style="background: #FF5582A6;">接受并执行</mark>客户端发迭的命令。
- Postmaster启动系统辅助进程
## Postmaster
一个数据库实例由数据库服务器守护进程 Postmaster 来管理，它是运行在服务器上的总控进程。Postmaster就像一个处理客户端请求的调度中心。当客户端程序需要对数据库进行操作时，首先会发出一个起始消息给 Postmaster 进行请求。 Postmaster 将根据这个起始消息中的信息对客户端的身份进行验证，如果身份验证通过， Postmaster 就为该客户端新建一个服务进程 Postgres 随后 Postmaster 与客户端的交互工作转交给 Postgres服务进程，由Postgres完成客户端所需要的数据库操作
- 管理系统的启动和关闭
- 错误后恢复系统
- 管理数据库文件
- 监听并接受来自客户端的连接请求，并为该请求fork一个postgres服务进程
- 管理辅助进程+
- 管理中断（指派子进程处理）
- 管理共享内存和信号库

>The `postgres` command can also be called in single-user mode. The primary use for this mode is during bootstrapping by [initdb](https://www.postgresql.org/docs/current/app-initdb.html "initdb"). Sometimes it is used for debugging or disaster recovery; note that running a single-user server is not truly suitable for debugging the server, since no realistic interprocess communication and locking will happen. When invoked in single-user mode from the shell, the user can enter queries and the results will be printed to the screen, but in a form that is more useful for developers than end users. In the single-user mode, the session user will be set to the user with ID 1, and implicit superuser powers are granted to this user. This user does not actually have to exist, so the single-user mode can be used to manually recover from certain kinds of accidental damage to the system catalogs.


![[Pasted image 20230407102939.png]]       ![[Pasted image 20230407113737.png]]                                                                                                                                            ![[Pasted image 20230407103051.png]]
#### 初始化内存上下文
从7.1版本开始，实现了新的内存管理机制，运行时大多数内存分配操作在各种语义的内存上下文( MemoryContext) 中进行。通过释放内存上下文避免内存泄漏。
- 调用`MemoryContextlnit` 创建 `TopMemoryContext`和 `ErrorContext`
	- `TopMemoryContext: TopMemoryContext 中分配的内存直到系统退出时才会释放。例如:TopMemoryContext 中存放了所有打开的文件描述符、内存上下文的控制节点等，它是所有内存上下文的树根`
	- `ErrorContext: 这是错误恢复处理的永久性内存环境，恢复完毕则重设。`
- 调用 `AllocSetContextCreate`以`TopMemoryContext` 为根节点创建 `PostmasterContext`，将全局指针 `CurrentMemoryContext` 指向 `PostmasterContext` 
	- `PostmasterContext: 这是 Postmaster 正常工作的内存环境，由它通过 fork 函数产生的子进程将会删除这个环境。` #？ 
	
>	At all times there is a "current" context denoted by the CurrentMemoryContext global variable.
	
>	PostmasterContext --- this is the postmaster's normal working context.After a backend is spawned, it can delete PostmasterContext to free its copy of memory the postmaster was using that it doesn't need.Note that in non-EXEC_BACKEND builds, the postmaster's copy of pg_hba.confand pg_ident.conf data is used directly during authentication in backendprocesses; so backends can't delete PostmasterContext until that's done.(The postmaster has only TopMemoryContext, PostmasterContext, andErrorContext --- the remaining top-level contexts are set up in eachbackend during startup.)

## 配置参数
GUC (Grand Unified Configuration) 模块实现了多种数据类型的变量配置。
#### 参数类型：
• `PGC_INTERNAL`: 参数只能通过内部进程设定，用户不能设定。
• `PGC_POSTMASTER`: 参数只能在 Postmaster 启动时通过读配置文件或处理命令行参数来配置。
• `PGC_SIGHUP`: 参数只能在 Postmaster 启动时配置，或当我们改变了配置文件并发送信号 SIGHUP 通知 Postmaster 或Postgres的时候进行配置
• `PGC_BACKEND`: 参数只能在 Postmaster 启动时读配置文件设置，或由客户端在进行连接请求时设置。已经启动的后台进程会忽略此类参数的改变。
• `PGC_USERSET`: 可以在任何时候配置。
• `PCC_SUSET`: 参数只能在 Postmaster 启动时或由超级用户通过 SQL 语言 (SET 命令)进行设置
#### 参数来源：优先级从低到高
```cpp
typedef enum
{
    PGC_S_DEFAULT,              /* hard-wired default ("boot_val") */
    PGC_S_DYNAMIC_DEFAULT,      /* default computed during initialization */
    PGC_S_ENV_VAR,              /* postmaster environment variable */
    PGC_S_FILE,                 /* postgresql.conf */
    PGC_S_ARGV,                 /* postmaster command line */
    PGC_S_GLOBAL,               /* global in-database setting */
    PGC_S_DATABASE,             /* per-database setting */
    PGC_S_USER,                 /* per-user setting */
    PGC_S_DATABASE_USER,        /* per-user-and-database setting */
    PGC_S_CLIENT,               /* from client connection request */
    PGC_S_OVERRIDE,             /* special case to forcibly set default */
    PGC_S_INTERACTIVE,          /* dividing line for error reporting */
    PGC_S_TEST,                 /* test per-database or per-user setting */
    PGC_S_SESSION               /* SET command */
} GucSource;
```
#### 参数类型构成
共性部分+特性部分，个人理解类似于CPP继承
```cpp
/* 共性部分*/
struct config_generic
{
    /* constant fields, must be set correctly in initial value: */
    const char *name;           /* name of variable - MUST BE FIRST */
    GucContext  context;        /* context required to set the variable */
    enum config_group group;    /* to help organize variables by function */
    const char *short_desc;     /* short desc. of this variable's purpose */
    const char *long_desc;      /* long desc. of this variable's purpose */
    int         flags;          /* flag bits, see guc.h */
    /* variable fields, initialized at runtime: */
    enum config_type vartype;   /* type of variable (set only at startup) */
    int         status;         /* status bits, see below */
    GucSource   source;         /* source of the current actual value */
    GucSource   reset_source;   /* source of the reset_value */
    GucContext  scontext;       /* context that set the current value */
    GucContext  reset_scontext; /* context that set the reset value */
    GucStack   *stack;          /* stacked prior values */
    void       *extra;          /* "extra" pointer for current actual value */
    char       *sourcefile;     /* file current setting is from (NULL if not
                                 * set in config file) */
    int         sourceline;     /* line in source file */
};

/*
 * GUC supports these types of variables:
 */
/* 数值类型*/
enum config_type
{
    PGC_BOOL,
    PGC_INT,
    PGC_REAL,
    PGC_STRING,
    PGC_ENUM
};

struct config_bool
{
    struct config_generic gen;
    /* constant fields, must be set correctly in initial value: */
    bool       *variable;
    bool        boot_val;
    GucBoolCheckHook check_hook;
    GucBoolAssignHook assign_hook;
    GucShowHook show_hook;
    /* variable fields, initialized at runtime: */
    bool        reset_val;
    void       *reset_extra;
};

struct config_int
{
    struct config_generic gen;
    /* constant fields, must be set correctly in initial value: */
    int        *variable;
    int         boot_val;
    int         min;
    int         max;
    GucIntCheckHook check_hook;
    GucIntAssignHook assign_hook;
    GucShowHook show_hook;
    /* variable fields, initialized at runtime: */
    int         reset_val;
    void       *reset_extra;
};
```
#### 配置参数
1. 将所有参数设置成默认值
	- 参数存放在全局静态`config_*`结构体数组中（`ConfigureNamesBool`，`ConfigureNamesInt`，`ConfigureNamesReal`，`ConfigureNamesString`，`ConfigureNamesEnum`）
	- 遍历数组将每个结构体的<mark style="background: #FF5582A6;">首地址</mark>存放在全局`config_generic`指针数组`guc_variables` 并排序 #？
	- 对`guc_variables`中的每个值设置默认值
2. 根据命令行参数配置参数
3. 读取配置文件，重新设置参数
#### 保证唯一一个Postmaster在运行
通过`CreateDataDirLockFile`完成，在目录中创建锁文件`postmaster.pid`，每次 Postmaster 或<mark style="background: #FF5582A6;">独立后台进程 Postgres </mark>启动时都会在数据目录中创建这个独一无二的文件
- 创建成功，写入自己的pid
- 创建失败，取出pid，kill该pid检测是否存在，存在就退出
- 检查共享内存段是否存在
## 创建监听套接字
- 解析字符串 `ListenAddress`，在每个地址上创建监听套接口。 #？ 服务器IP·地址
- 处于监听状态的流套接字将维护一个客户端连接请求队列。超过最大连接请求数，返回错误
- 创建用于进程间通信的共享内存和信号量
## 注册信号处理函数
- 三个信号集
	- `BlockSig`要屏蔽的信号集
	- `UnBlockSig`不屏蔽的信号集
	- `AuthBlockSig`连接认证时需要屏蔽的信号集
- 使用`pqsignal`注册信号处理函数
- 系统关闭信号处理
	- `Smart Shutdown`: Postmaster 将等待所有子进程完成当前的任务后再安全关闭系统，对应于`SIGTERM `信号。
	- `Fast Shutdown`: Postmaster 将向所有子进程发出 `SIGTERM` 信号， 等待子进程接收到这个信号回滚当前事务并退出后再安全关闭系统，对应于 `SIGINT` 信号。
	- `Immediate Shutdown`: Postmaster 将向所有子进程发 `SIGQUIT` 信号，子进程接收到这个信号马上退出，同时系统非正常关闭，对应于 `SIGQUIT` 信号。
- 子进程退出时，给Postmaster发送一个`SIGCHLD`信号，Postmaster调用`reaper`函数清理退出的子进程
## 辅助进程启动
1. Syslogger辅助进程初始化：通过一个管道从Postmaster 、所有后台进程以及其他的子进程那里收集所有的 `stderr` 输出，并将这些输出写入到日志文件中 。
2. PgStat辅助进程初始化：主要完成用于发送和接收统计消息的 UDP 端口创建和测试
3. AutoVacuum赋值进程初始化
4. 初始化完成后，进行数据库的启动操作。其他辅助进程的启动将在循环等待连接`SeverLoop`中检查和启动。
## 装载客户端认证文件
- `pg_hba.conf`
- `pg_ident.conf`
## 循环等待客户连接请求
- `Postmaster`将调用`ServerLoop`函数来循环等待客户端的连接请求，该函数的主体是一个死循环，它的主要功能就是在监听到用户的连接请求后建立与该用户的连接，然后通过调用 fork 函数复制出一个 Postgres进程为该用户服务。
- `while(true)`
	- 监听连接请求
	- fork postgres
	- 加入BackendList链表中进行监控
	- 检查辅助进程状态，启动剩余的辅助进程
# 05: 辅助进程
## Syslogger
- 创建日志目录和文件
- fork一个子进程
- 丢弃与Postmaster的共享内存的函数
- 初始化
- `while(true):`
	- 判断`SIGHUP`信号
	- 判断是否需要切换日志，执行相应的操作（文件名，文件路径，日志大小）
	- 监听日志管道，写入日志文件
## BgWriter
BgWriter是在后台将脏页写到磁盘的辅助进程。
- 定期写出缓冲区中的部分脏页到磁盘中，为缓冲区腾出空间，降低查询处理被阻塞的可能性
- 减少checkpoint时的IO操作
- 流程
	- 变量初始化：局部变量，全局变量，记录PID
	- 注册信号处理函数：响应函数中，将变量置为true
	- 运行环境初始化：创建资源跟踪器，创建运行内存上下文
	- 注册异常处理：使用`setjump`和`longjmp`，。使用 `setjmp`和`longjmp`是C语言编程中常用的错误恢复方法 #？ 
	- 处理写磁盘请求
	- 处理信号分支：根据设置的标志变量
	- 创建检查点
		- 请求创建检查点或者时间间隔到了，创建检查点或者重启点
		- 不创建检查点，调用函数刷脏页
			![[Pasted image 20230421104249.png]]
## WalWriter预写式日志进程
- 先将对文件的修改记录到WAL，再修改文件
- 对比数据修改，更轻量级。提交日志更快。
- 同步日志的开销更小
- PostgreSQL 在数据集簇的 pg_xlog目录中始终只使用 一个WAL 日志文件，这个日志文件记录数据库中数据文件的每个改变。
与BgWriter处理流程非常相似
![[Pasted image 20230421105030.png]]
## PgArch 预写式日志归档进程
PostgreSQL 数据库会产生一个无限长的顺序的 WAL记录序列。PostgreSQL 在物理上把这个 WAL 记录序列分割成多个WAL 文件。WAL文件个数有限制，需要将暂时不用的WAL文件（准确说是在上次checkpoint时间点之前的WAL文件）归档，后续如果需要PITR，可以使用归档后的WAL文件。
#### 参数
- `wal_level`:`archive`或者`hot_standby`
- `archive_mode`:`on`
- `archive_command`:一个shell命令（cp）
#### 处理流程
- fork创建Postmaster的子进程PgArch，关闭从父进程复制的网络连接端口，关闭与父进程的共享内存之间的联系。
- ![[Pasted image 20230421110432.png]]
## AutoVacuum系统自动清理进程
对表元组的`update`和`delete`操作不会立即删除旧版本的数据，会被标记为删除状态，事务提交后才能删除旧版本，此时需要进一步清理，才可释放该空间供后续数据写入。
#### 参数
- `autovacuum`: 是否启动系统自动消理功能，默认值为 on
- `autovacuum_max_workers`: 设置系统自动清理工作进程的最大数量。
- `autovacuum naptime`: 置两次系统自动清理操作之间的间隔时间。
- `autovacuum_ vacuum_threshold` `autovacuum analyze threshold`: 设置当表上被更新的元组数的阀值超过这些阀值时分别需要执行 `vacuum`和`analyze`
- `autovacuum_ vacuum scale factor` `autovacuum_analyze_scale_factor`: 设置表大小的缩放系数
- `autovacuum_freeze_max_age`: 设置需要强制对数据库进行清理的 XID 上限值。
#### AutoVacuum Launcher 监控进程
收集数据库运行信息，选择数据库，调度一个AutoVacuum Worker进程执行清理操作。
- 选择最早未执行过自动清理操作的数据库
- 当XID超过autovacuum_freeze_max_age，强制清理更新XID
- 维护三个AutoVacuum Worker进程列表
	- 空闲
	- 正在启动 允许存在一个
	- 运行中
- 处理流程
	- 执行fork，创建Postmaster的子进程AutoVacuum Launcher，关闭从父进程复制的网络连接端口
	- 构建数据库列表，记录OID，启动时间戳，评分值（加入hash表中的序号）
		- 将hash表中的数据库按照评分值的升序加入链表，设置一个`adl_next_worker`值，记录应该调度worker的时间
	- 设置进程休眠时间：根据空闲Worker和数据库列表设置。Worker进程退出时可以唤醒
	- 信号处理
	- 调度worker
		- 数据库列表为空，启动
		- 数据库列表不为空，检查链表尾部的`adl_next_worker`参数如果小于当前时间，启动 #？
- ![[Pasted image 20230421112642.png]]
#### AutoVacuum Worker
![[Pasted image 20230421113747.png]]
## PgStat统计数据收集进程
PgStat辅助进程是数据库系统的统计信息收集器，专门收集数据库系统运行中的统计信息，如在一个表和索引上进行了多少次插入与更新操作，磁盘块的数量和元组数量等。<mark style="background: #FFB8EBA6;">统计信息主要用于查询优化时的代价估算</mark>。
#### 参数
- `track_activities` :表示是否对会话中 前执行的命令开启统计信息收集功能 该参数只对超级用户和会话所有者可见，默认值为 on (开启)
- `track counts`: 表示是否对数据库活动 启统计信息收集功能，由于在 AutoVacuum 进程中选择清理的数据库时，需要数据库的统计信息，因此该参数默认值为 on
- `track function`: 是否开启函数的调用次数和调用耗时统计
- `track_activity _query _size`: 设置用于跟踪每一个活动会话的当前执行命令的字节数，默认值为1024. 只能在数据库启动后设置。
#### 过程
- 初始化后，创建用于和后台进程之间通信的UDP端口，监听端口，进入相应的处理接口
- 后台进程向该进程发送统计消息
	![[Pasted image 20230421114722.png]]
- 进入`PgstatCollectorMain`
	- 读取统计信息文件
	- 更新统计信息文件，从统计信息临时文件中
![[Pasted image 20230421114610.png]]
# 06: 服务进程Postgres
Postgres进程是实际的接受查询请求并执行操作的PostgreSQL服务进程。它直接接受用户命令，返回结果。一直循环，知道用户断开连接。
#### 模式
- 多用户。由Postmaster创建为用户服务
- 单用户。用于`initdb`,debug和disaster recovery
#### 流程
![[Pasted image 20230421115738.png]]
- 初始化内存环境
- 配置运行参数和处理客户端传递的GUC参数
- 设置信号处理和信号屏蔽
	- `SIGHUP`重读postgresql.conf，pg_hba.conf，pg_ident.conf
	- `SIGINT`中指正在进行的查询操作
	- `SIGTERM`终止当前事物
	- `SIGQUIT`屏蔽其他信号，结束正在进行的工作并退出
	- `SIGALRM`由进程等待锁的时间超时引发。存在死锁，将自己从锁等待队列中退出，唤醒自己，设置错误类型。
- 初始化Postgres的运行环境
	- 设置路径，检查版本信息
	- BaseInit：完成Postgres进程的内存，信号量以及文件句柄的创建和初始化工作。
	- InitPostgres：初始化后端缓冲池，Xlog访问，关系Cache，系统表Cache，查询计划Cache，Portal管理器，状态收集器，退出码
- 创建内存上下文并设置查询取消跳跃点
	- 创建MessageContext，存储接收的查询命令，查询产生的中间数据，每次循环重置该context
	- 设置跳跃点，取消一次查询请求或者发生错误时，从这个点退出当前事务重新开始查询
- 循环等待处理查询
	- 服务进程与用户进程使用一种基于消息的协议进行通信，所有的通信都是通过一个消息进行的。
	- 第一个字节标识消息类型，接下来四个字节声明剩下部分的长度，后续就是消息内容。
#### 简单查询的执行流程
- 编译器:编译器是主流程的第一个模块。它扫描用户输入字符串的命令，检查其合法性，转换成内部数据结构
- 分析器:分析器接收编译器传递过来的各种命令数据结构(语法树) ，对它们进行相应的的处理，最终转换为统一的数据结构 Query。如果是查询命令，会对Query进行规则重写。
- 优化器:优化器接收分析器输出的 Query 结构体，进行优化处理后，输出执行器可以执行的计划(Plan)。
- 执行器: 执行查询计划
![[Pasted image 20230421131910.png]]