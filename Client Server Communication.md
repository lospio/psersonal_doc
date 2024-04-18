# 概述
```text
1. 三次握手建立 TCP 连接。

2. 建立 MySQL 连接，也就是认证阶段。
    服务端 -> 客户端：发送握手初始化包 (Handshake Initialization Packet)。
    客户端 -> 服务端：发送验证包 (Client Authentication Packet)。
    服务端 -> 客户端：认证结果消息。

3. 认证通过之后，客户端开始与服务端之间交互，也就是命令执行阶段。
    客户端 -> 服务端：发送命令包 (Command Packet)。
    服务端 -> 客户端：发送回应包 (OK Packet, or Error Packet, or Result Set Packet)。

4. 断开 MySQL 连接。
    客户端 -> 服务器：发送退出命令包。

5. 四次握手断开 TCP 连接。
```
### 图示
未加密：
```plantuml
Server -> Client: 发送握手初始包(Handshake Initialization Packet)
Client -> Server: 发送验证包(Client Authentication Packet)
Server -> Client: 发送认证结果包
Client -> Server: 命令包(Command Packet)
Server -> Client: 回应包(Response Packet OK Packet, or Error Packet, or Result Set Packet)
== 重复 ==
Client -> Server: 退出命令包
```
# 数据包格式

| offset | length | Description                                |
| ------ | ------ | ------------------------------------------ |
| 0      | 3      | packet body length with the low byte first |
| 3       | 1       |   Packet sequence number                                         |
#### 按照压缩类型
压缩和未压缩两种格式；
所有的包有统一的格式，并通过函数 `my_net_write()@sql/net_serv.cc` 写入 buffer 等待发送。压缩的数据包会有额外的3-byte，表示压缩的数据包长度
```text
3-byte -> 16MB
MAX_PACKET_LENGTH 2^24 - 1 大于该参数就会分为多个的数据包
```

```text
+-------------------+--------------+---------------------------------------------------+
|      3 Bytes      |    1 Byte    |                   N Bytes                         |
+-------------------+--------------+---------------------------------------------------+
|<= length of msg =>|<= sequence =>|<==================== data =======================>|
|<============= header ===========>|<==================== body =======================>|
```
MySQL 报文格式如上，消息头包含了
	A) 报文长度，标记当前请求的实际数据长度，以字节为单位；
	B) 序号，为了保证交互时报文的顺序，每次客户端发起请求时，序号值都会从 0 开始计算。
消息体用于存放报文的具体数据，长度由消息头中的长度值决定。

```text
单个报文的最大长度为 (2^24-1)Bytes ，也即 (16M-1)Bytes，对于包长为 (2^24-1)Bytes 也会拆为两个包发送。这是因为最初没有考虑 16M 的限制，从而没有预留任何字段来标志这个包的数据不完整，所以只好把长度为 (2^24-1) 的包视做不完整的包，直到后面收到一个长度小于 (2^24-1) 的包，然后拼起来。
这也意味着最后一个包的长度有可能是 0。
```
#### 按照发送方式
```text
### Client发送包： 
1. 命令包
### Server返回包：
1. data packets
2. end-of-data-stream packets
3. OK packets
4. error message packets
```

# MySQL通讯协议与操作系统层的关系
```text
1. 将Packets写入network buffer
2. 达到上限就会将buffer中的data packets发送
```
# 认证协议
```text
  MySQL 的用户管理模块信息存储在系统表 `mysql.user` 中，其中包括了授权用户的基本信息以及一些权限信息。在登陆时，只会用到 host、user、passwd 三个字段，
也就是说登陆认证需要 host+user 关联，当然可以使用 `*` 通配符。
  服务器在收到新的连接请求时，会调用 `login_connection()` 作身份验证，先根据 IP 做 ACL 检查，然后才进入用户名密码验证阶段。
```
其中报文的格式如下。
![[Pasted image 20230915005956.png]]
MySQL 认证采用经典的 CHAP 协议，即挑战握手认证协议，在 `native_password_authenticate()` 函数的注释中简单介绍了该协议的执行过程：
```text
1. the server sends the random scramble to the client.
2. client sends the encrypted password back to the server.
3. the server checks the password.
```
random scramble 在 4.1 之前的版本中是 8 字节整数，在 4.1 以及后续版本是 20 字节整数，该值是通过 `create_random_string()` 函数生成。
根据版本不同，分为了两类。
#### 4.0 版本以前
```text
基本流程如下：
1. 服务器发送随机字符串 (scramble) 给客户端。可以参考 `create_random_string()` 的生成方法。
2. 客户端把用户明文密码加密一下，然后再将其与服务器发送的随机字符串加密一下，然后变成了新的 `scramble_buff` 发送给服务端。可以参考 `scramble()` 函数的实现。
3. 服务端将 `mysql.user.password` 中的值加上原始随机字符串进行加密，如果加密后的值和客户端发送过来的内容一样，则验证成功。
4. 
需要注意的是：真正意义上的密码是明文密码的加密 hash 值; 如果有人知道了这个用户的 password 哈希值，而不用知道原始明文密码，实际上他就能直接登录服务器。
```
#### 4.1 以后版本
```text
数据库中保存的密码是用 SHA1(SHA1(password)) 加密的，其流程为：
1. 服务器发送随机字符串 (scramble) 给客户端。
2. 客户端作如下计算，然后客户端将 token 发送给服务端。
    stage1_hash = SHA1(明文密码)
    token = SHA1(scramble + SHA1(stage1_hash)) XOR stage1_hash
3. 服务端作如下计算，比对 SHA1(stage1_hash) 和 mysql.user.password 是否相同。
    stage1_hash = token XOR SHA1(scramble + mysql.user.password)
这里实际用到了异或的自反性： `A XOR B XOR B = A` ，对于给定的数 A，用同样的运算因子 B 作两次异或运算后仍得到 A 本身。对于当前情况的话，实际的计算过程如下。

token = SHA1(scramble + SHA1(SHA1(password))) XOR SHA1(password)         // 客户端返回的值
      = PASSWORD XOR SHA1(password)

stage1_hash = token XOR SHA1(scramble + mysql.user.password) = token XOR PASSWORD
            = [PASSWORD XOR SHA1(password)] XOR PASSWORD
            = SHA1(password)

因此，校验时，只需要 `SHA1(stage1_hash)` 与 `mysql.user.password` 比较一下即可。
这次没上一个版本的缺陷了. 有了 `mysql.user.password` 和 `scramble` 也不能获得 `token`，因为没法获得 `stage1_hash`。
但是如果用户的 `mysql.user.password` 泄露，并且可以在网络上截取的一次完整验证数据，从而可以反解出 `stage1_hash` 的值。而该值是不变的，因此下次连接获取了新的 scramble 后，自己加密一下 token 仍然可以链接到服务器。
```
## 协议功能位掩码
4.0之前：2bytes
4.1之后：4bytes

|Bit macro symbol|Hex value|Description|
|---|---|---|
|`CLIENT_LONG_PASSWORD`|0x0001|Apparently was used in the early development of 4.1 to indicate that the server is able to use the new password format.|
|`CLIENT_FOUND_ROWS`|0x0002|Normally, in reporting the results of an `UPDATE` query, the server returns the number of records that were actually modified. If this flag is set, the server is being asked to report the number of records that were matched by the `WHERE` clause. Not all of those will necessarily be updated, as some may already contain the desired values.|
|`CLIENT_LONG_FLAG`|0x0004|This flag will be set for all modern clients. Some old clients expect to receive only 1 byte of flags in the field definition record, while the newer ones expect 2 bytes. If this flag is cleared, the client is old and wants only 1 byte for field flags. This flag will also be set by the modern server to indicate that it is capable of sending the field definition in the new format with 2 bytes for field flags. Old servers (pre-3.23) will not report having this capability.|
|`CLIENT_CONNECT_WITH_DB`|0x0008|This flag is also set for all modern clients and servers. It indicates that the initial default database can be specified during authentication.|
|`CLIENT_NO_SCHEMA`|0x0010|If set, the client is asking the server to consider the syntax _`db_name.table_name.col_name`_ an error. This syntax is normally accepted.|
|`CLIENT_COMPRESS`|0x0020|When set, indicates that the client or the server is capable of using the compressed protocol.|
|`CLIENT_ODBC`|0x0040|Apparently was created to indicate that the client is an ODBC client. At this point, it does not appear to be used.|
|`CLIENT_LOCAL_FILES`|0x0080|When set, indicates that the client is capable of uploading local files with `LOAD DATA LOCAL INFILE`.|
|`CLIENT_IGNORE_SPACE`|0x0100|When set, communicates to the server that the parser should ignore the space characters between identifiers and subsequent ‘.’ or '(' characters. This flag enables syntax such as:<br><br>	db_name .table_name<br><br>or<br><br>	length (str)<br><br>which would normally be illegal.|
|`CLIENT_PROTOCOL_41`|0x0200|When set, indicates that the client or the server is capable of using the new protocol that was introduced in version 4.1.|
|`CLIENT_INTERACTIVE`|0x0400|When set, the client is communicating to the server that it is accepting commands directly from a human. For the server, this means that a different inactivity timeout value should be applied. The server has two settings: `wait_timout` and `interactive_timeout`. The former is for regular clients, while the latter is for the interactive ones. This distinction was created to deal with applications using buggy persistent connection pools that would lose track of established connections without closing them first, keep creating new ones, and eventually overflow the server `max_connections` limit. The workaround was to set `wait_timeout` to a low value that would disconnect the lost connections sooner. This, unfortunately, had a side effect of disconnecting interactive clients too soon, which was solved by giving them a separate timeout.|
|`CLIENT_SSL`|0x0800|When set, indicates the capability of the client or the server to use SSL.|
|`CLIENT_IGNORE_SIGPIPE`|0x1000|Used internally in the client code in versions 3.23 and 4.0. `SIGPIPE` is a Unix signal sent to a process when the socket or the pipe it is writing to has already been closed by the peer. However, a thread in a threaded application on some platforms may get a `SIGPIPE` signal spuriously under some circumstances. Versions 3.23 and 4.0 permit the client programmer to choose whether `SIGPIPE` should be ignored. Version 4.1 just blocks it during the client initialization and does not worry about the issue from that point on.|
|`CLIENT_TRANSACTIONS`|0x2000|When set in the packet coming from the server, indicates that the server supports transactions and is capable of reporting transaction status. When present in the client packet, indicates that the client is aware of servers that support transactions.|
|`CLIENT_RESERVED`|0x4000|Not used.|
|`CLIENT_SECURE_CONNECTION`|0x8000|When set, indicates that the client or the server can authenticate using the new SHA1 method introduced in 4.1.|
|`CLIENT_MULTI_STATEMENTS`|0x10000|When set, indicates that the client can send more than one statement in one query, for example:<br><br>	res = mysql_query(con,"SELECT a FROM<br>	t1 WHERE id =1; SELECT b FROM t1<br>	WHERE id=3");|
|`CLIENT_MULTI_RESULTS`|0x20000|When set, indicates that the client can receive results from multiple queries in the same statement.|
|`CLIENT_REMEMBER_OPTIONS`|0x80000000|Internal flag used inside the client routines. Never sent to the server.|
# 命令包
### 客户端发送的命令包格式

| Offset in the body | Length                                                                                                                            | Description                              |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| 0                  | 1                                                                                                                                 | Command code.                            |
| 1                  | For the noncompressed packet, total packet length from the header – 1. For the compressed packet, the compressed body length – 1. | The argument of the command, if present. |

客户端命令：

| Command code enum value | Code numeric value | Argument description                                                                                                                                                                                                                                                                                                                                                             | Command description                                                                                                                                                                                                                                                                                                                      |
| ----------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `COM_SLEEP`             | 0                  | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Never sent by a client. Reserved for internal use.                                                                                                                                                                                                                                                                                       |
| `COM_QUIT`              | 1                  | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Tells the server to end the session. Issued by the client API call `mysql_close( )`.                                                                                                                                                                                                                                                     |
| `COM_INIT_DB`           | 2                  | A string containing the name of the database.                                                                                                                                                                                                                                                                                                                                    | Tells the server to change the default database for the session to the one specified by the argument. Issued by the client API call `mysql_select_db( )`.                                                                                                                                                                                |
| `COM_QUERY`             | 3                  | A string containing the query.                                                                                                                                                                                                                                                                                                                                                   | Tells the server to run the query. Issued by the client API call `mysql_query( )`.                                                                                                                                                                                                                                                       |
| `COM_FIELD_LIST`        | 4                  | A string containing the name of the table.                                                                                                                                                                                                                                                                                                                                       | Tells the server to return a list of fields for the specified table. This is an obsolete command still supported on the server for compatibility with old clients. Newer clients use the `SHOW FIELDS` query.                                                                                                                            |
| `COM_CREATE_DB`         | 5                  | A string containing the name of the database                                                                                                                                                                                                                                                                                                                                     | Tells the server to create a database with the specified name. This is an obsolete command still supported on the server for compatibility with old clients. Newer clients use the `CREATE DATABASE` query.                                                                                                                              |
| `COM_DROP_DB`           | 6                  | A string containing the name of the database.                                                                                                                                                                                                                                                                                                                                    | Tells the server to drop the database with the specified name. This is an obsolete command still supported on the server for compatibility with old clients. Newer clients use the `DROP DATABASE` query.                                                                                                                                |
| `COM_REFRESH`           | 7                  | A byte containing the bit mask of reloading operations.                                                                                                                                                                                                                                                                                                                          | Tells the server to refresh the table cache, rotate the logs, reread the access control tables, clear the host name lookup cache, reset the status variables to 0, clear the replication master logs, or reset the replication slave depending on the options in the bit mask. Issued by the client API call `mysql_refresh( )`.         |
| `COM_SHUTDOWN`          | 8                  | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Tells the server to shut down. Issued by the client API call `mysql_shutdown( )`.                                                                                                                                                                                                                                                        |
| `COM_STATISTICS`        | 9                  | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Tells the server to send back a string containing a brief status report. Issued by the client API call `mysql_stat( )`.                                                                                                                                                                                                                  |
| `COM_PROCESS_INFO`      | 10                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Tells the server to send back a report on the status of all running threads. This is an obsolete command still supported on the server for compatibility with old clients. Newer clients use the `SHOW PROCESSLIST` query.                                                                                                               |
| `COM_CONNECT`           | 11                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Never sent by a client. Used for internal purposes.                                                                                                                                                                                                                                                                                      |
| `COM_PROCESS_KILL`      | 12                 | A 4-byte integer with the low byte first containing the MySQL ID of the thread to be terminated.                                                                                                                                                                                                                                                                                 | Tells the server to terminate the thread identified by the argument. Issued by the client API call `mysql_kill( )`. This is an obsolete command still supported on the server for compatibility with old clients. Newer clients use the `KILL` query.                                                                                    |
| `COM_DEBUG`             | 13                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Tells the server to dump some debugging information into its error log. Issued by the client API call `mysql_dump_debug_info( )`.                                                                                                                                                                                                        |
| `COM_PING`              | 14                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Tells the server to respond with an `OK` packet. If the server is alive and reachable, it will. Issued by the client API call `mysql_ping( )`.                                                                                                                                                                                           |
| `COM_TIME`              | 15                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Never sent by a client. Used for internal purposes.                                                                                                                                                                                                                                                                                      |
| `COM_DELAYED_INSERT`    | 16                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Never sent by a client. Used for internal purposes.                                                                                                                                                                                                                                                                                      |
| `COM_CHANGE_USER`       | 17                 | A byte sequence in the following format: zero-terminated user name, encrypted password, zero-terminated default database name.                                                                                                                                                                                                                                                   | Tells the server the client wants to change the user associated with this session. Issued by the client API call `mysql_change_user( )`.                                                                                                                                                                                                 |
| `COM_BINLOG_DUMP`       | 18                 | A byte sequence in the following format: 4-byte integer for the offset, 2- byte integer for the flags, 4-byte integer for the slave server ID, and a string for the log name. All integers are formatted with the low byte first.                                                                                                                                                | Tells the server to send a continuous feed of the replication master log events starting at the specified offset in the specified log. Used by the replication slave, and in the _mysqlbinlog_ command-line utility.                                                                                                                     |
| `COM_TABLE_DUMP`        | 19                 | A byte sequence in the following format: 1 byte for database name length, database name, 1 byte for table name length, table name.                                                                                                                                                                                                                                               | Tells the server to send the table definition and data to the client in raw format. Used when a replication slave receives a `LOAD DATA FROM MASTER` query.                                                                                                                                                                              |
| `COM_CONNECT_OUT`       | 20                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Never sent by a client. Used for internal purposes.                                                                                                                                                                                                                                                                                      |
| `COM_REGISTER_SLAVE`    | 21                 | A byte sequence in the following format: a 4-byte integer for the server ID, then a sequence of 1 byte-length prefixed strings in the following order: slave host name, slave user to connect as, slave user password. Then a 2-byte slave user port, 4-byte replication recovery rank, and another 4-byte field that is currently unused. All integers have the low byte first. | Tells the replication master server to register the slave using the information supplied in the argument. This command is a remnant of the started fail-safe replication project. It was introduced in the early version 4.0, but not much has changed since. It is possible that this command might get removed in the future versions. |
| `COM_PREPARE`           | 22                 | A string containing the statement.                                                                                                                                                                                                                                                                                                                                               | Tells the server to prepare the statement specified by the argument. Issued by the client API call `mysql_stmt_prepare( )`. New in version 4.1.                                                                                                                                                                                          |
| `COM_EXECUTE`           | 23                 | A byte sequence in the following format: 4-byte statement ID, 1 byte for flags, and 4-byte iteration count. All integers have the low byte first.                                                                                                                                                                                                                                | Tells the server to execute the statement referenced by the statement ID. Issued by the client API call `mysql_stmt_ execute( )`. New in version 4.1.                                                                                                                                                                                    |
| `COM_LONG_DATA`         | 24                 | A byte sequence in the following format: 4 byte statement ID, 2 byte parameter number, parameter string. Both integers have the low byte first.                                                                                                                                                                                                                                  | Tells the server the packet contains the data for one bound parameter in a prepared statement. Used to avoid unnecessary copying of a large amount of data when the value of the bound parameter is very long. Issued by the client API call `mysql_stmt_send_long_data( )`. New in version 4.1.                                         |
| `COM_CLOSE_STMT`        | 25                 | 4-byte statement ID with the low byte first.                                                                                                                                                                                                                                                                                                                                     | Tells the server to close the prepared statement specified by the statement ID. Issued by the client API call `mysql_stmt_close( )`. New in version 4.1.                                                                                                                                                                                 |
| `COM_RESET_STMT`        | 26                 | 4-byte statement ID with the low byte first.                                                                                                                                                                                                                                                                                                                                     | Tells the server to discard the current parameter values in the prepared statement specified by the statement ID that may have been set with `COM_ LONG_DATA`. Issued by the client API call `mysql_stmt_reset( )`. New in version 4.1.                                                                                                  |
| `COM_SET_OPTION`        | 27                 | 2-byte code for the option, low byte first.                                                                                                                                                                                                                                                                                                                                      | Tells the server to enable or disable the option specified by the code. At this point, seems to be used only to enable or disable the support of multiple statements in one query string. Issued by the client API call `mysql_set_server_option( )`. New in version 4.1.                                                                |
| `COM_END`               | 28                 | No argument.                                                                                                                                                                                                                                                                                                                                                                     | Never sent by a client. Used for internal purposes.                                                                                                                                                                                                                                                                                      |

```cpp
enum enum_server_command {

/**

Currently refused by the server. See ::dispatch_command.

Also used internally to mark the start of a session.

*/

COM_SLEEP,

COM_QUIT, /**< See @ref page_protocol_com_quit */

COM_INIT_DB, /**< See @ref page_protocol_com_init_db */

COM_QUERY, /**< See @ref page_protocol_com_query */

COM_FIELD_LIST, /**< Deprecated. See @ref page_protocol_com_field_list */

COM_CREATE_DB, /**< Currently refused by the server. See ::dispatch_command */

COM_DROP_DB, /**< Currently refused by the server. See ::dispatch_command */

COM_REFRESH, /**< Deprecated. See @ref page_protocol_com_refresh */

COM_DEPRECATED_1, /**< Deprecated, used to be COM_SHUTDOWN */

COM_STATISTICS, /**< See @ref page_protocol_com_statistics */

COM_PROCESS_INFO, /**< Deprecated. See @ref page_protocol_com_process_info */

COM_CONNECT, /**< Currently refused by the server. */

COM_PROCESS_KILL, /**< Deprecated. See @ref page_protocol_com_process_kill */

COM_DEBUG, /**< See @ref page_protocol_com_debug */

COM_PING, /**< See @ref page_protocol_com_ping */

COM_TIME, /**< Currently refused by the server. */

COM_DELAYED_INSERT, /**< Functionality removed. */

COM_CHANGE_USER, /**< See @ref page_protocol_com_change_user */

COM_BINLOG_DUMP, /**< See @ref page_protocol_com_binlog_dump */

COM_TABLE_DUMP,

COM_CONNECT_OUT,

COM_REGISTER_SLAVE,

COM_STMT_PREPARE, /**< See @ref page_protocol_com_stmt_prepare */

COM_STMT_EXECUTE, /**< See @ref page_protocol_com_stmt_execute */

/** See @ref page_protocol_com_stmt_send_long_data */

COM_STMT_SEND_LONG_DATA,

COM_STMT_CLOSE, /**< See @ref page_protocol_com_stmt_close */

COM_STMT_RESET, /**< See @ref page_protocol_com_stmt_reset */

COM_SET_OPTION, /**< See @ref page_protocol_com_set_option */

COM_STMT_FETCH, /**< See @ref page_protocol_com_stmt_fetch */

/**

Currently refused by the server. See ::dispatch_command.

Also used internally to mark the session as a "daemon",

i.e. non-client THD. Currently the scheduler and the GTID

code does use this state.

These threads won't be killed by `KILL`

  

@sa Event_scheduler::start, ::init_thd, ::kill_one_thread,

::Find_thd_with_id

*/

COM_DAEMON,

COM_BINLOG_DUMP_GTID,

COM_RESET_CONNECTION, /**< See @ref page_protocol_com_reset_connection */

COM_CLONE,

COM_SUBSCRIBE_GROUP_REPLICATION_STREAM,

/* don't forget to update const char *command_name[] in sql_parse.cc */

  

/* Must be last */

COM_END /**< Not a real command. Refused. */

};
```
为了保证旧客户端的向后兼容性，新添加的命令必须在COM_END之前。
### 服务器端响应
服务器收到命令，就会对其进行处理并发送一个或多个响应数据包。
#### 数据段
严格规定长度
```cpp
char *
net_store_length(char *pkg, ulonglong length)
{
  uchar *packet=(uchar*) pkg;
  if (length < (ulonglong) LL(251))
  {
     *packet=(uchar) length;
     return (char*) packet+1;
  }
  /* 251 is reserved for NULL */
  if (length < (ulonglong) LL(65536))
  { 
    *packet++=252;
    int2store(packet,(uint) length);
    return (char*) packet+2;
  }
  if (length < (ulonglong) LL(16777216))
  {
    *packet++=253;
    int3store(packet,(ulong) length);
    return (char*) packet+3;
  }
  *packet++=254;
  int8store(packet,length);
  return (char*) packet+8;
}
```

```text
packet 存 code 值,后面的 1-8 位存 length
1. if (0, 251)                 then 1 bytes
2. if == 251                   then null
3. if [252, 2 bytes)           then 2bytes
4. if [2 bytes, 4 btyes)       then 4bytes
5. if [4 bytes,  )             then 8bytes
```
数据包数量巨大，在这种情况下，即使每个字段浪费一个字节也会增加很大的开销
#### OK Packet
作为如下命令包的回复：
- `COM_PING`
- `COM_QUERY` if the query does not need to return a result set; for example, `INSERT, UPDATE`, or `ALTER TABLE`
- `COM_REFRESH`
- `COM_REGISTER_SLAVE`
这种类型的数据包适用于不返回结果集的命令

| Offset in the body                                                                                                                                                                                  | Length     | Description                                                                                                                                                                                                                                                                                                                                       |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0                                                                                                                                                                                                   | 1          | A byte with the value of 0, indicating that the packet has no fields.                                                                                                                                                                                                                                                                             |
| 1                                                                                                                                                                                                   | `rows_len` | The number of records that the query has changed in the field length format described in the “Data Field” section, earlier in this chapter. Its length varies depending on the value. I will refer to its length as `rows_len` to express the subsequent offsets.                                                                                 |
| `1 + rows_len`                                                                                                                                                                                      | `id_len`   | The value of the generated auto-increment ID for the primary key. Set to 0 if not applicable in the context. The value is stored in the field length format of a data field. I will refer to the length of this value as `id_len`.                                                                                                                |
| `1 + rows_len + id_len`                                                                                                                                                                             | 2          | Server status bit mask, low byte first. For details on different values, see the macros starting with `STATUS_` in _include/mysql_com.h_. In the protocol of version 4.0 and earlier, the status field is present only if it is a nonzero value. In the protocol of version 4.1 and later, it is reported unconditionally.                        |
| `3 + rows_len + id_len`                                                                                                                                                                             | 2          | Present only in the protocol of version 4.1 and later. Contains the number of warnings the last command has generated. For example, if the command was `COM_QUERY` with `LOAD DATA INFILE`, and some of the fields or lines could not be properly imported, a number of warnings will be generated. The number is stored with the low byte first. |
| `5 + rows_len + id_len` in version 4.1 and later protocol., `1 + rows_len + id_len` or `3 + rows_len + id_len` in the older protocol, depending on whether the server status bit mask was included. | `msg_len`  | An optional field for the status message if one is present in the standard data field format with the field length followed by field value, which in this case is a character string.                                                                                                                                                             |

#### Error Packet

| Offset in the body                               | Length | Description                                                                                                                                                                                        |
| ------------------------------------------------ | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0                                                | 1      | A byte containing 255. The client will always treat a response packet starting with a byte containing 255 as an error message.                                                                     |
| 1                                                | 2      | The error code. Low byte first. The field will not be included if the server is talking to a very ancient pre-3.23 client, and the subsequent offsets should be adjusted accordingly in that case. |
| 3                                                | 2      | Character '`#`' followed by the byte containing the value of the ODBC/JDBC SQL state. Present only in version 4.1 and later.                                                                       |
| 5 in version 4.1 and later, 3 in 4.0 and earlier | Varies | Zero-terminated text of the error message.                                                                                                                                                         |

#### EOF Packet
使用场景：
- End-of-field information data in a result set
- End-of-row data in a result set
- Server acknowledgment of `COM_SHUTDOWN`
- Server reporting success in response to `COM_SET_OPTION` and `COM_DEBUG`
- Request for the old-style credentials during authentication

| Offset in the body | Length | Description               |
| ------------------ | ------ | ------------------------- |
| 0                  | 1      | Byte with the decimal 254 |
| 1                  | 2      | Number of warnings        |
| 3                  | 2      | Server status bit mask    |

#### Result Set Packet
#? 空结果的返回 ;client是否判断空结果集;分析协议
```cpp
frame #0: 0x00000001054d29e4 mysqld`THD::send_result_metadata(this=0x000000013a809600, list=0x00000001409b1ff8, flags=5) at sql_class.cc:2834:13
    frame #1: 0x000000010538f780 mysqld`Query_result_send::send_result_set_metadata(this=0x00000001409b3988, thd=0x000000013a809600, list=0x00000001409b1ff8, flags=5) at query_result.cc:70:20
    frame #2: 0x0000000105789e00 mysqld`Query_expression::ExecuteIteratorQuery(this=0x00000001409b1850, thd=0x000000013a809600) at sql_union.cc:1207:21
    frame #3: 0x000000010578a790 mysqld`Query_expression::execute(this=0x00000001409b1850, thd=0x000000013a809600) at sql_union.cc:1343:10
    frame #4: 0x00000001056a5b28 mysqld`Sql_cmd_dml::execute_inner(this=0x00000001409b3950, thd=0x000000013a809600) at sql_select.cc:786:15
    frame #5: 0x00000001056a4d84 mysqld`Sql_cmd_dml::execute(this=0x00000001409b3950, thd=0x000000013a809600) at sql_select.cc:586:7
    frame #6: 0x00000001055f957c mysqld`mysql_execute_command(thd=0x000000013a809600, first_level=true) at sql_parse.cc:4604:29
    frame #7: 0x00000001055f1258 mysqld`dispatch_sql_command(thd=0x000000013a809600, parser_state=0x000000016cb1d7a8) at sql_parse.cc:5239:19
    frame #8: 0x00000001055ed234 mysqld`dispatch_command(thd=0x000000013a809600, com_data=0x000000016cb1ee40, command=COM_QUERY) at sql_parse.cc:1959:7
    frame #9: 0x00000001055ef814 mysqld`do_command(thd=0x000000013a809600) at sql_parse.cc:1362:18
    frame #10: 0x00000001058d329c mysqld`handle_connection(arg=0x00006000032dc000) at connection_handler_per_thread.cc:302:13
    frame #11: 0x000000010755caa0 mysqld`pfs_spawn_thread(arg=0x00000001138041f0) at pfs.cc:2942:3
    frame #12: 0x0000000182d97034


(lldb) bt
* thread #41, name = 'connection', stop reason = breakpoint 3.1
  * frame #0: 0x0000000102e0b87c mysqld`Query_result_send::send_data(this=0x000000013a4edd40, thd=0x000000011500ca00, items=0x000000013a4f6d80) at query_result.cc:97:3
    frame #1: 0x0000000103206314 mysqld`Query_expression::ExecuteIteratorQuery(this=0x000000014300d050, thd=0x000000011500ca00) at sql_union.cc:1305:25
    frame #2: 0x0000000103206790 mysqld`Query_expression::execute(this=0x000000014300d050, thd=0x000000011500ca00) at sql_union.cc:1343:10
    frame #3: 0x0000000103121b28 mysqld`Sql_cmd_dml::execute_inner(this=0x000000014300dba0, thd=0x000000011500ca00) at sql_select.cc:786:15
    frame #4: 0x0000000103120d84 mysqld`Sql_cmd_dml::execute(this=0x000000014300dba0, thd=0x000000011500ca00) at sql_select.cc:586:7
    frame #5: 0x000000010313fdfc mysqld`Sql_cmd_show::execute(this=0x000000014300dba0, thd=0x000000011500ca00) at sql_show.cc:207:26
    frame #6: 0x000000010307557c mysqld`mysql_execute_command(thd=0x000000011500ca00, first_level=true) at sql_parse.cc:4604:29
    frame #7: 0x000000010306d258 mysqld`dispatch_sql_command(thd=0x000000011500ca00, parser_state=0x000000016f0a17a8) at sql_parse.cc:5239:19
    frame #8: 0x0000000103069234 mysqld`dispatch_command(thd=0x000000011500ca00, com_data=0x000000016f0a2e40, command=COM_QUERY) at sql_parse.cc:1959:7
    frame #9: 0x000000010306b814 mysqld`do_command(thd=0x000000011500ca00) at sql_parse.cc:1362:18
    frame #10: 0x000000010334f29c mysqld`handle_connection(arg=0x00006000029d0000) at connection_handler_per_thread.cc:302:13
    frame #11: 0x0000000104fd8aa0 mysqld`pfs_spawn_thread(arg=0x0000000114e04f10) at pfs.cc:2942:3
    frame #12: 0x0000000182d97034



* thread #41, name = 'connection', stop reason = breakpoint 1.1
  * frame #0: 0x00000001015fe9e4 mysqld`THD::send_result_metadata(this=0x000000011a809600, list=0x00000001709f0658, flags=2) at sql_class.cc:2834:13
    frame #1: 0x00000001017f8e48 mysqld`mysqld_list_fields(thd=0x000000011a809600, table_list=0x00000001709f1be8, wild="") at sql_show.cc:1404:12
    frame #2: 0x0000000101719ef0 mysqld`dispatch_command(thd=0x000000011a809600, com_data=0x00000001709f2e40, command=COM_FIELD_LIST) at sql_parse.cc:2136:7
    frame #3: 0x000000010171b814 mysqld`do_command(thd=0x000000011a809600) at sql_parse.cc:1362:18
    frame #4: 0x00000001019ff29c mysqld`handle_connection(arg=0x0000600003694000) at connection_handler_per_thread.cc:302:13
    frame #5: 0x0000000103688aa0 mysqld`pfs_spawn_thread(arg=0x000000011d704370) at pfs.cc:2942:3
    frame #6: 0x0000000182d97034
```

结果集由一系列数据包组成
- 说明字段个数的数据包，它表示结果集中的字段数。
- 一组字段描述数据包
- EOF packet
- 实际的数据，一个数据一个packet
- EOF packet

4.1以后版本：

| Length | Description                                                                                                                                                                                                                                                                           |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 4      | Data field (see the section “Data Field,” earlier in this chapter) containing the ASCII string `def`.                                                                                                                                                                                 |
| Varies | Database name of the field in the data field format.                                                                                                                                                                                                                                  |
| Varies | Table name of the field in the data field format. If the table was aliased in the query, contains the name of the alias.                                                                                                                                                              |
| Varies | Table name of the field in the data field format. If the table was aliased in the query, contains the original name of the table.                                                                                                                                                     |
| Varies | Column name of the field in the data field format. If the column was aliased in the query, contains the name of the alias.                                                                                                                                                            |
| Varies | Column name of the field in the data field format. If the column was aliased in the query, contains the original name of the table.                                                                                                                                                   |
| 1      | Byte containing decimal 12, meaning that 12 bytes of data follow. The idea is to make the sequence look like a standard data field.                                                                                                                                                   |
| 2      | Character set code of the field (low byte first).                                                                                                                                                                                                                                     |
| 4      | Field length (low byte first).                                                                                                                                                                                                                                                        |
| 1      | Type code of the field according to enum `field_types` in _include/mysql_com.h_.                                                                                                                                                                                                      |
| 2      | Bit mask of field option flags (low byte first). See [Table 4-13](https://www.oreilly.com/library/view/understanding-mysql-internals/0596009577/ch04.html#orm9780596009571-CHP-4-TABLE-13 "Table 4-13. Option flags in server’s result set packets") for the explanation of the bits. |
| 1      | Decimal-point precision of field values.                                                                                                                                                                                                                                              |
| 2      | Reserved.                                                                                                                                                                                                                                                                             |
| Varies | Optional element. If present, contains the default value of the field in the standard field data format.                                                                                                                                                                              |

数据集的选项标志：

|Bit macro|Hexadecimal bit value|Description|
|---|---|---|
|`NOT_NULL_FLAG`|0x0001|The field value cannot be `NULL` (it is declared with the `NOT NULL` attribute).|
|`PRI_KEY_FLAG`|0x0002|The field is a part of the primary key.|
|`UNIQUE_KEY_FLAG`|0x0004|The field is a part of a unique key.|
|`MULTIPLE_KEY_FLAG`|0x0008|The field is a part of some non-unique key.|
|`BLOB_FLAG`|0x0010|The field is a `BLOB` or `TEXT`.|
|`UNSIGNED_FLAG`|0x0020|The field was declared with the `UNSIGNED` attribute, which has the same meaning as the `unsigned` keyword in C.|
|`ZEROFILL_FLAG`|0x0040|The field has been declared with the `ZEROFILL` attribute, which tells the server to pad the numeric types with leading zeros in the output to fit the specified field length.|
|`BINARY_FLAG`|0x0080|The field has been declared with the `BINARY` attribute, which tells the server to compare strings byte-for-byte in a case-sensitive manner.|
|`ENUM_FLAG`|0x0100|The field is an `ENUM`.|
|`AUTO_INCREMENT_FLAG`|0x0200|The field has been declared with the `AUTO_INCREMENT` attribute, which enables the automatic generation of primary key values when a new record is inserted.|
|`TIMESTAMP_FLAG`|0x0400|The field is a timestamp.|
|`SET_FLAG`|0x0800|The field is a `SET`.|
|`NUM_FLAG`|0x8000|Used with cursors in version 4.1 to indicate that the field is numeric.|
