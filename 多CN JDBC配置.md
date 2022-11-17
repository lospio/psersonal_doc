1. 通过JDBC连接PostgreSQL数据库，代码中的JDBC链接格式如下：

```java
jdbc:postgresql://host:port/database?usert=fred&password=secret
```
2. 参数说明
- **`host`** 服务器地址. 默认为 `localhost` . 要指定 IPv6 地址，必须用方括号将主机参数括起来，例如: `jdbc:postgresql://[::1]:5740/accounting`
- **`port`**  port. 默认为 5432.
- **`database`**  数据库名名称. 默认同连接的用户名
- **`user`** 用户名
- **`password`** 密码
- **`options`** 指定连接初始化参数. 例如 `-c statement_timeout=5min` 会将此会话的语句超时参数设置为 5 分钟.
3. [官方文档](https://jdbc.postgresql.org/documentation/use/)