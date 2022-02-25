scope: citus_wk1

namespace: /service/

name: wk1_1

  

restapi:

 listen: 0.0.0.0:8008

 connect_address: 192.168.60.12:8008

  

etcd:

 host: 192.168.60.11:2379

  

bootstrap:

 dcs:

 ttl: 30

 loop_wait: 10

 retry_timeout: 10

 maximum_lag_on_failover: 1048576

 master_start_timeout: 300

 synchronous_mode: true

  

 postgresql:

 use_pg_rewind: true

 use_slots: true

 parameters:

 wal_level: hot_standby

 hot_standby: "on"

  

 wal_keep_segments: 100

 max_wal_senders: 10

  

 wal_log_hints: "on"

 synchronous_commit: "on"

 synchronous_standby_names: "*"

  

 initdb:

 - encoding: UTF8

 - locale: C

 - lc-ctype: zh_CN.UTF-8

 - data-checksums

  

 pg_hba: 

 - host replication repl 0.0.0.0/0 md5

 - host all all 0.0.0.0/0 md5

  

 users:

 repl:

 password: "123456"

 options:

 - createrole

 - createdb

  

postgresql:

 listen: 0.0.0.0:5432

 connect_address: 192.168.60.12:5432

 data_dir: /var/lib/pgsql/13/data_patroni

 bin_dir: /usr/pgsql-13/bin

  

 authentication:

 replication:

 username: repl

 password: "123456"

 superuser:

 username: postgres

 password: "123456"

  

 basebackup:

 max-rate: 100M

 checkpoint: fast

  

tags:

 nofailover: false

 noloadbalance: false

 clonefrom: false

 nosync: false