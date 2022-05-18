1. scale factor 至少要大于 client
2. 至少做三次取平均值
3. write-heavy tests需要长时间，十分钟左右
4. autovacuum保持一致
5. debug_assertions 为true将极大地影响性能，随着shared_memory上升断言的开销也将增大
6. worker threads必须是cleint的整数倍
7. client不能超过系统核心数量太多
8. 根据disk情况找到client和每次插入数据长度的饱和点（越过之后，效率下降）