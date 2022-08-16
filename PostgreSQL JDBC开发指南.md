1. 获取JDBC包，配置路径。
	```bash 
	CLASSPATH=/usr/local/pgsql/share/java/postgresql-42.2.15.jar:.
	```
2. 导入JDBC
	```java
	import java.sql.*;
	```
3. 加载JDBC
	```java
	Class.forName("org.postgresql.Driver");
	```
4. 连接数据库
	- 连接字符串格式
		-   jdbc:postgresql:_`database`_
		-   jdbc:postgresql:/
		-   jdbc:postgresql://_`host/database`_
		-   jdbc:postgresql://_`host/`_
		-   jdbc:postgresql://_`host:port/database`_
		-   jdbc:postgresql://_`host:port/`_
		