# Citus 分布式查询
[分布式查询策略](https://docs.citusdata.com/en/v11.0/develop/reference_sql.html)
#### Aggregate Functions
1. 按照分布式列分组，可以把整个查询下推
2. 特定操作，特定处理
	>avg, min, max, sum, count, array_agg, jsonb_agg, jsonb_object_agg, json_agg, json_object_agg, bit_and, bit_or, bool_and, bool_or, every, hll_add_agg, hll_union_agg, topn_add_agg, topn_union_agg, any_value, var_pop(float4), var_pop(float8), var_samp(float4), var_samp(float8), variance(float4), variance(float8) stddev_pop(float4), stddev_pop(float8), stddev_samp(float4), stddev_samp(float8) stddev(float4), stddev(float8) tdigest(double precision, int), tdigest_percentile(double precision, int, double precision), tdigest_percentile(double precision, int, double precision[]), tdigest_percentile(tdigest, double precision), tdigest_percentile(tdigest, double precision[]), tdigest_percentile_of(double precision, int, double precision), tdigest_percentile_of(double precision, int, double precision[]), tdigest_percentile_of(tdigest, double precision), tdigest_percentile_of(tdigest, double precision[])

3. 上述两种情况之外，数据全部汇集到CN

#### 代码
##### 源码
```c++
static List *

WorkerAggregateExpressionList(Aggref *originalAggregate,

                              WorkerAggregateWalkerContext *walkerContext)

{

    AggregateType aggregateType = GetAggregateType(originalAggregate->aggfnoid);

    List *workerAggregateList = NIL;

    AggClauseCosts aggregateCosts;

  

    if (aggregateType == AGGREGATE_COUNT && originalAggregate->aggdistinct &&

        CountDistinctErrorRate == DISABLE_DISTINCT_APPROXIMATION &&

        walkerContext->pullDistinctColumns)

    {

        Aggref *aggregate = (Aggref *) copyObject(originalAggregate);

        List *columnList = pull_var_clause_default((Node *) aggregate);

        ListCell *columnCell = NULL;

        foreach(columnCell, columnList)

        {

            Var *column = (Var *) lfirst(columnCell);

            workerAggregateList = list_append_unique(workerAggregateList, column);

        }

  

        walkerContext->createGroupByClause = true;

    }

    else if (aggregateType == AGGREGATE_COUNT && originalAggregate->aggdistinct &&

             CountDistinctErrorRate != DISABLE_DISTINCT_APPROXIMATION)

    {

        /*

         * If the original aggregate is a count(distinct) approximation, we want

         * to compute hll_add_agg(hll_hash(var), storageSize) on worker nodes.

         */

        const AttrNumber firstArgumentId = 1;

        const AttrNumber secondArgumentId = 2;

        const int hashArgumentCount = 2;

        const int addArgumentCount = 2;

  

        TargetEntry *hashedColumnArgument = NULL;

        TargetEntry *storageSizeArgument = NULL;

        List *addAggregateArgumentList = NIL;

        Aggref *addAggregateFunction = NULL;

  

        /* init hll_hash() related variables */

        Oid argumentType = AggregateArgumentType(originalAggregate);

        TargetEntry *argument = (TargetEntry *) linitial(originalAggregate->args);

        Expr *argumentExpression = copyObject(argument->expr);

  

        /* extract schema name of hll */

        Oid hllId = get_extension_oid(HLL_EXTENSION_NAME, false);

        Oid hllSchemaOid = get_extension_schema(hllId);

        const char *hllSchemaName = get_namespace_name(hllSchemaOid);

  

        char *hashFunctionName = CountDistinctHashFunctionName(argumentType);

        Oid hashFunctionId = FunctionOid(hllSchemaName, hashFunctionName,

                                         hashArgumentCount);

        Oid hashFunctionReturnType = get_func_rettype(hashFunctionId);

  

        /* init hll_add_agg() related variables */

        Oid addFunctionId = FunctionOid(hllSchemaName, HLL_ADD_AGGREGATE_NAME,

                                        addArgumentCount);

        Oid hllType = TypeOid(hllSchemaOid, HLL_TYPE_NAME);

        int logOfStorageSize = CountDistinctStorageSize(CountDistinctErrorRate);

        Const *logOfStorageSizeConst = MakeIntegerConst(logOfStorageSize);

  

        /* construct hll_hash() expression */

        FuncExpr *hashFunction = makeNode(FuncExpr);

        hashFunction->funcid = hashFunctionId;

        hashFunction->funcresulttype = hashFunctionReturnType;

        hashFunction->args = list_make1(argumentExpression);

  

        /* construct hll_add_agg() expression */

        hashedColumnArgument = makeTargetEntry((Expr *) hashFunction,

                                               firstArgumentId, NULL, false);

        storageSizeArgument = makeTargetEntry((Expr *) logOfStorageSizeConst,

                                              secondArgumentId, NULL, false);

        addAggregateArgumentList = list_make2(hashedColumnArgument, storageSizeArgument);

  

        addAggregateFunction = makeNode(Aggref);

        addAggregateFunction->aggfnoid = addFunctionId;

        addAggregateFunction->aggtype = hllType;

        addAggregateFunction->args = addAggregateArgumentList;

        addAggregateFunction->aggkind = AGGKIND_NORMAL;

        addAggregateFunction->aggfilter = (Expr *) copyObject(

            originalAggregate->aggfilter);

  

        workerAggregateList = lappend(workerAggregateList, addAggregateFunction);

    }

    else if (aggregateType == AGGREGATE_AVERAGE)

    {

        /*

         * If the original aggregate is an average, we want to compute sum(var)

         * and count(var) on worker nodes.

         */

        Aggref *sumAggregate = copyObject(originalAggregate);

        Aggref *countAggregate = copyObject(originalAggregate);

  

        /* extract function names for sum and count */

        const char *sumAggregateName = AggregateNames[AGGREGATE_SUM];

        const char *countAggregateName = AggregateNames[AGGREGATE_COUNT];

  

        /*

         * Find the type of the expression over which we execute the aggregate.

         * We then need to find the right sum function for that type.

         */

        Oid argumentType = AggregateArgumentType(originalAggregate);

  

        /* find function implementing sum over the original type */

        sumAggregate->aggfnoid = AggregateFunctionOid(sumAggregateName, argumentType);

        sumAggregate->aggtype = get_func_rettype(sumAggregate->aggfnoid);

  

        sumAggregate->aggtranstype = InvalidOid;

        sumAggregate->aggargtypes = list_make1_oid(argumentType);

        sumAggregate->aggsplit = AGGSPLIT_SIMPLE;

  

        /* count has any input type */

        countAggregate->aggfnoid = AggregateFunctionOid(countAggregateName, ANYOID);

        countAggregate->aggtype = get_func_rettype(countAggregate->aggfnoid);

        countAggregate->aggtranstype = InvalidOid;

        countAggregate->aggargtypes = list_make1_oid(argumentType);

        countAggregate->aggsplit = AGGSPLIT_SIMPLE;

  

        workerAggregateList = lappend(workerAggregateList, sumAggregate);

        workerAggregateList = lappend(workerAggregateList, countAggregate);

    }

    else

    {

        /*

         * All other aggregates are sent as they are to the worker nodes.

         */

        Aggref *workerAggregate = copyObject(originalAggregate);

        workerAggregateList = lappend(workerAggregateList, workerAggregate);

    }

  
  

    /* Run AggRefs through cost machinery to mark required fields sanely */

    memset(&aggregateCosts, 0, sizeof(aggregateCosts));

  

    get_agg_clause_costs(NULL, (Node *) workerAggregateList, AGGSPLIT_SIMPLE,

                         &aggregateCosts);

  

    return workerAggregateList;

}
```
###### 伪代码
```c++
foreach(targetEntryCell, targetEntryList)
{
	if hasAgg && !haveWindowFunction:
	{
		 /*count(distinct) */
		if count(distinct() && disable approximate):
			 遍历每一个column，去掉agg，加入group by clause，当做一般查找列处理
		}
		else if count(distinct() && enable approximate)
		{
			使用hll拓展处理
		}
		else if avg()
		{
			处理变成两个函数sumAgg和countAgg
		}
		else
		{
			不做改变
		}
	}
	else
	{
		不作处理，添加到列表后面
	}
}

将得到的列表，加入worker target list


```