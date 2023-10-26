#### 修改方案：

复制表改为分布式表：

- 将数据大小为10G以上的复制表改为分布式表

分布式表shard数选择：

- 小于1G，64
    
- 1G-100G，128
    
- 100G-1000G，128
    
- 1000G+，cpu核数 * worker数 / 4 (320)
    
- min(wk _Q,)  
    Q:1-cpu核数  
    wk_ Q > 64
    
- shard 参考因子
    
    - cpu数
    - wk数
    - 表大小
    - 元组数 per shard
- shard 上限
    
    - maxconcurrent queries(max_concurrent-q)  _shard count(shard) < number of workers(n-wk)_  max_connections per worker(max_connections-wk) shard < n-wk* max_connections-wk/max_concurrent-q
- shard下限  
    - shard > n-wk _cpu_ q(1)  
    - shard > cpu