## 什么是 Hook？

**Hook** 是一种回调机制，在数据库系统的执行流程中插入自定义的逻辑。它允许开发者在不同的数据库操作过程中（如解析、优化、执行等阶段）插入自定义代码，从而修改系统的行为或添加额外的功能。
### Hook 原理

在 PostgreSQL 中，**Hook** 机制的核心思想是拦截并扩展数据库的标准行为。每个 Hook 都有一个预定义的接口，开发者可以通过实现这些接口来“挂钩”到 PostgreSQL 的执行过程中。通过这种方式，我们能够控制查询的解析、计划生成、执行过程等，从而实现跨数据库兼容性。
Hook 的工作流程通常如下：
1. PostgreSQL 在执行过程中遇到预定义的 Hook 点。
2. 如果 Hook 已被注册，PostgreSQL 会调用开发者提供的回调函数。
3. 开发者的回调函数会根据需求修改数据库的行为。
4. 执行完 Hook 后，PostgreSQL 继续按常规流程执行。
### 为什么使用 Hook？
- **非侵入式扩展**：无需修改源代码，通过动态加载共享库实现功能增强。
- **事件驱动**：在预定义的“事件点”触发自定义逻辑。
- **兼容性开发**：通过 Hook，我们可以将 PostgreSQL 转变为支持其他数据库的兼容层，
---
## PostgreSQL 中的 Hook 类型

PostgreSQL 提供了多种 Hook，覆盖从 SQL 接收到结果返回的整个生命周期。以下是一些关键 Hook：


| Hook 名称                                                           | 触发时机                       | 典型用途                                      |
| ----------------------------------------------------------------- | -------------------------- | ----------------------------------------- |
| `ProcessUtility_hook`                                             | 执行 DDL、事务控制、VACUUM 等工具类命令时 | 拦截 `CREATE TABLE`、`DROP USER` 等命令，实现兼容性转换 |
| `ExecutorStart_hook` / `ExecutorRun_hook` / `ExecutorFinish_hook` | 查询执行阶段                     | 修改执行计划、注入监控逻辑                             |
| `planner_hook`                                                    | 生成查询计划前                    | 重写查询、优化路径选择                               |
| `post_parse_analyze_hook`                                         | SQL 解析完成后、语义分析结束时          | 修改解析树（Parse Tree），实现语法兼容                  |
| `emit_log_hook`                                                   | 日志输出时                      | 自定义日志格式或转发日志                              |
| `check_password_hook`                                             | 用户密码验证时                    | 集成外部认证系统                                  |

---
## Babelfish hook
babelfish对原生的PostgreSQL做了修改，扩充了部分hook，以下部分介绍babelfish中使用的关键hook：

### 一、关系名（表名）查找 Hook
```cpp
typedef Oid (*relname_lookup_hook_type) (const char *relname, Oid relnamespace);
```
- **触发时机**：当服务器需要查找关系（如表、视图）的 OID 时。
- **Babelfish 用途**：覆盖 PostgreSQL 原生的表名查找逻辑，实现 **SQL Server 风格的标识符解析规则**（如大小写敏感性、默认 schema 等）。
### 二、函数与过程（Stored Procedure）相关 Hooks

#### 1. AS 子句处理
```cpp
typedef bool (*check_lang_as_clause_hook_type)(
    const char *lang, 
    List *as, 
    char **prosrc_str_p, 
    char **probin_str_p
);
```
- 允许扩展语言（如 T-SQL）自定义 `AS` 子句的解析逻辑。
#### 2. 修改 CREATE FUNCTION 的存储行为
```cpp
typedef void (*write_stored_proc_probin_hook_type)(
    CreateFunctionStmt *stmt, 
    Oid languageOid, 
    char** probin_str_p
);
```
- T-SQL 过程在底层以 **JSON 格式** 存储，此 Hook 用于生成对应的 `probin` 字段内容。
### 三、序列（Sequence）与 IDENTITY 列 Hooks

#### 1. 序列增量验证
```cpp
typedef void (*pltsql_sequence_validate_increment_hook_type) (

int64 increment_by, int64 max_value, int64 min_value

);
```
#### 2. 序列数据类型处理

```cpp
typedef void (*pltsql_sequence_datatype_hook_type) (

ParseState *pstate,

Oid *newtypid,

bool for_identity,

DefElem *as_type,

DefElem **max_value,

DefElem **min_value

);
```

#### 3. IDENTITY 列数据类型控制

```cpp
typedef void (*pltsql_identity_datatype_hook_type) (ParseState *pstate, ...);
```

- 这些 Hook 用于使 PostgreSQL 的序列行为（如起始值、步长、数据类型）与 SQL Server 的 `IDENTITY` 列保持一致。
### 四、解析与查询计划阶段 Hooks

#### 1. 解析前/后 Hook
```cpp
typedef void (*pre_parse_analyze_hook_type) (ParseState *pstate, RawStmt *parseTree);
// 通常配合 post_parse_analyze_hook 使用
```
- `pre_parse_analyze_hook`：在语法树解析后、语义分析前介入。
- `post_parse_analyze_hook`：在完整分析后介入，常用于重写查询树。
#### 2. 查询计划 Qual 节点转换
```cpp
typedef Node* (*planner_node_transformer_hook_type) (

PlannerInfo *root, Node *expr, int kind

);
```

- `Qual` 指查询中的过滤条件（如 `WHERE col = 10`），此 Hook 可用于重写谓词逻辑。
#### 3. 目标列表（Target List）处理
```cpp
// 转换目标项

typedef void (*pre_transform_target_entry_hook_type)(

ResTarget *res, ParseState *pstate, ParseExprKind exprKind

);

// 解析未知类型的目标项

typedef void (*resolve_target_list_unknowns_hook_type)(

ParseState *pstate, List *targetlist

);

// 目标项名称比较

typedef bool (*tle_name_comparison_hook_type)(

const char *tlename, const char *identifier

);
```

- 用于处理 `SELECT` 列表、`INSERT` 目标列等场景，解决 SQL Server 与 PostgreSQL 在列名解析、匿名表达式处理上的差异。
### 五、DML 语句增强 Hooks（OUTPUT 子句支持）

SQL Server 的 `OUTPUT` 子句（类似 `RETURNING` 但功能更强）需要深度集成：
#### 1. RETURNING 子句前处理
```cpp
typedef void (*pre_transform_returning_hook_type) (

CmdType command, List *returningList, ParseState *pstate

);
```
#### 2. UPDATE 语句转换（用于 OUTPUT）
```cpp
typedef Node* (*pre_output_clause_transformation_hook_type) (

ParseState *pstate, UpdateStmt *stmt, CmdType command

);
```

- 对 `UPDATE` 语句进行自连接等转换，以支持 `OUTPUT DELETED.*, INSERTED.*`。
#### 3. OUTPUT 子句状态读取
```cpp
typedef bool (*get_output_clause_status_hook_type) (void);
```
- 读取全局标志，判断当前是否处于 OUTPUT 子句上下文中。
#### 4. INSERT 行转换后 Hook
```cpp
typedef void (*post_transform_insert_row_hook_type) (List *icolumns, List *exprList);
```

### 六、列定义与扩展属性 Hooks

#### 1. 列选项验证
```cpp
typedef bool (*check_extended_attoptions_hook_type) (Node *options);
```

- 支持 SQL Server 特有的列属性（如 `SPARSE`、`FILESTREAM` 等）。

#### 2. 列定义转换后处理
```cpp
typedef void (*post_transform_column_definition_hook_type) (

ParseState *pstate, RangeVar* relation, ColumnDef *column, List **alist

);
```
### 七、解析器与语法扩展 Hooks

#### 1. 原始解析器 Hook
```cpp
typedef List * (*raw_parser_hook_type) (const char *str);
```

- 完全接管原始 SQL 字符串的解析，可用于实现 T-SQL 特有语法。
#### 2. 递归 CTE 检查
```cpp
typedef bool (*check_recursive_cte_hook_type) (WithClause *with_clause);
```

- 允许 CTE 名称为 `TIME` 或 `ORDINALITY`（PostgreSQL 原生禁止）。
### 八、协议与初始化 Hooks

#### 1. 监听初始化
```cpp
typedef void (*listen_init_hook_type)(void);
```

- 启动 TDS 协议监听端口（通常为 1433）。

#### 2. 字符串截断错误抑制
```cpp
typedef bool (*suppress_string_truncation_error_hook_type)();
```

- 在 Babelfish 内部大量存在字符串截断场景（如日志、错误信息），此 Hook 可选择性忽略截断错误。
---
## 使用 Hook 实现异构数据库的兼容性开发

### 步骤 1：调研目标数据库，整理与原生数据库的功能差异确定开发目标

要实现数据库的兼容性，首先需要深入理解目标数据库的语法、查询计划、执行方式以及网络协议等方面的差异。
### 步骤 2：定义 Hook 和回调函数

根据目标数据库的特性，选择合适的 Hook 类型进行扩展。通过编写回调函数，修改查询解析、查询计划或执行过程，以适应目标数据库的行为。
### 步骤 3：注册 Hook 并实现兼容性逻辑
通过在 PostgreSQL 启动时注册 Hook，我们可以确保每次查询执行时都会触发相应的兼容性调整。在回调函数中，可以实现如下逻辑：
- 语法转换：将目标数据库的查询语法转换为 PostgreSQL 语法。
- 语法支持：将目标库的独特语法解析利用hook实现
- 查询计划调整：调整查询优化器生成的查询计划，使其能够高效地执行目标数据库的查询。
- 执行过程调整：根据目标数据库的执行策略，修改查询执行的逻辑。
- 协议适配：在与目标数据库的客户端通信时，转换通信协议。
