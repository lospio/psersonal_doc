```shell
CPPFLAGS=-I/usr/proj80/include LDFLAGS=-L/usr/proj80/lib ./configure
```

```shell
./configure --with-pgconfig=/usr/pgsql/13_clean/bin/pg_config \
--with-geosconfig=/share/geos-3.10.2/tools/geos-config \
--with-protobuf-inc=/usr/include/protobuf-c \
--with-protobufdir=/usr/local/protobuf-3.19.4 \
--with-protobuf-lib=/usr/local/protobuf-3.19.4/lib \
--with-gdalconfig=/download/gdal-3.4.1/bin/gdal-config \
--with-projdir=/usr/proj80
```

```shell
./configure --prefix=/home/postgres \
--with-gdalconfig=/usr/gdal34/bin/gdal-config \
--with-pgconfig=/usr/pgsql/13_clean/bin/pg_config \
--with-geosconfig=/usr/local/bin/geos-config \
--with-projdir=/usr/proj80 \
--with-xml2config=/usr/local/bin/xml2-config \
#--with-jsondir=/usr/local/json-c-0.13.1 \
--with-protobufdir=/usr/local/protobuf-3.19.4 \
--without-protobuf
#--with-sfcgal=/usr/local/sfcgal-1.3.7/bin/sfcgal-config
```


