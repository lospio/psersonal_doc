1. 添加InitExtensionCatalogCache函数，该函数初始化extension syscache，并将其添加到当前线程的Syscache中`u_sess->syscache_ctx.SyscCche[]`
2. GetSysCacheOid2    参数问题，去掉第二个参数
3. get_ENR queryEnviroment去掉第三个参数 bool search，在标准版中，如果传入为true，当当前list中不存在该环境变量时，会继续遍历parentEnv，在我们的实现中不存在这种逻辑，于是去掉第三个参数
4. 使用`u_sess->SPI_ctx._current->queryEnv`代替currentQeuryENV
5. 新增`timestamptz2Timestamp`,调用`DirectFunctionCall1`调用sql层的函数实现转换
6. `bbf_table_beginscan_catalog`封装使用了`tableam_beginscan`,内部调用了`GetCatalogSanpshot`#?


# function.
1. get_namedlist 当前缺少获取父级的ENRs
2. `tdsstat_fetch_stat_numbackends` 代替`pgstat_fetch_stat_numbackends`
3. 使用`GlobalTransactionId`代替`FullTransactionId`

# procedures.c
1. `table_beginscan_catalog`
2. `ProcessUtility`