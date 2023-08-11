# 文件
1. `conn_audit_log.sh`包含shell执行命令，支持检索log内容，筛选登录信息
2. `conn_audit_log.sql`包含udf定义，使用时`select * from conn_audit_log()'
# 安装
1. 将`conn_audit_log.sh`文件存入一个postgres用户具有访问权限的路径，更改其为可执行。
	- `chmod +x conn_audit_log.sh`
2. 执行`conn_audit_log.sql`,创建udf `conn_audit_log(query text , script_path text , log_path text ')`,调用时传入三个参数
	- query : `select * from conn_audit_log;`
	- script_path: conn_audit_log.sh的路径
	- log_path：数据库配置的log路径