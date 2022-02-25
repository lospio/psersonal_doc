# 需求 
实现postgresql自定义show create语句功能
- ----

## 分解需求
- schema ,table
- create table 语句
	- 名称
	- 类型
		- 基础类型
		- 需要转换（serial, smallserial,bigserial)
	- 默认值
	- 约束
		- primary key
		- unique
		- check
		-  ***foreign key (支持alter constraint)
- comment on
- index
- partition
	- partition by
	- attach partition
- -----
# 解决方案
## 参考
[stack overflow解决方案](https://stackoverflow.com/a/64618577/17890439)
[postgresql手册系统表目录](https://www.postgresql.org/docs/10/catalogs.html)
[postgresql系统信息函数](https://www.postgresql.org/docs/10/functions-info.html)

## 实现
- schema table
	- table
		1. [`pg_namespace`](https://www.postgresql.org/docs/10/catalog-pg-namespace.html#:~:text=%C2%A0Next-,51.32.%C2%A0pg_namespace,-The%20catalog%20pg_namespace)
		2. [`pg_class`](https://www.postgresql.org/docs/10/catalog-pg-class.html#:~:text=51.11.%C2%A0-,pg_class,-The%20catalog%20pg_class)
	- where 
			```
			pg_class.relnamespace = pg_namespace.oid
			and pg_class.relname = table_name
			and pg_namespace.nspname = schema_table
			``` 
- create table语句
	1. 名称  
		- table
			 [`pg_attribute`](https://www.postgresql.org/docs/10/catalog-pg-attribute.html#:~:text=%C2%A0Next-,51.7.%C2%A0pg_attribute,-The%20catalog%20pg_attribute)
		- where
			`pg_attribute.attrelid = pg_class.oid`
		- ***especially:serial smallserial bigserial 
			 通过[`pg_get_serial_sequence`](https://www.postgresql.org/docs/10/functions-info.html#:~:text=pg_get_serial_sequence%20returns%20the,serial%20column%20definition.) 判断结果是否为NULL来判断是否绑定有sequence
				
			> `pg_get_serial_sequence` returns the name of the sequence associated with a column, or NULL if no sequence is associated with the column. If the column is an identity column, the associated sequence is the sequence internally created for the identity column. For columns created using one of the serial types (`serial`, `smallserial`, `bigserial`), it is the sequence created for that serial column definition.   
			
     2. 默认值
	     - table
			 [`pg_attrdef`](https://www.postgresql.org/docs/10/catalog-pg-attrdef.html#:~:text=%C2%A0Next-,51.6.%C2%A0pg_attrdef,-The%20catalog%20pg_attrdef) 
		- where
			`pg_attrdef.adrelid = pg_attribute.attrelid`
		- function
			[`pg_get_expr`](https://www.postgresql.org/docs/10/functions-info.html#:~:text=pg_get_expr(pg_node_tree%2C%20relation_oid) )
     3. 约束
	     - primary key, foreign key, check, unique
	     - table:
		    [`pg_constraint`](https://www.postgresql.org/docs/10/catalog-pg-constraint.html#:~:text=51.13.%C2%A0-,pg_constraint,-The%20catalog%20pg_constraint)
	     - where
		     `pg_constraint.conrelid=pg_class.oid` 
	     - function
		    [`pg_get_constraintdef(pg_constraint.oid)`获取contraint的定义](https://www.postgresql.org/docs/10/functions-info.html#:~:text=pg_get_constraintdef(constraint_oid),of%20a%20constraint)
		 
	
- comment on
	- table
		[`pg_catalog.col_description`](https://www.postgresql.org/docs/10/catalog-pg-description.html#:~:text=51.19.%C2%A0-,pg_description,-The%20catalog%20pg_description)
	- 获取列信息
		 [`pg_catalog.col_description(pg_class.oid,pg_attribute.colnum)`](https://www.postgresql.org/docs/10/functions-info.html#:~:text=shared%20database%20object-,col_description,-returns%20the%20comment)
	- 获取表信息
		[`pg_catalog.obj_description(pg_class.oid)`](https://www.postgresql.org/docs/10/functions-info.html#:~:text=a%20table%20column-,obj_description(object_oid%2C%20catalog_name),get%20comment%20for%20a%20database%20object,-obj_description(object_oid) )
- index
	- table:
		[`pg_index`](https://www.postgresql.org/docs/10/catalog-pg-index.html#:~:text=51.26.%C2%A0-,pg_index,-The%20catalog%20pg_index)
	- index这里比较特殊，常规的约束也会自动生成index，除了将index与table绑定还需要剔除在constraint中存在的index
		1. `pg_index.indrelid=pg_class.oid`   绑定table
		2. ***剔除重复的index***,使用left join避免not in
		3. [`pg_catalog.pg_get_indexdef(i.indexrelid, 0, true)获取标准的index 语句`](https://www.postgresql.org/docs/10/functions-info.html#:~:text=command%20for%20index-,pg_get_indexdef(index_oid%2C%20column_no%2C%20pretty_bool),-text)
		 
```
LEFT JOIN pg_catalog.pg_constraint c ON (

 pg_constraint.conrelid = i.indrelid

 AND  pg_constraint.conindid = i.indexrelid

 AND  pg_constraint.contype IN ('p', 'u', 'x')

 )
 ```

- partition
	- partition by
		- function
			 [`pg_catalog.pg_get_partkeydef(pg_class.oid)` 获取分组属性]() 
	- atttion partition  
		- table
			1. [`pg_catalog.pg_inherits`](https://www.postgresql.org/docs/10/catalog-pg-inherits.html#:~:text=51.27.%C2%A0-,pg_inherits,-The%20catalog%20pg_inherits)
			2. [`pg_class`](https://www.postgresql.org/docs/10/catalog-pg-class.html#:~:text=51.11.%C2%A0-,pg_class,-The%20catalog%20pg_class)
		- where
		```
		pg_clasas.oid = pg_inherits.inhrelid
		and pg_clasas.relispartition
		```
		- function
			[`pg_catalog.pg_get_expr(pg_class.relpartbound, pg_inherits.inhrelid)`](https://www.postgresql.org/docs/10/functions-info.html#:~:text=pg_get_expr(pg_node_tree%2C%20relation_oid))
