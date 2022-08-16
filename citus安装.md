# citus
 
```shell
#获取源
wget https://github.com/citusdata/citus/archive/refs/tags/v10.2.3.tar.gz --no-check-certificate

tar -xzvf v10.2.3.tar.gz
#导入配置
cd citus-10.2.3/
export PG_CONFIG=/usr/pgsql-13/bin/pg_config
#安装依赖
sudo yum -y install lz4-devel.x86_64
sudo yum -y install libzstd-devel
#配置安装项
./configure
#安装
make
make isntall
#初始化。、
su - postgres
cd ~
mkdir citus
pg_ctl -D citus initdb

#测试安装
pg_ctl -D citus -o "-p 9700" -l citus_logfile start
psql -p 9700 -c "CREATE EXTENSION citus;"
psql -p 9700 -c "select citus_version();"
```

## 常见错误
- wget: unable to resolve host address ‘github.com’
	参照[[修改dns]]
## 参考链接
- https://docs.citusdata.com/en/v10.2/installation/single_node_rhel.html
- http://citusdb.cn/?p=257