```sql
create server pg_server foreign data wrapper postgres_fdw options( host '192.168.223.129' , port '5432', dbname 'postgres');
```
```sql
create user mapping for current_user server pg_server options(user 'postgres', password '123456');
```
