# 1. 要求
将一个表的页面一直放到buffer pool不被淘汰，类似oracle的memtable
# 2. 机制  
## 2.1 Create Page  
 - 从buffer pool中申请一个clean block
 - 使用该block初始化一个page，将该page插入page hash
 - 将page插入LRU list
## 2.2 Get Page
从page hash中根据block->page_id查找对应的page
## 2.3 申请block
![[Pasted image 20240704111657.png]]
1. 首先从free list中申请block，如果成功，则返回block，否则继续2
2. 第一轮扫描，从LRU list尾部查找可用的blcok，如果成功，则返回block，否则继续步骤3。如果设置了try_LRU_scan，则调用buf_LRU_scan_and_free_block开始第一轮扫描LRU list，最多从LRU list尾部扫描srv_LRU_scan_depth个block，如果还没成功的话调用buf_flush_single_page_from_LRU将flush list中最尾部的页面刷入磁盘。如果还是没有获取到空闲block则跳转到步骤3重新开始第二轮扫描。
3. 第二轮扫描，即使没有设置try_LRU_scan，也会扫描整个lru list。没有获取到空闲block则再调用buf_flush_single_page_from_LRU将flush list中最尾部的页面刷入磁盘。还是没获取空闲页面则进入第三轮。
4. 第三轮扫描，每轮中间间隔10ms，其他和第二轮扫描相同。
# 2. 设计
1. 在buffer pool中新增一个IM list，当前表具有in-memory标识时，他的page保存到该list中
2. IM list申请page时从free list中获取clean page;如果free list为空，则申请刷脏，空闲的page放入free list，再次尝试从free list中申请
3. ![[Pasted image 20240704111624.png]]
# 3. 任务拆分
1. 语法
2. 表的元信息，涉及dd table 修改，server，innodb，内存三者之间交互
3. buffer pool新增IM list，unzip_IM list以及相关的锁，基本方法（参照LRU）
4. 完成与hash table，free list，flush list，withdraw list，change buffer，之间的交互
	- hash -> IM list (route)
	- IM list <- free list (allocate from)
	- IM list -> flush list (add to flush)
	- withdraw list ？
	- change buffer ？
5. 数据读取 ？
	- NORMAL
	- SCAN
6. 统计数据
7. 完善
	- 新增清理命令
	- GUC参数
# 4. 限制
1. 非分区表
