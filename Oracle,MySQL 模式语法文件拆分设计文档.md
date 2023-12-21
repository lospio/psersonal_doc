# 01. 需求
## 背景
当前项目中有些 MySQL 原生功能与 Oracle 兼容功能产生冲突,需要添加额外的模式判断语句明确功能.
- 增加了代码数量,难于管理
- 无法解决某些关键字冲突.
## 需求描述
拆分 sql_yacc.yy 文件,生成两个语法文件
- MySQL 模式(默认)
- Oracle 模式
## 需求分析

### Parser 图示
![[mysqld.svg]]
### Parser 过程
Parser 过程分为两步,词法解析和语法解析(the lexical scanner and the grammar rule module).
#### 词法解析
扫描 query,将其分解为一个个 token
示例:
```sql
select  count(*), state from t group by state;
```

```text
# tokens
- select
- count
- (
- *
- )
- ,
- state
- from
- t
- group
- by
- state
```
每个 token 可能是一个 a keyword , a string literal, a number, an operator or a function name 
#### 语法解析
匹配token,查找 sql_yacc文件中对应的语法规则
示例:
```cpp
// 四则运算的语法规则
%%

E   :   E '+' E '\n'        { printf("this is addtion.\n"); }
	    |   E '-' E           { printf("this is subtraction.\n"); }
	    |   E '*' E           { printf("this is multiplication.\n"); }
	    |   E '/' E           { printf("this is division.\n"); }
	    |   T_NUM        { printf("this is a number.\n");}
	    |   '(' E ')'          { printf("this is parenthesis.\n"); }
	    ;

%%
```
>bison 里面 ”:” 代表一个 “->” ，同一个非终结符的不同产生式用 “|” 隔开，用 ”;” 结束表示一个非终结符产生式的结束；每条产生式的后面花括号内是一段 C 代码、这些代码将在该产生式被应用时执行，这些代码被称为 action ，产生式的中间以及 C 代码内部可以插入注释（稍后再详细解释本文件中的这些代码）；产生式右边是 ε 时，不需要写任何符号，一般用一个注释 /* empty */ 代替。
```sql
create table t(id int) partition by range(id) ( partition p0 values less than (100));
```
```cpp
%token  PARTITION_SYM 656                 /* SQL-2003-R */  
%token<lexer.keyword> PARTITIONS_SYM 657  
%token<lexer.keyword> PARTITIONING_SYM 658

// partition 子句语法规则
partition_clause:  
          PARTITION_SYM BY part_type_def opt_num_parts opt_sub_part  
          opt_part_defs  
          {  
            $$= NEW_PTN PT_partition($3, $4, $5, @6, $6);  
          }  
        ;  
  
part_type_def:  
          opt_linear KEY_SYM opt_key_algo '(' opt_name_list ')'  
          {  
            $$= NEW_PTN PT_part_type_def_key($1, $3, $5);  
          }  
        | opt_linear HASH_SYM '(' bit_expr ')'  
          {  
            $$= NEW_PTN PT_part_type_def_hash($1, @4, $4);  
          }  
  
        | RANGE_SYM '(' bit_expr ')'  
          {  
            $$= NEW_PTN PT_part_type_def_range_expr(@3, $3);  
          }  
        | RANGE_SYM COLUMNS '(' name_list ')'  
          {  
            $$= NEW_PTN PT_part_type_def_range_columns($4);  
          }  
        | LIST_SYM '(' bit_expr ')'  
          {  
            $$= NEW_PTN PT_part_type_def_list_expr(@3, $3);  
          }  
        | LIST_SYM COLUMNS '(' name_list ')'  
          {  
            $$= NEW_PTN PT_part_type_def_list_columns($4);  
          }  
        ;
```
 part_type_def 匹配到 RANGE_SYM,于是实例化一个PT_part_type_def_range_expr class, 放入 parse tree
## 代码调用过程
- sql_parser
	- MYSQLparse
		- MYSQLlex
## 需求规格
将语法文件sql_yacc.yy拆分成两个文件,根据 sql_dialect 的值调用不同的语法文件
- sql_dialect=mysql 默认语法文件
- sql_dialect=oracle oracle 语法文件
## 总结
![[Pasted image 20231204143414.png]]
# 02.设计实现
## 设计思路
1. parser 的两个步骤中,根据需求我们需要修改语法解析,词法解析无需修改.
2. 实现两个 bison 规则,在 sql_parser 中根据 sql_dialect 的值调用相应的 parse 函数
## 实现方法
1. 在 sql_yacc.yy 文件中做标注,添加 %ifdef MYSQL 或者 %ifdef ORACLE
2. 根据匹配到的 MYSQL 或者 ORACLE 将该行文件内容写入到指定的文件中
	- %ifdef MYSQL -> sql_yacc_default.yy
	- %ifdef ORACLE -> sql_yacc_oracle.yy
3. 其余内容两个文件都要写入
4. 添加两个文件的bison执行规则,cmake 编译规则
5. 在 sql_parser 中根据 sql_dialect 的值调用相应的语法函数 XXXparse(XXX 是 bison 命令中指定的前缀)
# 03. 友商参考方案
1. Mariadb
2. GreateSQL
Mariadb 和 GreateSQL 都使用了同样方式实现了 yacc 文件的拆分,该设计参考了相同的方案,代码上参考了 GreateSQL 的实现
## Mariadb
该次提交涉及该功能
```git
git show 9f6aca198c9d580c310630dcf3f545647bb49368
```
# 04. 使用方法
修改~/sql/sql_yacc.yy 文件
## 示例:
Oracle 模式下,range解析为 range column
![[Pasted image 20231130174447.png]]
修改完毕,编译项目.可以看到在 build目录/sql 下面有这些文件
1. sql_yacc.yy生成 sql_yacc_oracle.yy 和 sql_yacc_default.yy 文件
2. bison 命令将sql_yacc_oracle.yy生成 sql_yacc_oracle.h 和 sql_yacc_oracle.cc
3. bison 命令将 sql_yacc_default.yy 生成 sql_yacc.h 和 sql_yacc.cc
4. cmake 编译
![[Pasted image 20231130174537.png]]
