## PostgreSQL打包
```shell
# 在exec目录下打包
cd /usr/pgsql-13
tar -zcvf pgsql-13.tar.gz ./
```
## PostgreSQL部署
```shell
su - root


#将安装包放置执行文件目录 推荐 /usr/pgsql-13
cd /usr
mkdir pgsql-13
cd pgsql-13
#拷贝安装包 scp root@192.168.182.139:/usr/pgsql-13/pgsql-13.tar.gz ./
tar -xzvf pgsql-13.tar.gz

#添加用户
groupadd postgres
useradd -g postgres postgres
chown -R postgres:postgres /usr/pgsql-13
mkdir /var/lib/pgsql
chown -R postgres:postgres /var/lib/pgsql
mkdir /var/run/postgresql
chown -R postgres:postgres /var/run/postgresql
passwd postgres
#输入密码

#切换用户
su - postgres

#配置环境变量
vi ~/.bash_profile

#修改path
PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/pgsql-13/bin
#添加变量
export LD_LIBRARY_PATH=/usr/pgsql-13/lib
export PGDATA=/var/lib/pgsql/13/data

#修改生效EX
source ~/.bash_profile

#初始化
/usr/pgsql-13/bin/./initdb -D /var/lib/pgsql/13/data

#配置log
vi $PG_DATA/postgresql.conf
#找到loggging_collector# This is used when logging to stderr:
logging_collector = on                  # Enable capturing of stderr and csvlog
                                        # into log files. Required to be on for
                                        # csvlogs.
                                        # (change requires restart)
# These are only used if logging_collector is on:
log_directory = 'log'                   # directory where log files are written,
                                        # can be absolute or relative to PGDATA
log_filename = 'postgresql-%a.log'      # log file name pattern,

#启动数据库
pg_ctl -D $PG_DATA start


```
## PG更新
替换exec_dir/bin/postgres文件