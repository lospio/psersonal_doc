#!/bin/bash

# shared buffers
echo -e  "\nshard_count: `psql -p 5005 -h localhost -c 'show shared_buffers'|sed -n '3p' |awk -FM '{print$1}'|sed s/[[:space:]]//g`" >> statistic.yml