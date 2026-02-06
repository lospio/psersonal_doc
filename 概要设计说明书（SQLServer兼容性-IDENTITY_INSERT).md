# 产品名称

## 概要设计说明书（SET IDENTITY_INSERT）

产品版本：<5.0.0>

### 修订记录

| 版本号 | 发布日期 | 描述 | 作者 | 批准 |
| :--- | :--- | :--- | :--- | :--- |
| <1.0> | 2026-02-05 | 初稿撰写 | 技术文档组 | 架构委员会 |
| | | | | |

### 变更记录

| 变更编号 | 变更日期 | 变更项 | 描述 | 基线版本 | 变更请求编号 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 2026-02-05 | Identity支持 | 新增 SET IDENTITY_INSERT 会话级开关支持 | V4.2 | REQ-2026-004 |

### 目录

1. [功能规格](#1-功能规格)
    1. [功能简述](#11-功能简述)
    2. [语法与参数](#12-语法与参数)
    3. [行为规则与限制](#13-行为规则与限制)
2. [语法语义与Hook设计](#2-语法语义与Hook设计)
    1. [语法解析改造](#21-语法解析改造)
    2. [会话状态管理](#22-会话状态管理)
    3. [Hook介入点](#23-Hook介入点)
3. [执行流程](#3-执行流程)
    1. [开关设置流程](#31-开关设置流程)
    2. [插入检查流程](#32-插入检查流程)
4. [其他说明](#4-其他说明)
    1. [接口说明](#41-接口说明)
    2. [内存管理](#42-内存管理)
    3. [安全](#43-安全)
    4. [性能](#44-性能)
    5. [升级管理](#45-升级管理)

---

## 概要设计说明书

SET IDENTITY_INSERT（MSSQL兼容性）

## 1 功能规格

### 功能简述

`SET IDENTITY_INSERT` 是一个会话级别（Session-Level）的控制命令，用于覆盖 Identity 列默认的“自动生成”行为。允许用户在执行数据迁移、恢复或测试时，向表中的 Identity 列显式插入特定值。

该功能需严格遵循 SQL Server 的行为规范，包括会话互斥性、显式列名要求以及插入后的序列自适应重置（Reseed）。

### 语法与参数

**语法结构：**

```sql
SET IDENTITY_INSERT [ [ database_name . ] schema_name . ] table_name { ON | OFF }
```

**参数说明：**

* **table_name**：包含 Identity 列的目标表名。
* **ON**：开启显式插入模式。允许用户在 INSERT 语句中为 Identity 列指定值。
* **OFF**：关闭显式插入模式。恢复为系统自动生成序列值。

### 行为规则与限制

#### 1. 会话互斥性 (Session Scope & Exclusivity)
* **规则**：在任一时刻，一个数据库会话（Session）中只能有一张表将 `IDENTITY_INSERT` 设置为 `ON`。
* **冲突处理**：如果当前会话中已有 Table A 设置为 ON，用户尝试将 Table B 设置为 ON，系统应报错：“Table 'Table A' already has IDENTITY_INSERT set to ON. Perform SET IDENTITY_INSERT 'Table A' OFF and try again.”（与 MSSQL 行为一致）。

#### 2. 插入行为限制
* **必须指定列名**：当 `IDENTITY_INSERT` 为 ON 时，执行 INSERT 语句必须在列列表中显式包含 Identity 列，否则报错。
* **禁止更新**：该开关仅影响 `INSERT` 语句，`UPDATE` 语句依然无法修改 Identity 列的值。

#### 3. 序列自适应 (Auto-Reseed)
* **规则**：如果用户显式插入的值大于表当前的当前标识值（Current Identity Value），系统必须自动将底层序列的“高水位”重置为该插入值。
* **目的**：确保后续关闭该开关并恢复自动生成时，不会生成重复的键值。

## 2 语法语义与Hook设计

### 语法解析改造

虽然 `SET` 是 PostgreSQL 的现有关键字（用于 GUC 变量），但 `IDENTITY_INSERT` 并非标准 GUC 格式。需在 Parser 层进行特殊处理。

**修改点 (`gram.y`)：**
* 扩展 `VariableSetStmt` 或新增 `SetIdentityInsertStmt` 节点。
* 增加规则识别 `SET IDENTITY_INSERT relation_expr ON/OFF`。

### 会话状态管理

由于该状态仅在当前 Session 有效，且不应持久化到磁盘，设计采用**会话级全局变量**进行存储。

**数据结构设计：**
```c
/* 全局变量，初始化为 InvalidOid */
Oid g_identity_insert_table_oid = InvalidOid; 
```

* **SET ... ON**：将目标表的 OID 赋值给 `g_identity_insert_table_oid`。
* **SET ... OFF**：检查目标表是否匹配，若匹配则将变量重置为 `InvalidOid`。
* **Session End**：会话断开时，变量自动销毁，无需额外清理。

### Hook介入点

主要通过 **ExecutorStart_hook** (用于 INSERT 前检查) 和 **ExecutorEnd_hook** (用于 Reseed 逻辑) 介入。

1.  **Permission Check Hook**:
    * 在 `SET` 命令执行时，检查用户是否有权修改该表属性（Owner 或 Alter 权限）。
2.  **Insert Pre-Check Hook**:
    * 拦截 `INSERT` 操作，校验 `TargetList` 是否包含 Identity 列与 `g_identity_insert_table_oid` 的状态匹配关系。
3.  **Insert Post-Check Hook (Reseed)**:
    * 在 `INSERT` 完成后，读取插入的 Tuple 数据，判断是否需要更新底层 Sequence。

## 3 执行流程

### 3.1 开关设置流程

1.  **解析**：用户执行 `SET IDENTITY_INSERT t1 ON`。
2.  **语义检查**：
    * 解析表名 `t1` 获取 OID。
    * 确认 `t1` 是否确实包含 Identity 列，若无则报错。
    * 检查用户权限。
3.  **互斥检查**：
    * 检查 `g_identity_insert_table_oid`。
    * 若不为 `InvalidOid` 且不等于 `t1` 的 OID，抛出错误。
4.  **状态更新**：
    * 将 `g_identity_insert_table_oid` 设置为 `t1` 的 OID。

### 3.2 插入检查流程

1.  **输入**：`INSERT INTO t1 (id, name) VALUES (100, 'A')`。
2.  **Pre-Execution 检查**：
    * 识别 `t1` 有 Identity 列 `id`。
    * 检查 `INSERT` 语句是否显式指定了 `id` 列的值 (100)。
    * **判断逻辑**：
        * 若显式指定了值，且 `g_identity_insert_table_oid != t1_oid` -> **报错** ("Cannot insert explicit value...")。
        * 若未指定值，且 `g_identity_insert_table_oid == t1_oid` -> **报错** ("Explicit value must be specified...")。
        * 若显式指定了值，且 `g_identity_insert_table_oid == t1_oid` -> **放行**。
3.  **执行插入**：写入数据到 Heap。
4.  **Post-Execution 调整 (Reseed)**：
    * 获取刚插入的 Identity 值 (例如 100)。
    * 获取底层序列当前值 (`currval` 或 `last_value`)。
    * **若 100 > Sequence_Value**：
        * 隐式调用 `setval('seq_t1', 100)`。
        * 确保下一次自动生成值为 101。

## 4 其他说明

### 接口说明

纯 SQL 语法支持，无 API 接口。

### 内存管理

* 仅使用一个 OID 类型的全局变量，内存占用可忽略不计。
* 表名解析过程使用标准的 Transaction Memory Context。

### 安全

* **权限**：执行 `SET IDENTITY_INSERT` 需要用户拥有该表的 `ALTER` 权限或为表的所有者。
* **审计**：建议将 `SET IDENTITY_INSERT` 的状态变更记录到审计日志中，因为这可能涉及数据篡改风险。

### 性能

* **SET 操作**：极快（变量赋值）。
* **INSERT 操作**：开启该开关后的 INSERT 操作，因增加了“Reseed 判断”步骤（需获取序列当前值并比较），性能微弱低于普通 INSERT，但在数据迁移场景下完全可接受。

### 升级管理

* **不涉及**：纯内存状态管理，不涉及持久化数据结构变更，对 `pg_upgrade` 无影响。