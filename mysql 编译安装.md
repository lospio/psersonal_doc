```bash
sudo cmake ../mysql-server -DBUILD_CONFIG=mysql_release -DWITH_DEBUG=1 -DCPACK_MONOLITHIC_INSTALL=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/var/lib -DWITH_SSL=//usr/local/openssl -DBISON_EXECUTABLE=/opt/homebrew/Cellar/bison/3.8.2/bin/bison



./mysqld-debug --basedir=/Users/juneszn/Desktop/work/project/mysql-server/bld/bin --datadir=/Users/juneszn/Desktop/work/project/mysql-server/bld/data --initialize-insecure --user=mysql
```