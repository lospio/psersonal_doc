
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
```

# todo
mysql 和 oracle 区别 需求分析