# xugu
#### jdbc_fdw 使用
```sql
create server xugu_server foreign data wrapper jdbc_fdw options(
drivername 'com.xugu.cloudjdbc.Driver',
url 'jdbc:xugu://172.22.7.112:5138/SYSTEM',
querytimeout '100',
jarfile '/root/zzly/jdbc/cloudjdbc-1.3.16.jar',
maxheapsize '600'
);


CREATE USER MAPPING FOR CURRENT_USER SERVER xugu_server OPTIONS(username 'SYSDBA',password 'SYSDBA');

create foreign table cf_tt01(id int, name varchar) server xugu_server options(table_name 'tt01');
```

***jar包必须可以被postgres用户访问***