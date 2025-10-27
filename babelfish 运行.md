```sql
init的时候创建一个mssql模式的库，加init选项：--dbcompatibility=MSSQL
create database test; \c test
drop schema sys cascade;
create extension "uuid-ossp";
create schema msdb_dbo;
create schema master_dbo;
create role sysadmin with password 'Aa123456';
create extension babelfishpg_money;
create extension babelfishpg_common;
create extension babelfishpg_tsql;

babelfishpg_tsql.sql_dialect = 'tsql'

```


1. 请总结论述技能看板内容，并做雷达图（右键点击雷达图编辑表格）
2. 请在答辩前提前打开OA个人档案，以便与答辩官现场交流
3. 以上文字为提示，不必在ppt中展示



