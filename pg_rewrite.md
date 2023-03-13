---
ctime: 2022-08-04 11:49
tags: simlpe card
author: lche
alias: 
---
#vault-squirreldoc  #PostgreSQL/tools
https://github.com/cybertec-postgresql/pg_rewrite

#### 功能
```sql
SELECT partition_table('measurement', 'measurement_aux', 'measurement_old');
```

1. The call will copy data from "measurement" to "measurement_aux", then it will lock "measurement" exclusively 
2. rename 
	1) "measurement" to "measurement_old", 
	2) "measurement_aux" to "measurement". 
   
   Thus "measurement" ends up to be the partitioned table, while "measurement_old" is the original, non-partitioned table.
#### 注意
1. Note that it's essential that both the source ("measurement") and destination ("measurement_aux") table have an identity index - the easiest way to ensure this is to create PRIMARY KEY or UNIQUE constraint.
2. **** unless you've set rewrite.check_constraints to false, make sure that the destination table has all the constraints that the source table has.
#### 限制
- foreign table
- foreign key



#参考
[blog/20211209_01.md at master · digoal/blog](cubox://card?id=ff8080818257183c018266f849f675e2)

