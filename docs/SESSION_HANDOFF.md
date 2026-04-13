# 会话交接摘要

## 当前所处阶段

阶段 1 ✅ 已完成，阶段 2 ✅ 已完成（本地代码完整，尚未推送到 GitHub main）。

---

## 阶段 2 已完成内容

### 前端改动

| 文件 | 改动 |
|---|---|
| `router/index.js` | 根路径 `/` redirect → `/home` |
| `store/modules/user.js` | 新增 `authLogin` action、`roles`/`activeRole` state + mutations |
| `store/getters.js` | 新增 `roles`/`activeRole` getters |
| `permission.js` | catch 块 redirect → `/auth` |
| `views/auth/index.vue` | 登录调 `store.dispatch('user/authLogin')`，注册调 `authRegister`，验证码调 `sendEmailCode` |
| `api/auth.js` | 5 个接口函数：`authLogin`、`authRegister`、`sendEmailCode`、`getAuthMe`、`switchRole` |

### 后端改动

| 文件 | 改动 |
|---|---|
| `AuthController.java` | 新建：`/auth/login`、`/auth/register`、`/auth/send-email-code`、`/auth/me`、`/auth/switch-role` |
| `EmailService.java` | 新建：Redis 验证码（5min TTL）+ 邮件 fallback |
| `MyWebConfig.java` | 白名单加 `/auth/login`、`/auth/register`、`/auth/send-email-code` |
| `pom.xml` | 加 `spring-boot-starter-mail` |
| `application.properties` | 加 `spring.mail.*` 占位配置 |
| `sql/2026-04-13-add-nickname-active-role.sql` | 可选字段变更脚本 |

### 关键设计决策

- 登录 `account` 含 `@` 按邮箱查，否则按用户名查
- `nickname` 复用 `User.name`，未新增列
- `activeRole` 不落库，登录时返回首个角色
- 邮件 fallback：发送失败不报错，验证码打控制台
- 旧 `/user/login`、`/user/info`、`/user/register` 全部保留

---

## 下一步：阶段 3

### 主要任务

- 新前台主站导航与头像菜单完善
- `MainLayout` 的 TopBar 头像下拉菜单接入真实用户信息
- SiteNav 高亮当前路由
- 可选：首页搜索框初步接入

### 前置条件

- 阶段 2 代码推送到 main 并确认后端可启动

---

## 当前风险

1. `application.properties` 邮件配置为占位值
2. `AuthController.resolveRoleId()` 硬编码角色 ID（artist=2, client=1）
3. 旧管理端 `/user/login` + `/user/info` → `menuList` → 动态路由不能断
4. 企划模块无表无接口，阶段 4+ 再建

---

## 参考文档

- `CLAUDE.md` — 仓库总览
- `artistsion-web/CLAUDE.md` — 前端指引
- `artistsion-admin/CLAUDE.md` — 后端指引
- `docs/PROJECT_MAP.md` — 业务映射
- `docs/REFACTOR_PROGRESS.md` — 长期进度
- `docs/FRONTEND_STYLE_SPEC.md` — 前端样式规范
