
```shell
cp JDBCDriverLoader.class /usr/pgsql/10_debug_o2/lib
cp JDBCUtils.class /usr/pgsql/10_debug_o2/lib
/bin/mkdir -p /usr/pgsql/10_debug_o2/lib
/bin/mkdir -p /usr/pgsql/10_debug_o2/share/extension
/bin/install -c -m 755  jdbc_fdw.so /usr/pgsql/10_debug_o2/lib/jdbc_fdw.so
/bin/install -c -m 644 jdbc_fdw.control /usr/pgsql/10_debug_o2/share/extension/
/bin/install -c -m 644 jdbc_fdw--1.0.sql  /usr/pgsql/10_debug_o2/share/extension/
```