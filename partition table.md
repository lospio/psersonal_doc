
# openGauss
```sql
create table tt01 (a int primary key, b int unique, c int) partition by range(c)(partition p1 values less than (5000),partition p2 values less than (MAXVALUE));
```
# MySQL
```sql
SELECT   partition_name part,   partition_expression expr,   partition_description descr,   FROM_DAYS(partition_description) lessthan_sendtime,   table_rows FROM   INFORMATION_SCHEMA.partitions WHERE   TABLE_SCHEMA = SCHEMA() AND TABLE_NAME='rc';



create table t1(a int, b datetime default(sysdate)) partition by range(a)(partition p0 values less than (10) , partition p1 values less than (100),partition p2 values less than (MAXVALUE));
```
insert
```cpp
* thread #40, name = 'connection', stop reason = breakpoint 3.1
  * frame #0: 0x00000001053212e4 mysqld`partition_info::is_full_part_expr_in_fields(this=0x000000012e502af8, fields=0x000000013b812050) at partition_info.cc:1922:24
    frame #1: 0x0000000105320f30 mysqld`partition_info::can_prune_insert(this=0x000000012e502af8, thd=0x000000013c009600, duplic=DUP_ERROR, update=0x000000016cb293d8, update_fields=0x000000013b8120c0, fields=0x000000013b812050, empty_values=false, can_prune_partitions=0x000000016cb294cc, prune_needs_default_values=0x000000016cb293bf, used_partitions=0x000000016cb293c0) at partition_info.cc:425:10
    frame #2: 0x000000010557dbd0 mysqld`Sql_cmd_insert_base::prepare_inner(this=0x000000013b812018, thd=0x000000013c009600) at sql_insert.cc:1450:34
    frame #3: 0x0000000105693944 mysqld`Sql_cmd_dml::prepare(this=0x000000013b812018, thd=0x000000013c009600) at sql_select.cc:395:9
    frame #4: 0x000000010569492c mysqld`Sql_cmd_dml::execute(this=0x000000013b812018, thd=0x000000013c009600) at sql_select.cc:533:9
    frame #5: 0x00000001055e5a48 mysqld`mysql_execute_command(thd=0x000000013c009600, first_level=true) at sql_parse.cc:3578:29
    frame #6: 0x00000001055e1258 mysqld`dispatch_sql_command(thd=0x000000013c009600, parser_state=0x000000016cb2d7a8) at sql_parse.cc:5240:19
    frame #7: 0x00000001055dd234 mysqld`dispatch_command(thd=0x000000013c009600, com_data=0x000000016cb2ee40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #8: 0x00000001055df814 mysqld`do_command(thd=0x000000013c009600) at sql_parse.cc:1363:7
    frame #9: 0x00000001058c329c mysqld`handle_connection(arg=0x0000600001248000) at connection_handler_per_thread.cc:302:13
    frame #10: 0x000000010754caa0 mysqld`pfs_spawn_thread(arg=0x0000000113d042a0) at pfs.cc:2942:3
    frame #11: 0x0000000184beb034

(lldb) bt
* thread #41, name = 'connection', stop reason = breakpoint 2.1
  * frame #0: 0x00000001026e51b0 mysqld`Partition_helper::ph_write_row(this=0x00000001371b0030, buf="\xf9\U00000001") at partition_handler.cc:455:8
    frame #1: 0x00000001043befbc mysqld`ha_innopart::write_row(this=0x00000001371b0030, record="\xf9\U00000001") at ha_innopart.h:1039:34
    frame #2: 0x00000001022cab48 mysqld`handler::ha_write_row(this=0x00000001371b0030, buf="\xf9\U00000001") at handler.cc:7873:3
    frame #3: 0x000000010292fb04 mysqld`write_record(thd=0x0000000113818600, table=0x00000001371aba20, info=0x000000016f7756a8, update=0x000000016f775630) at sql_insert.cc:2168:36
    frame #4: 0x000000010292dd30 mysqld`Sql_cmd_insert_values::execute_inner(this=0x0000000137083218, thd=0x0000000113818600) at sql_insert.cc:640:11
    frame #5: 0x0000000102a48d84 mysqld`Sql_cmd_dml::execute(this=0x0000000137083218, thd=0x0000000113818600) at sql_select.cc:586:7
    frame #6: 0x0000000102999a48 mysqld`mysql_execute_command(thd=0x0000000113818600, first_level=true) at sql_parse.cc:3578:29
    frame #7: 0x0000000102995258 mysqld`dispatch_sql_command(thd=0x0000000113818600, parser_state=0x000000016f7797a8) at sql_parse.cc:5240:19
    frame #8: 0x0000000102991234 mysqld`dispatch_command(thd=0x0000000113818600, com_data=0x000000016f77ae40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #9: 0x0000000102993814 mysqld`do_command(thd=0x0000000113818600) at sql_parse.cc:1363:7
    frame #10: 0x0000000102c7729c mysqld`handle_connection(arg=0x0000600001e1c000) at connection_handler_per_thread.cc:302:13
    frame #11: 0x0000000104900aa0 mysqld`pfs_spawn_thread(arg=0x0000000110a056b0) at pfs.cc:2942:3
    frame #12: 0x0000000184beb034

// primary key  报错逻辑
(lldb) bt
* thread #41, name = 'connection', stop reason = breakpoint 2.1
  * frame #0: 0x0000000103ecac68 mysqld`my_error(nr=1503, MyFlags=0) at my_error.cc:218:3
    frame #1: 0x0000000102aafbbc mysqld`check_primary_key(table=0x000000016f66d988) at sql_partition.cc:1022:7
    frame #2: 0x0000000102aaea28 mysqld`fix_partition_func(thd=0x000000012a00dc00, table=0x000000016f66d988, is_create_table_ind=true) at sql_partition.cc:1580:16
    frame #3: 0x0000000102c960f0 mysqld`unpack_partition_info(thd=0x000000012a00dc00, outparam=0x000000016f66d988, share=0x000000016f66e318, engine_type=0x000000013f806b40, is_create_table=true) at table.cc:2736:13
    frame #4: 0x0000000102c96ef0 mysqld`open_table_from_share(thd=0x000000012a00dc00, share=0x000000016f66e318, alias="", db_stat=0, prgflag=1, ha_open_flags=0, outparam=0x000000016f66d988, is_create_table=true, table_def_param=0x0000000000000000) at table.cc:2979:7
    frame #5: 0x00000001023c59f0 mysqld`ha_create_table(thd=0x000000012a00dc00, path="./code/tt111", db="code", table_name="tt111", create_info=0x000000016f671878, update_create_info=false, is_temp_table=false, table_def=0x000000013d73db60) at handler.cc:5107:7
    frame #6: 0x0000000102be712c mysqld`rea_create_base_table(thd=0x000000012a00dc00, path="./code/tt111", sch_obj=0x0000600001518020, db="code", table_name="tt111", create_info=0x000000016f671878, create_fields=0x000000016f6717f0, keys=1, key_info=0x000000012c857048, keys_onoff=ENABLE, fk_keys=0, fk_key_info=0x000000012c857128, check_cons_spec=0x000000016f6717d0, file=0x000000012c856230, no_ha_table=false, do_not_store_in_dd=false, part_info=0x000000013d9b43e0, binlog_to_trx_cache=0x000000016f670b0e, table_def_ptr=0x000000016f6704c8, post_ddl_ht=0x000000016f670b00) at sql_table.cc:1173:7
    frame #7: 0x0000000102baa1a0 mysqld`create_table_impl(thd=0x000000012a00dc00, schema=0x0000600001518020, db="code", table_name="tt111", error_table_name="tt111", path="./code/tt111", create_info=0x000000016f671878, alter_info=0x000000016f671710, internal_tmp_table=false, select_field_count=0, find_parent_keys=true, no_ha_table=false, do_not_store_in_dd=false, is_trans=0x000000016f670b0e, key_info=0x000000016f6704e8, key_count=0x000000016f6704e4, keys_onoff=ENABLE, fk_key_info=0x000000016f6704d8, fk_key_count=0x000000016f6704d4, existing_fk_info=0x0000000000000000, existing_fk_count=0, existing_fk_table=0x0000000000000000, fk_max_generated_name_number=0, table_def=0x000000016f6704c8, post_ddl_ht=0x000000016f670b00) at sql_table.cc:8935:9
    frame #8: 0x0000000102ba80b0 mysqld`mysql_create_table_no_lock(thd=0x000000012a00dc00, db="code", table_name="tt111", create_info=0x000000016f671878, alter_info=0x000000016f671710, select_field_count=0, find_parent_keys=true, is_trans=0x000000016f670b0e, post_ddl_ht=0x000000016f670b00) at sql_table.cc:9176:10
    frame #9: 0x0000000102bad5b0 mysqld`mysql_create_table(thd=0x000000012a00dc00, create_table=0x000000013d9b3568, create_info=0x000000016f671878, alter_info=0x000000016f671710) at sql_table.cc:10108:12
    frame #10: 0x00000001029d3230 mysqld`Sql_cmd_create_table::execute(this=0x000000013d9b41b8, thd=0x000000012a00dc00) at sql_cmd_ddl_table.cc:433:13
    frame #11: 0x0000000102a9da48 mysqld`mysql_execute_command(thd=0x000000012a00dc00, first_level=true) at sql_parse.cc:3578:29
    frame #12: 0x0000000102a99258 mysqld`dispatch_sql_command(thd=0x000000012a00dc00, parser_state=0x000000016f6757a8) at sql_parse.cc:5240:19
    frame #13: 0x0000000102a95234 mysqld`dispatch_command(thd=0x000000012a00dc00, com_data=0x000000016f676e40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #14: 0x0000000102a97814 mysqld`do_command(thd=0x000000012a00dc00) at sql_parse.cc:1363:7
    frame #15: 0x0000000102d7b29c mysqld`handle_connection(arg=0x0000600002a04000) at connection_handler_per_thread.cc:302:13
    frame #16: 0x0000000104a04aa0 mysqld`pfs_spawn_thread(arg=0x0000000110b04490) at pfs.cc:2942:3
    frame #17: 0x0000000184beb034

// unique
* thread #41, name = 'connection', stop reason = breakpoint 3.1
  * frame #0: 0x00000001049bec68 mysqld`my_error(nr=1503, MyFlags=0) at my_error.cc:218:3
    frame #1: 0x00000001035a3d2c mysqld`check_unique_keys(table=0x000000016eb79988) at sql_partition.cc:1064:9
    frame #2: 0x00000001035a2acc mysqld`fix_partition_func(thd=0x0000000112812a00, table=0x000000016eb79988, is_create_table_ind=true) at sql_partition.cc:1584:16
    frame #3: 0x000000010378a0f0 mysqld`unpack_partition_info(thd=0x0000000112812a00, outparam=0x000000016eb79988, share=0x000000016eb7a318, engine_type=0x00000001487054e0, is_create_table=true) at table.cc:2736:13
    frame #4: 0x000000010378aef0 mysqld`open_table_from_share(thd=0x0000000112812a00, share=0x000000016eb7a318, alias="", db_stat=0, prgflag=1, ha_open_flags=0, outparam=0x000000016eb79988, is_create_table=true, table_def_param=0x0000000000000000) at table.cc:2979:7
    frame #5: 0x0000000102eb99f0 mysqld`ha_create_table(thd=0x0000000112812a00, path="./code/tttt", db="code", table_name="tttt", create_info=0x000000016eb7d878, update_create_info=false, is_temp_table=false, table_def=0x00000001487eb280) at handler.cc:5107:7
    frame #6: 0x00000001036db12c mysqld`rea_create_base_table(thd=0x0000000112812a00, path="./code/tttt", sch_obj=0x00006000015d04d0, db="code", table_name="tttt", create_info=0x000000016eb7d878, create_fields=0x000000016eb7d7f0, keys=1, key_info=0x000000011285ca48, keys_onoff=ENABLE, fk_keys=0, fk_key_info=0x000000011285cb28, check_cons_spec=0x000000016eb7d7d0, file=0x000000011285bc30, no_ha_table=false, do_not_store_in_dd=false, part_info=0x000000014a225be0, binlog_to_trx_cache=0x000000016eb7cb0e, table_def_ptr=0x000000016eb7c4c8, post_ddl_ht=0x000000016eb7cb00) at sql_table.cc:1173:7
    frame #7: 0x000000010369e1a0 mysqld`create_table_impl(thd=0x0000000112812a00, schema=0x00006000015d04d0, db="code", table_name="tttt", error_table_name="tttt", path="./code/tttt", create_info=0x000000016eb7d878, alter_info=0x000000016eb7d710, internal_tmp_table=false, select_field_count=0, find_parent_keys=true, no_ha_table=false, do_not_store_in_dd=false, is_trans=0x000000016eb7cb0e, key_info=0x000000016eb7c4e8, key_count=0x000000016eb7c4e4, keys_onoff=ENABLE, fk_key_info=0x000000016eb7c4d8, fk_key_count=0x000000016eb7c4d4, existing_fk_info=0x0000000000000000, existing_fk_count=0, existing_fk_table=0x0000000000000000, fk_max_generated_name_number=0, table_def=0x000000016eb7c4c8, post_ddl_ht=0x000000016eb7cb00) at sql_table.cc:8935:9
    frame #8: 0x000000010369c0b0 mysqld`mysql_create_table_no_lock(thd=0x0000000112812a00, db="code", table_name="tttt", create_info=0x000000016eb7d878, alter_info=0x000000016eb7d710, select_field_count=0, find_parent_keys=true, is_trans=0x000000016eb7cb0e, post_ddl_ht=0x000000016eb7cb00) at sql_table.cc:9176:10
    frame #9: 0x00000001036a15b0 mysqld`mysql_create_table(thd=0x0000000112812a00, create_table=0x000000014a224d68, create_info=0x000000016eb7d878, alter_info=0x000000016eb7d710) at sql_table.cc:10108:12
    frame #10: 0x00000001034c7230 mysqld`Sql_cmd_create_table::execute(this=0x000000014a2259b8, thd=0x0000000112812a00) at sql_cmd_ddl_table.cc:433:13
    frame #11: 0x0000000103591a48 mysqld`mysql_execute_command(thd=0x0000000112812a00, first_level=true) at sql_parse.cc:3578:29
    frame #12: 0x000000010358d258 mysqld`dispatch_sql_command(thd=0x0000000112812a00, parser_state=0x000000016eb817a8) at sql_parse.cc:5240:19
    frame #13: 0x0000000103589234 mysqld`dispatch_command(thd=0x0000000112812a00, com_data=0x000000016eb82e40, command=COM_QUERY) at sql_parse.cc:1960:7


// insert 第一次
(lldb) bt
* thread #41, name = 'connection', stop reason = step over
  * frame #0: 0x00000001051a1a68 mysqld`get_partition_id_range(part_info=0x00000001258656f8, part_id=0x000000016cf8908c, func_value=0x000000016cf89080) at sql_partition.cc:3094:3
    frame #1: 0x0000000104ec1870 mysqld`partition_info::set_used_partition(this=0x00000001258656f8, thd=0x0000000125012800, fields=0x0000000125048850, values=0x0000000125047770, info=0x000000016cf89450, copy_default_values=false, used_partitions=0x000000016cf893c0) at partition_info.cc:513:20
    frame #2: 0x000000010511dcac mysqld`Sql_cmd_insert_base::prepare_inner(this=0x0000000125048818, thd=0x0000000125012800) at sql_insert.cc:1470:36
    frame #3: 0x0000000105233944 mysqld`Sql_cmd_dml::prepare(this=0x0000000125048818, thd=0x0000000125012800) at sql_select.cc:395:9
    frame #4: 0x000000010523492c mysqld`Sql_cmd_dml::execute(this=0x0000000125048818, thd=0x0000000125012800) at sql_select.cc:533:9
    frame #5: 0x0000000105185a48 mysqld`mysql_execute_command(thd=0x0000000125012800, first_level=true) at sql_parse.cc:3578:29
    frame #6: 0x0000000105181258 mysqld`dispatch_sql_command(thd=0x0000000125012800, parser_state=0x000000016cf8d7a8) at sql_parse.cc:5240:19
    frame #7: 0x000000010517d234 mysqld`dispatch_command(thd=0x0000000125012800, com_data=0x000000016cf8ee40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #8: 0x000000010517f814 mysqld`do_command(thd=0x0000000125012800) at sql_parse.cc:1363:7
    frame #9: 0x000000010546329c mysqld`handle_connection(arg=0x0000600003df0260) at connection_handler_per_thread.cc:302:13
    frame #10: 0x00000001070ecaa0 mysqld`pfs_spawn_thread(arg=0x0000000113204700) at pfs.cc:2942:3
    frame #11: 0x0000000188e27034

// insert 第二次
* thread #41, name = 'connection', stop reason = breakpoint 3.1
  * frame #0: 0x000000010518d80c mysqld`get_partition_id_range(part_info=0x00000001302b86f8, part_id=0x000000016cf9cec4, func_value=0x000000016cf9ceb8) at sql_partition.cc:3060:27
    frame #1: 0x0000000104ebd358 mysqld`Partition_helper::ph_write_row(this=0x00000001302b6430, buf="\xf9\U00000014'") at partition_handler.cc:502:11
    frame #2: 0x0000000106b96fbc mysqld`ha_innopart::write_row(this=0x00000001302b6430, record="\xf9\U00000014'") at ha_innopart.h:1039:34
    frame #3: 0x0000000104aa2b48 mysqld`handler::ha_write_row(this=0x00000001302b6430, buf="\xf9\U00000014'") at handler.cc:7873:3
    frame #4: 0x0000000105107b04 mysqld`write_record(thd=0x000000013400a200, table=0x00000001302b4220, info=0x000000016cf9d6a8, update=0x000000016cf9d630) at sql_insert.cc:2168:36
    frame #5: 0x0000000105105d30 mysqld`Sql_cmd_insert_values::execute_inner(this=0x000000011d83aa18, thd=0x000000013400a200) at sql_insert.cc:640:11
    frame #6: 0x0000000105220d84 mysqld`Sql_cmd_dml::execute(this=0x000000011d83aa18, thd=0x000000013400a200) at sql_select.cc:586:7
    frame #7: 0x0000000105171a48 mysqld`mysql_execute_command(thd=0x000000013400a200, first_level=true) at sql_parse.cc:3578:29
    frame #8: 0x000000010516d258 mysqld`dispatch_sql_command(thd=0x000000013400a200, parser_state=0x000000016cfa17a8) at sql_parse.cc:5240:19
    frame #9: 0x0000000105169234 mysqld`dispatch_command(thd=0x000000013400a200, com_data=0x000000016cfa2e40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #10: 0x000000010516b814 mysqld`do_command(thd=0x000000013400a200) at sql_parse.cc:1363:7
    frame #11: 0x000000010544f29c mysqld`handle_connection(arg=0x0000600001878000) at connection_handler_per_thread.cc:302:13
    frame #12: 0x00000001070d8aa0 mysqld`pfs_spawn_thread(arg=0x000000011d4043f0) at pfs.cc:2942:3
    frame #13: 0x0000000188e27034
 thread #41, name = 'connection', stop reason = breakpoint 3.1

//insert 第三次
  * frame #0: 0x000000010518d80c mysqld`get_partition_id_range(part_info=0x00000001302b86f8, part_id=0x000000016cf9cbb4, func_value=0x000000016cf9cba8) at sql_partition.cc:3060:27
    frame #1: 0x00000001060618b8 mysqld`get_rpl_part_id(part_info=0x00000001302b86f8) at log_event.cc:7655:5
    frame #2: 0x00000001060315a8 mysqld`Rows_log_event* THD::binlog_prepare_pending_rows_event<Write_rows_log_event>(this=0x000000013400a200, table=0x00000001302b4220, serv_id=1, needed=10, is_transactional=true, extra_row_info=0x0000000000000000, source_part_id=2147483647) at binlog.cc:10769:18
    frame #3: 0x00000001060312e4 mysqld`THD::binlog_write_row(this=0x000000013400a200, table=0x00000001302b4220, is_trans=true, record="\xf9\U00000014'", extra_row_info=0x0000000000000000) at binlog.cc:11069:7
    frame #4: 0x00000001060720cc mysqld`Write_rows_log_event::binlog_row_logging_function(thd_arg=0x000000013400a200, table=0x00000001302b4220, is_transactional=true, before_record=0x0000000000000000, after_record="\xf9\U00000014'") at log_event.cc:11777:19
    frame #5: 0x0000000104aa1f08 mysqld`binlog_log_row(table=0x00000001302b4220, before_record=0x0000000000000000, after_record="\xf9\U00000014'", log_func=(mysqld`Write_rows_log_event::binlog_row_logging_function(THD*, TABLE*, bool, unsigned char const*, unsigned char const*) at log_event.cc:11776))(THD*, TABLE*, bool, unsigned char const*, unsigned char const*)) at handler.cc:7779:15
    frame #6: 0x0000000104aa2d2c mysqld`handler::ha_write_row(this=0x00000001302b6430, buf="\xf9\U00000014'") at handler.cc:7878:25
    frame #7: 0x0000000105107b04 mysqld`write_record(thd=0x000000013400a200, table=0x00000001302b4220, info=0x000000016cf9d6a8, update=0x000000016cf9d630) at sql_insert.cc:2168:36
    frame #8: 0x0000000105105d30 mysqld`Sql_cmd_insert_values::execute_inner(this=0x000000011d83aa18, thd=0x000000013400a200) at sql_insert.cc:640:11
    frame #9: 0x0000000105220d84 mysqld`Sql_cmd_dml::execute(this=0x000000011d83aa18, thd=0x000000013400a200) at sql_select.cc:586:7
    frame #10: 0x0000000105171a48 mysqld`mysql_execute_command(thd=0x000000013400a200, first_level=true) at sql_parse.cc:3578:29
    frame #11: 0x000000010516d258 mysqld`dispatch_sql_command(thd=0x000000013400a200, parser_state=0x000000016cfa17a8) at sql_parse.cc:5240:19
    frame #12: 0x0000000105169234 mysqld`dispatch_command(thd=0x000000013400a200, com_data=0x000000016cfa2e40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #13: 0x000000010516b814 mysqld`do_command(thd=0x000000013400a200) at sql_parse.cc:1363:7
    frame #14: 0x000000010544f29c mysqld`handle_connection(arg=0x0000600001878000) at connection_handler_per_thread.cc:302:13
    frame #15: 0x00000001070d8aa0 mysqld`pfs_spawn_thread(arg=0x000000011d4043f0) at pfs.cc:2942:3
    frame #16: 0x0000000188e27034

// select
* thread #41, name = 'connection', stop reason = breakpoint 6.1
  * frame #0: 0x000000010199a394 mysqld`Query_expression::ExecuteIteratorQuery(this=0x0000000139381080, thd=0x0000000117809600) at sql_union.cc:1315:30
    frame #1: 0x000000010199a790 mysqld`Query_expression::execute(this=0x0000000139381080, thd=0x0000000117809600) at sql_union.cc:1343:10
    frame #2: 0x00000001018b5b28 mysqld`Sql_cmd_dml::execute_inner(this=0x0000000139383750, thd=0x0000000117809600) at sql_select.cc:786:15
    frame #3: 0x00000001018b4d84 mysqld`Sql_cmd_dml::execute(this=0x0000000139383750, thd=0x0000000117809600) at sql_select.cc:586:7
    frame #4: 0x000000010180957c mysqld`mysql_execute_command(thd=0x0000000117809600, first_level=true) at sql_parse.cc:4605:29
    frame #5: 0x0000000101801258 mysqld`dispatch_sql_command(thd=0x0000000117809600, parser_state=0x000000017090d7a8) at sql_parse.cc:5240:19
    frame #6: 0x00000001017fd234 mysqld`dispatch_command(thd=0x0000000117809600, com_data=0x000000017090ee40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #7: 0x00000001017ff814 mysqld`do_command(thd=0x0000000117809600) at sql_parse.cc:1363:7
    frame #8: 0x0000000101ae329c mysqld`handle_connection(arg=0x0000600000594000) at connection_handler_per_thread.cc:302:13
    frame #9: 0x000000010376caa0 mysqld`pfs_spawn_thread(arg=0x000000010ff04810) at pfs.cc:2942:3
    frame #10: 0x0000000188e27034

(lldb) bt
* thread #41, name = 'connection', stop reason = step in
  * frame #0: 0x0000000104d595d0 mysqld`Partition_helper::ph_rnd_next(this=0x0000000125975630, buf="\xff") at partition_handler.cc:1535:7
    frame #1: 0x0000000106a2ee1c mysqld`ha_innopart::rnd_next(this=0x0000000125975630, record="\xff") at ha_innopart.h:1109:31
    frame #2: 0x00000001049285b8 mysqld`handler::ha_rnd_next(this=0x0000000125975630, buf="\xff") at handler.cc:2896:3
    frame #3: 0x0000000104b7c410 mysqld`TableScanIterator::Read(this=0x00000001259a53c0) at basic_row_iterators.cc:214:32
    frame #4: 0x0000000104b7e864 mysqld`FilterIterator::Read(this=0x00000001259a53f0) at composite_iterators.cc:76:25
    frame #5: 0x000000010519e1bc mysqld`Query_expression::ExecuteIteratorQuery(this=0x00000001259a1080, thd=0x0000000149814200) at sql_union.cc:1290:36
    frame #6: 0x000000010519e790 mysqld`Query_expression::execute(this=0x00000001259a1080, thd=0x0000000149814200) at sql_union.cc:1343:10
    frame #7: 0x00000001050b9b28 mysqld`Sql_cmd_dml::execute_inner(this=0x00000001259a3750, thd=0x0000000149814200) at sql_select.cc:786:15
    frame #8: 0x00000001050b8d84 mysqld`Sql_cmd_dml::execute(this=0x00000001259a3750, thd=0x0000000149814200) at sql_select.cc:586:7
    frame #9: 0x000000010500d57c mysqld`mysql_execute_command(thd=0x0000000149814200, first_level=true) at sql_parse.cc:4605:29
    frame #10: 0x0000000105005258 mysqld`dispatch_sql_command(thd=0x0000000149814200, parser_state=0x000000016d1097a8) at sql_parse.cc:5240:19
    frame #11: 0x0000000105001234 mysqld`dispatch_command(thd=0x0000000149814200, com_data=0x000000016d10ae40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #12: 0x0000000105003814 mysqld`do_command(thd=0x0000000149814200) at sql_parse.cc:1363:7
    frame #13: 0x00000001052e729c mysqld`handle_connection(arg=0x0000600001470000) at connection_handler_per_thread.cc:302:13
    frame #14: 0x0000000106f70aa0 mysqld`pfs_spawn_thread(arg=0x00000001131042a0) at pfs.cc:2942:3
    frame #15: 0x0000000188e27034



* thread #40, name = 'connection', stop reason = breakpoint 1.1
  * frame #0: 0x0000000101627580 mysqld`partition_info::partition_info(this=0x0000000144b78888) at partition_info.h:464:16
    frame #1: 0x0000000101625da0 mysqld`partition_info::partition_info(this=0x0000000144b78888) at partition_info.h:463:37
    frame #2: 0x0000000100c26c78 mysqld`PT_partition::PT_partition(this=0x0000000144b78838, part_type_def=0x0000000144b784b0, opt_num_parts=0, opt_sub_part=0x0000000000000000, part_defs_pos=0x00000001791e6a50, part_defs=0x0000000144b78778) at parse_tree_partitions.h:606:3
    frame #3: 0x0000000100c19a0c mysqld`PT_partition::PT_partition(this=0x0000000144b78838, part_type_def=0x0000000144b784b0, opt_num_parts=0, opt_sub_part=0x0000000000000000, part_defs_pos=0x00000001791e6a50, part_defs=0x0000000144b78778) at parse_tree_partitions.h:613:30
    frame #4: 0x0000000100bc8670 mysqld`MYSQLparse(YYTHD=0x0000000117013800, parse_tree=0x00000001791e8288) at sql_yacc.yy:6256:47
    frame #5: 0x00000001013bbc94 mysqld`THD::sql_parser(this=0x0000000117013800) at sql_class.cc:3037:7
    frame #6: 0x00000001014e513c mysqld`parse_sql(thd=0x0000000117013800, parser_state=0x00000001791e97a8, creation_ctx=0x0000000000000000) at sql_parse.cc:7057:34
    frame #7: 0x00000001014d8aa8 mysqld`dispatch_sql_command(thd=0x0000000117013800, parser_state=0x00000001791e97a8) at sql_parse.cc:5136:11
    frame #8: 0x00000001014d52a0 mysqld`dispatch_command(thd=0x0000000117013800, com_data=0x00000001791eae40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #9: 0x00000001014d7880 mysqld`do_command(thd=0x0000000117013800) at sql_parse.cc:1363:7
    frame #10: 0x00000001017bb29c mysqld`handle_connection(arg=0x0000600000ffc1a0) at connection_handler_per_thread.cc:302:13
    frame #11: 0x0000000103444aa0 mysqld`pfs_spawn_thread(arg=0x0000000113904a50) at pfs.cc:2942:3
    frame #12: 0x0000000188f73034


* thread #42, name = 'connection', stop reason = breakpoint 2.1
  * frame #0: 0x0000000100a0d8a0 mysqld`PT_partition::contextualize(this=0x0000000138185918, pc=0x0000000171431c20) at parse_tree_partitions.cc:474:35
    frame #1: 0x00000001003ae654 mysqld`MYSQLparse(YYTHD=0x0000000113832000, parse_tree=0x0000000171433a58) at sql_yacc.yy:2196:13
    frame #2: 0x0000000100bb3c94 mysqld`THD::sql_parser(this=0x0000000113832000) at sql_class.cc:3037:7
    frame #3: 0x0000000100cdd13c mysqld`parse_sql(thd=0x0000000113832000, parser_state=0x0000000171433c58, creation_ctx=0x0000000000000000) at sql_parse.cc:7057:34
    frame #4: 0x0000000100ceca14 mysqld`mysql_unpack_partition(thd=0x0000000113832000, part_buf=" PARTITION BY RANGE (`id`)\n(PARTITION p1 VALUES LESS THAN (100) ENGINE = InnoDB,\n PARTITION p2 VALUES LESS THAN MAXVALUE ENGINE = InnoDB)", part_info_len=137, table=0x0000000171435988, is_create_table_ind=true, default_db_type=0x0000000137f06e90, work_part_info_used=0x00000001714352ba) at sql_partition.cc:3912:7
    frame #5: 0x0000000100ecdf5c mysqld`unpack_partition_info(thd=0x0000000113832000, outparam=0x0000000171435988, share=0x0000000171436318, engine_type=0x0000000137f06e90, is_create_table=true) at table.cc:2716:9
    frame #6: 0x0000000100eceef0 mysqld`open_table_from_share(thd=0x0000000113832000, share=0x0000000171436318, alias="", db_stat=0, prgflag=1, ha_open_flags=0, outparam=0x0000000171435988, is_create_table=true, table_def_param=0x0000000000000000) at table.cc:2979:7
    frame #7: 0x00000001005fda5c mysqld`ha_create_table(thd=0x0000000113832000, path="./pat/t", db="pat", table_name="t", create_info=0x0000000171439878, update_create_info=false, is_temp_table=false, table_def=0x0000000137f616e0) at handler.cc:5107:7
    frame #8: 0x0000000100e1f12c mysqld`rea_create_base_table(thd=0x0000000113832000, path="./pat/t", sch_obj=0x000060000226c7a0, db="pat", table_name="t", create_info=0x0000000171439878, create_fields=0x00000001714397f0, keys=0, key_info=0x000000011482acf0, keys_onoff=ENABLE, fk_keys=0, fk_key_info=0x000000011482acf0, check_cons_spec=0x00000001714397d0, file=0x0000000114829ee0, no_ha_table=false, do_not_store_in_dd=false, part_info=0x0000000114829a00, binlog_to_trx_cache=0x0000000171438b0e, table_def_ptr=0x00000001714384c8, post_ddl_ht=0x0000000171438b00) at sql_table.cc:1173:7
    frame #9: 0x0000000100de21a0 mysqld`create_table_impl(thd=0x0000000113832000, schema=0x000060000226c7a0, db="pat", table_name="t", error_table_name="t", path="./pat/t", create_info=0x0000000171439878, alter_info=0x0000000171439710, internal_tmp_table=false, select_field_count=0, find_parent_keys=true, no_ha_table=false, do_not_store_in_dd=false, is_trans=0x0000000171438b0e, key_info=0x00000001714384e8, key_count=0x00000001714384e4, keys_onoff=ENABLE, fk_key_info=0x00000001714384d8, fk_key_count=0x00000001714384d4, existing_fk_info=0x0000000000000000, existing_fk_count=0, existing_fk_table=0x0000000000000000, fk_max_generated_name_number=0, table_def=0x00000001714384c8, post_ddl_ht=0x0000000171438b00) at sql_table.cc:8935:9
    frame #10: 0x0000000100de00b0 mysqld`mysql_create_table_no_lock(thd=0x0000000113832000, db="pat", table_name="t", create_info=0x0000000171439878, alter_info=0x0000000171439710, select_field_count=0, find_parent_keys=true, is_trans=0x0000000171438b0e, post_ddl_ht=0x0000000171438b00) at sql_table.cc:9176:10
    frame #11: 0x0000000100de55b0 mysqld`mysql_create_table(thd=0x0000000113832000, create_table=0x0000000114828c30, create_info=0x0000000171439878, alter_info=0x0000000171439710) at sql_table.cc:10108:12
    frame #12: 0x0000000100c0b29c mysqld`Sql_cmd_create_table::execute(this=0x00000001148297e0, thd=0x0000000113832000) at sql_cmd_ddl_table.cc:433:13
    frame #13: 0x0000000100cd5ab4 mysqld`mysql_execute_command(thd=0x0000000113832000, first_level=true) at sql_parse.cc:3578:29
    frame #14: 0x0000000100cd12c4 mysqld`dispatch_sql_command(thd=0x0000000113832000, parser_state=0x000000017143d7a8) at sql_parse.cc:5240:19
    frame #15: 0x0000000100ccd2a0 mysqld`dispatch_command(thd=0x0000000113832000, com_data=0x000000017143ee40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #16: 0x0000000100ccf880 mysqld`do_command(thd=0x0000000113832000) at sql_parse.cc:1363:7
    frame #17: 0x0000000100fb329c mysqld`handle_connection(arg=0x0000600001d58360) at connection_handler_per_thread.cc:302:13
    frame #18: 0x0000000102c3caa0 mysqld`pfs_spawn_thread(arg=0x000000010ff0bac0) at pfs.cc:2942:3
    frame #19: 0x0000000185997034
* thread #42, name = 'connection', stop reason = step over
  * frame #0: 0x0000000103465924 mysqld`PT_partition::contextualize(this=0x00000001428ed518, pc=0x000000016e9d9c20) at parse_tree_partitions.cc:482:7
    frame #1: 0x0000000102e06654 mysqld`MYSQLparse(YYTHD=0x0000000142148000, parse_tree=0x000000016e9dba58) at sql_yacc.yy:2196:13
    frame #2: 0x000000010360bc94 mysqld`THD::sql_parser(this=0x0000000142148000) at sql_class.cc:3037:7
    frame #3: 0x000000010373513c mysqld`parse_sql(thd=0x0000000142148000, parser_state=0x000000016e9dbc58, creation_ctx=0x0000000000000000) at sql_parse.cc:7057:34
    frame #4: 0x0000000103744a14 mysqld`mysql_unpack_partition(thd=0x0000000142148000, part_buf=" PARTITION BY RANGE (`id`)\n(PARTITION p1 VALUES LESS THAN (100) ENGINE = InnoDB,\n PARTITION p2 VALUES LESS THAN MAXVALUE ENGINE = InnoDB)", part_info_len=137, table=0x000000016e9dd988, is_create_table_ind=true, default_db_type=0x0000000141e05be0, work_part_info_used=0x000000016e9dd2ba) at sql_partition.cc:3912:7
    frame #5: 0x0000000103925f5c mysqld`unpack_partition_info(thd=0x0000000142148000, outparam=0x000000016e9dd988, share=0x000000016e9de318, engine_type=0x0000000141e05be0, is_create_table=true) at table.cc:2716:9
    frame #6: 0x0000000103926ef0 mysqld`open_table_from_share(thd=0x0000000142148000, share=0x000000016e9de318, alias="", db_stat=0, prgflag=1, ha_open_flags=0, outparam=0x000000016e9dd988, is_create_table=true, table_def_param=0x0000000000000000) at table.cc:2979:7
    frame #7: 0x0000000103055a5c mysqld`ha_create_table(thd=0x0000000142148000, path="./pat/t", db="pat", table_name="t", create_info=0x000000016e9e1878, update_create_info=false, is_temp_table=false, table_def=0x0000000141f5d960) at handler.cc:5107:7
    frame #8: 0x000000010387712c mysqld`rea_create_base_table(thd=0x0000000142148000, path="./pat/t", sch_obj=0x0000600001a18b60, db="pat", table_name="t", create_info=0x000000016e9e1878, create_fields=0x000000016e9e17f0, keys=0, key_info=0x00000001428d8ef0, keys_onoff=ENABLE, fk_keys=0, fk_key_info=0x00000001428d8ef0, check_cons_spec=0x000000016e9e17d0, file=0x00000001428d80e0, no_ha_table=false, do_not_store_in_dd=false, part_info=0x00000001428d7c00, binlog_to_trx_cache=0x000000016e9e0b0e, table_def_ptr=0x000000016e9e04c8, post_ddl_ht=0x000000016e9e0b00) at sql_table.cc:1173:7
    frame #9: 0x000000010383a1a0 mysqld`create_table_impl(thd=0x0000000142148000, schema=0x0000600001a18b60, db="pat", table_name="t", error_table_name="t", path="./pat/t", create_info=0x000000016e9e1878, alter_info=0x000000016e9e1710, internal_tmp_table=false, select_field_count=0, find_parent_keys=true, no_ha_table=false, do_not_store_in_dd=false, is_trans=0x000000016e9e0b0e, key_info=0x000000016e9e04e8, key_count=0x000000016e9e04e4, keys_onoff=ENABLE, fk_key_info=0x000000016e9e04d8, fk_key_count=0x000000016e9e04d4, existing_fk_info=0x0000000000000000, existing_fk_count=0, existing_fk_table=0x0000000000000000, fk_max_generated_name_number=0, table_def=0x000000016e9e04c8, post_ddl_ht=0x000000016e9e0b00) at sql_table.cc:8935:9
    frame #10: 0x00000001038380b0 mysqld`mysql_create_table_no_lock(thd=0x0000000142148000, db="pat", table_name="t", create_info=0x000000016e9e1878, alter_info=0x000000016e9e1710, select_field_count=0, find_parent_keys=true, is_trans=0x000000016e9e0b0e, post_ddl_ht=0x000000016e9e0b00) at sql_table.cc:9176:10
    frame #11: 0x000000010383d5b0 mysqld`mysql_create_table(thd=0x0000000142148000, create_table=0x00000001428d6e30, create_info=0x000000016e9e1878, alter_info=0x000000016e9e1710) at sql_table.cc:10108:12
    frame #12: 0x000000010366329c mysqld`Sql_cmd_create_table::execute(this=0x00000001428d79e0, thd=0x0000000142148000) at sql_cmd_ddl_table.cc:433:13
    frame #13: 0x000000010372dab4 mysqld`mysql_execute_command(thd=0x0000000142148000, first_level=true) at sql_parse.cc:3578:29
    frame #14: 0x00000001037292c4 mysqld`dispatch_sql_command(thd=0x0000000142148000, parser_state=0x000000016e9e57a8) at sql_parse.cc:5240:19
    frame #15: 0x00000001037252a0 mysqld`dispatch_command(thd=0x0000000142148000, com_data=0x000000016e9e6e40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #16: 0x0000000103727880 mysqld`do_command(thd=0x0000000142148000) at sql_parse.cc:1363:7
    frame #17: 0x0000000103a0b29c mysqld`handle_connection(arg=0x0000600002515800) at connection_handler_per_thread.cc:302:13
    frame #18: 0x0000000105694aa0 mysqld`pfs_spawn_thread(arg=0x0000000115556e20) at pfs.cc:2942:3
    frame #19: 0x0000000185997034

* thread #42, name = 'connection', stop reason = breakpoint 14.1
  * frame #0: 0x0000000106d22c68 mysqld`my_error(nr=1054, MyFlags=0) at my_error.cc:218:3
    frame #1: 0x00000001057a6698 mysqld`find_field_in_tables(thd=0x000000011e00a200, item=0x00000001561b3b88, first_table=0x00000001561b5960, last_table=0x0000000000000000, ref=0x000000016c814868, report_error=REPORT_ALL_ERRORS, want_privilege=0, register_tree_change=true) at sql_base.cc:8078:9
    frame #2: 0x000000010529e984 mysqld`Item_field::fix_fields(this=0x00000001561b3b88, thd=0x000000011e00a200, reference=0x000000016c814868) at item.cc:5654:18
    frame #3: 0x00000001059074a8 mysqld`fix_fields_part_func(thd=0x000000011e00a200, func_expr=0x00000001561b3b88, table=0x000000016c815988, is_sub_part=false, is_create_table_ind=true) at sql_partition.cc:950:27
    frame #4: 0x000000010590677c mysqld`fix_partition_func(thd=0x000000011e00a200, table=0x000000016c815988, is_create_table_ind=true) at sql_partition.cc:1540:20
    frame #5: 0x0000000105aee0f0 mysqld`unpack_partition_info(thd=0x000000011e00a200, outparam=0x000000016c815988, share=0x000000016c816318, engine_type=0x0000000154e07de0, is_create_table=true) at table.cc:2736:13
    frame #6: 0x0000000105aeeef0 mysqld`open_table_from_share(thd=0x000000011e00a200, share=0x000000016c816318, alias="", db_stat=0, prgflag=1, ha_open_flags=0, outparam=0x000000016c815988, is_create_table=true, table_def_param=0x0000000000000000) at table.cc:2979:7
    frame #7: 0x000000010521da5c mysqld`ha_create_table(thd=0x000000011e00a200, path="./pat/t2", db="pat", table_name="t2", create_info=0x000000016c819878, update_create_info=false, is_temp_table=false, table_def=0x0000000147bc0a00) at handler.cc:5107:7
    frame #8: 0x0000000105a3f12c mysqld`rea_create_base_table(thd=0x000000011e00a200, path="./pat/t2", sch_obj=0x00006000009d3ef0, db="pat", table_name="t2", create_info=0x000000016c819878, create_fields=0x000000016c8197f0, keys=0, key_info=0x00000001561b53a8, keys_onoff=ENABLE, fk_keys=0, fk_key_info=0x00000001561b53a8, check_cons_spec=0x000000016c8197d0, file=0x00000001561b4598, no_ha_table=false, do_not_store_in_dd=false, part_info=0x00000001561b40b8, binlog_to_trx_cache=0x000000016c818b0e, table_def_ptr=0x000000016c8184c8, post_ddl_ht=0x000000016c818b00) at sql_table.cc:1173:7
    frame #9: 0x0000000105a021a0 mysqld`create_table_impl(thd=0x000000011e00a200, schema=0x00006000009d3ef0, db="pat", table_name="t2", error_table_name="t2", path="./pat/t2", create_info=0x000000016c819878, alter_info=0x000000016c819710, internal_tmp_table=false, select_field_count=0, find_parent_keys=true, no_ha_table=false, do_not_store_in_dd=false, is_trans=0x000000016c818b0e, key_info=0x000000016c8184e8, key_count=0x000000016c8184e4, keys_onoff=ENABLE, fk_key_info=0x000000016c8184d8, fk_key_count=0x000000016c8184d4, existing_fk_info=0x0000000000000000, existing_fk_count=0, existing_fk_table=0x0000000000000000, fk_max_generated_name_number=0, table_def=0x000000016c8184c8, post_ddl_ht=0x000000016c818b00) at sql_table.cc:8935:9
    frame #10: 0x0000000105a000b0 mysqld`mysql_create_table_no_lock(thd=0x000000011e00a200, db="pat", table_name="t2", create_info=0x000000016c819878, alter_info=0x000000016c819710, select_field_count=0, find_parent_keys=true, is_trans=0x000000016c818b0e, post_ddl_ht=0x000000016c818b00) at sql_table.cc:9176:10
    frame #11: 0x0000000105a055b0 mysqld`mysql_create_table(thd=0x000000011e00a200, create_table=0x00000001561b32e8, create_info=0x000000016c819878, alter_info=0x000000016c819710) at sql_table.cc:10108:12
    frame #12: 0x000000010582b29c mysqld`Sql_cmd_create_table::execute(this=0x00000001561b3e98, thd=0x000000011e00a200) at sql_cmd_ddl_table.cc:433:13
    frame #13: 0x00000001058f5ab4 mysqld`mysql_execute_command(thd=0x000000011e00a200, first_level=true) at sql_parse.cc:3578:29
    frame #14: 0x00000001058f12c4 mysqld`dispatch_sql_command(thd=0x000000011e00a200, parser_state=0x000000016c81d7a8) at sql_parse.cc:5240:19
    frame #15: 0x00000001058ed2a0 mysqld`dispatch_command(thd=0x000000011e00a200, com_data=0x000000016c81ee40, command=COM_QUERY) at sql_parse.cc:1960:7
    frame #16: 0x00000001058ef880 mysqld`do_command(thd=0x000000011e00a200) at sql_parse.cc:1363:7
    frame #17: 0x0000000105bd329c mysqld`handle_connection(arg=0x00006000036f4000) at connection_handler_per_thread.cc:302:13
    frame #18: 0x000000010785caa0 mysqld`pfs_spawn_thread(arg=0x0000000113a040a0) at pfs.cc:2942:3
    frame #19: 0x0000000185997034



// index
* thread #42, name = 'connection', stop reason = breakpoint 8.1
  * frame #0: 0x0000000102d14ac4 mysqld`btr_create(type=0, space=70, index_id=368, index=0x0000000117911eb0, mtr=0x0000000280a97c88) at btr0btr.cc:839:3
    frame #1: 0x0000000102e83408 mysqld`dict_create_index_tree_in_mem(index=0x0000000117911eb0, trx=0x0000000124611000) at dict0crea.cc:425:13
    frame #2: 0x0000000102f50d18 mysqld`ddl::create_index(trx=0x0000000124611000, table=0x000000010f951110, index_def=0x0000000117910a88, add_v=0x0000000000000000) at ddl0ddl.cc:242:9
    frame #3: 0x00000001031503f8 mysqld`bool prepare_inplace_alter_table_dict<dd::Table>(ha_alter_info=0x0000000280a9a960, altered_table=0x000000011790cc20, old_table=0x000000012f8dd820, old_dd_tab=0x000000012f799c10, new_dd_tab=0x000000010f952450, table_name="t", flags=33, flags2=2064, fts_doc_id_col=18446744073709551615, add_fts_doc_id=false, add_fts_doc_id_idx=false) at handler0alter.cc:4855:9
    frame #4: 0x0000000103131d6c mysqld`bool ha_innobase::prepare_inplace_alter_table_impl<dd::Table>(this=0x000000012f8f0e30, altered_table=0x000000011790cc20, ha_alter_info=0x0000000280a9a960, old_dd_tab=0x000000012f799c10, new_dd_tab=0x000000010f952450) at handler0alter.cc:6010:10
    frame #5: 0x000000010312f278 mysqld`ha_innobase::prepare_inplace_alter_table(this=0x000000012f8f0e30, altered_table=0x000000011790cc20, ha_alter_info=0x0000000280a9a960, old_dd_tab=0x000000012f799c10, new_dd_tab=0x000000010f952450) at handler0alter.cc:1411:10
    frame #6: 0x0000000100ffa62c mysqld`handler::ha_prepare_inplace_alter_table(this=0x000000012f8f0e30, altered_table=0x000000011790cc20, ha_alter_info=0x0000000280a9a960, old_table_def=0x000000012f799c10, new_table_def=0x000000010f952450) at handler.cc:4994:10
    frame #7: 0x000000010181bfa4 mysqld`mysql_inplace_alter_table(thd=0x000000012f8f5e00, schema=0x0000600000eba3c0, new_schema=0x0000600000eba3c0, table_def=0x000000012f799c10, altered_table_def=0x000000010f952450, table_list=0x000000012f969208, table=0x000000012f8dd820, altered_table=0x000000011790cc20, ha_alter_info=0x0000000280a9a960, inplace_supported=HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE, alter_ctx=0x0000000280a9c4d0, columns=size=0, fk_key_info=0x000000012f96ac90, fk_key_count=0, fk_invalidator=0x0000000280a9aca8) at sql_table.cc:13581:22
    frame #8: 0x0000000101810250 mysqld`mysql_alter_table(thd=0x000000012f8f5e00, new_db="pat", new_name="t", create_info=0x0000000280a9d720, table_list=0x000000012f969208, alter_info=0x0000000280a9d5b8) at sql_table.cc:17707:11
    frame #9: 0x000000010161d9f4 mysqld`Sql_cmd_create_or_drop_index_base::execute(this=0x000000012f9699f8, thd=0x000000012f8f5e00) at sql_cmd_ddl_table.cc:547:7
    frame #10: 0x00000001016ea988 mysqld`mysql_execute_command(thd=0x000000012f8f5e00, first_level=true) at sql_parse.cc:3621:29
    frame #11: 0x00000001016e6160 mysqld`dispatch_sql_command(thd=0x000000012f8f5e00, parser_state=0x0000000280aa1738) at sql_parse.cc:5322:19
    frame #12: 0x00000001016e20cc mysqld`dispatch_command(thd=0x000000012f8f5e00, com_data=0x0000000280aa2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #13: 0x00000001016e46d4 mysqld`do_command(thd=0x000000012f8f5e00) at sql_parse.cc:1394:18
    frame #14: 0x00000001019ccea4 mysqld`handle_connection(arg=0x00006000031b02a0) at connection_handler_per_thread.cc:302:13
    frame #15: 0x000000010367cad0 mysqld`pfs_spawn_thread(arg=0x000000010f807aa0) at pfs.cc:2942:3
    frame #16: 0x0000000186063034


// create table
* thread #41, name = 'connection', stop reason = breakpoint 5.1
  * frame #0: 0x0000000104370ac4 mysqld`btr_create(type=259, space=2, index_id=18446744073709551615, index=0x00000001598c06b0, mtr=0x00000001779e6ee8) at btr0btr.cc:839:3
    frame #1: 0x0000000104380c38 mysqld`btr_sdi_create(space_id=2, mtr=0x00000001779e6ee8, table=0x0000000158f58660) at btr0btr.cc:4673:17
    frame #2: 0x00000001043807e4 mysqld`btr_sdi_create_index(space_id=2, dict_locked=false) at btr0btr.cc:4703:23
    frame #3: 0x00000001044de158 mysqld`dict_build_tablespace_for_table(table=0x0000000158f58060, create_info=0x00000001779ed718, trx=0x0000000140e69000) at dict0crea.cc:300:11
    frame #4: 0x00000001044dd7d0 mysqld`dict_build_table_def(table=0x0000000158f58060, create_info=0x00000001779ed718, trx=0x0000000140e69000) at dict0crea.cc:85:17
    frame #5: 0x0000000104a180b0 mysqld`row_create_table_for_mysql(table=0x00000001779e83e8, compression=0x0000000000000000, create_info=0x00000001779ed718, trx=0x0000000140e69000, heap=0x00000001598c1218) at row0mysql.cc:2758:9
    frame #6: 0x000000010470d324 mysqld`create_table_info_t::create_table_def(this=0x00000001779e8d00, dd_table=0x0000000158f56be0, old_part_table=0x0000000000000000) at ha_innodb.cc:11986:13
    frame #7: 0x000000010470ab6c mysqld`create_table_info_t::create_table(this=0x00000001779e8d00, dd_table=0x0000000158f56be0, old_part_table=0x0000000000000000) at ha_innodb.cc:13957:11
    frame #8: 0x000000010477db50 mysqld`ha_innopart::create(this=0x000000015a4eec30, name="./pat/t", form=0x00000001779e9728, create_info=0x00000001779ed718, table_def=0x0000000158f56be0) at ha_innopart.cc:2593:23
    frame #9: 0x0000000102656aec mysqld`handler::ha_create(this=0x000000015a4eec30, name="./pat/t", form=0x00000001779e9728, info=0x00000001779ed718, table_def=0x0000000158f56be0) at handler.cc:5137:10
    frame #10: 0x0000000102657314 mysqld`ha_create_table(thd=0x0000000119810a00, path="./pat/t", db="pat", table_name="t", create_info=0x00000001779ed718, update_create_info=false, is_temp_table=false, table_def=0x0000000158f56be0, recycle_original_create_info=0x0000000000000000) at handler.cc:5323:23
    frame #11: 0x0000000102e93bb0 mysqld`rea_create_base_table(thd=0x0000000119810a00, path="./pat/t", sch_obj=0x0000600002580020, db="pat", table_name="t", create_info=0x00000001779ed718, create_fields=0x00000001779ed690, keys=0, key_info=0x000000011a817b40, keys_onoff=ENABLE, fk_keys=0, fk_key_info=0x000000011a817b40, check_cons_spec=0x00000001779ed670, file=0x000000011a816bf0, no_ha_table=false, do_not_store_in_dd=false, part_info=0x000000011901c9e0, binlog_to_trx_cache=0x00000001779ec91e, table_def_ptr=0x00000001779ec2c8, post_ddl_ht=0x00000001779ec910) at sql_table.cc:1183:7
    frame #12: 0x0000000102e55a00 mysqld`create_table_impl(thd=0x0000000119810a00, schema=0x0000600002580020, db="pat", table_name="t", error_table_name="t", path="./pat/t", create_info=0x00000001779ed718, alter_info=0x00000001779ed5b0, internal_tmp_table=false, select_field_count=0, find_parent_keys=true, no_ha_table=false, do_not_store_in_dd=false, is_trans=0x00000001779ec91e, key_info=0x00000001779ec2e8, key_count=0x00000001779ec2e4, keys_onoff=ENABLE, fk_key_info=0x00000001779ec2d8, fk_key_count=0x00000001779ec2d4, existing_fk_info=0x0000000000000000, existing_fk_count=0, existing_fk_table=0x0000000000000000, fk_max_generated_name_number=0, table_def=0x00000001779ec2c8, post_ddl_ht=0x00000001779ec910) at sql_table.cc:9089:9
    frame #13: 0x0000000102e53910 mysqld`mysql_create_table_no_lock(thd=0x0000000119810a00, db="pat", table_name="t", create_info=0x00000001779ed718, alter_info=0x00000001779ed5b0, select_field_count=0, find_parent_keys=true, is_trans=0x00000001779ec91e, post_ddl_ht=0x00000001779ec910) at sql_table.cc:9330:10
    frame #14: 0x0000000102e58e84 mysqld`mysql_create_table(thd=0x0000000119810a00, create_table=0x000000011901bfe0, create_info=0x00000001779ed718, alter_info=0x00000001779ed5b0) at sql_table.cc:10274:12
    frame #15: 0x0000000102c78e44 mysqld`Sql_cmd_create_table::execute(this=0x000000011901c8b8, thd=0x0000000119810a00) at sql_cmd_ddl_table.cc:434:13
    frame #16: 0x0000000102d46988 mysqld`mysql_execute_command(thd=0x0000000119810a00, first_level=true) at sql_parse.cc:3621:29
    frame #17: 0x0000000102d42160 mysqld`dispatch_sql_command(thd=0x0000000119810a00, parser_state=0x00000001779f1738) at sql_parse.cc:5322:19
    frame #18: 0x0000000102d3e0cc mysqld`dispatch_command(thd=0x0000000119810a00, com_data=0x00000001779f2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #19: 0x0000000102d406d4 mysqld`do_command(thd=0x0000000119810a00) at sql_parse.cc:1394:18
    frame #20: 0x0000000103028ea4 mysqld`handle_connection(arg=0x0000600001a8c000) at connection_handler_per_thread.cc:302:13
    frame #21: 0x0000000104cd8ad0 mysqld`pfs_spawn_thread(arg=0x0000000118f04aa0) at pfs.cc:2942:3
    frame #22: 0x000000018b12f034

// alter table add index
(lldb) bt
* thread #41, name = 'connection', stop reason = breakpoint 5.1
  * frame #0: 0x0000000104370ac4 mysqld`btr_create(type=0, space=2, index_id=161, index=0x00000001598c2ab0, mtr=0x00000001779e7488) at btr0btr.cc:839:3
    frame #1: 0x00000001044df408 mysqld`dict_create_index_tree_in_mem(index=0x00000001598c2ab0, trx=0x0000000140e69000) at dict0crea.cc:425:13
    frame #2: 0x00000001045acd18 mysqld`ddl::create_index(trx=0x0000000140e69000, table=0x0000000158f58060, index_def=0x000000015a4e9c88, add_v=0x0000000000000000) at ddl0ddl.cc:242:9
    frame #3: 0x00000001047c5f20 mysqld`bool prepare_inplace_alter_table_dict<dd::Partition>(ha_alter_info=0x00000001779ea280, altered_table=0x00000001598bde20, old_table=0x000000015a4e9020, old_dd_tab=0x000000011a2090f0, new_dd_tab=0x000000015b0d6cd0, table_name="t", flags=33, flags2=2064, fts_doc_id_col=18446744073709551615, add_fts_doc_id=false, add_fts_doc_id_idx=false) at handler0alter.cc:4855:9
    frame #4: 0x000000010479f3f0 mysqld`bool ha_innobase::prepare_inplace_alter_table_impl<dd::Partition>(this=0x000000015a4e4e30, altered_table=0x00000001598bde20, ha_alter_info=0x00000001779ea280, old_dd_tab=0x000000011a2090f0, new_dd_tab=0x000000015b0d6cd0) at handler0alter.cc:6010:10
    frame #5: 0x000000010479c10c mysqld`ha_innopart::prepare_inplace_alter_table(this=0x000000015a4e4e30, altered_table=0x00000001598bde20, ha_alter_info=0x00000001779ea280, old_table_def=0x000000011a006210, new_table_def=0x000000015b0d5db0) at handler0alter.cc:10349:11
    frame #6: 0x000000010265662c mysqld`handler::ha_prepare_inplace_alter_table(this=0x000000015a4e4e30, altered_table=0x00000001598bde20, ha_alter_info=0x00000001779ea280, old_table_def=0x000000011a006210, new_table_def=0x000000015b0d5db0) at handler.cc:4994:10
    frame #7: 0x0000000102e77fa4 mysqld`mysql_inplace_alter_table(thd=0x0000000119810a00, schema=0x0000600002580020, new_schema=0x0000600002580020, table_def=0x000000011a006210, altered_table_def=0x000000015b0d5db0, table_list=0x000000011a817a20, table=0x000000015a4e9020, altered_table=0x00000001598bde20, ha_alter_info=0x00000001779ea280, inplace_supported=HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE, alter_ctx=0x00000001779ebdf0, columns=size=0, fk_key_info=0x000000015a4f7cc0, fk_key_count=0, fk_invalidator=0x00000001779ea5c8) at sql_table.cc:13581:22
    frame #8: 0x0000000102e6c250 mysqld`mysql_alter_table(thd=0x0000000119810a00, new_db="pat", new_name=0x0000000000000000, create_info=0x00000001779ed0b8, table_list=0x000000011a817a20, alter_info=0x00000001779ecf50) at sql_table.cc:17707:11
    frame #9: 0x0000000102bd8cbc mysqld`Sql_cmd_alter_table::execute(this=0x000000011a818210, thd=0x0000000119810a00) at sql_alter.cc:349:12
    frame #10: 0x0000000102d4a5f4 mysqld`mysql_execute_command(thd=0x0000000119810a00, first_level=true) at sql_parse.cc:4668:29
    frame #11: 0x0000000102d42160 mysqld`dispatch_sql_command(thd=0x0000000119810a00, parser_state=0x00000001779f1738) at sql_parse.cc:5322:19
    frame #12: 0x0000000102d3e0cc mysqld`dispatch_command(thd=0x0000000119810a00, com_data=0x00000001779f2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #13: 0x0000000102d406d4 mysqld`do_command(thd=0x0000000119810a00) at sql_parse.cc:1394:18
    frame #14: 0x0000000103028ea4 mysqld`handle_connection(arg=0x0000600001a8c000) at connection_handler_per_thread.cc:302:13
    frame #15: 0x0000000104cd8ad0 mysqld`pfs_spawn_thread(arg=0x0000000118f04aa0) at pfs.cc:2942:3
    frame #16: 0x000000018b12f034

(lldb) bt
* thread #41, name = 'connection', stop reason = breakpoint 5.1
  * frame #0: 0x0000000104370ac4 mysqld`btr_create(type=0, space=2, index_id=163, index=0x00000001598c00b0, mtr=0x00000001779e7b68) at btr0btr.cc:839:3
    frame #1: 0x00000001044df408 mysqld`dict_create_index_tree_in_mem(index=0x00000001598c00b0, trx=0x0000000140e69000) at dict0crea.cc:425:13
    frame #2: 0x00000001045acd18 mysqld`ddl::create_index(trx=0x0000000140e69000, table=0x0000000158f58060, index_def=0x0000000159080a88, add_v=0x0000000000000000) at ddl0ddl.cc:242:9
    frame #3: 0x00000001047c5f20 mysqld`bool prepare_inplace_alter_table_dict<dd::Partition>(ha_alter_info=0x00000001779ea960, altered_table=0x000000011b030220, old_table=0x00000001598b8420, old_dd_tab=0x0000000158f57c90, new_dd_tab=0x000000011a10b3c0, table_name="t", flags=33, flags2=2064, fts_doc_id_col=18446744073709551615, add_fts_doc_id=false, add_fts_doc_id_idx=false) at handler0alter.cc:4855:9
    frame #4: 0x000000010479f3f0 mysqld`bool ha_innobase::prepare_inplace_alter_table_impl<dd::Partition>(this=0x00000001598b8e30, altered_table=0x000000011b030220, ha_alter_info=0x00000001779ea960, old_dd_tab=0x0000000158f57c90, new_dd_tab=0x000000011a10b3c0) at handler0alter.cc:6010:10
    frame #5: 0x000000010479c10c mysqld`ha_innopart::prepare_inplace_alter_table(this=0x00000001598b8e30, altered_table=0x000000011b030220, ha_alter_info=0x00000001779ea960, old_table_def=0x0000000158f568b0, new_table_def=0x000000011a10a420) at handler0alter.cc:10349:11
    frame #6: 0x000000010265662c mysqld`handler::ha_prepare_inplace_alter_table(this=0x00000001598b8e30, altered_table=0x000000011b030220, ha_alter_info=0x00000001779ea960, old_table_def=0x0000000158f568b0, new_table_def=0x000000011a10a420) at handler.cc:4994:10
    frame #7: 0x0000000102e77fa4 mysqld`mysql_inplace_alter_table(thd=0x0000000119810a00, schema=0x0000600002580020, new_schema=0x0000600002580020, table_def=0x0000000158f568b0, altered_table_def=0x000000011a10a420, table_list=0x000000015a4f7a10, table=0x00000001598b8420, altered_table=0x000000011b030220, ha_alter_info=0x00000001779ea960, inplace_supported=HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE, alter_ctx=0x00000001779ec4d0, columns=size=0, fk_key_info=0x000000015a4f9d20, fk_key_count=0, fk_invalidator=0x00000001779eaca8) at sql_table.cc:13581:22
    frame #8: 0x0000000102e6c250 mysqld`mysql_alter_table(thd=0x0000000119810a00, new_db="pat", new_name="t", create_info=0x00000001779ed720, table_list=0x000000015a4f7a10, alter_info=0x00000001779ed5b8) at sql_table.cc:17707:11
    frame #9: 0x0000000102c799f4 mysqld`Sql_cmd_create_or_drop_index_base::execute(this=0x000000015a4f8200, thd=0x0000000119810a00) at sql_cmd_ddl_table.cc:547:7
    frame #10: 0x0000000102d46988 mysqld`mysql_execute_command(thd=0x0000000119810a00, first_level=true) at sql_parse.cc:3621:29
    frame #11: 0x0000000102d42160 mysqld`dispatch_sql_command(thd=0x0000000119810a00, parser_state=0x00000001779f1738) at sql_parse.cc:5322:19
    frame #12: 0x0000000102d3e0cc mysqld`dispatch_command(thd=0x0000000119810a00, com_data=0x00000001779f2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #13: 0x0000000102d406d4 mysqld`do_command(thd=0x0000000119810a00) at sql_parse.cc:1394:18
    frame #14: 0x0000000103028ea4 mysqld`handle_connection(arg=0x0000600001a8c000) at connection_handler_per_thread.cc:302:13
    frame #15: 0x0000000104cd8ad0 mysqld`pfs_spawn_thread(arg=0x0000000118f04aa0) at pfs.cc:2942:3
    frame #16: 0x000000018b12f034


(lldb) bt
* thread #41, name = 'connection', stop reason = breakpoint 6.1
  * frame #0: 0x00000001033d3ee4 mysqld`ha_innopart::prepare_inplace_alter_table(this=0x000000012e404830, altered_table=0x000000012e445420, ha_alter_info=0x0000000178db2960, old_table_def=0x000000012cf69f00, new_table_def=0x000000010fc7b810) at handler0alter.cc:10326:13
    frame #1: 0x000000010128e62c mysqld`handler::ha_prepare_inplace_alter_table(this=0x000000012e404830, altered_table=0x000000012e445420, ha_alter_info=0x0000000178db2960, old_table_def=0x000000012cf69f00, new_table_def=0x000000010fc7b810) at handler.cc:4994:10
    frame #2: 0x0000000101aaffa4 mysqld`mysql_inplace_alter_table(thd=0x000000012e373000, schema=0x0000600001b44a70, new_schema=0x0000600001b44a70, table_def=0x000000012cf69f00, altered_table_def=0x000000010fc7b810, table_list=0x000000012e42a210, table=0x000000012e403e20, altered_table=0x000000012e445420, ha_alter_info=0x0000000178db2960, inplace_supported=HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE, alter_ctx=0x0000000178db44d0, columns=size=0, fk_key_info=0x000000012e44eae8, fk_key_count=0, fk_invalidator=0x0000000178db2ca8) at sql_table.cc:13581:22
    frame #3: 0x0000000101aa4250 mysqld`mysql_alter_table(thd=0x000000012e373000, new_db="pat", new_name="t", create_info=0x0000000178db5720, table_list=0x000000012e42a210, alter_info=0x0000000178db55b8) at sql_table.cc:17707:11
    frame #4: 0x00000001018b19f4 mysqld`Sql_cmd_create_or_drop_index_base::execute(this=0x000000012e42aa00, thd=0x000000012e373000) at sql_cmd_ddl_table.cc:547:7
    frame #5: 0x000000010197e988 mysqld`mysql_execute_command(thd=0x000000012e373000, first_level=true) at sql_parse.cc:3621:29
    frame #6: 0x000000010197a160 mysqld`dispatch_sql_command(thd=0x000000012e373000, parser_state=0x0000000178db9738) at sql_parse.cc:5322:19
    frame #7: 0x00000001019760cc mysqld`dispatch_command(thd=0x000000012e373000, com_data=0x0000000178dbae40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #8: 0x00000001019786d4 mysqld`do_command(thd=0x000000012e373000) at sql_parse.cc:1394:18
    frame #9: 0x0000000101c60ea4 mysqld`handle_connection(arg=0x0000600002441f20) at connection_handler_per_thread.cc:302:13
    frame #10: 0x0000000103910ad0 mysqld`pfs_spawn_thread(arg=0x000000012cf206b0) at pfs.cc:2942:3
    frame #11: 0x000000018b12f034
    
* thread #42, name = 'connection', stop reason = breakpoint 11.1
  * frame #0: 0x0000000104f91a0c mysqld`fill_record(thd=0x00000001558a3a00, table=0x000000012681c020, fields=0x0000000126819438, values=0x0000000126818460, bitmap=0x0000000126820330, insert_into_fields_bitmap=0x0000000000000000, raise_autoinc_has_expl_non_null_val=false) at sql_base.cc:9960:3
    frame #1: 0x0000000104e0b5d4 mysqld`partition_info::set_used_partition(this=0x0000000126820280, thd=0x00000001558a3a00, fields=0x0000000126819438, values=0x0000000126818460, info=0x000000016d09d2e0, copy_default_values=false, used_partitions=0x000000016d09d250) at partition_info.cc:488:9
    frame #2: 0x0000000105078364 mysqld`Sql_cmd_insert_base::prepare_inner(this=0x0000000126819400, thd=0x00000001558a3a00) at sql_insert.cc:1496:36
    frame #3: 0x000000010518ff60 mysqld`Sql_cmd_dml::prepare(this=0x0000000126819400, thd=0x00000001558a3a00) at sql_select.cc:395:9
    frame #4: 0x0000000105190f48 mysqld`Sql_cmd_dml::execute(this=0x0000000126819400, thd=0x00000001558a3a00) at sql_select.cc:533:9
    frame #5: 0x00000001050e03b0 mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:3621:29
    frame #6: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #7: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #8: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #9: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #10: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #11: 0x0000000189beb034

(lldb) bt
* thread #42, name = 'connection', stop reason = breakpoint 8.1
  * frame #0: 0x0000000106b13fa8 mysqld`ha_innopart::write_row_in_part(this=0x0000000126815a30, part_id=0, record="\xfd\U00000003") at ha_innopart.cc:1425:36
    frame #1: 0x0000000104e1b59c mysqld`Partition_helper::ph_write_row(this=0x0000000126815a30, buf="\xfd\U00000003") at partition_handler.cc:521:11
    frame #2: 0x0000000106b1f4a0 mysqld`ha_innopart::write_row(this=0x0000000126815a30, record="\xfd\U00000003") at ha_innopart.h:1039:34
    frame #3: 0x00000001049f9b40 mysqld`handler::ha_write_row(this=0x0000000126815a30, buf="\xfd\U00000003") at handler.cc:8085:3
    frame #4: 0x0000000105076010 mysqld`write_record(thd=0x00000001558a3a00, table=0x000000012681c020, info=0x000000016d09d548, update=0x000000016d09d4d0) at sql_insert.cc:2194:36
    frame #5: 0x000000010507423c mysqld`Sql_cmd_insert_values::execute_inner(this=0x0000000126819400, thd=0x00000001558a3a00) at sql_insert.cc:643:11
    frame #6: 0x00000001051913a0 mysqld`Sql_cmd_dml::execute(this=0x0000000126819400, thd=0x00000001558a3a00) at sql_select.cc:586:7
    frame #7: 0x00000001050e03b0 mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:3621:29
    frame #8: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #9: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #10: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #11: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #12: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #13: 0x0000000189beb034

thread #42, name = 'connection', stop reason = breakpoint 16.1
  * frame #0: 0x0000000106e72bcc mysqld`row_upd_sec_index_entry_low(node=0x000000012703ecf0, old_entry=0x0000000000000000, thr=0x0000000156979840) at row0upd.cc:2158:9
    frame #1: 0x0000000106e72b90 mysqld`row_upd_sec_index_entry(node=0x000000012703ecf0, thr=0x0000000156979840) at row0upd.cc:2400:11
    frame #2: 0x0000000106e6e8ac mysqld`row_upd_sec_step(node=0x000000012703ecf0, thr=0x0000000156979840) at row0upd.cc:2473:15
    frame #3: 0x0000000106e69b00 mysqld`row_upd(node=0x000000012703ecf0, thr=0x0000000156979840) at row0upd.cc:3194:13
    frame #4: 0x0000000106e692fc mysqld`row_upd_step(thr=0x0000000156979840) at row0upd.cc:3299:9
    frame #5: 0x0000000106db0270 mysqld`row_update_for_mysql_using_upd_graph(mysql_rec="\xff\U00000005", prebuilt=0x000000012703dcb0) at row0mysql.cc:2356:3
    frame #6: 0x0000000106daf6f4 mysqld`row_update_for_mysql(mysql_rec="\xff\U00000005", prebuilt=0x000000012703dcb0) at row0mysql.cc:2452:13
    frame #7: 0x0000000106a9a23c mysqld`ha_innobase::delete_row(this=0x000000012703bc30, record="\xff\U00000005") at ha_innodb.cc:10105:13
    frame #8: 0x00000001049fa590 mysqld`handler::ha_delete_row(this=0x000000012703bc30, buf="\xff\U00000005") at handler.cc:8142:3
    frame #9: 0x00000001063ce34c mysqld`dd::Raw_record::drop(this=0x0000600002038840) at raw_record.cc:100:27
    frame #10: 0x0000000106172c5c mysqld`dd::Collection<dd::Partition_index*>::drop_items(this=0x0000000126648f08, otx=0x000000016d098808, table=0x00000001573fe600, key=0x0000600002038780) const at collection.cc:248:12
    frame #11: 0x000000010646917c mysqld`dd::Partition_impl::drop_children(this=0x0000000126648dc0, otx=0x000000016d098808) const at partition_impl.cc:195:20
    frame #12: 0x00000001061728d0 mysqld`dd::Collection<dd::Partition*>::drop_items(this=0x0000000126647c08, otx=0x000000016d098808, table=0x00000001573fd600, key=0x00006000020236e0) const at collection.cc:237:15
    frame #13: 0x000000010647ccb0 mysqld`dd::Table_impl::drop_children(this=0x00000001266479b0, otx=0x000000016d098808) const at table_impl.cc:384:23
    frame #14: 0x000000010649e6f0 mysqld`dd::Weak_object_impl_<true>::drop(this=0x00000001266479b0, otx=0x000000016d098808) const at weak_object_impl.cc:216:13
    frame #15: 0x00000001063b16e0 mysqld`bool dd::cache::Storage_adapter::drop<dd::Table>(thd=0x00000001558a3a00, object=0x00000001266479b0) at storage_adapter.cc:271:48
    frame #16: 0x00000001062569bc mysqld`bool dd::cache::Dictionary_client::drop<dd::Table>(this=0x0000000147f3f140, object=0x00000001266479b0) at dictionary_client.cc:2505:7
    frame #17: 0x0000000105212130 mysqld`mysql_inplace_alter_table(thd=0x00000001558a3a00, schema=0x0000600001f30110, new_schema=0x0000600001f30110, table_def=0x00000001266479b0, altered_table_def=0x0000000127908310, table_list=0x0000000130059060, table=0x0000000000000000, altered_table=0x00000001573c6820, ha_alter_info=0x000000016d09a280, inplace_supported=HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE, alter_ctx=0x000000016d09bdf0, columns=size=0, fk_key_info=0x000000013005b5f0, fk_key_count=0, fk_invalidator=0x000000016d09a5c8) at sql_table.cc:13698:27
    frame #18: 0x0000000105205e6c mysqld`mysql_alter_table(thd=0x00000001558a3a00, new_db="pat", new_name=0x0000000000000000, create_info=0x000000016d09d0b8, table_list=0x0000000130059060, alter_info=0x000000016d09cf50) at sql_table.cc:17707:11
    frame #19: 0x0000000104f726e4 mysqld`Sql_cmd_alter_table::execute(this=0x0000000130059998, thd=0x00000001558a3a00) at sql_alter.cc:349:12
    frame #20: 0x00000001050e401c mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:4668:29
    frame #21: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #22: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #23: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #24: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #25: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #26: 0x0000000189beb034

// isnert 第一次
* thread #42, name = 'connection', stop reason = breakpoint 11.1
  * frame #0: 0x0000000104f91a0c mysqld`fill_record(thd=0x00000001558a3a00, table=0x00000001573e8c20, fields=0x0000000130059838, values=0x0000000130058860, bitmap=0x00000001573fea30, insert_into_fields_bitmap=0x0000000000000000, raise_autoinc_has_expl_non_null_val=false) at sql_base.cc:9960:3
    frame #1: 0x0000000104e0b5d4 mysqld`partition_info::set_used_partition(this=0x00000001573fe980, thd=0x00000001558a3a00, fields=0x0000000130059838, values=0x0000000130058860, info=0x000000016d09d2e0, copy_default_values=false, used_partitions=0x000000016d09d250) at partition_info.cc:488:9
    frame #2: 0x0000000105078364 mysqld`Sql_cmd_insert_base::prepare_inner(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_insert.cc:1496:36
    frame #3: 0x000000010518ff60 mysqld`Sql_cmd_dml::prepare(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_select.cc:395:9
    frame #4: 0x0000000105190f48 mysqld`Sql_cmd_dml::execute(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_select.cc:533:9
    frame #5: 0x00000001050e03b0 mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:3621:29
    frame #6: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #7: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #8: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #9: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #10: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #11: 0x0000000189beb034

// insert 第二次
(lldb) bt
* thread #42, name = 'connection', stop reason = breakpoint 11.1
  * frame #0: 0x0000000104f91a0c mysqld`fill_record(thd=0x00000001558a3a00, table=0x00000001573e8c20, fields=0x0000000130059838, values=0x0000000130058860, bitmap=0x0000000000000000, insert_into_fields_bitmap=0x0000000000000000, raise_autoinc_has_expl_non_null_val=true) at sql_base.cc:9960:3
    frame #1: 0x0000000104f92b1c mysqld`fill_record_n_invoke_before_triggers(thd=0x00000001558a3a00, optype_info=0x000000016d09d548, fields=0x0000000130059838, values=0x0000000130058860, table=0x00000001573e8c20, event=TRG_EVENT_INSERT, num_fields=1, raise_autoinc_has_expl_non_null_val=true, is_row_changed=0x0000000000000000) at sql_base.cc:10324:9
    frame #2: 0x0000000105074074 mysqld`Sql_cmd_insert_values::execute_inner(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_insert.cc:606:11
    frame #3: 0x00000001051913a0 mysqld`Sql_cmd_dml::execute(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_select.cc:586:7
    frame #4: 0x00000001050e03b0 mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:3621:29
    frame #5: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #6: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #7: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #8: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #9: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #10: 0x0000000189beb034

// insert 第三次
(lldb) bt
* thread #42, name = 'connection', stop reason = breakpoint 8.1
  * frame #0: 0x0000000106b13fa8 mysqld`ha_innopart::write_row_in_part(this=0x00000001573fce30, part_id=2, record="\xfd\U00000003") at ha_innopart.cc:1425:36
    frame #1: 0x0000000104e1b59c mysqld`Partition_helper::ph_write_row(this=0x00000001573fce30, buf="\xfd\U00000003") at partition_handler.cc:521:11
    frame #2: 0x0000000106b1f4a0 mysqld`ha_innopart::write_row(this=0x00000001573fce30, record="\xfd\U00000003") at ha_innopart.h:1039:34
    frame #3: 0x00000001049f9b40 mysqld`handler::ha_write_row(this=0x00000001573fce30, buf="\xfd\U00000003") at handler.cc:8085:3
    frame #4: 0x0000000105076010 mysqld`write_record(thd=0x00000001558a3a00, table=0x00000001573e8c20, info=0x000000016d09d548, update=0x000000016d09d4d0) at sql_insert.cc:2194:36
    frame #5: 0x000000010507423c mysqld`Sql_cmd_insert_values::execute_inner(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_insert.cc:643:11
    frame #6: 0x00000001051913a0 mysqld`Sql_cmd_dml::execute(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_select.cc:586:7
    frame #7: 0x00000001050e03b0 mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:3621:29
    frame #8: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #9: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #10: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #11: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #12: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #13: 0x0000000189beb034

(lldb) bt
* thread #42, name = 'connection', stop reason = breakpoint 19.1
  * frame #0: 0x0000000106d9c904 mysqld`row_ins_sec_index_entry_low(flags=0, mode=2, index=0x00000001558accb0, offsets_heap=0x000000013781ac18, heap=0x000000013781ba18, entry=0x00000001278104d8, trx_id=0, thr=0x00000001573e9d70, dup_chk_only=false) at row0ins.cc:2839:13
    frame #1: 0x0000000106da00b8 mysqld`row_ins_sec_index_entry(index=0x00000001558accb0, entry=0x00000001278104d8, thr=0x00000001573e9d70, dup_chk_only=false) at row0ins.cc:3256:9
    frame #2: 0x0000000106da910c mysqld`row_ins_index_entry(index=0x00000001558accb0, entry=0x00000001278104d8, multi_val_pos=0x00000001573e9b50, thr=0x00000001573e9d70) at row0ins.cc:3356:13
    frame #3: 0x0000000106da8bc0 mysqld`row_ins_index_entry_step(node=0x00000001573e9a90, thr=0x00000001573e9d70) at row0ins.cc:3488:9
    frame #4: 0x0000000106da1538 mysqld`row_ins(node=0x00000001573e9a90, thr=0x00000001573e9d70) at row0ins.cc:3607:13
    frame #5: 0x0000000106da11a4 mysqld`row_ins_step(thr=0x00000001573e9d70) at row0ins.cc:3744:9
    frame #6: 0x0000000106daec64 mysqld`row_insert_for_mysql_using_ins_graph(mysql_rec="\xfd\U00000002", prebuilt=0x00000001573e92b0) at row0mysql.cc:1585:3
    frame #7: 0x0000000106dae2c0 mysqld`row_insert_for_mysql(mysql_rec="\xfd\U00000002", prebuilt=0x00000001573e92b0) at row0mysql.cc:1715:13
    frame #8: 0x0000000106a96d9c mysqld`ha_innobase::write_row(this=0x00000001573fce30, record="\xfd\U00000002") at ha_innodb.cc:9212:11
    frame #9: 0x0000000106b13ff4 mysqld`ha_innopart::write_row_in_part(this=0x00000001573fce30, part_id=1, record="\xfd\U00000002") at ha_innopart.cc:1438:24
    frame #10: 0x0000000104e1b59c mysqld`Partition_helper::ph_write_row(this=0x00000001573fce30, buf="\xfd\U00000002") at partition_handler.cc:521:11
    frame #11: 0x0000000106b1f4a0 mysqld`ha_innopart::write_row(this=0x00000001573fce30, record="\xfd\U00000002") at ha_innopart.h:1039:34
    frame #12: 0x00000001049f9b40 mysqld`handler::ha_write_row(this=0x00000001573fce30, buf="\xfd\U00000002") at handler.cc:8085:3
    frame #13: 0x0000000105076010 mysqld`write_record(thd=0x00000001558a3a00, table=0x00000001573c7e20, info=0x000000016d09d548, update=0x000000016d09d4d0) at sql_insert.cc:2194:36
    frame #14: 0x000000010507423c mysqld`Sql_cmd_insert_values::execute_inner(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_insert.cc:643:11
    frame #15: 0x00000001051913a0 mysqld`Sql_cmd_dml::execute(this=0x0000000130059800, thd=0x00000001558a3a00) at sql_select.cc:586:7
    frame #16: 0x00000001050e03b0 mysqld`mysql_execute_command(thd=0x00000001558a3a00, first_level=true) at sql_parse.cc:3621:29
    frame #17: 0x00000001050dbb88 mysqld`dispatch_sql_command(thd=0x00000001558a3a00, parser_state=0x000000016d0a1738) at sql_parse.cc:5322:19
    frame #18: 0x00000001050d7af4 mysqld`dispatch_command(thd=0x00000001558a3a00, com_data=0x000000016d0a2e40, command=COM_QUERY) at sql_parse.cc:1996:7
    frame #19: 0x00000001050da0fc mysqld`do_command(thd=0x00000001558a3a00) at sql_parse.cc:1394:18
    frame #20: 0x00000001053c2ac0 mysqld`handle_connection(arg=0x00006000020249e0) at connection_handler_per_thread.cc:302:13
    frame #21: 0x0000000107072ba4 mysqld`pfs_spawn_thread(arg=0x0000000147f3ee90) at pfs.cc:2942:3
    frame #22: 0x0000000189beb034
```

# todo
mysql 和 oracle 区别 需求分析