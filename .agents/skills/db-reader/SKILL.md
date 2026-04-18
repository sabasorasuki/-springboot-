---
name: db-reader
description: Read-only MySQL database inspection skill for viewing tables, checking schema, sampling rows, and validating data with safe SELECT-only queries. Use when asked to 查看数据库、验证数据、检查表结构、抽样看数据、排查登录数据异常、检查 role/menu/user/order/report 等表的数据关系。
---

# DB Reader

## Description

Use `tools/db_readonly.py` for database inspection in this repository.
Keep all database access strictly read-only.

## Trigger Scenarios

- 查看数据库有哪些表
- 检查某张表的字段结构
- 抽样查看表里的数据
- 验证登录、角色、菜单、订单、举报等数据是否匹配
- 排查“数据库里看起来对，但页面行为不对”的数据问题

## Workflow

1. Always inspect table structure first with `schema`.
2. Then inspect a small sample with `sample`.
3. Only after that, run a targeted `sql` SELECT query if needed.
4. Keep queries narrow and small; prefer filters and small limits.
5. Report:
   - command executed
   - SQL executed or implied
   - result summary
   - conclusion

## Safety Rules

- Never run `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, or `CREATE`.
- Never suggest modifying database data through this skill.
- Never bypass `tools/db_readonly.py` with direct database shell commands.
- Reject dangerous SQL immediately.
- Prefer the smallest query that can answer the question.

## Prohibited

- 修改任何数据库数据
- 创建、删除、重建表
- 执行带锁查询
- 一次拉取大量数据
- 跳过表结构直接下复杂 SQL

## Recommended Commands

```bash
python tools/db_readonly.py tables
python tools/db_readonly.py schema x_user
python tools/db_readonly.py sample x_user 10
python tools/db_readonly.py sql "SELECT id, username, deleted FROM x_user LIMIT 20"
python tools/db_readonly.py sql "SELECT username, COUNT(*) AS cnt FROM x_user GROUP BY username HAVING COUNT(*) > 1"
```

## Response Format

When using this skill, present results in this order:

1. Command
2. SQL
3. Result summary
4. Conclusion

Keep the summary concise and do not dump more rows than needed.
