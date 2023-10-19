# 1. MySQL锁
三中层级的锁`Table-level locks` `Page-level locks` `row_level locks`
粒度依次递减,复杂度提升
对于 table-level locks, 实现逻辑简单,更少的 bug,获取锁的时候更高效,死锁检验也会变得简单;同时,大量并发读写的效率会降低
对于 row-level locks,复杂的逻辑和实现机制带来了更细粒度的锁,提高了并发读写效率;同时,获取锁,避免死锁更加繁琐,更易出错,内存占用更多

| 锁类型            | 存储引擎         | 
| ----------------- | ---------------- | 
| table-level locks | MyISAM , MEMOERY |    
| page-level locks  | Berkeley DB      |    
| row-level locks   | InnoDB           |    
### Table-level locks
#### 类型
- 表锁
- 元数据锁(MDL)
- 意向锁
- AUTO-INC 锁
#### 特点
```text
1. 对整张表加锁
2. 开销小
3. 加锁快
4. 无死锁
5. 锁粒度大，发生锁冲突概率大，并发性低
```
#### 表锁
```text
读锁（read lock），也叫共享锁（shared lock） 针对同一份数据，多个读操作可以同时进行而不会互相影响（select）

写锁（write lock），也叫排他锁（exclusive lock） 当前操作没完成之前，会阻塞其它读和写操作（update、insert、delete）
```
####  元数据锁
```text
我们不需要显式的使用 MDL，因为当我们对数据库表进行操作时，会自动给这个表加上 MDL：

- 对一张表进行 CRUD 操作时，加的是 **MDL 读锁**；
- 对一张表做结构变更操作的时候，加的是 **MDL 写锁**；

MDL 是为了保证当用户对表执行 CRUD 操作时，防止其他线程对这个表结构做了变更。

当有线程在执行 select 语句（ 加 MDL 读锁）的期间，如果有其他线程要更改该表的结构（ 申请 MDL 写锁），那么将会被阻塞，直到执行完 select 语句（ 释放 MDL 读锁）。

反之，当有线程对表结构进行变更（ 加 MDL 写锁）的期间，如果有其他线程执行了 CRUD 操作（ 申请 MDL 读锁），那么就会被阻塞，直到表结构变更完成（ 释放 MDL 写锁）。

MDL 在事务提交后才会释放,在事务执行期间,一直被持有 ;如果在一个未提交的长事务中存在 select 语句,后续其他事务对该表的读操作不受影响,写操作会被阻塞,在这之后其他事务的读操作也会被阻塞:
这是因为申请 MDL 锁的操作会形成一个队列，队列中**写锁获取优先级高于读锁**，一旦出现 MDL 写锁等待，会阻塞后续该表的所有 CRUD 操作。
```
####  意向锁
```text 
- 在使用 InnoDB 引擎的表里对某些记录加上「共享锁」之前，需要先在表级别加上一个「意向共享锁」；
- 在使用 InnoDB 引擎的表里对某些纪录加上「独占锁」之前，需要先在表级别加上一个「意向独占锁」；

也就是，当执行插入、更新、删除操作，需要先对表加上「意向独占锁」，然后对该记录加独占锁

有了意向锁,在加独占表锁时,只需要检查该表是否有意向独占锁,可以加快判断表里是否有记录被加锁 。
```
#### AUTO-INC 锁
```text
表里的主键通常都会设置成自增的，这是通过对主键字段声明 `AUTO_INCREMENT` 属性实现的。

之后可以在插入数据时，可以不指定主键的值，数据库会自动给主键赋值递增的值，这主要是通过 **AUTO-INC 锁**实现的。

AUTO-INC 锁是特殊的表锁机制，锁**不是再一个事务提交后才释放，而是再执行完插入语句后就会立即释放**。

**在插入数据时，会加一个表级别的 AUTO-INC 锁**，然后为被 `AUTO_INCREMENT` 修饰的字段赋值递增的值，等插入语句执行完成后，才会把 AUTO-INC 锁释放掉。

那么，一个事务在持有 AUTO-INC 锁的过程中，其他事务的如果要向该表插入语句都会被阻塞，从而保证插入数据时，被 `AUTO_INCREMENT` 修饰的字段的值是连续递增的。

在 MySQL 5.1.22 版本开始，InnoDB 存储引擎提供了一种**轻量级的锁**来实现自增。

一样也是在插入数据的时候，会为被 `AUTO_INCREMENT` 修饰的字段加上轻量级锁，**然后给该字段赋值一个自增的值，就把这个轻量级锁释放了，而不需要等待整个插入语句执行完后才释放锁**。

InnoDB 存储引擎提供了个 innodb_autoinc_lock_mode 的系统变量，是用来控制选择用 AUTO-INC 锁，还是轻量级的锁。

- 当 innodb_autoinc_lock_mode = 0，就采用 AUTO-INC 锁，语句执行结束后才释放锁；
- 当 innodb_autoinc_lock_mode = 2，就采用轻量级锁，申请自增主键后就释放锁，并不需要等语句执行后才释放。
- 当 innodb_autoinc_lock_mode = 1：
    - 普通 insert 语句，自增锁在申请之后就马上释放；
    - 类似 insert … select 这样的批量插入数据的语句，自增锁还是要等语句结束后才被释放；

当 innodb_autoinc_lock_mode = 2 是性能最高的方式，但是当搭配 binlog 的日志格式是 statement 一起使用的时候，在「主从复制的场景」中会发生**数据不一致的问题**。
```
### Row-level locks
InnoDB 引擎是支持行级锁的，而 MyISAM 引擎并不支持行级锁。

普通的 select 语句是不会对记录加锁的，因为它属于快照读。如果要在查询时对记录加行锁，可以使用下面这两个方式，这种查询会加锁的语句称为**锁定读**。
```sql
//对读取的记录加共享锁
select ... lock in share mode;

//对读取的记录加独占锁
select ... for update;
```
上面这两条语句必须在一个事务中，**因为当事务提交了，锁就会被释放**，所以在使用这两条语句的时候，要加上 begin、start transaction 或者 set autocommit = 0。

共享锁（S锁）满足读读共享，读写互斥。独占锁（X锁）满足写写互斥、读写互斥。

和意向共享锁(IS) 意向独占锁(IS)关系如图

|      | `X`      | `IX`       | `S`        | `IS`       |
| ---- | -------- | ---------- | ---------- | ---------- |
| `X`  | Conflict | Conflict   | Conflict   | Conflict   |
| `IX` | Conflict | Compatible | Conflict   | Compatible |
| `S`  | Conflict | Conflict   | Compatible | Compatible |
| `IS` | Conflict | Compatible | Compatible | Compatible |

#### 类型
- Record Lock，记录锁，也就是仅仅把一条记录锁上；
- Gap Lock，间隙锁，锁定一个范围，但是不包含记录本身；
- Next-Key Lock：Record Lock + Gap Lock 的组合，锁定一个范围，并且锁定记录本身。
- Insert Intention Locks: 插入意向锁是一种间隙锁，由 INSERT 操作在行插入之前设置。
#### Record Lock
```text
Record Lock 称为记录锁，锁住的是一条记录。而且记录锁是有 S 锁和 X 锁之分的：

- 当一个事务对一条记录加了 S 型记录锁后，其他事务也可以继续对该记录加 S 型记录锁（S 型与 S 锁兼容），但是不可以对该记录加 X 型记录锁（S 型与 X 锁不兼容）;
- 当一个事务对一条记录加了 X 型记录锁后，其他事务既不可以对该记录加 S 型记录锁（S 型与 X 锁不兼容），也不可以对该记录加 X 型记录锁（X 型与 X 锁不兼容）。
```
```sql
mysql > begin;
mysql > select * from t_test where id = 1 for update;
```
![[Pasted image 20231019202950.png]]
#### Gap Lock
```text
Gap Lock 称为间隙锁，只存在于可重复读隔离级别，目的是为了解决可重复读隔离级别下幻读的现象。

假设，表中有一个范围 id 为（3，5）间隙锁，那么其他事务就无法插入 id = 4 这条记录了，这样就有效的防止幻读现象的发生。

间隙锁虽然存在 X 型间隙锁和 S 型间隙锁，但是并没有什么区别，**间隙锁之间是兼容的，即两个事务可以同时持有包含共同间隙范围的间隙锁，并不存在互斥关系，因为间隙锁的目的是防止插入幻影记录而提出的**。
```
```sql
mysql > begin;
mysql > select * from t_test where id between 3 and 5 for update;
```
![[Pasted image 20231019203058.png]]
#### Next-Key Lock
```text
Next-Key Lock 称为临键锁，是 Record Lock + Gap Lock 的组合，锁定一个范围，并且锁定记录本身。

假设，表中有一个范围 id 为（3，5] 的 next-key lock，那么其他事务即不能插入 id = 4 记录，也不能修改 id = 5 这条记录。

所以，next-key lock 即能保护该记录，又能阻止其他事务将新纪录插入到被保护记录前面的间隙中。

**next-key lock 是包含间隙锁+记录锁的，如果一个事务获取了 X 型的 next-key lock，那么另外一个事务在获取相同范围的 X 型的 next-key lock 时，是会被阻塞的**。
```
![[Pasted image 20231019203607.png]]
#### 插入意向锁
```text
一个事务在插入一条记录的时候，需要判断插入位置是否已被其他事务加了间隙锁（next-key lock 也包含间隙锁）。

如果有的话，插入操作就会发生**阻塞**，直到拥有间隙锁的那个事务提交为止（释放间隙锁的时刻），在此期间会生成一个**插入意向锁**，表明有事务想在某个区间插入新记录，但是现在处于等待状态。

假设事务 A 已经对表加了一个范围 id 为（3，5）间隙锁。

当事务 A 还没提交的时候，事务 B 向该表插入一条 id = 4 的新记录，这时会判断到插入的位置已经被事务 A 加了间隙锁，于是事物 B 会生成一个插入意向锁，然后将锁的状态设置为等待状态（_PS：MySQL 加锁时，是先生成锁结构，然后设置锁的状态，如果锁状态是等待状态，并不是意味着事务成功获取到了锁，只有当锁状态为正常状态时，才代表事务成功获取到了锁_），此时事务 B 就会发生阻塞，直到事务 A 提交了事务。
```

![](https://cdn.xiaolincoding.com/gh/xiaolincoder/mysql/%E9%94%81/gap%E9%94%81.drawio.png)
### Table Lock Manager
 ### 锁类型
```cpp
enum thr_lock_type {  
  TL_IGNORE = -1,  
  TL_UNLOCK, /* UNLOCK ANY LOCK */  
  /*    Parser only! At open_tables() becomes TL_READ or    TL_READ_NO_INSERT depending on the binary log format    (SBR/RBR) and on the table category (log table).    
  Used for tables that are read by statements which    modify tables.  */  
  TL_READ_DEFAULT,  
  TL_READ, /* Read lock */  
  TL_READ_WITH_SHARED_LOCKS,  
  /* High prior. than TL_WRITE. Allow concurrent insert */  
  TL_READ_HIGH_PRIORITY,  
  /* READ, Don't allow concurrent insert */  
  TL_READ_NO_INSERT,  
  /*  
     Write lock, but allow other threads to read / write.     
     Used by BDB tables in MySQL to mark that someone is  reading/writing to the table.   */  
     TL_WRITE_ALLOW_WRITE,  
  /*  
    parser only! Late bound low_priority_flag.    
    At open_tables() becomes thd->insert_lock_default.  */  
    TL_WRITE_CONCURRENT_DEFAULT,  
  /*  
    WRITE lock used by concurrent insert. Will allow    READ, 
    if one could use concurrent insert on table.  */  
    TL_WRITE_CONCURRENT_INSERT,  
  /*  
    parser only! Late bound low_priority flag.    
    At open_tables() becomes thd->update_lock_default.  */  
    TL_WRITE_DEFAULT,  
  /* WRITE lock that has lower priority than TL_READ */  
  TL_WRITE_LOW_PRIORITY,  
  /* Normal WRITE lock */  
  TL_WRITE,  
  /* Abort new lock request with an error */  
  TL_WRITE_ONLY  
};


```
| held \\ request             | TL_READ_DEFAULT | TL_READ | TL_READ_WITH_SHARED_LOCKS | TL_READ_HIGH_PRIORITY | TL_READ_NO_INSERT |
| --------------------------- | --------------- | ------- | ------------------------- | --------------------- | ----------------- |
| TL_WRITE_ALLOW_WRITE        |                 |         |                           |                       |                   |
| TL_WRITE_CONCURRENT_DEFAULT |                 |         |                           |                       |                   |
| TL_WRITE_CONCURRENT_INSERT  |                 |         |                           |                       |                   |
| TL_WRITE_DEFAULT            |                 |         |                           |                       |                   |
| TL_WRITE_LOW_PRIORITY       |                 |         |                           |                       |                   |
| TL_WRITE                    |                 |         |                           |                       |                   |
|        TL_WRITE_ONLY                     |                 |         |                           |                       |                   |


