# 01. Oracle
1. NULL 代表没有值或者包含 NULL 值:If a column in a row has no value, then the column is said to be null, or to contain null
2. 空字符串视为 NULL:Oracle Database treats a character value with a length of zero as null
3. Any arithmetic expression containing a null always evaluates to null
```sql
SQL> create table t2(a int, b char);

Table created.

SQL> insert into t2 values(1,' ');

1 row created.

SQL> insert into t2 values(2,'');

1 row created.

SQL> insert into t2 values(3,NULL);

1 row created.

SQL> select * from t2 where b is null;

	 A B
---------- -
	 2
	 3

SQL> select * from t2 where b is not null;

	 A B
---------- -
	 1

SQL> select * from t2 order by b;

	 A B
---------- -
	 1
	 3
	 2

SQL> select * from t2 order by b desc;

	 A B
---------- -
	 2
	 3
	 1

SQL> select * from t2 where b ='';

no rows selected

SQL> select * from t2 where b =' ';

	 A B
---------- -
	 1

SQL> select * from t2 where b  is null;

	 A B
---------- -
	 2
	 3

SQL> select * from t2 where b > NULL;

no rows selected

SQL> select * from t2 where b >  '';

no rows selected

SQL> select * from t2 where b =  '';

no rows selected
```
# 02.MySQL
1. 空字符串不为 NULL
2. NULL 参与的算数比较都为 NULL
3. 0和 NULL 视为 false;其余任何值都为 true
4. order by 的时候 ,desc 时 NULL 在最后, asc 时 NULL在最前
```sql
mysql> create table t2(a int, b char);
Query OK, 0 rows affected (0.11 sec)

mysql> insert into t2 values(1,'');
Query OK, 1 row affected (0.02 sec)

mysql> insert into t2 values(2,' ');
Query OK, 1 row affected (0.00 sec)

mysql> insert into t2 values(3,NULL);
Query OK, 1 row affected (0.00 sec)

mysql> select * from t2 where b = '';
+------+------+
| a    | b    |
+------+------+
|    1 |      |
|    2 |      |
+------+------+
2 rows in set (0.01 sec)

mysql> select * from t2 where b is null;
+------+------+
| a    | b    |
+------+------+
|    3 | NULL |
+------+------+
1 row in set (0.00 sec)

mysql> select * from t2 order by b;
+------+------+
| a    | b    |
+------+------+
|    3 | NULL |
|    1 |      |
|    2 |      |
+------+------+
3 rows in set (0.01 sec)


```