
# openGauss
```sql
create table tt01 (a int primary key, b int unique, c int) partition by range(c)(partition p1 values less than (5000),partition p2 values less than (MAXVALUE));
```
# MySQL
```sql
SELECT   partition_name part,   partition_expression expr,   partition_description descr,   FROM_DAYS(partition_description) lessthan_sendtime,   table_rows FROM   INFORMATION_SCHEMA.partitions WHERE   TABLE_SCHEMA = SCHEMA() AND TABLE_NAME='rc';
```