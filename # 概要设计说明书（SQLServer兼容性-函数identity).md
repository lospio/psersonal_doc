# 产品名称

## 概要设计说明书 — Identity 函数支持

产品版本：<5.0.0>

### 修订记录

| 版本号 | 发布日期 | 描述 | 作者 | 批准 |
| :--- | :---: | :--- | :--- | :--- |
| 1.0 | 2026-02-05 | 初稿撰写 | 技术文档组 | 架构委员会 |

### 变更记录

| 变更编号 | 变更日期 | 变更项 | 描述 | 基线版本 | 变更请求编号 |
| :---: | :---: | :--- | :--- | :---: | :--- |
| 1 | 2026-02-05 | Identity 函数 | 新增 `SELECT INTO` 语句中 IDENTITY 函数支持 | V4.2 | REQ-2026-002 |

---

## 目录

1. 功能规格
    - 功能简述
    - 参数与语法
    - 支持与限制
2. 语法语义与 Hook 设计
    - 语法解析改造
    - 语义分析与转换
    - Hook 设计方案
3. 执行流程
    - 解析与重写流程
    - 执行与元数据持久化
4. 其他说明
    - 接口说明
    - 内存管理
    - 安全
    - 性能
    - 升级管理

---

## 概要

本文档描述在 MSSQL 兼容模式下，向 `SELECT ... INTO` 语句中新增对 `IDENTITY()` 函数支持的概要设计与实现要点。

## 1 功能规格

### 1.1 功能简述

`IDENTITY()` 函数为 MSSQL 兼容模式下的扩展，仅允许出现在 `SELECT ... INTO table_name` 的选择列表中。其语义为：在创建目标表的同时，指定某一列为标识列（Identity），并根据查询结果行顺序自动填充连续的序列值。

该函数并不像普通函数那样返回单一固定值，而是标注列应在新建表中具有 Identity 属性，并在数据插入阶段由运行时生成器按行计算序列值。

### 1.2 参数与语法

语法：

```sql
IDENTITY ( data_type [ , seed , increment ] ) AS column_name
```

参数说明：
- data_type：标识列的数据类型（支持 int, bigint, smallint, tinyint，以及 scale=0 的 decimal/numeric）。
- seed（可选）：起始值，默认 1。
- increment（可选）：增量，默认 1。
- column_name：必须通过 AS 指定别名，作为新表中列名。

### 1.3 支持与限制

支持要点：
- 在 `SELECT INTO` 创建新表时动态创建具 Identity 属性的列。
- 支持常见整数类型及无小数的 decimal/numeric。
- 新表列自动填充连续的标识值，且该列在新表中保留 Identity 属性（关联序列），后续 INSERT 会继续使用序列。

限制：
- 仅允许在 `SELECT ... INTO` 的选择列表中使用，其他上下文（普通 SELECT、INSERT、UPDATE）应报语义错误。
- 每个 `SELECT INTO` 仅允许一个 `IDENTITY()` 调用（每表最多一个标识列）。
- 必须指定列别名（AS column_name）。
- 生成列自动标记为 NOT NULL。

## 2 语法语义与 Hook 设计

### 2.1 语法解析改造

无需在 `gram.y` 中新增关键字，但需在表达式/语义分析阶段识别并校验 `IDENTITY(...)`。PostgreSQL 的 Parser 会把 `IDENTITY(...)` 视作普通函数调用，故必须在语义分析（transform）阶段做上下文校验与转换。

### 2.2 语义分析与转换

设计要点（Transform Logic）：

1. 识别：在 `transformTargetList` 或 `transformSelectStmt` 中检测当前语句是否为 `SELECT INTO`（即 `intoClause` 不为空）。
2. 扫描：遍历 `targetList`，查找函数名为 `IDENTITY` 的表达式节点。
3. 校验：
    - 在非 `SELECT INTO` 场景发现则报错。
    - 参数个数为 1~3 个，类型合法性检查。
    - 检查同一语句中是否多次调用（不允许）。
4. 替换：将 `IDENTITY()` 节点替换为内部运行时函数（例如 `identity_runtime`）以在数据生成阶段逐行计算值。

同时，需要将 Identity 元数据（data_type、seed、increment、目标列位置等）暂存到 `Query` 结构或解析上下文，以便在随后建表（CTAS）阶段可读取并持久化为列属性。

### 2.3 Hook 设计方案

为把 Identity 属性写入新表的元数据，需要在建表阶段通过 Hook 介入：

1) Executor / Utility Hook（拦截 CTAS）
- 目标：在创建新表的 `TupleDesc` 时，检测是否存在由 `IDENTITY()` 指定的列。
- 逻辑：读取暂存的 seed/increment/type 信息；隐式创建对应的 Sequence；将该列的默认值设为 `nextval(sequence)`；设置该列的 `attidentity` 属性（例如 'm'）。

2) 运行时生成函数（Runtime Function）
- 设计内部函数 `identity_generate_value(seed, increment)`，在查询执行期间每行调用。
- 在查询执行上下文中维护计数器（row_number），按公式计算：current_value = seed + (row_number - 1) * increment。
- 查询结束后，通过 `setval` 同步更新底层 Sequence 的当前值，以保证后续 INSERT 的连续性。

## 3 执行流程

### 3.1 解析与重写流程

示例 SQL：

```sql
SELECT IDENTITY(int, 100, 1) AS id, name
INTO new_t
FROM old_t;
```

处理流程：
1. Parser 解析 SQL 并构建初始 Parse 树。
2. Analyzer：检测 `intoClause`，发现 `IDENTITY()`，校验参数并标记。
3. 将 `IDENTITY()` 节点替换为内部执行节点，例如 `FuncExpr(identity_runtime, seed=100, incr=1)`，并在 `ParseState/Query` 中记录该列为 Identity（含参数）。

### 3.2 执行与元数据持久化

Executor（Create Table）阶段：

1. 开始创建新表 `new_t`。
2. Hook 介入：根据解析时保存的 Identity 元数据，隐式创建序列（如 `seq_new_t_id`，start=100, increment=1），并将 `id` 列的默认值设置为 `nextval('seq_new_t_id')`，设置 `attidentity='m'`。

数据写入阶段（Data Population）：

1. 执行 SELECT，针对每一行调用 `identity_runtime`（或 `identity_generate_value`）获得标识值，作为插入列的值写入 `new_t`。
2. 写入完成后，统计插入行数 N，计算最终序列值 `Last_Val = seed + (N * increment)`。
3. 调用 `setval('seq_new_t_id', Last_Val)` 同步序列，确保后续 INSERT 的连续性与唯一性。

## 4 其他说明

### 4.1 接口说明

此功能为 SQL 语法层增强，无外部系统接口变更。对外表现为支持 `SELECT INTO` 中的 `IDENTITY()` 扩展语法。

### 4.2 内存管理

运行时计数器应放在查询级的内存上下文（Query Memory Context），随查询生命周期分配与释放，避免内存泄漏。

### 4.3 安全

权限要求：执行该语句的用户需对源表有 SELECT 权限，并对目标 schema 有 CREATE TABLE 权限。

审计：该操作等同于 DDL + DML 复合操作，应在审计日志中同时记录建表和数据插入动作。

### 4.4 性能

性能开销：
- 序列对象创建：一次性开销。
- 每行数值生成：纯算术计算，开销极低。
- 查询结束时的 `setval`：一次性开销。

总体上，对比普通 `SELECT INTO`，性能损耗可忽略不计。

### 4.5 升级管理

该功能在运行时创建新表与序列，不涉及已有数据迁移。

兼容性建议：避免与已有同名用户函数冲突；可考虑将 `IDENTITY` 在兼容模式下视作受限关键字或优先级较高的保留标识，以免覆盖用户自定义函数语义。

---
