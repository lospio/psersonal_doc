#### 安装gcc
```bash
yum install centos-release-scl -y
yum install devtoolset-9 -y
scl enable devtoolset-9 bash
```
#### pg编译依赖
```shell
yum install -y perl-ExtUtils-Embed readline-devel zlib-devel pam-devel libxml2-devel libxslt-devel openldap-devel python-devel  openssl-devel cmake make
```
```shell
yum install -y libuuid-devel systemd-devel tcl-devel perl-IPC-Run pam-devel gettext-devel libicu-devel python3 python3-debug bison flex
```
#### postgis
- rpm 解压 `rpm2cpio xxx.rpm | cpio -div`
[centos7安装](https://computingforgeeks.com/how-to-install-postgis-on-centos-7/)
[centos8安装](https://people.planetpostgresql.org/devrim/index.php?/archives/107-Installing-PostGIS-3.1-and-PostgreSQL-13-on-CentOS-8.html)