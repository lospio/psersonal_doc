# 01. 需求分析
### 官方文档
Oracle Database 11g Release 2 (11.2):
- [SYS_GUID()](https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions187.htm#SQLRF06120)

MySQL 8.0:
- [UUID()](https://dev.mysql.com/doc/refman/8.0/en/miscellaneous-functions.html#function_uuid)
- [UUID_SHORT()](https://dev.mysql.com/doc/refman/8.0/en/miscellaneous-functions.html#function_uuid-short)

### Oralce 中的 SYS_GUID() 函数
![](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/sys_guid.gif)
SYS_GUID 生成并返回由 16 个字节组成的全局唯一标识符（RAW 值）。在大多数平台上，生成的标识符由主机标识符、调用该函数的进程或线程的进程或线程标识符以及该进程或线程的非重复值（字节序列）组成。

```sql
create table tt01 (id int , uid1 raw(16));
insert into tt01(id) values(1);
insert into tt01(id) values(2);
insert into tt01(id) values(3);
insert into tt01(id) values(4);
update tt01 set uid1 = sys_guid() ;
select * from tt01;
```

|ID|UID1|
|---|---|
|1|0393DD9DBF8E2444E063410EA8C02BF0|
|2|0393DD9DBF8F2444E063410EA8C02BF0|
|3|0393DD9DBF902444E063410EA8C02BF0|
|4|0393DD9DBF912444E063410EA8C02BF0|


### MySQL 中的 UUID()函数
返回根据 RFC 4122“通用唯一标识符 (UUID) URN 命名空间”生成的通用唯一标识符 (UUID).该值是一个 128 位数字，表示为 5 个十六进制数字的 utf8mb3 字符串，格式为 aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeeeee

```sql
create table tt01(id int ,uid1 varchar(36));
insert into tt01(id) values(1);
insert into tt01(id) values(2);
insert into tt01(id) values(3);
insert into tt01(id) values(4);
update tt01 set uid1 = uuid() ;
select * from tt01;

mysql> select * from tt01;
+------+--------------------------------------+
| id   | uid1                                 |
+------+--------------------------------------+
|    1 | 10c37274-4191-11ee-81b0-397bba36deb8 |
|    2 | 10c3dfa2-4191-11ee-81b0-397bba36deb8 |
|    3 | 10c41846-4191-11ee-81b0-397bba36deb8 |
|    4 | 10c44e74-4191-11ee-81b0-397bba36deb8 |
+------+--------------------------------------+
4 rows in set (0.00 sec)
```

```sql
create table tt01(id int ,uid1 varchar(32));
insert into tt01(id) values(1);
insert into tt01(id) values(2);
insert into tt01(id) values(3);
insert into tt01(id) values(4);
update tt01 set uid1 = uuid() ;
select * from tt01;

mysql> select * from tt01;
+------+----------------------------------+
| id   | uid1                             |
+------+----------------------------------+
|    1 | 92a776a6419011ee0a75f0bb3aef0137 |
|    2 | 92a7d862419011ee0a75f0bb3aef0137 |
|    3 | 92a7f1ee419011ee0a75f0bb3aef0137 |
|    4 | 92a8146c419011ee0a75f0bb3aef0137 |
+------+----------------------------------+
4 rows in set (0.01 sec)
```

```sql
create table tt01(id int ,uid1 varbinary(16));
insert into tt01(id) values(1);
insert into tt01(id) values(2);
insert into tt01(id) values(3);
insert into tt01(id) values(4);
update tt01 set uid1 = sys_guid() ;
select * from tt01;

mysql> select * from tt01;
+------+----------------------------------+
| id   | uid1                             |
+------+----------------------------------+
|    1 | 92a776a6419011ee0a75f0bb3aef0137 |
|    2 | 92a7d862419011ee0a75f0bb3aef0137 |
|    3 | 92a7f1ee419011ee0a75f0bb3aef0137 |
|    4 | 92a8146c419011ee0a75f0bb3aef0137 |
+------+----------------------------------+
4 rows in set (0.01 sec)
```
# 02. 规格说明
# 03. 功能实现
