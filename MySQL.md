- 允许所有ip
	```sql
	use mysql;
	UPDATE user SET Host='%' WHERE User='root';
	FLUSH PRIVILEGES;
	```