---
name: db-reader
description: MCP-based MySQL database operation skill for this repository, including schema inspection, SELECT queries, INSERT, UPDATE, DELETE, transactions, and targeted data maintenance. Use when asked to 连接数据库、查看数据库、执行 SQL、增删改查、修复/清理/验证 role/menu/user/order/report 等表数据、排查数据库驱动的页面或业务异常。
---

# DB MCP Operator

## Description

Use the configured MCP MySQL tool for all database access in this repository.
Do not use or recreate `tools/db_readonly.py`.

## Trigger Scenarios

- 连接 MCP 数据库
- 查看数据库有哪些表
- 检查某张表的字段结构
- 抽样查看表里的数据
- 执行 SELECT、INSERT、UPDATE、DELETE
- 执行 JOIN、聚合、子查询、CTE、事务等复杂 SQL
- 验证登录、角色、菜单、订单、举报等数据是否匹配
- 修复、清理、补录业务数据
- 排查“数据库里看起来对，但页面行为不对”的数据问题

## Workflow

1. Use MCP MySQL queries only.
2. For unfamiliar tables, inspect structure first with `SHOW CREATE TABLE table_name` or `DESCRIBE table_name`.
3. Then inspect a small sample or targeted rows with `SELECT ... LIMIT ...` when useful.
4. For data-changing work, identify the target rows with `SELECT` before running `INSERT`, `UPDATE`, or `DELETE`.
5. Keep writes targeted with explicit columns, primary keys, or narrow `WHERE` clauses.
6. For multi-step changes, prefer explicit transactions when supported: `START TRANSACTION`, changes, verification query, then `COMMIT`; use `ROLLBACK` if verification fails.
7. Verify changes after execution with a focused `SELECT` or affected-row summary.
8. Report:
   - MCP tool used
   - SQL executed
   - result summary
   - verification or conclusion

## Allowed Operations

- Read operations: `SELECT`, `SHOW`, `DESCRIBE`, `EXPLAIN`
- Data changes: `INSERT`, `UPDATE`, `DELETE`
- Complex SQL: joins, grouping, ordering, subqueries, CTEs, aggregates, transactions
- Schema changes: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, and index changes only when the user explicitly asks for schema-level work

## Guardrails

- Do not run broad `UPDATE` or `DELETE` without a clear target condition unless the user explicitly asks for a whole-table operation.
- Do not guess table or column names when they can be inspected through MCP.
- Do not dump large result sets; use focused filters and limits for inspection.
- For destructive or schema-level changes, state the intended impact and verify afterward.
- Keep database credentials out of responses.

## Recommended MCP SQL

```sql
SHOW TABLES;
DESCRIBE x_user;
SELECT id, username, deleted FROM x_user LIMIT 20;
SELECT username, COUNT(*) AS cnt FROM x_user GROUP BY username HAVING COUNT(*) > 1;
UPDATE x_user SET deleted = 1 WHERE id = 123;
DELETE FROM x_user_role WHERE user_id = 123 AND role_id = 4;
```

## Response Format

When using this skill, present results in this order:

1. Tool
2. SQL
3. Result summary
4. Verification or conclusion

Keep the summary concise and do not dump more rows than needed.
