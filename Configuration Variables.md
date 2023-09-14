# 配置变量教程
mysqld可以从命令行中读取配置参数，也可以从配置文件中读取参数
## 配置文件my.cnf
### 文件位置
```text
# 默认文件
1. /etc/my.cnf
2. $DATADIR/mycnf
3. ~/.my.cnf

优先级依次升高。多个文件配置都可以生效，相同的配置项会被之后读取到的值覆盖。

# 命令行指定配置文件，该参数必须紧挨着 mysqld
--no-default
--default-file=path        # 默认的文件会被跳过
-- default-extra-file=path # 优先级最高
```
### 格式
```yaml
[section_name]
option_name=option_value#comment
option_name=option_value
#comment
option_with_no_argument

#example
[mysqld]
key-buffer-size=128M
# make sure we log queries that do not use keys
log-long-format
long-query-time='3' # anything longer than this is too long
max-connections=300
socket="/var/lib/mysql/mysql.sock"
datadir=/var/lib/mysql
```
- 每个可执行文件对应一个section_name
- 可以带参数
- 可以带注释
# 配置选项解析的内部原理
每个配置项由一个`stuct my_option`定义

Members of struct my_option

| Definition                       | Description                                                                                                                                                                                                                                                                                                                                                  |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `const char *name`               | Option name as it appears in the configuration file. On the command line, the option name is prefixed with a double hyphen: --.                                                                                                                                                                                                                              |
| `int id`                         | A unique integer code for the option. If the code fits within the printable ACSII character range, it is also used for the short (prefixed by a single hyphen) form of the command line option. For example, if the value is the ASCII code for b, this option can be specified with _-b_ on the command line.                                               |
| `const char *comment`            | A brief documentation of the option that appears in the output of _mysqld --help_.                                                                                                                                                                                                                                                                           |
| `gptr *value`                    | A pointer to the memory location that will store the value of the option once it is parsed. The type of the variable pointed at should be specified by the appropriate value of the `var_type` member. If the option accepts no arguments, should be set to 0.                                                                                               |
| `gptr *u_max_value`              | A pointer to the memory location that will store the maximum possible value of the option. Usually points to a member of a `max_system_variables` structure, which results in its initialization.                                                                                                                                                            |
| `const char **str_values`        | At this point, does not appear to be used anywhere in the code. Apparently was intended to point to an array of possible string values for the option. Set it to 0 if you are adding your own option.                                                                                                                                                        |
| `ulong var_type`                 | Variable type code. For possible values and their meanings, see [Table 5-2](https://learning.oreilly.com/library/view/understanding-mysql-internals/0596009577/ch05.html#orm9780596009571-CHP-5-TABLE-2 "Table 5-2. Variable type codes allowed in the var_type field"). The preprocessor macros containing the values are defined in _include/my_getopt.h_. |
| `enum get_opt_arg_type arg_type` | Argument type code. For possible values, see [Table 5-3](https://learning.oreilly.com/library/view/understanding-mysql-internals/0596009577/ch05.html#orm9780596009571-CHP-5-TABLE-3 "Table 5-3. Argument type codes allowed in the arg_type field"). `enum get_opt_arg_ type` is defined in _include/my_getopt.h_.                                          |
| `longlong def_value`             | Default value.                                                                                                                                                                                                                                                                                                                                               |
| `longlong min_value`             | Minimum value. If a lower value is specified, the actual value of the option is set to the minimum value.                                                                                                                                                                                                                                                    |
| `longlong max_value`             | Maximum value. If a higher value is specified, the actual value of the option is set to the maximum value.                                                                                                                                                                                                                                                   |
| `longlong sub_size`              | The value to subtract from the option before storing it in the variable associated with the option.                                                                                                                                                                                                                                                          |
| `long block_size`                | The option value will be adjusted to be a multiple of this parameter.                                                                                                                                                                                                                                                                                        |
| `int app_type`                   | Apparently reserved for future use. Safe to set to 0.                                                                                                                                                                                                                                                                                                        | 

Variable type codes allowed in the var_type field

|Macro|Decimal value|Description|
|---|---|---|
|`GET_NO_ARG`|1|There is no variable to worry about because the option accepts no argument.|
|`GET_BOOL`|2|The variable is of type `my_bool`.|
|`GET_INT`|3|The variable is of type `int`.|
|`GET_UINT`|4|The variable is of type `uint`.|
|`GET_LONG`|5|The variable is of type `long`.|
|`GET_ULONG`|6|The variable is of type `ulong`.|
|`GET_LL`|7|The variable is of type `longlong`.|
|`GET_ULL`|8|The variable is of type `ulonglong`.|
|`GET_STR`|9|The variable is of type `char*`. When the corresponding option is parsed, the variable will be pointed to the location containing the option value. In other words, it points to somewhere in the middle of one of the members of the argv array. No memory is allocated.|
|`GET_STR_ALLOC`|10|The variable is of type `char*`. If the initial value is not 0, the option parsing code assumes that the pointer has been allocated earlier with `my_malloc( )` and will free it with a call to `my_free( )`. Otherwise the pointer is allocated with `my_ malloc( )`. Thus, the value of the option can end up either in a predefined location allocated by the caller, or in a location allocated by the options parser .|
|`GET_DISABLED`|11|The option is understood by the option parser but is disabled. If used, the parsing is aborted and an error code is returned.|
|`GET_ASK_ADDR`|128|This value is ORed with other values. If enabled, the address for the variable will be provided by a special function `mysql_getopt_value( )` from _sql/mysqld.cc_. This is useful for option arguments in the style of _namespace.arg_name_; e.g., `keycache1.key_buffer_size`. The `mysql_getopt_value( )` method receives the value of the _namespace_ part as an argument, and is able to supply the correct storage address based on this information. Currently, this syntax is used to support configuration of multiple key caches in MyISAM tables, but could be used for other things in the future.|

Table 5-3. Argument type codes allowed in the arg_type field

| `Value`        | Description                                                                                                                                                                                                                                                                                                                                                                                                                                          |     |     |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- | --- |
| `NO_ARG`       | The option does not accept an argument. It is an error to provide one. This type is usually used for Boolean flags.                                                                                                                                                                                                                                                                                                                                  |     |     |
| `OPT_ARG`      | The option may accept an argument, but it is not an error to not provide one. In that case the value of the variable will be set to its default value. This type is usually used for options that tell MySQL to log something, and may optionally specify the location of the log, or for options that enable a feature that has several different modes of operations, with one being a very reasonable default, and others being somewhat obscure. |     |     |
| `REQUIRED_ARG` | The option requires the user to provide an argument. If no argument is supplied, an error is reported. This type is usually used for numeric variables, or for other options where it does not make sense to just name the option and expect the server to supply a reasonable default.                                                                                                                                                              |     |     |
## 添加新配置选项的示例
```cpp
# 示例：新增一个参数，opt_kill_old_mysqld,每次开启一个新的mysqld的时候，如果已经存在，则把旧的mysqld kill掉
# 1. 添加一个新的配置项到 my_long_options in sql/mysqld.cc
{"kill-old-mysqld", OPT_KILL_OLD_MYSQLD,
    "Kill old instance of mysqld on startup",
    (gptr*) &opt_kill_old_mysqld, (gptr*) &opt_kill_old_mysqld, 0,GET_BOOL, NO_ARG,
    0, 0, 0, 0, 0, 0},
# 2. 声明一个全局变量
 my_bool opt_kill_old_mysqld = 0;
# 3. 在初始化参数后添加处理逻辑
if (opt_kill_old_mysqld)
        kill_old_mysqld();
# 4. 完成函数开发
static void kill_old_mysqld(void)
	{
	  File fd = -1;
	
	  /* pid value can have no more than 20 digits,
	     and we need one extra byte for the new line character
	   */

	  char buf[21];
	  char* p;
	  long pid;

	  /* return if we cannot open the file */
	  if ((fd= my_open(pidfile_name,O_RDONLY,MYF(0))) < 0)
	    return;

	  /* Populate the buffer. For the sake of simplicity
	     we do not deal
	     with the case of a partial read, and leave it
	     as an exercise for
	     the meticulous reader.
	   */
	  if (my_read(fd, buf, sizeof(buf), MYF(0)) <= 0)
	    goto err;

	  /* boundary for strchr() */
	  buf[sizeof(buf) - 1]= 0;

	  /* find the end of line and put a \0 terminator instead */
	  if (!(p= strchr(buf,'\n')))
	    goto err;
	  *p= 0;

	  if (!(pid= strtol(buf,0,10)))
	    goto err;

	  /* Support for Windows is left as an exercise for
	     the reader */
	#ifndef __WIN__
	  /* A crude kill method with no checks.
	     A more refined method is left
	     as an exercise for the reader.
	   */
	  kill(pid, SIGTERM);
	  sleep(5);
	  kill(pid, SIGKILL);
	  sleep(2);
	#endif

	  /* Cleanup. Should be executed in all cases,
	     success or error
	   */
	err:
	  if (fd >= 0)
	    my_close(fd,MYF(0));
	}
```
# Configuration
| 参数                           | 解释                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |     |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| big-tables                     | 每当创建一个表时候，会首先考虑使用in-memory temporary table，当该表的空间超过 `tmp_table_size`时，会把临时表转变为disk-based table；开启这个选项以后，当创建一个表的时候，直接创建为disk-based table 、                                                                                                                                                                                                                                                                 |     |
| concurrent-insert              | 当一条记录插入表中时，MyISAM存储引擎首先尝试查找之前删除的记录，该记录的空间足够大以容纳新记录，并用新记录覆盖该空间 ；如果不存在，就写入到最后。                                                                                                                                                                                                                                                                                                                       |     |
| core-file                      | 如果不幸发生崩溃，此选项将充分发挥被称为 MySQL 的巫毒黑魔法的全部力量，以诱使不合作的内核写出核心文件                                                                                                                                                                                                                                                                                                                                                                   |     |
| default-storage-engine         | 设置默认的存储引擎                                                                                                                                                                                                                                                                                                                                                                                                                                                      |     |
| delay-key-write                | 通常，服务器在每次查询结束时将更改的密钥块从 MyISAM 密钥缓存中刷新出来 。该选项可以延后该flush 操作。（flush tables，flush table，server shutdown，该表在缓存中被替换，该block被替换）                                                                                                                                                                                                                                                                                  |     |
| ft_stopword_file               | MyISAM支持full-text搜索。一个句子中经常出现的毫无特征的单词（例如the)被称为stop words。这些单词加入会被忽略。更改该项需要reindex表，使用REPAIR TBLE                                                                                                                                                                                                                                                                                                                     |     |
| innodb_buffer_pool_size        | 该配置控制使用多少内存来缓存 InnoDB 表数据和索引。                                                                                                                                                                                                                                                                                                                                                                                                                      |     |
| innodb_flush_log_at_trx_commit | InnoDB维护事务日志，该日志用于异常恢复。当 innodb_flush_log_at_trx_commit 设置为 0 时，日志缓冲区每秒写入日志文件一次，并对文件描述符执行刷新到磁盘操作，但在事务提交期间不执行任何操作。 当该值为 1 时，在每次事务提交期间，日志缓冲区都会写出到日志文件，并对文件描述符执行刷新到磁盘操作。 当设置为 2 时，在每次提交期间，日志缓冲区都会写出到文件描述符，但不会对其执行刷新到磁盘操作。                                                                             |     |
| innodb_file_per_table          | 启用后，innodb_file_per_table 会导致新表将其索引和数据存储在单独的文件 table_name.ibd 中。                                                                                                                                                                                                                                                                                                                                                                              |     |
| innodb_lock_wait_timeout       | InnoDB支持行级锁。该选项设置单个线程申请某个锁的最大时间，超过即视为发生死锁。                                                                                                                                                                                                                                                                                                                                                                                          |     |
| innodb_force_recovery          | 该选项告诉 InnoDB 尝试恢复丢失数据的难度。 0 表示不超出标准恢复算法，而 6 表示不惜一切代价启动数据库，然后努力运行查询而不崩溃。 如果此选项的值大于 0，则不允许更新表的查询。 用户应该转储表来挽救数据，然后重新创建一个干净的表空间并重新填充它。                                                                                                                                                                                                                      |     |
| init_file                      | 此选项在服务器启动时从指定文件运行一组 SQL 命令。                                                                                                                                                                                                                                                                                                                                                                                                                       |     |
| key_buffer_size                | MyISAM 存储引擎缓存表键。该选项控制 MyISAM key缓存的大小。请注意，MyISAM 中没有设置数据缓存的选项。                                                                                                                                                                                                                                                                                                                                                                     |     |
| language                       | 该选项指定包含错误消息文件 errmsg.sys 的目录的路径.不同的目录包含不同语言的文件，因此选项的名称也不同。                                                                                                                                                                                                                                                                                                                                                                 |     |
| log                            | 此选项启用一般活动日志，记录每条命令。                                                                                                                                                                                                                                                                                                                                                                                                                                  |     |
| log-bin                        | 此选项启用二进制格式的更新日志（因此名称中包含_-bin ）。它主要用于复制主机上的复制，但也可用于增量备份。日志记录发生在逻辑级别；即，正在记录查询以及一些元信息。                                                                                                                                                                                                                                                                                                        |     |
| log-isam                       | 该选项跟踪低级别MyISAM存储引擎的操作，如打开和关闭表、写入或读取记录、索引文件状态查询和更新等功能。可以使用命令行实用程序查看日志                                                                                                                                                                                                                                                                                                                                      |     |
| log-slow-queries               | 此选项可以记录优化器认为不是最佳的查询。有两个标准：执行时间（由`long_query_time`选项控制）和key使用。`log-slow-queries``log-queries-not-using-indexes``log-long-format`                                                                                                                                                                                                                                                                                                |     |
| max_allowed_packet             | 此选项可以控制数据包大小的上限，避免内存不足                                                                                                                                                                                                                                                                                                                                                                                                                            |     |
| max_connections                | 此选项对数量设置了上限服务器愿意接受的最大连接数                                                                                                                                                                                                                                                                                                                                                                                                                        |     |
| max_heap_table_size            | 此选项对每个内存表的大小设置了上限。                                                                                                                                                                                                                                                                                                                                                                                                                                    |     |
| max_join_size                  | 主要旨在防止有错误的应用程序和缺乏经验的用户导致服务器瘫痪。它告诉优化器中止它认为需要检查超过给定数量的记录组合的查询。                                                                                                                                                                                                                                                                                                                                                |     |
| max_sort_length                | 该变量对排序键前缀的长度施加限制                                                                                                                                                                                                                                                                                                                                                                                                                                        |     |
| myisam-recover                 | 该选项启用后，一旦 MyISAM 存储引擎发现损坏，就立即修复损坏的 MyISAM 表。                                                                                                                                                                                                                                                                                                                                                                                                |     |
| query_cache_type               | 该选项设置缓存策略。可能的值是 0 表示不缓存，1 表示缓存除具有该标志的查询之外的所有查询`SQL_NO_CACHE`，2 表示仅缓存具有该`SQL_CACHE` 标志的查询。                                                                                                                                                                                                                                                                                                                       |     |
| read_buffer_size               | 虽然MyISAM存储引擎一般不会缓存数据行，但在执行顺序扫描时会使用预读缓冲区。该选项控制其大小                                                                                                                                                                                                                                                                                                                                                                              |     |
| relay-log                      | 从属服务器现在有两个线程：一个用于网络 I/O，另一个用于应用 SQL 更新。I/O 线程从主服务器读取更新并将其附加到所谓的中继日志中。SQL线程依次读取relay log的内容，并将其应用到slave数据上。                                                                                                                                                                                                                                                                                  |     |
| server-id                      | 此选项为服务器分配一个数字 ID，以便在网络上的复制对等方之间进行识别                                                                                                                                                                                                                                                                                                                                                                                                     |     |
| skip-grant-tables              | 该选项告诉服务器启动时不加载访问权限表。                                                                                                                                                                                                                                                                                                                                                                                                                                |     |
| skip-stack-trace               | 此选项关闭崩溃后自诊断。                                                                                                                                                                                                                                                                                                                                                                                                                                                |     |
| slave-skip-errors              | 该选项告诉从属服务器应该忽略哪些错误代码。可以在逗号分隔的列表中指定要忽略的错误代码，或者可以仅使用关键字 all 来忽略所有错误。                                                                                                                                                                                                                                                                                                                                         |     |
| sort_buffer_size               | 该选项通过指定允许基数排序使用多少内存来间接控制使用基数排序在内存中排序的块的大小。                                                                                                                                                                                                                                                                                                                                                                                    |     |
| sql-mode                       | 该选项用来设置不同模式                                                                                                                                                                                                                                                                                                                                                                                                                                                  |     |
| table_cache                    | 该选项控制可以同时缓存多少个表描述符（不是表！）。                                                                                                                                                                                                                                                                                                                                                                                                                      |     |
| temp-pool                      | 此选项专门用于解决 Linux 内核中的设计缺陷（至少在版本 2.4 中）。当进程重复创建和删除具有唯一名称的文件时，内核最终会分配大量从未释放的内存。MySQL 有时可能需要创建临时文件来解决查询。在具有大量流量和各种查询的大型站点上，这种情况可能会频繁发生，从而导致严重的问题。对于大多数用户来说，直到 MySQL 在一个负载非常大且包含大量频繁执行的复杂查询的站点上使用时，情况才发生变化。MySQL 开发人员通过添加一个选项来将临时表名称的可能性限制为较小的名称集来解决此问题。 |     |
| transaction-isolation          |  该选项允许为整个服务器设置全局事务隔离级别。                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |     |
