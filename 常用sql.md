- 查询所有shard数小于17的表
	```sql
	SELECT
	shard.logicalrelid as name,
	    count(*) as num, pg_size_pretty(table_size(shard.logicalrelid::text)) as tablesize, table_size(shard.logicalre
	FROM pg_dist_placement placement
	JOIN pg_dist_node node
	  ON placement.groupid = node.groupid
	 AND node.noderole = 'primary'::noderole
	JOIN pg_dist_shard shard
	  ON placement.shardid = shard.shardid
	left join pg_class c
	  on shard.logicalrelid=c.relname::regclass
	LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	where
	c.relispartition is FALSE
	and c.relkind in('r', 'p')
	AND n.nspname = 'public'
	group by name  having count(*) <17 order by size desc , count(*);
	```