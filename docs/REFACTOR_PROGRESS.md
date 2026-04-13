# Artistsion 重构进度记录

## 项目目标

将 vue-admin-template 风格的混合前端，重构为画师委托交易平台前台站。

最终产品形态：

- 统一认证页 `/auth`（登录 + 注册合一）
- 双层导航前台首页 `/home`（作品推荐）
- 画师发现页 `/artists`
- 企划大厅 `/projects`
- 双身份模型（客户 client / 画师 artist）
- 旧后台管理端保留，但不再作为默认入口

---

## 阶段 1：前台入口骨架 ✅ 已完成

### 已完成内容

- 新建 `src/layout/MainLayout.vue`（双层顶部导航，无 sidebar）
- 新增 `/auth`、`/home`、`/artists`、`/projects` 路由及占位页
- 新建 `src/api/auth.js`（接口函数签名）
- `permission.js` 白名单加 `/auth`，未登录 fallback → `/auth`，已登录 `/auth` → `/home`
- 旧后台全部保留（Layout、dashboard、动态菜单、管理页、旧登录/注册）

### 改动文件

| 文件 | 操作 |
|---|---|
| `artistsion-web/src/layout/MainLayout.vue` | 新建 |
| `artistsion-web/src/views/auth/index.vue` | 新建 |
| `artistsion-web/src/views/home/index.vue` | 新建 |
| `artistsion-web/src/views/artists/index.vue` | 新建 |
| `artistsion-web/src/views/projects/index.vue` | 新建 |
| `artistsion-web/src/api/auth.js` | 新建 |
| `artistsion-web/src/router/index.js` | 修改 |
| `artistsion-web/src/permission.js` | 修改 |

---

## 阶段 2：认证系统重构 ✅ 已完成（本地未推送）

### 已完成内容

#### 前端

- `router/index.js`：根路径 `/` redirect 改为 `/home`
- `store/modules/user.js`：新增 `authLogin` action，新增 `roles`/`activeRole` state 和 mutations，旧 `login`/`getInfo`/`logout` 保留
- `store/getters.js`：新增 `roles`/`activeRole` getters
- `permission.js`：catch 块 redirect 改为 `/auth`
- `views/auth/index.vue`：登录接入 `store.dispatch('user/authLogin')`，注册接入 `authRegister` API，验证码接入 `sendEmailCode` API
- `api/auth.js`：5 个接口函数完整实现

#### 后端

- 新建 `AuthController.java`（`/auth/login`、`/auth/register`、`/auth/send-email-code`、`/auth/me`、`/auth/switch-role`）
- 新建 `EmailService.java`（Redis 存验证码 5min TTL，邮件发送失败 fallback 到控制台）
- `MyWebConfig.java`：白名单加 `/auth/login`、`/auth/register`、`/auth/send-email-code`
- `pom.xml`：加 `spring-boot-starter-mail`
- `application.properties`：加 `spring.mail.*` 占位配置

#### SQL

- `sql/2026-04-13-add-nickname-active-role.sql`：可选字段变更脚本（不自动执行）

### 关键设计决策

- 登录支持用户名或邮箱（`account` 包含 `@` 则按邮箱查）
- `nickname` 暂复用 `User.name` 字段，未新增数据库列
- `activeRole` 不持久化，由 `/auth/login` 返回首个角色作为默认值
- 邮件发送失败不阻塞注册流程（fallback 到控制台打印验证码）
- 旧 `/user/login`、`/user/info`、`/user/register` 全部保留

### 当前状态

**代码已在本地工作区完成，尚未推送到 GitHub main 分支。**

---

## 当前风险

1. 邮件配置 `application.properties` 中是占位值，需替换真实 SMTP 信息才能实际发信
2. 旧管理端依赖 `/user/login` + `/user/info` → `menuList` → 动态路由注入，不能断
3. 双 Layout 共存——新前台 `MainLayout`、旧管理 `Layout`，路由不要搞混
4. 企划模块是全新业务——当前无企划表/接口，后续阶段再建
5. `AuthController.resolveRoleId()` 硬编码了角色 ID 映射（artist=2, client=1），需与数据库一致

---

## 旧代码删除前提

以下条件全部满足前，不删除旧登录/注册页和旧接口：

1. `/auth` 登录/注册功能可用且验证通过
2. `/auth/login` 返回结构能被 `store/modules/user.js` 正确消费
3. `/auth/me` 能替代 `/user/info` 提供 `menuList`（或新前台不再依赖 `menuList`）
4. 旧后台管理端有独立入口或确认不再需要
5. 数据库迁移已执行且验证

---

## 后续阶段

| 阶段 | 内容 |
|---|---|
| 阶段 3 | 新前台主站导航与头像菜单完善 |
| 阶段 4 | 首页 / 画师 / 企划静态页面完善 |
| 阶段 5 | 对接真实数据 |
| 阶段 6 | 个人中心与双身份闭环 |
