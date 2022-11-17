## 停止
#### 主机
1. patronictl -c    /DATA1/spatial/patroni/patroni_cn*_1.yml pause --wait
2. systemctl stop spacturePrimary
3. 切换到postgres用户
4. pg_ctl stop -D $PGDATA
#### 备机
1. systemctl stop spactureReplica
2. 切换到postgres用户
3. pg_ctl stop -D $PGDATA

## 启动

#### 主机
1. systemctl start spacturePrimary
2.  patronictl -c    /DATA1/spatial/patroni/patroni_cn*_1.yml resume 

#### 备机
1. systemctl start spactureReplica