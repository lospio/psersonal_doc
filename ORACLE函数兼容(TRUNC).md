## 01. 需求分析
### 官方文档
Oracle Database 11g Release 2 (11.2):
- [TRUNC (date)](https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions220.htm#SQLRF06151)
- [TRUNC(number)](https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions221.htm#SQLRF06150)


MySQL 8.0:
- [TRUNCATE(X,D)](https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_truncate)
### ORACLE 中的 `TRUNC`函数
#### trunc_number:
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/trunc_number.gif)
`TRUNC（number）`函数返回 n1 截断至 n2 位的小数。

| 参数  |      |解释                                                                                            |
| ------ | :----: | :----------------------------------------------------------------------------------------------- |
| $\mathrm{n1}$     | 必须 | 任何数值数据类型或任何可隐式转换为数值数据类型的非数值数据类型                                  |
| $\mathrm{n2}$     | 可选 | 任何数值数据类型或任何可隐式转换为数值数据类型的非数值数据类型作为参数                          |
| 返回值 |      | 如果省略 $\mathrm{n2}$，则该函数返回与参数的数值数据类型相同的数据类型。如果包含 $\mathrm{n2}$，则该函数返回 $\mathrm{NUMBER}$。 |
 
对 n2 参数说明:
- 若 n2 省略,则将 n1 截断至 0 位(不含小数位)
- 若 n2 >= 0,将 n1 截断至 n2 位小数
- 若n2 < 0, 将n1 截断小数点左侧的 n 位

```sql
SQL> select trunc(1111.1111) from dual;

TRUNC(1111.1111)
----------------
	    1111

SQL> select trunc(1111.1111,1) from dual;

TRUNC(1111.1111,1)
------------------
	    1111.1

SQL> select trunc(1111.1111,2) from dual;

TRUNC(1111.1111,2)
------------------
	   1111.11

SQL> select trunc(1111.1111,-1) from dual;

TRUNC(1111.1111,-1)
-------------------
	       1110

SQL> select trunc(1111.1111,-2) from dual;

TRUNC(1111.1111,-2)
-------------------
	       1100
```

```sql
SQL> select trunc(5555.5555) from dual;

TRUNC(5555.5555)
----------------
	    5555

SQL> select trunc(5555.5555,1) from dual;

TRUNC(5555.5555,1)
------------------
	    5555.5

SQL> select trunc(5555.5555,2) from dual;

TRUNC(5555.5555,2)
------------------
	   5555.55

SQL> select trunc(5555.5555,-1) from dual;

TRUNC(5555.5555,-1)
-------------------
	       5550

SQL> select trunc(5555.5555,-2) from dual;

TRUNC(5555.5555,-2)
-------------------
	       5500
```

```sql
SQL> select trunc(5555.5555,-5) from dual;

TRUNC(5555.5555,-5)
-------------------
		  0

SQL> select trunc(5555.5555,-4) from dual;

TRUNC(5555.5555,-4)
-------------------
		  0

SQL> select trunc(5555.5555,5) from dual;

TRUNC(5555.5555,5)
------------------
	 5555.5555

SQL> select trunc(5555.5555,6) from dual;

TRUNC(5555.5555,6)
------------------
	 5555.5555
```

```sql
SQL> select trunc(1E+126) from dual;
select trunc(1E+126) from dual
             *
ERROR at line 1:
ORA-01426: numeric overflow
```
#### trunc_date:
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/trunc_date.gif)
`TRUNC（date）`函数返回日期，其中一天中的时间部分被截断为格式模型 fmt 指定的单位

|   参数 |      | 解释             |
| ------:| ---- |:---------------- |
| $date$ | 必须 | 日期时间数据类型 |
|  $fmt$ | 可选 |  默认值$'DD'$                |
| 返回值       |      | $DATE$ 数据类型                 |

| 日期格式                         | 说明                                                |
| -------------------------------- |:-------------------------------------------------------- |
| $CC,SCC$                         | 截断至日期所在世纪的第一天                           |
| $SYYYY,YYYY,YEAR,SYEAR,YYY,YY,Y$ | 截断至日期所在年的第一天                                |
| $IYYY,IYY,IY,I$                  | 截断至日期所在 $ISO$ 年的第一天                   |
| $Q$                              | 截断至日期所在季的第一天                 |
| $MONTH,MON,MM,RM$                | 截断至日期所在月的第一天                                 |
| $WW$                             | 截断至与日期所在年第一天(1月1日)星期数相同的最近日期                       |
| $IW$                             | 截断至日期所在星期(ISO)第一天 **(周一)** |
| $W$                              | 往回截断至与日期所在月第一天(1日)星期数相同的最近日期                         |
| $DDD,DD,J$                       | 截断至当日凌晨 $00:00:00$                                                      |
| $DAY,DY,D$                       | 截断至日期所在星期第一天 **(周日）**                                           |
| $HH,HH12,HH24$                   | 截断至日期所在小时起始(分、秒等归零)                                                     |
| $MI$                                 |       截断至日期所在分钟起始(秒、微秒等归零)                                                   |

日期格式 `DAY、DY 和 D` 使用的一周的开始日期由初始化参数 `NLS_TERRITORY 隐式指定

```sql
SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'SCC') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'CC') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'SYYYY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'YYYY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'YEAR') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'SYEAR') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'YYY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'YY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'Y') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'IYYY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'IYY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'IY') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'I') "date"  from dual;

date
-------------------
2001-01-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'Q') "date"  from dual;

date
-------------------
2001-10-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'MONTH') "date"  from dual;

date
-------------------
2001-10-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'MON') "date"  from dual;

date
-------------------
2001-10-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'MM') "date"  from dual;

date
-------------------
2001-10-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'RM') "date"  from dual;

date
-------------------
2001-10-01 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'WW') "date"  from dual;

date
-------------------
2001-10-22 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'IW') "date"  from dual;

date
-------------------
2001-10-22 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'W') "date"  from dual;

date
-------------------
2001-10-22 00:00:00


SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'DDD') "date"  from dual;

date
-------------------
2001-10-27 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'DD') "date"  from dual;

date
-------------------
2001-10-27 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'J') "date"  from dual;

date
-------------------
2001-10-27 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'DAY') "date"  from dual;

date
-------------------
2001-10-21 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'DY') "date"  from dual;

date
-------------------
2001-10-21 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001','DD-MON-YYYY'), 'D') "date"  from dual;

date
-------------------
2001-10-21 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001 13:23:35','DD-MON-YYYY HH24:MI:ss'), 'D') "date"  from dual;

date
-------------------
2001-10-21 00:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001 13:23:35','DD-MON-YYYY HH24:MI:ss'), 'HH') "date"  from dual;

date
-------------------
2001-10-27 13:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001 13:23:35','DD-MON-YYYY HH24:MI:ss'), 'HH12') "date"  from dual;

date
-------------------
2001-10-27 13:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001 13:23:35','DD-MON-YYYY HH24:MI:ss'), 'HH24') "date"  from dual;

date
-------------------
2001-10-27 13:00:00

SQL> SELECT TRUNC(TO_DATE('27-OCT-2001 13:23:35','DD-MON-YYYY HH24:MI:ss'), 'MI') "date"  from dual;

date
-------------------
2001-10-27 13:23:00
```

```sql
mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'SCC') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'CC') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'SYYYY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'YYYY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'YYY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'YY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'Y') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'IYYYY') date  from dual;
+------+
| date |
+------+
| NULL |
+------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'IYYY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'IYY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'IY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'I') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-01-01 00:00:00 |
+---------------------+
1 row in set (0.01 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'Q') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'MONTH') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'MON') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-01 00:00:00 |
+---------------------+
1 row in set (0.01 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'MM') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'RM') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-01 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql>
mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'WW') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-22 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'IW') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-22 00:00:00 |
+---------------------+
1 row in set (0.01 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'W') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-22 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'DD') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-27 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'J') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-27 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'DAY') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-21 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001','%d-%m-%Y'),'D') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-21 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %h:%i:%s'),'D') date  from dual;
+------+
| date |
+------+
| NULL |
+------+
1 row in set, 1 warning (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %24h:%i:%s'),'D') date  from dual;
+------+
| date |
+------+
| NULL |
+------+
1 row in set, 1 warning (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %h24:%i:%s'),'D') date  from dual;
+------+
| date |
+------+
| NULL |
+------+
1 row in set, 1 warning (0.00 sec)

mysql>  
+---------------------+
| date                |
+---------------------+
| 2001-10-21 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %H:%i:%s'),'D') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-21 00:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %H:%i:%s'),'HH') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-27 13:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %H:%i:%s'),'HH12') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-27 13:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %H:%i:%s'),'HH24') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-27 13:00:00 |
+---------------------+
1 row in set (0.00 sec)

mysql> select trunc(str_to_date('27-10-2001 13:23:35','%d-%m-%Y %H:%i:%s'),'MI') date  from dual;
+---------------------+
| date                |
+---------------------+
| 2001-10-27 13:23:00 |
+---------------------+
1 row in set (0.00 sec)
```


```sql
mysql> select truncate(1111.1111) ;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ')' at line 1
mysql> select truncate(1111.1111,1) ;
+-----------------------+
| truncate(1111.1111,1) |
+-----------------------+
|                1111.1 |
+-----------------------+
1 row in set (0.00 sec)

mysql> select truncate(1111.1111,2) ;
+-----------------------+
| truncate(1111.1111,2) |
+-----------------------+
|               1111.11 |
+-----------------------+
1 row in set (0.00 sec)

mysql> select truncate(1111.1111,3) ;
+-----------------------+
| truncate(1111.1111,3) |
+-----------------------+
|              1111.111 |
+-----------------------+
1 row in set (0.00 sec)

mysql> select truncate(1111.1111,-1) ;
+------------------------+
| truncate(1111.1111,-1) |
+------------------------+
|                   1110 |
+------------------------+
1 row in set (0.00 sec)

mysql> select truncate(1111.1111,-2) ;
+------------------------+
| truncate(1111.1111,-2) |
+------------------------+
|                   1100 |
+------------------------+
1 row in set (0.00 sec)

mysql> select truncate(5555.5555) ;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ')' at line 1
mysql> select truncate(5555.5555,1) ;
+-----------------------+
| truncate(5555.5555,1) |
+-----------------------+
|                5555.5 |
+-----------------------+
1 row in set (0.00 sec)

mysql> select truncate(5555.5555,2) ;
+-----------------------+
| truncate(5555.5555,2) |
+-----------------------+
|               5555.55 |
+-----------------------+
1 row in set (0.00 sec)

mysql> select truncate(5555.5555,-1) ;
+------------------------+
| truncate(5555.5555,-1) |
+------------------------+
|                   5550 |
+------------------------+
1 row in set (0.00 sec)

mysql> select truncate(5555.5555,-2) ;
+------------------------+
| truncate(5555.5555,-2) |
+------------------------+
|                   5500 |
+------------------------+
1 row in set (0.00 sec)

```
#  问题
### trunc(number)
1. 对于 trunc(decimal,decimal),oracle 会对第二个参数截断处理,mysql 会做 round
2. 
	```sql
	-1.235E+10	  123	-1.235E+10
	-1.235E+10	   -9	-1.200E+10 数据被截断
	```
3. 0000 0001  支持
4. 不支持的月数 天数报错
5. 不支持的 format 报错