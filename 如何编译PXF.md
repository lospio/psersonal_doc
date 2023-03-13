---
ctime: 2023-02-13 18:13
tags: simlpe-card
author: lche
alias: 
---
#Greenplum #vault-squirreldoc 
- root 用户执行
```shell
yum install maven
yum install go
yum install libcurl-devel
yum install rpm-build
yum install greenplum-db-6.19.1-rhel7-x86_64.rpm 
```

- 编译用户执行
```shell
go env -w GOPROXY=https://goproxy.cn
go install github.com/onsi/ginkgo/ginkgo@v1.16.5
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
go install github.com/onsi/ginkgo/ginkgo@v1.16.5

make rpm
```
## 参考
- https://github.com/greenplum-db/pxfhttps://github.com/greenplum-db/pxf