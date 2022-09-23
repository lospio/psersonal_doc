- what does "Bitmap Heap Scan" phase do?

A plain indexscan fetches one tuple-pointer at a time from the index,  
and immediately visits that tuple in the table. A bitmap scan fetches  
all the tuple-pointers from the index in one go, sorts them using an  
in-memory "bitmap" data structure, and then visits the table tuples in  
physical tuple-location order. The bitmap scan improves locality of  
reference to the table at the cost of more bookkeeping overhead to  
manage the "bitmap" data structure --- and at the cost that the data  
is no longer retrieved in index order, which doesn't matter for your  
query but would matter if you said ORDER BY.

- what is "Recheck condition" and why is it needed?

If the bitmap gets too large we convert it to "lossy" style, in which we  
only remember which pages contain matching tuples instead of remembering  
each tuple individually. When that happens, the table-visiting phase  
has to examine each tuple on the page and recheck the scan condition to  
see which tuples to return.

- why are proposed "width" fields in the plan different between the two  
 plans?

Updated statistics about average column widths, presumably.

 (actually, a nice explanation what exactly are those widths would also  
 be nice :) )

Sum of the average widths of the columns being fetched from the table.

- I thought "Bitmap Index Scan" was only used when there are two or more  
 applicable indexes in the plan, so I don't understand why is it used  
 now?

True, we can combine multiple bitmaps via AND/OR operations to merge  
results from multiple indexes before visiting the table ... but it's  
still potentially worthwhile even for one index. A rule of thumb is  
that plain indexscan wins for fetching a small number of tuples, bitmap  
scan wins for a somewhat larger number of tuples, and seqscan wins if  
you're fetching a large percentage of the whole table.

regards, tom lane
[BitmapScan](https://www.postgresql.org/message-id/12553.1135634231@sss.pgh.pa.us)


## 理解
1. 多个index and or 组合查询
2. 一次取所有的index pointer按磁盘顺序读取 每个tuple
3. 数据量大的时候使用bitmap scan，小的时候使用plain index scan
4. 数据量大的时候，使用loosy模式，近似筛选一遍，在按照index contidition recheck
5. 选择率
# TODO
-