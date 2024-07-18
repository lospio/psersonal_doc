```sql
 CREATE TABLE `bmsql_district_new` (
       `d_id` int NOT NULL,
       `d_w_id` int NOT NULL,
       `d_ytd` decimal(12,2) DEFAULT NULL,
       `d_tax` decimal(4,4) DEFAULT NULL,
       `d_next_o_id` int DEFAULT NULL,
       `d_name` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `d_street_1` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `d_street_2` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `d_city` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `d_state` char(2) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `d_zip` char(9) COLLATE utf8mb4_general_ci DEFAULT NULL,
       PRIMARY KEY (`d_w_id`,`d_id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `bmsql_warehouse_local` (
       `w_id` int ,
       `w_ytd` decimal(12,2) DEFAULT NULL,
       `w_tax` decimal(4,4) DEFAULT NULL,
       `w_name` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `w_street_1` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `w_street_2` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `w_city` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `w_state` char(2) COLLATE utf8mb4_general_ci DEFAULT NULL,
       `w_zip` char(9) COLLATE utf8mb4_general_ci DEFAULT NULL,
       PRIMARY KEY (`w_id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `bmsql_warehouse` (
  `w_id` int default null,
  `w_ytd` decimal(12,2) DEFAULT NULL,
  `w_tax` decimal(4,4) DEFAULT NULL,
  `w_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `w_street_1` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `w_street_2` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `w_city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `w_state` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `w_zip` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
 PARTITION BY RANGE (`w_id`)
(PARTITION p01 VALUES LESS THAN (51) ENGINE = InnoDB,
 PARTITION p02 VALUES LESS THAN (101) ENGINE = InnoDB,
 PARTITION p03 VALUES LESS THAN (151) ENGINE = InnoDB,
 PARTITION p04 VALUES LESS THAN (201) ENGINE = InnoDB,
 PARTITION p05 VALUES LESS THAN (251) ENGINE = InnoDB,
 PARTITION p06 VALUES LESS THAN (301) ENGINE = InnoDB,
 PARTITION p07 VALUES LESS THAN (351) ENGINE = InnoDB,
 PARTITION p08 VALUES LESS THAN (401) ENGINE = InnoDB,
 PARTITION p09 VALUES LESS THAN (451) ENGINE = InnoDB,
 PARTITION p10 VALUES LESS THAN (501) ENGINE = InnoDB);

CREATE TABLE `bmsql_district` (
  `d_id` int NOT NULL,
  `d_w_id` int NOT NULL,
  `d_ytd` decimal(12,2) DEFAULT NULL,
  `d_tax` decimal(4,4) DEFAULT NULL,
  `d_next_o_id` int DEFAULT NULL,
  `d_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `d_street_1` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `d_street_2` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `d_city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `d_state` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `d_zip` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`d_w_id`,`d_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
PARTITION BY RANGE (`d_w_id`)
(PARTITION p01 VALUES LESS THAN (51) ENGINE = InnoDB,
 PARTITION p02 VALUES LESS THAN (101) ENGINE = InnoDB,
 PARTITION p03 VALUES LESS THAN (151) ENGINE = InnoDB,
 PARTITION p04 VALUES LESS THAN (201) ENGINE = InnoDB,
 PARTITION p05 VALUES LESS THAN (251) ENGINE = InnoDB,
 PARTITION p06 VALUES LESS THAN (301) ENGINE = InnoDB,
 PARTITION p07 VALUES LESS THAN (351) ENGINE = InnoDB,
 PARTITION p08 VALUES LESS THAN (401) ENGINE = InnoDB,
 PARTITION p09 VALUES LESS THAN (451) ENGINE = InnoDB,
 PARTITION p10 VALUES LESS THAN (501) ENGINE = InnoDB);



explain select b.*, a.* from (select d_w_id, sum(d_ytd) s from bmsql_district where d_w_id = 500 group by d_w_id) b left join (Select w_id, w_ytd from bmsql_warehouse_new where w_id = 500) a  on a.w_id=b.d_w_id and a.w_ytd=b.s where a.w_id is null;


select b.*, a.* from (Select w_id, w_ytd from bmsql_warehouse where w_id = 500)b left join   (select d_w_id, sum(d_ytd) s from bmsql_district where d_w_id = 500 group by d_w_id) a  on b.w_id=a.d_w_id and b.w_ytd=a.s where b.w_id is null;

select b.*, a.* from   (select d_w_id, sum(d_ytd) s from bmsql_district where d_w_id = 500 group by d_w_id) a  left join   (Select w_id, w_ytd from bmsql_warehouse where w_id = 500)b on b.w_id=a.d_w_id and b.w_ytd=a.s where b.w_id is null;
```