- ## 获取表字段信息
	- sql
		```sql
		CREATE OR REPLACE FUNCTION public.show_column_information(schema_name character varying, table_name character varying) RETURNS SETOF pg_attribute AS
		$body$
		BEGIN
		    RETURN QUERY
		        WITH table_rec AS(
		            SELECT c.oid AS oid, n.nspname AS nspname, c.relname as relname
		            FROM pg_catalog.pg_class c
		            LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		            WHERE c.relkind in('r', 'p', 's')
		            --r = ordinary table, i = index, S = sequence, t = TOAST table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table		
		                AND n.nspname !~ '^pg_toast'		
		                AND n.nspname = schema_name		
		                AND c.relname = table_name		
		        )		
		        SELECT a.*  		
		        FROM pg_attribute a		
		        RIGHT JOIN table_rec t		
		        ON a.attrelid = t.oid;		
		    RETURN;		
		END;		
		$body$		
		LANGUAGE plpgsql;				
		```
	- 使用 
		```sql
		-- select * from show_column_infomation(schmema_name , table_name);
		-- 示例
		select * from show_column_infomation('public','beidou_pts');
		```

	- 结果 ![[Pasted image 20220808114735.png]]
- ## 获取索引
	- sql
		```sql
		CREATE OR REPLACE FUNCTION public.show_index(schema_name character varying, table_name character varying) RETURNS SETOF pg_catalog.pg_index AS
	
		$body$
		
		BEGIN  
		
		    RETURN QUERY
		
		    WITH table_rec AS(
		
		        SELECT c.oid AS oid, n.nspname AS nspname, c.relname as relname
		
		        FROM pg_catalog.pg_class c
		
		        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		
		        WHERE c.relkind in('r', 'p', 's')
		
		        --r = ordinary table, i = index, S = sequence, t = TOAST table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table
		
		            AND n.nspname !~ '^pg_toast'
		
		            AND n.nspname = schema_name
		
		            AND c.relname = table_name
		
		    )
		
		    SELECT
		
		        i.*
		
		    FROM
		
		        pg_catalog.pg_index i
		
		        LEFT JOIN pg_catalog.pg_constraint c ON (
		
		            conrelid = i.indrelid
		
		            AND conindid = i.indexrelid
		
		            AND contype IN ('p', 'u', 'x')
		
		        )
		
		    RIGHT JOIN table_rec t
		
		    ON t.oid = i.indrelid
		
		    WHERE
		
		        c.conindid IS NULL;
		
		    RETURN;
		
		END;
		
		$body$
		
		LANGUAGE plpgsql;
		```
	- 使用
		```sql
		select * from show_index('schema_name','table_name');
		```
	- 效果
	![[Pasted image 20220808141522.png]]
- ## 获取外键
	- sql
		```sql
		CREATE OR REPLACE FUNCTION show_foreign_key(schema_name character varying, table_name character varying) RETURNS SETOF pg_catalog.pg_constraint AS
		
		$body$
		
		BEGIN
		
		    RETURN QUERY
		
		    WITH table_rec AS(
		
		        SELECT c.oid AS oid, n.nspname AS nspname, c.relname as relname
		
		        FROM pg_catalog.pg_class c
		
		        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		
		        WHERE c.relkind in('r', 'p', 's')
		
		        --r = ordinary table, i = index, S = sequence, t = TOAST table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table
		
		            AND n.nspname !~ '^pg_toast'
		
		            AND n.nspname = schema_name
		
		            AND c.relname = table_name
		
		  
		
		    )
		
		    SELECT  c.*
		
		    FROM pg_constraint c
		
		    RIGHT JOIN table_rec t
		
		    ON t.oid = c.conrelid
		
		    WHERE
		
		        c.contype = 'f';
		
		    RETURN;
		
		END;
		
		$body$
		
		LANGUAGE plpgsql;
		```
	- 使用
		```sql
		select * from show_foreign_key('schema_name','table_name');
		```
	- 效果
	![[Pasted image 20220808144113.png]]
- ## 建表语句
	- sql
		```sql
		CREATE OR REPLACE FUNCTION public.show_create_table(schema_name character varying, table_name character varying) RETURNS SETOF TEXT AS 
		$body$
		BEGIN
		    RETURN query
		    WITH table_rec AS(
		        SELECT c.oid AS oid, n.nspname AS nspname, c.relname as relname
		        FROM pg_catalog.pg_class c
		        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		        WHERE c.relkind in('r', 'p', 's')
		        --r = ordinary table, i = index, S = sequence, t = TOAST table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table
		
		            AND n.nspname !~ '^pg_toast'
		
		            AND n.nspname = schema_name
		
		            AND c.relname = table_name
		
		  
		
		    ),
		
		    cat_rec AS (
		
		        SELECT
		
		            a.attnum,
		
		            CASE pg_catalog.format_type(a.atttypid, a.atttypmod)
		
		                WHEN 'integer' THEN 'serial'
		
		                WHEN 'bigint' THEN 'bigserial'
		
		                WHEN 'smallint' THEN 'smallserial'
		
		            END  AS coltype,
		
		            '' AS column_default_value
		
		        FROM pg_catalog.pg_attribute a
		
		        RIGHT JOIN table_rec t on t.oid = a.attrelid
		
		        WHERE
		
		            a.attnum > 0
		
		            AND NOT a.attisdropped
		
		            AND pg_get_serial_sequence(format(E'%s.%s',$1,$2),a.attname) IS NOT NULL
		
		        UNION
		
		        SELECT
		
		            a.attnum,
		
		            pg_catalog.format_type(a.atttypid, a.atttypmod) AS coltype,
		
		            (
		
		                SELECT
		
		                    CONCAT('DEFAULT ',substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128))--adbin:The internal representation of the column default value
		
		                FROM
		
		                    pg_catalog.pg_attrdef d
		
		                WHERE
		
		                    d.adrelid = a.attrelid
		
		                    AND d.adnum = a.attnum
		
		                    AND a.atthasdef
		
		                    AND pg_catalog.pg_get_expr(d.adbin, d.adrelid) IS NOT NULL
		
		            )AS column_default_value
		
		        FROM pg_catalog.pg_attribute a
		
		        RIGHT JOIN table_rec t on t.oid = a.attrelid
		
		        WHERE
		
		            a.attnum > 0
		
		            AND NOT a.attisdropped
		
		            AND pg_get_serial_sequence(format(E'%s.%s',$1,$2),a.attname) IS NULL
		
		    ),
		
		    col_rec AS (
		
		        SELECT
		
		            a.attname AS colname,
		
		            b.coltype AS coltype,
		
		            a.attrelid AS oid,
		
		            a.attnum AS colnum,
		
		            b.column_default_value AS column_default_value,
		
		            CASE WHEN a.attnotnull = TRUE THEN
		
		                'NOT NULL'
		
		            ELSE
		
		                ''
		
		            END AS column_not_null,
		
		            a.attnum AS attnum
		
		        FROM
		
		            pg_catalog.pg_attribute a
		
		            RIGHT JOIN cat_rec b on b.attnum = a.attnum
		
		        WHERE
		
		            a.attnum > 0
		
		            AND NOT a.attisdropped
		
		        ORDER BY
		
		            a.attnum
		
		    ),
		
		    con_rec AS (
		
		        SELECT
		
		            conrelid::regclass::text AS relname,
		
		            conname,
		
		            pg_get_constraintdef(c.oid) AS condef,
		
		            contype,
		
		            --c = check constraint, f = foreign key constraint, p = primary key constraint, u = unique constraint, t = constraint trigger, x = exclusion constraint
		
		            conrelid AS oid
		
		        FROM
		
		            pg_constraint c
		
		            JOIN pg_catalog.pg_class t ON c.conrelid = t.oid
		
		    ),
		
		    com_rec AS(
		
		        SELECT
		
		            pg_catalog.col_description(table_rec.oid,col_rec.colnum) AS comment,
		
		            col_rec.oid AS oid,
		
		            col_rec.colname AS colname
		
		        FROM table_rec, col_rec
		
		        WHERE pg_catalog.col_description(table_rec.oid,col_rec.colnum) is not null
		
		        ORDER BY
		
		        oid
		
		    ),
		
		    range_key_rec AS(
		
		        SELECT
		
		            pg_catalog.pg_get_partkeydef(oid) AS range_key,
		
		            oid
		
		        FROM
		
		            table_rec
		
		    ),
		
		    attach_to_rec AS(
		
		        SELECT
		
		            inhparent :: pg_catalog.regclass AS attach_to_table_name,
		
		            pg_catalog.pg_get_expr(c.relpartbound, inhrelid) AS partbound,
		
		            c.oid AS oid
		
		        FROM
		
		            pg_catalog.pg_class c
		
		            JOIN pg_catalog.pg_inherits i ON c.oid = inhrelid
		
		        WHERE
		
		            c.relispartition
		
		  
		
		    ),
		
		    glue AS (
		
		        SELECT
		
		            format( E'create table %1$I.%2$I (\n', t.nspname, t.relname) AS top,
		
		            CASE WHEN r.range_key IS NULL
		
		                THEN format( E'\n);\n\n\n')
		
		            ELSE format(E'\n) PARTITION BY %s;\n\n\n',r.range_key)
		
		            END AS bottom,
		
		            t.oid
		
		        FROM
		
		            table_rec t
		
		        LEFT JOIN range_key_rec r ON t.oid = r.oid
		
		    ),
		
		    cols AS (
		
		        SELECT
		
		            string_agg(format(E'    %-20s %-20s %-10s %s', col.colname, col.coltype, col.column_not_null, col.column_default_value), E',\n') AS lines,
		
		            oid
		
		        FROM
		
		            col_rec col
		
		        GROUP BY
		
		            oid
		
		    ),
		
		    constr AS(
		
		        SELECT
		
		            string_agg(format(E',\n    CONSTRAINT "%s" %s',conname,condef),E'') AS cons,
		
		            oid
		
		        FROM
		
		            con_rec
		
		        WHERE contype <> 'f'
		
		        GROUP BY
		
		            oid
		
		    ),
		
		  
		
		    table_cmen AS(
		
		        SELECT
		
		           format(E'comment on table %s.%s is \'%s\';', schema_name, table_name, pg_catalog.obj_description(oid)) AS comment
		
		           ,oid
		
		        FROM table_rec
		
		        WHERE pg_catalog.obj_description(oid) is not null
		
		        GROUP BY
		
		            oid
		
		    ),
		
		    cmen AS(
		
		        SELECT
		
		            string_agg(format(E'comment on column %s.%s.%s is \'%s\';', schema_name, table_name, colname,comment), E'\n') AS comment_line,
		
		            oid
		
		        FROM com_rec
		
		        GROUP BY
		
		            oid
		
		    ),
		
		    frnkey AS (
		
		        SELECT
		
		            string_agg(format(E'ALTER TABLE %s.%s ADD CONSTRAINT "%s" %s;', $1, $2, conname, condef), E';\n') AS lines,
		
		            oid
		
		        FROM
		
		            con_rec
		
		        WHERE
		
		            contype = 'f'
		
		        GROUP BY
		
		            oid
		
		    ),
		
		    attach_to AS(
		
		        SELECT
		
		            format(E'ALTER TABLE %s ATTACH PARTITION %s %s;\n', a.attach_to_table_name , t.relname, a.partbound) AS lines,
		
		            a.oid
		
		        FROM attach_to_rec a
		
		        JOIN table_rec t on t.oid = a.oid
		
		    ),
		
		    get_index AS(
		
		        SELECT
		
		            format(E'%s ;',pg_catalog.pg_get_indexdef(i.indexrelid, 0, true)) AS line,
		
		            i.indrelid as oid
		
		        FROM
		
		            pg_catalog.pg_index i
		
		            LEFT JOIN pg_catalog.pg_constraint c ON (
		
		                conrelid = i.indrelid
		
		                AND conindid = i.indexrelid
		
		                AND contype IN ('p', 'u', 'x')
		
		            )
		
		        WHERE
		
		            c.conindid IS NULL
		
		    )
		
		    SELECT CONCAT(glue.top,cols.lines, constr.cons,glue.bottom,frnkey.lines,E'\n', table_cmen.comment,E'\n', cmen.comment_line,E'\n',attach_to.lines,E'\n', get_index.line)
		
		    FROM glue
		
		    JOIN cols ON cols.oid = glue.oid
		
		        LEFT JOIN  cmen on cmen.oid = glue.oid
		
		        LEFT JOIN constr ON constr.oid = glue.oid
		
		        LEFT JOIN frnkey ON frnkey.oid = glue.oid
		
		        LEFT JOIN table_cmen on table_cmen.oid = glue.oid
		
		        LEFT JOIN attach_to on attach_to.oid = glue.oid
		
		        LEFT JOIN get_index on get_index.oid = glue.oid;
		
		    --test cat_rec
		
		    -- SELECT CONCAT(attnum, E'\n',coltype, E'\n',column_default_value)
		
		    -- FROM cat_rec;
		
		  
		
		END
		
		$body$
		
		LANGUAGE plpgsql;
		```
	- 使用
		```sql
		select show_create_table('schema','table_name');
		```
	- 效果
		
		![[Pasted image 20220808144323.png]]
- ## 显示表注释
	- sql
		```sql
		-- 表注释
		
		CREATE OR REPLACE FUNCTION show_table_comment(schema_name character varying, table_name character varying) RETURNS SETOF TEXT AS
		
		$body$
		
		BEGIN
		
		    RETURN QUERY
		
		    WITH table_rec AS(
		
		        SELECT c.oid AS oid, n.nspname AS nspname, c.relname as relname
		
		        FROM pg_catalog.pg_class c
		
		        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		
		        WHERE c.relkind in('r', 'p', 's')
		
		        --r = ordinary table, i = index, S = sequence, t = TOAST table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table
		
		            AND n.nspname !~ '^pg_toast'
		
		            AND n.nspname = schema_name
		
		            AND c.relname = table_name
		
		  
		
		    )
		
		    SELECT
		
		        format(E'comment on table %s.%s is \'%s\';', schema_name, table_name, pg_catalog.obj_description(oid)) AS comment  
		
		    FROM table_rec
		
		    WHERE pg_catalog.obj_description(oid) is not null;
		
		    RETURN;
		
		END;
		
		$body$
		
		LANGUAGE plpgsql;
		```
	- 使用
		```sql
		select * from show_table_comment('schema_name','table_name');
		```
	- 效果
	
		![[Pasted image 20220808150857.png]]
- ## 显示表信息
	- sql
		```sql
		create or replace function public.show_table_information(schema_name character varying, table_name character varying) returns setof text as
		
		$body$
		
		  
		
		begin
		
		    return query
		
		    with table_rec as(
		
		        select c.oid as oid, n.nspname as nspname, c.relname as relname
		
		        from pg_catalog.pg_class c
		
		        left join pg_catalog.pg_namespace n on n.oid = c.relnamespace
		
		        where c.relkind in('r', 'p', 's')
		
		        --r = ordinary table, i = index, s = sequence, t = toast table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table
		
		            and n.nspname !~ '^pg_toast'
		
		            and n.nspname = schema_name
		
		            and c.relname = table_name
		
		  
		
		    ),
		
		    col_info as(
		
		        select
		
		            a.attname,
		
		            pg_catalog.format_type(a.atttypid, a.atttypmod) as coltype,
		
		            (
		
		                 select substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
		
		                from pg_catalog.pg_attrdef d
		
		                where d.adrelid = a.attrelid and d.adnum = a.attnum and a.atthasdef
		
		            ) as default_vvv ,
		
		            case a.attnotnull
		
		                when 't' then 'not null'
		
		                when 'f' then ''
		
		            end  as notnullval,
		
		            a.attnum,
		
		            (
		
		                select c.collname
		
		                from pg_catalog.pg_collation c, pg_catalog.pg_type t
		
		                where c.oid = a.attcollation and t.oid = a.atttypid and a.attcollation <> t.typcollation
		
		            ) as attcollation,
		
		            a.attidentity,
		
		            null as indexdef,
		
		            null as attfdwoptions,
		
		            a.attstorage,
		
		            case
		
		                when a.attstattarget=-1 then null
		
		                else a.attstattarget
		
		            end as attstattarget,
		
		            pg_catalog.col_description(a.attrelid, a.attnum) as col_descrip,
		
		            a.attrelid as oid
		
		            from pg_catalog.pg_attribute a
		
		            where  a.attnum > 0 and not a.attisdropped
		
		            order by attname asc
		
		    ),
		
		    col_lines as(
		
		        select string_agg(format(E'%-20s| %-30s| %-10s| %-10s| %-50s| %-10s| %-20s| %-50s', attname, coltype, attcollation, notnullval, default_vvv, attstorage, attstattarget, col_descrip ), E',\n') as lines,
		
		        oid
		
		        from col_info
		
		        group by oid
		
		    ),
		
		    glue as(
		
		        select  format( E'%-90s%s.%s \n%-20s| %-30s| %-10s| %-10s| %-50s| %-10s| %-20s| %-50s\n\n\n',
		
		        '',t.nspname, t.relname,'Column','Type','Collation','Nullable','Default','Storage','Stats target','Description' ) AS top,
		
		        oid
		
		        from table_rec t
		
		    )
		
		    select CONCAT(glue.top,c.lines)
		
		    from glue
		
		    left join col_lines  c on c.oid = glue.oid;
		
		    --test cat_rec
		
		    -- select concat(attnum, e'\n',coltype, e'\n',column_default_value)
		
		    -- from cat_rec;
		
		    return;
		
		end
		
		$body$
		
		language plpgsql;
		```
	- 使用
		```sql
		select * from show_table_information('schema_name','table_name');
		```
	- 效果
		![[Pasted image 20220809122708.png]]