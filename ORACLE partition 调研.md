# ORACLE 分区
## 基本功能
分区允许将表、索引或索引组织的表细分为更小的部分。数据库对象的每个部分都被称为一个分区。每个分区都有自己的名称，也可以选择有自己的存储特性。
但是，从应用程序的角度来看，分区表与非分区表是相同的；当使用SQL DML命令访问分区表时，不需要进行任何修改 .
数据库对象——表、索引和索引组织的表——使用“分区键”进行分区，“分区键是一组列，它决定给定的行将驻留在哪个分区中
### 分区索引

#### Local Indexes
本地索引是一个分区表上的一个索引，它与底层的分区表相结合，从表中“继承”分区策略
耦合支持优化的分区维护；例如，当一个表分区被删除时，Oracle也只需删除相应的索引分区。没有昂贵的索引维护 是必需的。本地索引在数据仓库环境中最为常见。
#### Global Partitioned Indexes:
全局分区索引是分区或非分区表上的索引，该索引使用与表不同的分区键或分区策略进行分区.
全局分区的索引可以使用范围分区或哈希分区进行分区，并从底层表中解耦
例如，一个表可以按月划分为范围，并且有12个分区，而该表上的一个索引可以使用不同的分区键进行范围分区，并有分不同数量的分区。全局分区索引在OLTP中比在数据仓库环境中更常见。
#### Global Non-Partitioned Indexes
全局非分区索引本质上与非分区表上的索引相同。索引结构没有从底层表中进行分区和分离。在数据仓库环境中,全局非分区索引最常用的用法是强制执行主键约束。另一方面，OLTP环境主要依赖于全局非分区索引
####  管理分区表的命令
添加新的分区、删除、分割、移动、合并、截断和可选地压缩分区。
#### 性能
Partitioning Pruning:减少访问数据
- range,list: range, like, in ,equal
- hash: equal, in
Partition-wise Joins:当两个表连接在一起时，至少有一个表在连接键上进行了分区可以应用分区级连接.

> Oracle is using either the fact of already (physical) equi-partitioned tables for the join or is transparently redistributing (= “repartitioning”) one table at runtime to create equi-partitioned data sets matching the partitioning of the other table, completing the overall join inless time.

#### 高可用
- 已分区的数据库对象提供了分区独立性。如果一个分区无法使用了,其他的分区依旧可用
- 每个分区可以指定不同的 tablespace
#### 分区策略
![[Pasted image 20230914165710.png]]
![[Pasted image 20230914165742.png]]
基本策略

| 类型                    | 解释                                                                    |
| ----------------------- | ----------------------------------------------------------------------- |
| RANGE 分区              | 根据分区键值范围分区,中间没有任何空值. 下边界由前一个分区的上边界决定.  |
| LIST    分区            | 根据分区键的值列表分区. 定义一个 DEFAULT 分区包含所有未在 list 中的分区 |
| HASH   分区             | 对分区键应用哈希算法来确定给定行的分区                                  |
| Single(one-level)  分区 | 单独使用一种策略分区                                                    |
|  Composite 分区                       |    两种数据分布方法的组合用于定义一个复合分区表                                                                     |

>Index-organized tables (IOTs) can be partitioned using range, hash, and list partitioning. Composite partitioning is not supported for IOTs.

拓展策略

| 策略                       | 解释                                                            | 其他                                                                                        |
| -------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Interval 分区              | 扩展了ramge方法使用==等分区范围==定义分区                       | 自动创建分区,无需显示指定 interval;支持 interval,interval_list,interval_hash,interval_range |
| Reference 分区             | 子表可以继承父表的分区关系,同时不需要存储父表的分区键(参照外键) | 继承父表分区策略;继承父表分区操作;还允许 partition-wise join                                |
| Virtual column-based  分区 | 允许表达式作为分区键,把表达式 存为元数据                        | 使用一个或多个 column                                                                                            |

#? 

> Partitioning automatically enables partition-wise joinsfor the equi-partitions of the parent and child table, improving the performance for this operation. 
> For example, a parent table ORDERS is Range partitioned on the ORDER_DATE column; its child table ORDER ITEMS does not contain the ORDER_DATE column but can be partitioned by reference to the ORDERS table. If the ORDERS table is partitioned by month, all order items for orders in 'Jan-2007' will then be stored in a single partition in the ORDER ITEMS table, equi-partitioned to the parent table ORDERS. If a partition 'Feb-2007' is added to the ORDERS table Oracle will transparently add the equivalent partition to the ORDER ITEMS table

#### 分区顾问
The SQL ACCESS Advisor除了为indexes、materialized views 和materialized views log提供的建议外，还可以生成分区建议以及该建议带来的预期性能收益. 

# 参考
Version:0.9 StartHTML:0000000105 EndHTML:0000000325 StartFragment:0000000141 EndFragment:0000000285

Partitioning in Oracle Database 11g