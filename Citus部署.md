成都。## 打包
```shell
cd ~
mkdir citus_pkg
cd citus_pkg
# 头文件
cp -r /usr/pgsql-13/include/server/distributed/ ./distributed
cp  /usr/pgsql-13/include/server/citus_version.h ./
# so文件
cp  /usr/pgsql-13/lib/citus.so ./
# sql脚本,control文件
mkdir extension
cp  /usr/pgsql-13/share/extension/citus* ./extension
# 打包
tar -zcvf citus_pkg.tar.gz ./
# 拷贝
# scp -p citus_pkg.tar.gz root@192.168.182.143:/root/code
```
## 部署
```shell
su - root
# 安装依赖
sudo yum -y install epel-release 
sudo yum -y install libzstd-devel
# 获取文件
mkdir citus_pkg
cd citus_pkg
# scp -p root@192.168.182.143:/root/code/citus_pkg.tar.gz ./
tar -zxvf citus_pkg.tar.gz

# 拷贝文件 下述exec_dir 为/usr/pgsql-13/，根据环境自行替换
cp -r distributed /usr/pgsql-13/include/server
cp citus_version.h /usr/pgsql-13/include/server/
cp citus.so /usr/pgsql-13/lib/
cp extension/* /usr/pgsql-13/share/extension/
# 验证
su - postgres
cd ~
mkdir citus
pg_ctl -D citus initdb
echo "shared_preload_libraries = 'citus'" >> citus/postgresql.conf
pg_ctl -D citus -o "-p 9700" -l citus_logfile start
psql -p 9700 -c "CREATE EXTENSION citus;"
psql -p 9700 -c "select citus_version();"
```