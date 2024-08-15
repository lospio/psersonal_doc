# 背景
传统数据库中的数据是完整的保存在磁盘上的，但计算却只能发生在内存中，因此需要有良好的机制来**协调内存及磁盘的数据交互，这就是Buffer Pool存在的意义**。也因此Buffer Pool通常按固定长度的Page来管理内存，从而方便的进行跟磁盘的数据换入换出。除此之外，磁盘和内存在访问性能上有着巨大的差距，**如何最小化磁盘的IO就成了Buffer Pool的设计核心目标**。
- 上层调用者先通过索引获得要访问的Page Number（space_id + page_number)；
- 之后用这个Page Number调用Buffer Pool的FIX接口，获得Page并对其进行访问或修改，被FIX的Page不会被换出Buffer Pool；
- 之后调用者通过UNFIX释放Page的锁定状态。
# 结构
## 物理结构
![[Pasted image 20240718165443.png]]
Buffer pool的物理结构自上而下分instance、chunk和page三层
### Buffer pool instance
  - 对应的结构体是buf_pool_t
  - 整个buffer pool由`innodb_buffer_pool_instances`个buffer pool instances组成
  - Instances 之间没有锁竞争
  - 每个Page固定属于其中一个Instances
  - 拥有hash_map, LRU, unzip_LRU, free_list, flush_list等结构方便管理
### Buffer pool chunk
	- 对应的结构体为buf_chunk_t
	- 每个buffer pool instance被均匀划分为多个chunk，buffer pool resize以chunk为粒度
### Buffer pool page
	- 对应的结构体是buf_block_t和buf_page_t，存储控制信息，不需要存储到文件中
	- block 和 page可以相互转换，buf_page_t的第一个成员变量就是buf_page_t
	- block和page存储page_id,页面mutex，page type ，所属链表等等信息
	- 指向数据存储的frame
### Page 类型
- BUF_BLOCK_POOL_WATCH：用于purge操作异步读取磁盘页面的一种类型。每个buf_pool_t结构体中都有一个名为watch的数组，元素类型为buf_page_t，大小为purge线程数+1。当purge操作需要读取一个不在buffer pool中的页面时，会将watch数组中一个BUF_BLOCK_POOL_WATCH状态的页面设置为BUF_BLOCK_ZIP_PAGE，设置对应space id，page id，设置buf_fix_count设置为1防止其被淘汰出buffer pool，并将其加入page hash中（buf_pool_watch_set）。当磁盘数据被读取进入buffer pool时，会将watch数组对应的页面状态恢复为BUF_BLOCK_POOL_WATCH，将watch页面从page hash中删除（buf_pool_watch_remove），后续会将新页面加入page hash中。通过较为tricky地判断存在于page hash的page地址是否在watch数组范围内，可以巧妙地判断目标页面是否成功读入buffer pool。
- BUF_BLOCK_ZIP_PAGE：压缩页未解压的对应状态。从磁盘读取压缩页时，用buf_page_alloc_descriptor分配一个临时页面描述符buf_page_t，再调用buf_buddy_alloc从伙伴系统中分配一个空间存放压缩页原始数据，临时的bpage会被加入LRU list和page hash（buf_page_init_for_read）。这个临时buf_page_t等到页面被解压时，innodb会使用从free_list中申请到的状态为BUF_BLOCK_FILE_PAGE的buf_page_t替换掉临时buf_page_t，放在LRU list相同的位置，并把解压页面的块描述符buf_block_t放入unzip LRU list中；删除page hash中的临时buf_page_t，在其中加入新的buf_page_t；最后通过buf_zip_decompress解压页面（zip_page_handler）。如果解压页被淘汰，而压缩页本身未被淘汰，并且页面未被修改，则此页面会再次被标记为BUF_BLOCK_ZIP_PAGE。关于BUF_BLOCK_ZIP_PAGE的另一个用法如前所述，为在watch操作中被用来标记尚未读入的页面，不再复述。
- BUF_BLOCK_ZIP_DIRTY：压缩页的解压页被释放时，如果页面被修改过（oldest_modification非0），则页面从BUF_BLOCK_FILE_PAGE状态变为BUF_BLOCK_ZIP_DIRTY状态，未被修改过则为BUF_BLOCK_ZIP_PAGE（buf_LRU_free_page/buf_CLOCK_free_page）。解压页被释放后，BUF_BLOCK_ZIP_PAGE/BUF_BLOCK_ZIP_DIRTY压缩页的页面描述符也会在buf_LRU_free_page/buf_CLOCK_free_page临时分配。BUF_BLOCK_ZIP_DIRTY状态的页面无法从LRU/CLOCK list中淘汰，只能在flush_list中等待刷盘。**在flush_list中，也只存在BUF_BLOCK_FILE_PAGE和BUF_BLOCK_ZIP_DIRTY这两种页面。**
- BUF_BLOCK_NOT_USED：页面在free_list中时的状态，此类页面较为常见。
- BUF_BLOCK_READY_FOR_USE：当页面从free list取下，准备放入LRU/CLOCK list（buf_LRU_get_free_block）时处于的临时状态。
- BUF_BLOCK_FILE_PAGE：非压缩页面的页面状态，压缩页解压页的页面状态。最常见的页面状态。
- BUF_BLOCK_MEMORY：用于存储内存对象，包括innodb行锁、AHI（自适应哈希）、压缩页伙伴系统等。此类页面不存在任何逻辑链表中。
- BUF_BLOCK_REMOVE_HASH：页面从page hash删除后，被放入free_list前处于的临时状态
## 逻辑结构
![[Pasted image 20240718165505.png]]
### Page hash
innodb为加速buffer pool中页面的查找，在每个buffer pool instance（buf_pool_t）中提供了page hash。page hash对应的结构体为hash_table_t.
- hash key = hash(page_id), page_id = (space_id, page_no)
- hash value 为buf_page_t，可以直接定位到page
### free list
双向链表，存储未被使用的block
- 初始化的时候会将所有新申请的block加入到该链表
- 申请新的block时，会向该list申请，如果失败就会从LUR list中释放一个block加入该list，再次尝试申请
### LRU list
![[Pasted image 20240718174125.png]]
双向链表，所有读取的page都会存在于该链表，mysql使用改良过后的LRU算法
- 所有新页面被插入距离队尾3/8 LRU list长度的位置，此位置称为midpoint，前5/8称为young list，濒临淘汰的3/8称为old list。
- 处于midpoint的页面在超过一定时间间隔（buf_LRU_old_threshold_ms）后再次被读取时才会被移入LRU list的头部。
- 处于LRU list前1/4的的页面属于热点页面，不会被移动到LRU list的头部（buf_page_peek_if_young）。
### unzip_LRU
是LRU的一个子链表，存放一个LRU中的压缩Page以及解压后的frame。一个block添加到LRU，当且仅当满足于buf_page_belongs_to_unzip_LRU(&block->page)，就会加入到unzip_LRU当中。
### Flush
在buffer pool中发生修改的Page成为脏页，脏页最终都需要写回到磁盘中，这个就是buffer pool的Flush过程。
- 脏页除了存在于LRU list，还会存在于FLush list
- Flush list中的Page大体按照oldest_modification有序排列的，接受在一定范围内（log_sys->recent_closed的容量大小）的乱序
# 机制
## 并发控制  
### 锁类型
- Chunks Mutex 在buffer pool resize的时候保护chunks，n_chunks
- Hash Map Lock  
- List Mutex  
	list都有自己的互斥锁Mutex，对List的读取或修改都需要持有List本身的Mutex这些锁的目的是保护对应的List本身的数据结构，因此会最小化到对List本身数据结构访问和修改的范围内。
- Block Mutex  
	每个Page的控制结构体buf_block_t上都有一个`block->mutex`用来保护这个block的一些诸如io_fix，buf_fix_count、访问时间等状态信息。
- Page Frame Mutex
	buf_block_t上有一个读写锁结构`block->lock`，这个读写锁保护的是真正的page内容，也就是block->frame。在对B+Tree的遍历和修改中都可能需要获取这把锁，除此之外，涉及到Page的IO的过程中也需要持有这把锁。
### 死锁避免
按照从下往上的顺序获取锁
```cpp
enum latch_level_t {
	...
	SYNC_BUF_FLUSH_LIST,  
	SYNC_BUF_FLUSH_STATE,  
	SYNC_BUF_ZIP_HASH,  
	SYNC_BUF_FREE_LIST,  
	SYNC_BUF_ZIP_FREE,  
	SYNC_BUF_BLOCK,  
	SYNC_BUF_PAGE_HASH,  
	SYNC_BUF_IM_LIST,  
	SYNC_BUF_LRU_LIST,  
	SYNC_BUF_CHUNKS,
	...
}
```
### 示例
设想一种场景：一个用户读请求，需要通过`buf_page_get_gen`来获取Page a，首先查找Hash Map发现其不在内存，检查Free List发现也没有空页，只好从LRU的Tail先踢出一个老的Page，将其Block A加入Free List，之后再从磁盘将Page a读入Block A，最后获得这个Page a，并持有其Lock及FIX状态。得到一个如下表所示的加锁过程：
![[Pasted image 20240719142541.png]]
## free list 
1. 添加 - buf_pool_create 过程中，将所有新建的block存入free list - 向free list中申请block，但free list为空时，会从LRU中移除一个block添加到free中 2. 移除 - 如果目标page不在buffer pool中，会重新申请一个空白block，此时向free list申请，成功后会移除一个block - buffer pool resize过程中，如果需要withdraw，则会从free list中移除block ## LRU 1. 添加 - 向buffer pool申请一个Page，该Page未在Page hash中找到时，需要从磁盘读取Page存入buffer pool，此时会从free list申请一个Page承载该内容，然后加入LRU  
- buf_create_page  
2. 移除  
- 向free list申请一个Page，free list为空时，会尝试释放一个LRU中的Page或者对LRU末尾位置申请刷新一页，成功后会移除该Page加入free list  
## 申请block
![[Pasted image 20240704111657.png]]
1. 首先从free list中申请block，如果成功，则返回block，否则继续2
2. 第一轮扫描，从LRU list尾部查找可用的blcok，如果成功，则返回block，否则继续步骤3。如果设置了try_LRU_scan，则调用buf_LRU_scan_and_free_block开始第一轮扫描LRU list，最多从LRU list尾部扫描srv_LRU_scan_depth个block，如果还没成功的话调用buf_flush_single_page_from_LRU将flush list中最尾部的页面刷入磁盘。如果还是没有获取到空闲block则跳转到步骤3重新开始第二轮扫描。
3. 第二轮扫描，即使没有设置try_LRU_scan，也会扫描整个lru list。没有获取到空闲block则再调用buf_flush_single_page_from_LRU将flush list中最尾部的页面刷入磁盘。还是没获取空闲页面则进入第三轮。
4. 第三轮扫描，每轮中间间隔10ms，其他和第二轮扫描相同。
## 读取Page
### 关键代码
```cpp
buf_page_get_gen  
	Buf_fetch<T>::single_page    
		Buf_fetch_normal::get     
			lookup      
			read_page        
				buf_read_page_low          
					buf_page_init_for_read            
						buf_LRU_get_free_block              
							buf_LRU_get_free_only              
							buf_LRU_scan_and_free_block                
								buf_LRU_free_from_unzip_LRU_list                  
									buf_LRU_free_page                    
										buf_LRU_block_remove_hashed                
								buf_LRU_free_from_common_LRU_list              
								buf_flush_single_page_from_LRU         
						buf_LRU_add_block              
							buf_LRU_add_block_low          
					fil_io          
					buf_page_io_complete
```
### 主要函数
| 函数                                | 功能                                      |
| --------------------------------- | --------------------------------------- |
| single_page                       | 从buffer poo中读取Page a，若存在直接返回，否则调用IO读取   |
| lookup                            | 根据传入的page_id在Hash Map中寻找Page            |
| read_page                         | 从磁盘中读取page存入buffer pool                 |
| buf_read_page_low                 | 分配一个新的Block，从磁盘中读取Page，装入该Block         |
| buf_page_init_for_read            | 申请一个未使用的block，完成初始化后加入LRU               |
| buf_LRU_get_free_block            | 申请一个未使用的Block，参考上述申请Block流程             |
| buf_LRU_get_free_only             | 向Free List申请一个Page                      |
| buf_LRU_scan_and_free_block       | 扫描LRU，释放Page                            |
| buf_LRU_free_from_unzip_LRU_list  | 遍历unzip_LRU,查找可替换的Page并释放               |
| buf_LRU_free_from_common_LRU_list | 遍历LRU,查找可替换的Page并释放                     |
| buf_LRU_free_page                 | 释放单个Page，如果是压缩页，则要将解压的Frame释放           |
| buf_LRU_block_remove_hashed       | 从Hash Map,LRU中剔除该页，并且释放Frame            |
| buf_flush_single_page_from_LRU    | 将LRU末尾的Page刷盘，将其从Hash Map，LRU中移除，加入free |
| fil_io                            | 完成io操作读取Page                            |
| buf_page_io_complete              | 设置状态                                    |
# 代码
## 函数
buf_pool_get_oldest_modification_approx
1. 返回flush list中最旧的lsn，即flush list中最早被修改的page上对应的lsn
2. 更新oldest_hp，即尾端位置的指针，flush list尾端。
3. 需要buf_pool->buf_flush_list_mutex
4. 得到的lsn可能out-date

buf_pool_get_oldest_modification_lwm
1. 返回 max(checkpoint, oldest_lsn - lag)


buf_block_alloc 分配一个block
1. 使用局部静态变量buf_pool_index，每次调用时++，用于计算该分配的block位于哪个instance
2. buf_LRU_get_free_block
3. 设置 block状态为BUF_BLOCK_MEMORY

buf_page_print打印一个page的信息



buf_LRU_get_free_block
1. 用户线程调用
2. 首先尝试从free list中获取一个clean block，成功即返回
3. 从lru中尾部查找，成功，存入free list，返回
4. 查找整个lru
5. 如果lru也没有，唤醒page cleaner刷脏页
6. 主动请求刷新lru list最后一页

buf_LRU_get_free_only
1. 从free list中获取一个clean block
2. 修改free list，需要获取 free_list_mutex
3. 每次从头部拿一个block
4. 检查状态，从free list中移除
5. 判断是否需要withdraw
6. 需要的话，假如withdraw list，继续取下一个
7. 否则 成功返回

buf_LRU_scan_and_free_block


buf_LRU_free_from_unzip_LRU_list
1. 判断能否从unzip_LRU中free，参考buf_LRU_evict_from_unzip_LRU
2. 从unzip_LRU list中最后一个block往前遍历，满足条件时free page
3. scan_all 或者 srv_LRU_scan_depth
4. 该函数需要LRU_list_mutex
5. free block时需要block->mutex

buf_LRU_evict_from_unzip_LRU
1. 选择是否从unzip_LRU中清除一个page
2. unzip_LRU为空
3. unzip_LRU长度小于LRU的1/10
4. 没有block从LRU中移除的时候，推测此时是disk bound型，使用unzip_LRU
5. 计算统计数据中的io和unzip_LRU操作数据
6. block存在于unzip_LRU_list, block->page存在于LRU_list
7. 清理unzip_LRU中compressed block对应的存在于LRU_list中的uncompressed page.

buf_LRU_free_page
1. 尝试free block
2. 判断该页can relocate
3. 判断zip || bpage->zip.data（zip为true表明把对应的压缩页一起释放），如果为脏页则退出
4. is_dirty && ！BUF_BLOCK_FILE_PAGE,退出
5. 新申请一个block b
6. 获取hash_lock
7. 继续2,3,4的判断
8. new (b) buf_page_t(*bpage);
9. 从hash 中移除page，下层函数释放hash_lock
12. 获取b->prev, 获取hash_lock的x锁，获取block_mutex，断言判断hash中找不到该page，同时判断变量in_page_hash,in_LRU_list
13. 将b插入hash
11. 将b插入lru中，在prev_b之后
12. 更新LRU_size，LRU_old_len，调整LRU_old的位置
13. 如果prev_b为nullptr，则手动添加一个block b
14. 获取zip_mutex,释放hash_lock
15. 如果为BUF_BLOCK_ZIP_PAGE，在LRU中插入一个干净的压缩页，否则将page移到b的位置


buf_page_can_relocate(buf_page_t *bpage, bool zip)
1. io state == BUF_IO_NONE 同时没有被fix
2. 判断一个block能否被relocated

buf_LRU_block_remove_hashed
1. 判断拥有LRU_list_mutex, page_mutex, hash_lock
2. 从LRU_list中移除page
3. freed_page_clock++
4. 更新modify_clock (每次page过时时更新)
5. 对于!zip（zip为true表示除了清理非压缩页，要将关联的压缩也一起清除）的非压缩页，将非压缩页拷贝到zip.data,保留下来
6. 如果page为index相关，就把对应的index在buffer_pool的page数量更新（减一)
7. 获取hashed_page
8. hashed_page不等于page时，清理资源错误退出
9. 使用HASH_DELETE删除hash_page
10. case BUF_BLOCK_ZIP_PAG（clean zip page），释放page->zip.data，释放bpage
11. case BUF_BLOCK_FILE_PAGE：将frame里面的page_offset 和 space_id置为0xff，设置page state，释放zip.data


buf_block_modify_clock_inc
1. 

buf_LRU_remove_block
1. LRU_list->mutex
2. 调整hazard pointers，如果page位于hazard pointers，就更新为page->prev
3. 调整LRU_old, 如果page位于LRU_old，就更微信page->prev
4. 将page从LUR_list中移除
5. 更新stat.LRU_bytes
6. 从unzip_LRU中移除
7. 如果LRU_list长度小于BUF_LRU_OLD_MIN_LIN, 导致LRU_old没有定义，清除LRU中的的page的old flag，然后返回
8. 否则更新LRU_old LRU_old_len
9. 调整LRU_old

buf_unzip_LRU_remove_block_if_needed
1. 存在于unzip_LRU时，将block从unzip_LRU中移除

buf_page_belongs_to_unzip_LRU
1. 通过page->state和page->zip.data判断是否存在于unzip_LRU

buf_page_hash_get_low (buf_pool_t *buf_pool,  onst page_id_t &page_id)
1. 通过page_id获取hash table的lock
2. 判断具有该hash_lock的读写x锁或者s锁
3. 使用HASH_SEARCH查找对应的page
4. 判断page

buf_page_free_descriptor (buf_page_t *bpage)
1. 重置page_id
2. 释放bpage

buf_LRU_insert_zip_clean


buf_block_init


madvise_dump


buf_chunk_init 给一组buffer frames 申请内存，已经存在的buffer pool可以使用该方法，必须持有free_list_mutex锁
1. 计算申请空间大小（frames + block descriptors）
2. 使用key `mem_key_buf_buf_pool`申请空间