
```shell
./configure --prefix=/home/postgres --with-gdalconfig=/usr/gdal34/bin/gdal-config --with-pgconfig=/usr/pgsql/10_debug_o2/bin/pg_config --with-geosconfig=/usr/local/bin/geos-config --with-projdir=/usr/proj80 --with-xml2config=/usr/local/bin/xml2-config --with-protobufdir=/usr/local/protobuf-3.19.4 --without-protobuf

```

```sql
--修改srid
select updategeometrysrid('mv_station_info','point',4326);
```


## yum安装
```bash
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install postgis25_12

```