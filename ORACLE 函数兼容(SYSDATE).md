## 01.需求分析
### 官方文档
Oracle Database 11g Release 2 (11.2):
- [SYSDATE](https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions191.htm#SQLRF06124)

MySQL 8.0:
- [SYSDATE([fsp])](https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html#function_sysdate)

### ORACLE 中的`SYSDATE` 函数
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/sysdate.gif)

| 参数 |     | 解释 |
| ---- | --- | ---- |
| 返回值     |     |返回值类型为 `DATE` 为数据库服务器所在的操作系统设置的当前日期和时间。      |

该函数不需要参数。在分布式 SQL 语句中，此函数返回为本地数据库的操作系统设置的日期和时间。不能在 CHECK 约束条件下使用此函数。

```sql
SQL> select sysdate,sysdate from dual;

SYSDATE   SYSDATE
--------- ---------
30-AUG-23 30-AUG-23

SQL> select sysdate,sysdate() from dual;
select sysdate,sysdate() from dual
                      *
ERROR at line 1:
ORA-00923: FROM keyword not found where expected

SQL> select   to_char (SYSDATE, 'MM-DD-YYYY HH24:MI:SS') "NOW" from dual;

NOW
-------------------
08-30-2023 15:32:24
```

### MySQL 8.0 中的`SYSDATE([fsp])` 函数
SYSDATE() 返回它执行的时间。这与 NOW() 的行为不同，NOW() 返回一个常量时间，指示语句开始执行的时间。

 返回值类型:
 - string:以“YYYY-MM-DD hh:mm:ss 格式的值返回当前日期和时间
 - numeric: 以 YYYYMMDDhhmmss 格式的值返回当前日期和时间

如果给定 fsp 参数来指定从 0 到 6 的小数秒精度，则返回值包括该多个数字的小数秒部分

```sql
mysql> SELECT SYSDATE(), SLEEP(2), SYSDATE();
+---------------------+----------+---------------------+
| SYSDATE()           | SLEEP(2) | SYSDATE()           |
+---------------------+----------+---------------------+
| 2023-08-30 15:43:12 |        0 | 2023-08-30 15:43:14 |
+---------------------+----------+---------------------+
1 row in set (2.01 sec)

mysql> select sysdate();
+---------------------+
| sysdate()           |
+---------------------+
| 2023-08-30 15:43:35 |
+---------------------+
1 row in set (0.00 sec)

mysql> select sysdate(0);
+---------------------+
| sysdate(0)          |
+---------------------+
| 2023-08-30 15:43:37 |
+---------------------+
1 row in set (0.00 sec)

mysql> select sysdate(1);
+-----------------------+
| sysdate(1)            |
+-----------------------+
| 2023-08-30 15:43:40.5 |
+-----------------------+
1 row in set (0.01 sec)

mysql> select sysdate(2);
+------------------------+
| sysdate(2)             |
+------------------------+
| 2023-08-30 15:43:42.01 |
+------------------------+
1 row in set (0.00 sec)

mysql> select sysdate(3);
+-------------------------+
| sysdate(3)              |
+-------------------------+
| 2023-08-30 15:43:43.943 |
+-------------------------+
1 row in set (0.00 sec)

mysql> select sysdate(4);
+--------------------------+
| sysdate(4)               |
+--------------------------+
| 2023-08-30 15:43:45.4084 |
+--------------------------+
1 row in set (0.00 sec)

mysql> select sysdate(5);
+---------------------------+
| sysdate(5)                |
+---------------------------+
| 2023-08-30 15:43:47.26439 |
+---------------------------+
1 row in set (0.00 sec)

mysql> select sysdate(6);
+----------------------------+
| sysdate(6)                 |
+----------------------------+
| 2023-08-30 15:43:49.687997 |
+----------------------------+
1 row in set (0.00 sec)

mysql> select sysdate(-1);
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '-1)' at line 1
mysql> select sysdate(7);
ERROR 1426 (42000): Too-big precision 7 specified for 'sysdate'. Maximum is 6.
```

