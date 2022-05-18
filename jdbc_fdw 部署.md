
```shell
cp JDBCDriverLoader.class /usr/pgsql/10_debug_o2/lib
cp JDBCUtils.class /usr/pgsql/10_debug_o2/lib
/bin/mkdir -p /usr/pgsql/10_debug_o2/lib
/bin/mkdir -p /usr/pgsql/10_debug_o2/share/extension
/bin/install -c -m 755  jdbc_fdw.so /usr/pgsql/10_debug_o2/lib/jdbc_fdw.so
/bin/install -c -m 644 jdbc_fdw.control /usr/pgsql/10_debug_o2/share/extension/
/bin/install -c -m 644 jdbc_fdw--1.0.sql  /usr/pgsql/10_debug_o2/share/extension/
```

```shell
cp -p /usr/lib/spatial/postgresql-10/lib/JDBCDriverLoader.class ./
cp -p /usr/lib/spatial/postgresql-10/lib/JDBCUtils.class ./
cp -p /usr/lib/spatial/postgresql-10/lib/resultSetInfo.class ./
cp -p /usr/lib/spatial/postgresql-10/lib/jdbc_fdw.so ./
cp -p /usr/lib/spatial/postgresql-10/share/extension/jdbc_fdw.control ./
cp -p /usr/lib/spatial/postgresql-10/share/extension/jdbc_fdw--1.0.sql ./
```

```shell
cp JDBCDriverLoader.class /usr/lib/spatial/postgresql-10/lib
cp *.class /usr/lib/spatial/postgresql-10/lib
cp JDBCUtils.class /usr/lib/spatial/postgresql-10/lib
/bin/mkdir -p /usr/lib/spatial/postgresql-10/lib
/bin/mkdir -p /usr/lib/spatial/postgresql-10/share/extension
/bin/install -c -m 755 jdbc_fdw.so /usr/lib/spatial/postgresql-10/lib/jdbc_fdw.so
/bin/install -c -m 644 jdbc_fdw.control /usr/lib/spatial/postgresql-10/share/extension/
/bin/install -c -m 644 jdbc_fdw--1.0.sql /usr/lib/spatial/postgresql-10/share/extension/
```
# ***不同环境pklibdir不同，需要按需配置***