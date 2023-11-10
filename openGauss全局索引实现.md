
# 1. 修改模块
## 语法支持
- 创建 index 时,GLOBAL 关键字支持
- 约束当中对 GLOBAL 的支持
```cpp

// tid bitmap scan
-638,12 +658,14 @@ TBMIterateResult* tbm_iterate(TBMIterator* iterator)
      */
     if (iterator->schunkptr < tbm->nchunks) {
         PagetableEntry* chunk = tbm->schunks[iterator->schunkptr];
-        BlockNumber chunk_blockno;
-
-        chunk_blockno = chunk->blockno + iterator->schunkbit;
-        if (iterator->spageptr >= tbm->npages || chunk_blockno < tbm->spages[iterator->spageptr]->blockno) {
+        PagetableEntryNode pnode;
+        pnode.blockNo = chunk->entryNode.blockNo + iterator->schunkbit;
+        pnode.partitionOid = chunk->entryNode.partitionOid;
+        if (iterator->spageptr >= tbm->npages ||
+            IS_CHUNK_BEFORE_PAGE(pnode, tbm->spages[iterator->spageptr]->entryNode)) {
             /* Return a lossy page indicator from the chunk */
-            output->blockno = chunk_blockno;
+            output->blockno = pnode.blockNo;
+            output->partitionOid = pnode.partitionOid;
             output->ntuples = -1;
             output->recheck = true;
             iterator->schunkbit++;
@@ -680,7 +702,8 @@ TBMIterateResult* tbm_iterate(TBMIterator* iterator)
                 }
             }
         }
-        output->blockno = page->blockno;
+        output->blockno = page->entryNode.blockNo;
+        output->partitionOid = page->entryNode.partitionOid;
         output->ntuples = ntuples;
         output->recheck = page->recheck;
         iterator->spageptr++;

// read index tuple
while (offnum <= maxoff) {  
    itup = _bt_checkkeys(scan, page, offnum, dir, &continuescan);  
    if (itup != NULL) {  
        /* Get partition oid for global partition index */  
        isnull = false;  
        partOid = scan->xs_want_ext_oid  
                      ? DatumGetUInt32(index_getattr(itup, PartitionOidAttr, tupdesc, &isnull))  
                      : heapOid;  
        Assert(!isnull);  
        /* tuple passes all scan key conditions, so remember it */  
        _bt_saveitem(so, itemIndex, offnum, itup, partOid);  
        itemIndex++;  
    }  
    if (!continuescan) {  
        /* there can't be any more matches, so stop */  
        so->currPos.moreRight = false;  
        break;  
    }  
  
    offnum = OffsetNumberNext(offnum);  
}

@@ -40,7 +40,7 @@ typedef struct IndexTupleData {
      *
      * 15th (high) bit: has nulls
      * 14th bit: has var-width attributes
-     * 13th bit: unused
+     * 13th bit: AM-defined meaning
      * 12-0 bit: size of tuple
      * ---------------
      */

typedef struct IndexScanDescData {
     AbsIdxScanDescData sd;
     /* scan parameters */
    Relation heapRelation;   /* heap relation descriptor, or NULL */
    Relation indexRelation;  /* index relation descriptor */
+  GPIScanDesc xs_gpi_scan;  /* global partition index scan use information */
    Snapshot xs_snapshot;    /* snapshot to see */
    int numberOfKeys;        /* number of index qualifier conditions */
    int numberOfOrderBys;    /* number of ordering operators */
    ScanKey keyData;         /* array of index qualifier descriptors */
    ScanKey orderByData;     /* array of ordering op descriptors */
    bool xs_want_itup;       /* caller requests index tuples */
    bool xs_want_ext_oid;    /* global partition index need partition oid */
 
     /* signaling to index AM about killing index tuples */
     bool kill_prior_tuple;      /* last-returned tuple is dead */
@@ -162,6 +164,20 @@ typedef struct IndexScanDescData {



@@ -473,6 +519,7 @@ typedef struct BTScanPosItem { /* what we remember about each match */
     ItemPointerData heapTid;   /* TID of referenced heap item */
     OffsetNumber indexOffset;  /* index item's location within page */
     LocationIndex tupleOffset; /* IndexTuple's offset in workspace, if any */
+    Oid partitionOid;          /* partition table oid in workspace, if any */
 } BTScanPosItem;
// 创建全局索引
  
/*  
 * ReindexGlobalIndexInternal - This routine is used to recreate a single global index 
 */
 void ReindexGlobalIndexInternal(Relation heapRelation, Relation iRel, IndexInfo* indexInfo)  
{  
    List* partitionList = NULL;  
    /* We'll open any partition of relation by partition OID and lock it */  
    partitionList = relationGetPartitionList(heapRelation, ShareLock);  
  
    /* We'll build a new physical relation for the index */  
    RelationSetNewRelfilenode(iRel, InvalidTransactionId);  
  
    /* Initialize the index and rebuild */  
    /* Note: we do not need to re-establish pkey setting */    
    index_build(heapRelation, NULL, iRel, NULL, indexInfo, false, true, INDEX_CREATE_GLOBAL_PARTITION);  
  
    releasePartitionList(heapRelation, &partitionList, NoLock);  
  
    // call the internal function, update pg_index system table  
    ATExecSetIndexUsableState(IndexRelationId, iRel->rd_id, true);  
}

// insert index tuple
--- a/src/include/utils/rel.h
+++ b/src/include/utils/rel.h
@@ -154,6 +154,7 @@ typedef struct RelationData {
     bytea* rd_options; /* parsed pg_class.reloptions */
 
     /* These are non-NULL only for an index relation: */
+    Oid rd_partHeapOid;   /* partition index's partition oid */
     Form_pg_index rd_index; /* pg_index tuple describing this index */
     /* use "struct" here to avoid needing to include htup.h: */
     struct HeapTupleData* rd_indextuple; /* all of pg_index tuple */



/* Save an index item into so->currPos.items[itemIndex] */  
static void _bt_saveitem(BTScanOpaque so, int itemIndex, OffsetNumber offnum, const IndexTuple itup, Oid partOid)  
{  
    BTScanPosItem* currItem = &so->currPos.items[itemIndex];  
  
    currItem->heapTid = itup->t_tid;  
    currItem->indexOffset = offnum;  
    currItem->partitionOid = partOid;  
    if (so->currTuples) {  
        Size itupsz = IndexTupleSize(itup);  
  
        currItem->tupleOffset = (uint16)so->currPos.nextTupleOffset;  
        errno_t rc = memcpy_s(so->currTuples + so->currPos.nextTupleOffset, itupsz, itup, itupsz);  
        securec_check(rc, "", "");  
        so->currPos.nextTupleOffset += MAXALIGN(itupsz);  
    }  
}


void tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool recheck, Oid partitionOid)
 {
     int i;
 
@@ -266,6 +282,7 @@ void tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool rech
         BlockNumber blk = ItemPointerGetBlockNumber(tids + i);
         OffsetNumber off = ItemPointerGetOffsetNumber(tids + i);
         PagetableEntry* page = NULL;
+        PagetableEntryNode pageNode = {blk, partitionOid};
         int wordnum, bitnum;
 
         /* safety check to ensure we don't overrun bit array bounds */
@@ -276,11 +293,11 @@ void tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool rech
                     errmsg("tuple offset out of range: %u", off)));
         }
 
-        if (tbm_page_is_lossy(tbm, blk)) {
+        if (tbm_page_is_lossy(tbm, pageNode)) {
             continue; /* whole page is already marked */
         }
 
-        page = tbm_get_pageentry(tbm, blk);
+        page = tbm_get_pageentry(tbm, pageNode);
 
         if (page->ischunk) {
             /* The page is a lossy chunk header, set bit for itself */
...
...
...
}
  */
 void tbm_add_page(TIDBitmap* tbm, BlockNumber pageno)
 {
+    PagetableEntryNode pnode = {pageno, InvalidOid};
     /* Enter the page in the bitmap, or mark it lossy if already present */
-    tbm_mark_page_lossy(tbm, pageno);
+    tbm_mark_page_lossy(tbm, pnode);
     /* If we went over the memory limit, lossify some more pages */
     if (tbm->nentries > tbm->maxentries) {
         tbm_lossify(tbm);
 ...
}



```

## B
```cpp
typedef struct RelationData {
     bytea* rd_options; /* parsed pg_class.reloptions */
 
     /* These are non-NULL only for an index relation: */
+    Oid rd_partHeapOid;   /* partition index's partition oid */
     Form_pg_index rd_index; /* pg_index tuple describing this index */
     /* use "struct" here to avoid needing to include htup.h: */
     struct HeapTupleData* rd_indextuple; /* all of pg_index tuple */
     ...
     ...
 }
/*  
 * btbuild() -- build a new btree index. 
 * */
Datum btbuild(PG_FUNCTION_ARGS)  {
	GlobalIndexBuildHeapScan{
		foreach(partitionCell, partitionIdList) {  
		    partitionId = lfirst_oid(partitionCell);  
		    partition = partitionOpen(heapRelation, partitionId, ShareLock);  
		    heapPartRel = partitionGetRelation(heapRelation, partition);  
		    relTuples = IndexBuildHeapScan(heapPartRel, indexRelation, indexInfo, true, callback, callbackState) {
			    /*  
				 * Scan all tuples in the base relation. 
				 */
				 while ((heapTuple = heap_getnext(scan, ForwardScanDirection)) != NULL) {
					 reltuples += 1;
					 /* Set up for predicate or expression evaluation */  
					(void)ExecStoreTuple(heapTuple, slot, InvalidBuffer, false);
					/*  
					 * For the current heap tuple, extract all the attributes we use in * this index, and note which are null.  This also performs evaluation of any expressions needed. 
					 */
					 FormIndexDatum(indexInfo, slot, estate, values, isnull);
				 }
		    }
		    globalIndexTuples[partitionIdx] = relTuples;  
		    releaseDummyRelation(&heapPartRel);  
		    partitionClose(heapRelation, partition, NoLock);  
		    partitionIdx++;  
		}
	}
	/*  
   * given a spool loaded by successive calls to _bt_spool, * create an entire btree. 
   */
   _bt_leafbuild(buildstate.spool, buildstate.spool2);
}

/*  
 * btgetbitmap() -- gets all matching tuples, and adds them to a bitmap */
 Datum btgetbitmap(PG_FUNCTION_ARGS){
	 /* This loop handles advancing to the next array elements, if any */  
	do {  
	    /* Fetch the first page & tuple */  
	    if (_bt_first(scan, ForwardScanDirection)) {  
	        /* Save tuple ID, and continue scanning */  
	        heapTid = &scan->xs_ctup.t_self;  
+	        Oid currPartOid = so->currPos.items[so->currPos.itemIndex].partitionOid;  
+	        tbm_add_tuples(tbm, heapTid, 1, false, currPartOid);  
	        ntids++;  
	  
	        for (;;) {  
	            /*  
	             * Advance to next tuple within page.  This is the same as the             * easy case in _bt_next().             */            if (++so->currPos.itemIndex > so->currPos.lastItem) {  
	                /* let _bt_next do the heavy lifting */  
	                if (!_bt_next(scan, ForwardScanDirection)) {  
	                    break;  
	                }  
	            }  
	  
	            /* Save tuple ID, and continue scanning */  
	            heapTid = &so->currPos.items[so->currPos.itemIndex].heapTid;  
+	            currPartOid = so->currPos.items[so->currPos.itemIndex].partitionOid;  
+	            tbm_add_tuples(tbm, heapTid, 1, false, currPartOid);  
	            ntids++;  
	        }  
	    }  
	    /* Now see if we have more array keys to deal with */  
	} while (so->numArrayKeys && _bt_advance_array_keys(scan, ForwardScanDirection));
 }

//tidbitmap.cpp

/*  
 * Used as key of hash table for PagetableEntry. 
 */
typedef struct PagetableEntryNode_s {
+    BlockNumber blockNo;    /* page number (hashtable key) */
+    Oid partitionOid;       /* used for GLOBAL partition index to indicate partition table */
+} PagetableEntryNode;


/*  
 * The hashtable entries are represented by this data structure.  For an exact page, blockno is the page number and bit k of the bitmap represents tuple offset k+1.
 */
 typedef struct PagetableEntry {
-    BlockNumber blockno; /* page number (hashtable key) */
+    PagetableEntryNode entryNode;
     bool ischunk;        /* T = lossy storage, F = exact */
     bool recheck;        /* should the tuples be rechecked? */
     bitmapword words[Max(WORDS_PER_PAGE, WORDS_PER_CHUNK)];
 } PagetableEntry;

/*  
 * Here is the representation for a whole TIDBitMap: */
 struct TIDBitmap {  
    NodeTag type;          /* to make it a valid Node */  
    MemoryContext mcxt;    /* memory context containing me */  
    TBMStatus status;      /* see codes above */  
    HTAB* pagetable;       /* hash table of PagetableEntry's */  
    int nentries;          /* number of entries in pagetable */  
    int maxentries;        /* limit on same to meet maxbytes */  
    int npages;            /* number of exact entries in pagetable */  
    int nchunks;           /* number of lossy entries in pagetable */  
    bool iterating;        /* tbm_begin_iterate called? */  
+  bool isGlobalPart;     /* represent global partition index tbm */  
    PagetableEntry entry1; /* used when status == TBM_ONE_PAGE */  
    /* these are valid when iterating is true: */    PagetableEntry** spages;  /* sorted exact-page list, or NULL */  
    PagetableEntry** schunks; /* sorted lossy-chunk list, or NULL */  
};

oid tbm_add_tuples(TIDBitmap* tbm, const ItemPointer tids, int ntids, bool recheck, Oid partitionOid)  
{  
    for (i = 0; i < ntids; i++) {  
        PagetableEntry* page = NULL;  
        PagetableEntryNode pageNode = {blk, partitionOid};  
        int wordnum, bitnum;  
        if (tbm_page_is_lossy(tbm, pageNode)) {  
            continue; /* whole page is already marked */  
        }  
+      page = tbm_get_pageentry(tbm, pageNode){
+			 /* Initialize it if not present before */  
+			if (!found) {  
+			    rc = memset_s(page, sizeof(PagetableEntry), 0, sizeof(PagetableEntry));  
+			    securec_check(rc, "", "");  
+			    page->entryNode.blockNo = pageNode.blockNo;  
+			    page->entryNode.partitionOid = pageNode.partitionOid;  
+			    /* must count it too */  
+			    tbm->nentries++;  
+			    tbm->npages++;  
			}
		}
        if (page->ischunk) {  
            /* The page is a lossy chunk header, set bit for itself */  
            wordnum = bitnum = 0;  
        } else {  
            /* Page is exact, so set bit for individual tuple */  
            wordnum = WORDNUM(off - 1);  
            bitnum = BITNUM(off - 1);  
        }  
        page->words[wordnum] |= ((bitmapword)1 << (unsigned int)bitnum);  
        page->recheck |= recheck;  
  
        if (tbm->nentries > tbm->maxentries) {  
            tbm_lossify(tbm);  
        }  
    }  
}

```


