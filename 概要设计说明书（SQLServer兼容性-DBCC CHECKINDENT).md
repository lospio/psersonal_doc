# 产品名称

## 概要设计说明书（DBCC CHECKIDENT）

产品版本：<5.0.0>

### 修订记录

| 版本号 | 发布日期 | 描述 | 作者 | 批准 |
| :--- | :--- | :--- | :--- | :--- |
| <1.0> | 2026-02-05 | 初稿撰写 | 技术文档组 | 架构委员会 |
| | | | | |

### 变更记录

| 变更编号 | 变更日期 | 变更项 | 描述 | 基线版本 | 变更请求编号 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 2026-02-05 | DBCC支持 | 新增MSSQL兼容命令 DBCC CHECKIDENT | V4.2 | REQ-2026-003 |

### 目录

1. [功能规格](#1-功能规格)
    1. [功能简述](#11-功能简述)
    2. [语法与参数](#12-语法与参数)
    3. [逻辑行为与返回值](#13-逻辑行为与返回值)
2. [语法语义与Hook设计](#2-语法语义与Hook设计)
    1. [语法解析改造](#21-语法解析改造)
    2. [底层映射机制](#22-底层映射机制)
3. [执行流程](#3-执行流程)
    1. [检查流程 (NORESEED)](#31-检查流程-noreseed)
    2. [重置流程 (RESEED)](#32-重置流程-reseed)
4. [其他说明](#4-其他说明)
    1. [接口说明](#41-接口说明)
    2. [内存管理](#42-内存管理)
    3. [安全](#43-安全)
    4. [性能](#44-性能)
    5. [升级管理](#45-升级管理)

---

## 概要设计说明书

DBCC CHECKIDENT（MSSQL兼容性）

## 1 功能规格

### 功能简述

`DBCC CHECKIDENT` 是 SQL Server 中用于检查和修正标识列（Identity Column）当前标识值的管理命令。在兼容模式下，该功能允许用户手动重置标识列的当前序列值（Seed），或在数据导入/删除后修复序列值与表中实际最大值不一致的问题。

### 语法与参数

**语法结构：**

```sql
DBCC CHECKIDENT ( table_name [, { NORESEED | { RESEED [, new_reseed_value ] } } ] )
[ WITH NO_INFOMSGS ]
```

**参数说明：**

* **table_name**：要检查标识值的表名。表必须包含 Identity 列。
* **NORESEED**：指定不更改当前的标识值，仅返回当前标识值和列中的最大值。
* **RESEED**：指定更改当前的标识值。
* **new_reseed_value** (可选)：用作标识列当前值的新值。
* **WITH NO_INFOMSGS**：取消显示所有信息性消息（兼容性参数，逻辑上可忽略或静默）。

### 逻辑行为与返回值

#### 1. 行为逻辑
* **Case A: `DBCC CHECKIDENT (table, NORESEED)`**
    * 不修改任何数据。
    * 查询并返回：1. 序列当前的 `last_value`；2. 表中 Identity 列的物理 `MAX(column)`。
* **Case B: `DBCC CHECKIDENT (table, RESEED, new_value)`**
    * 强制将底层序列的当前值设置为 `new_value`。
    * **插入行为变更**：
        * 若表非空：下一条插入值的计算结果通常为 `new_value + increment`。
        * 若表为空：下一条插入值为 `new_value`。
* **Case C: `DBCC CHECKIDENT (table, RESEED)` (不带新值)**
    * **自动修复模式**。
    * 若表中有数据：取 `MAX(column)` 作为新的序列值。
    * 若表为空：将序列重置为建表时指定的初始 Seed 值。

#### 2. 返回值
命令执行后应返回标准消息字符串（Client Notice）：
> "Checking identity information: current identity value 'X', current column value 'Y'."
> (若使用了 RESEED，提示信息可能略有不同，通常提示 "DBCC execution completed.")

## 2 语法语义与Hook设计

### 语法解析改造

PG 内核原生不支持 `DBCC` 关键字。需要在 `gram.y` 中增加顶层语句支持。

**修改点：**
* **Keywords**: 引入 `DBCC`, `CHECKIDENT`, `RESEED`, `NORESEED`。
* **Statement**: 定义 `DbccStmt` 节点。
* **Parser Rule**:
    ```yacc
    DbccStmt:
        DBCC CHECKIDENT '(' qualified_name_list_opt_args ')' opt_with_clause
        {
            /* 构建函数调用节点，映射到内部函数 */
        }
    ```

### 底层映射机制

将 DBCC 命令映射为内部存储过程或 C 函数调用 `vb_dbcc_checkident(rel regclass, option text, new_val int8)`。

**核心映射逻辑：**
1.  **定位序列**：通过 `pg_depend` 系统表，查找目标表 Identity 列所依赖的 Sequence OID。
2.  **操作序列**：使用 PG 原生的 `setval()` 函数进行值的修改。
    * `setval(seq_oid, new_val, is_called)`
    * **难点**：PG 的 `is_called` 参数控制下一次 `nextval` 是直接返回 `new_val` 还是 `new_val + increment`。需根据 MSSQL 规范精确映射。

## 3 执行流程

### 3.1 检查流程 (NORESEED)

1.  **输入**：`DBCC CHECKIDENT ('t1', NORESEED)`
2.  **查找**：获取 `t1` 的 Identity 列及其关联序列 `seq_t1`。
3.  **获取序列值**：调用 `pg_sequence_last_value(seq_t1)` 得到 `Current_Identity`。
4.  **获取表数据**：构造并执行内部查询 `SELECT MAX(id) FROM t1` 得到 `Current_Column_Value`。
5.  **输出**：通过 `ereport(NOTICE, ...)` 输出格式化信息。

### 3.2 重置流程 (RESEED)

#### 场景 A：指定新值
1.  **输入**：`DBCC CHECKIDENT ('t1', RESEED, 100)`
2.  **检查表状态**：检查表是否为空。
3.  **执行重置**：
    * **如果表为空**：调用 `setval('seq_t1', 100, false)`。
        * *解释*：`is_called=false`，下次 `nextval` 返回 100。
    * **如果表非空**：调用 `setval('seq_t1', 100, true)`。
        * *解释*：`is_called=true`，下次 `nextval` 返回 100 + increment。
    * *(注：具体行为需严格对齐 MSSQL 文档，此处为推演的兼容逻辑)*。

#### 场景 B：自动修复 (无参数)
1.  **输入**：`DBCC CHECKIDENT ('t1', RESEED)`
2.  **查询最大值**：`SELECT MAX(id) FROM t1`。
3.  **分支判断**：
    * **结果为 NULL (空表)**：
        * 查询 `pg_attribute` 或 `pg_sequence` 获取建表时的初始 `start_value` (Seed)。
        * 调用 `setval('seq_t1', Seed, false)`。
    * **结果为 N (非空)**：
        * 调用 `setval('seq_t1', N, true)`。
        * 确保下一次插入值为 `N + increment`。

## 4 其他说明

### 接口说明

无新增 API，表现为 SQL 命令。

### 内存管理

过程性命令，使用标准的 Transaction 内存上下文，执行完毕即释放。若涉及全表扫描（查找 Max），需依赖 Buffer Pool。

### 安全

* **权限要求**：必须是表的所有者 (Owner)，或是 `sysadmin` 固定服务器角色、`db_owner` 固定数据库角色或 `db_ddladmin` 固定数据库角色的成员。
* **权限检查**：在函数入口处调用 `pg_class_ownercheck` 或类似 ACL 检查函数。

### 性能

* **NORESEED**：涉及 `MAX()` 查询。若 Identity 列上有索引（通常是主键，必有索引），性能为 `O(log N)`，非常快。
* **RESEED (with value)**：`O(1)`，直接更新元数据。
* **RESEED (auto)**：同 NORESEED，依赖索引扫描效率。

### 升级管理

* **不涉及**：此功能为运行时管理命令，不修改物理存储格式，不影响 pg_upgrade。