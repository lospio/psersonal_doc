# 00:背景
为了提高PostgreSQL数据库的安全规范使用，编写该文档
# 01: 方法
## A.  Access
#### Connection
- Unix Domain Socket Unix 本地连接
	- `unix_socket_group`
	- `unix_socket_permissions` 770
	- `unix_socket_directories`
- TCP/IP
	- `listen_address`
	- `port`
	- `max_connections`
		- 对普通数据库用户设置连接数限制
		- 设置少量的保留超级用户登陆连接数
####  防火墙
限制端口号和源地址
#### Transport Encryption
配置OpenSSL
- ssl_ciphers ssl_ciphers
- ssl_ecdh_curve ssl_ecdh_curve
- ssl_dh_params_file ssl_dh_params_file
- ssl_min_protocol_version  
## B. Authentication
#### pg_hba.conf
#### .pgpass
## C. Roles
#### superuser
自定义超级用户，删除默认的postgres数据库
#### Role attributes
- LOGIN - can this role be used to login to the database server?  
- SUPERUSER - is this role a superuser?  
- CREATEDB - can this role create databases?  
- CREATEROLE - can this role create new roles?  
- REPLICATION - can this role initiate streaming replication?  
- PASSWORD - the password for the role, if set.  
- BYPASSRLS - can this role bypass Row Level Security checks?  ？
- VALID UNTIL - an optional timestamp after which time the password will no longer be valid.  
- Roles with the SUPERUSER flag set automatically bypass all permission checks except the right to login.  
## D. Data Access Control
#### GRANT & REVOKE
#### Row Level Security
- create policy
#### View
## E. LOG
```bash
#记录成功与非成功连接尝试 
log_connections = on
#记录终止对话
log_disconnections = on
#记录所有执行过的SQL语句
log_statement = all
```

# 02: 参考
- [How to Secure PostgreSQL: Security Hardening Best Practices & Tips](https://www.enterprisedb.com/blog/how-to-secure-postgresql-security-hardening-best-practices-checklist-tips-encryption-authentication-vulnerabilities)
- [PostgreSQL 安全最佳实践](https://www.infoq.cn/article/a3x1rkzxo7srzffvktgj)
- [PostgreSQL中常见的14个用户安全配置](https://cloud.tencent.com/developer/article/1657615)