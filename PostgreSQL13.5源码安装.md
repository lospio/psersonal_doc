f-个# CentOS7源码安装PostgreSQL13.5
## 一、 环境准备
-  CentOS 7.9
-  [PostgreSQL 13.5 官网下载链接](https://ftp.postgresql.org/pub/source/v13.5/postgresql-13.5.tar.gz)  下载`postgresql-13.5.tar.gz`这个包

## 二、 前提条件

要求OS上已经安装下述软件。如果没有，可以直接通过yum来安装

1. 编译工具gmake或者make要求至少3.80版本以上
![[Pasted image 20220118141045.png]]
2. C编译器
![[Pasted image 20220118141149.png]]
3. tar软件包
![[Pasted image 20220118141234.png]]
4. GNU readline library
	该库文件默认启用。用于在psql命令行工具下，可以通过键盘的上下箭头调出历史命令以及编辑之前的命令。如果不需要此功能的话，可以在configure的时候，带上–without-readline选项。类似Oracle中的rlwrap。
	报错：***error: readline library not found when Installing PostgreSQL***
      需要：`yum -y install readline-devel`
## 三、 源码安装
#### 1. 创建用户及组

`groupadd postgres
useradd -g postgres postgres
passwd postgres` 

#### 2. 创建数据库软件的安装路径

设定数据库软件安装在/usr/local/pgsql/路径下  
数据库的数据存放在/data/postgres/13.5/data路径下

这里，先把/data/postgres/13.5/路径创建出来即可，/data/postgres/13.5/data路径不需提前创建，届时初始化数据库的时候，会自动创建。

```shell
mkdir -p /data/postgres/13.5/
chown -R postgres:postgres /data/
```

#### 3. 将安装包上传到postgres家目录

下载好上传或者直接在服务器端wget下载


#### 4. 解压源码

	tar -xzvf postgresql-13.5.tar.gz 
	
#### 5. 执行configure


执行configure的命令行选项，–-prefix参数，表示把PostgreSQL安装在哪个路径下。默认情况下，不带该参数时，则会安装在/usr/local/pgsql路径下。

`--定位到解压文件`
`cd postgresql-13.5/`

`./configure`

#### 6.执行make world

`make world`

#### 7 .执行make install-world

`make install-world`

#### 8. 初始化数据库

`--切换用户`
`su - postgres`
`/usr/local/pgsql/bin/initdb -D /data/postgres/13.5/data`
![[Pasted image 20220118144719.png]]

#### 9. 启动数据库

`-- -l执行输出启动日志
/usr/local/pgsql/bin/pg_ctl -D /data/postgres/13.5/data -l logfile start`

#### 10. 修改环境变量

`vi ~/.bash_profile

--PATH添加 /usr/local/pgsql/bin
--添加PGDATA= /data/postgres/13.5/data

PGDATA=/data/postgres/13.5/data
PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/local/pgsql/bin
export PGDATA
export PATH

--生效 source ~/.bash_profile

`

### 四、删除数据库软件

使用postgres用户进入源码解压后的文件夹中，执行make uninstall命令进行卸载。

`make uninstall`


注意该命令只是把前面我们手工执行编译安装configure，install命令过程中写入操作系统的一些可执行命令删除，以及一些环境变量删了。我们在步骤2中手工创建的数据库安装路径依然存在，并不会被删除。

### 五、重新编译安装数据库软件

在一些情况下，我们可能需要重新编译安装数据库软件，比如初次安装的时候，如果不是使用make world编译源码的话，那么默认情况下少了很多数据库的扩展，而我们又发现需要用到这些扩展，该怎么办？或者，干脆，我们需要推倒重来的话，就可以选择重新编译安装。

#### 方式1.重新解压源码、编译、安装

可以从前面第4步开始重新走一遍流程，即重新解压源码，用新解压出来的源码文件，再依次进行configure，make world,make install-world。

#### 方式2.清除之前的编译状态

就是把之前第5步骤执行configure之后的文件状态，恢复到configure之前的状态，然后再通过执行configure，make world,make install-world。这个命令是make distclean。说白了，这个命令就是将源代码路径下的文件恢复到刚解压出来的状态，清除了之前执行configure命令对该路径下的所有文件的修改。

`--执行该命令后，源代码路径的输出结果和最开始的解压源码之后的输出保持一样，即恢复到刚解压的状态
gmake distclean`
