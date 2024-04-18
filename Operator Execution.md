# Execution
输入：plan,树状结构，语法树
输出：results
执行器做的工作就是按照执行计划执行SQL，返回最终结果。
- Data flows from the leaves of the tree up towards the root
- 语法树中的每个节点是一个执行算子，下层节点输入数据，处理完吐出数据给上层节点

up towards the root.
![[Pasted image 20240418190243.png]]
# SORTING
前提：
关系模型中的数据是不排序的
数据排序有两种场景
1. 结果要求排序 order by clause
2. 结果未要求排序，但是排序操作可以优化执行
	- distinct 去重
	- aggregation 聚合函数 group by
	- bulk loading sorted tuples
## IN-MEMORY SORTING
前提：
Data fits in memory
方式：
Use standard sorting algorithm like quicksort
原因：
内存的随机读取很快，不需要考虑数据随机扫描或者顺序扫描带来的性能差异
## EXTERNAL SORTING
前提：
Data does not fit in memory
方式：
需要借助外部资源（磁盘）辅助排序
原因：
内存无法存下所有数据，此时需要借助缓存完成磁盘和内存间的数据交换，进而完成对数据全集的处理，这种情况下必须格外注意磁盘读写数据的代价
## TOP-N HEAP SORT
场景：
order by with limit
实现：
数据扫描一次，在内存中维护一个指定大小的大顶堆（或者小顶堆）
![[Pasted image 20240419003308.png]]
## EXTERNAL MERGE SORT
场景：
Data doesn't fit in memory
实现：
1. 将数据集按照内存能容纳的大小分成多个块
2. 每个块单独排序，再写入磁盘
3. 多个块合并
4. 中间步骤中，内存用完了就flush数据
实例：
DATA with N pages
The DBMS has a finite number of B buffer pool pages
![[Pasted image 20240419004248.png]]
![[Pasted image 20240419021936.png]]
## Two-way Merge Sort
N pages，buffer pool size：B
pass numbers：
1 + ⌈log2N⌉
Total I/O cost：
2N*(pass numbers)
限制：
2-ways 两两分组，B的取值为3已经是效率最高了，继续增大buffer size无法提高速度
## General (K-way) Merge Sort
N pages，buffer pool size：B
pass numbers:
1 + ⌈ logB-1 ⌈N / B⌉ ⌉
Total I/O Cost :
2N ∙ (# of passes)
## Optimization
- double buffer 。减少I/O等待时间。
>	Prefetching the next run in the background and storing it in a second buffer while the system is processing the current run. 

- hardcoded version of sort function 。减少指针寻址时间。
- suffix truncation 。针对较长的varchar类型字符串，使用前缀定长字符比较
# AGGREGATIONS
>Collapse values for a single attribute from multiple tuples into a single scalar value.

将结果按照某些属性进一步划分。
## 实现方式
- Sorting
	- order by clause
- Hashing
	- group by clause
	- distince without order by
	- better than sorting
	
## External hashing aggregate

The data does not fit in memory。
1. partition
	![[Pasted image 20240419023933.png]]
2. rehash
		![[Pasted image 20240419024001.png]]
## Hash Summarization
1. 存储（groupkey，val）
2. rehash时，发现key匹配就更新val
3. 否则插入新的值
![[Pasted image 20240419024257.png]]
# Conclusion
1. Sorting
	- External sorting
	- In-memory sorting
2. Aggregation
	- Sorting :order clause
	- Hash: better choice
	