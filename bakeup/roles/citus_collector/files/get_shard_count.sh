#!/bin/bash

# shards count
echo -e "\nshard_count: `psql -p 5005 -h localhost -c 'show citus.shard_count'|sed -n '3p'`" >> statistic.yml

# worker num

echo -e "\nworker_num: `psql -p 5005 -h localhost -c 'select count(*) from pg_dist_node;'|sed -n '3p'|sed s/[[:space:]]//g`" >> statistic.yml
