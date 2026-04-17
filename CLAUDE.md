# Artistsion 仓库指引

## 项目是什么

Artistsion 是一个画师约稿 / 作品交易 / 社区内容平台。当前仓库同时包含：

- `artistsion-web`：Vue 2 单体前端，混合主站、个人中心和 admin 控制台
- `artistsion-admin`：Spring Boot 后端
- `artistsion.sql`：主数据库导出
- `docs/`：给 AI 助手的精简项目文档

## 仓库结构

- `artistsion-web/src/router/index.js`：静态路由与两套 layout 入口
- `artistsion-web/src/permission.js`：登录守卫、动态菜单注入、`/admin` 兼容映射
- `artistsion-web/src/utils/adminConsole.js`：admin 菜单收敛与权限边界
- `artistsion-admin/src/main/java/com/lf/controller`：后端接口入口
- `artistsion-admin/src/main/resources/mapper`：MyBatis XML
- `artistsion-admin/sql`：增量 SQL 补丁

## AI 助手优先阅读顺序

1. 本文件
2. 任务对应的 `artistsion-web/CLAUDE.md` 或 `artistsion-admin/CLAUDE.md`
3. `docs/PROJECT_MAP.md`
4. `docs/SESSION_HANDOFF.md`

## 启动方式

- 后端：`cd artistsion-admin && .\mvnw.cmd spring-boot:run`
- 前端：`cd artistsion-web && npm install && npm run dev`
- 默认端口：前端 `8888`，后端 `9999`
- 本地依赖：MySQL `artistsion`、Redis、`artistsion.sql`

## 敏感配置提醒

- `artistsion-admin/src/main/resources/application.properties` 与本地覆写文件包含数据库、JWT、支付宝、DashScope、邮件、文件存储等敏感配置。
- 不要把真实账号、密码、密钥、支付参数写进文档、日志、截图或提交。
- 动库前先确认本地库是否已经执行 `artistsion-admin/sql` 中对应补丁。

## 高风险改动提醒

- 当前认证与菜单链路仍高度耦合：前端统一认证页是 `/auth`，但 admin 运行时仍依赖 `/user/info` -> `menuList` -> `permission.js` 动态路由。
- `/admin` 是控制台统一入口，但旧路径 `/dashboard`、`/sys/*`、`/order/*`、`/shangp/*` 等仍保留兼容访问。
- 涉及上传、支付、AI、订单时，先检查硬编码 URL、敏感配置和前后端契约，再改代码。
