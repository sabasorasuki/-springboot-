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

- 新建 `src/layout/MainLayout.vue`（双层顶部导航，无 sidebar）
- 新增 `/auth`、`/home`、`/artists`、`/projects` 路由及占位页
- 新建 `src/api/auth.js`（接口函数签名）
- `permission.js` 白名单加 `/auth`，未登录 fallback → `/auth`，已登录 `/auth` → `/home`
- 旧后台全部保留

---

## 阶段 2：认证系统重构 ✅ 已完成

### 前端

- `router/index.js`：根路径 `/` redirect → `/home`
- `store/modules/user.js`：新增 `authLogin` action，新增 `roles`/`activeRole` state + mutations，旧 login/getInfo/logout 保留
- `store/getters.js`：新增 `roles`/`activeRole`
- `permission.js`：token 失效 catch 块 redirect → `/auth`
- `views/auth/index.vue`：登录/注册/验证码全部接入真实 API
- `api/auth.js`：5 个接口函数完整实现

### 后端

- 新建 `AuthController.java`（`/auth/login`、`/auth/register`、`/auth/send-email-code`、`/auth/me`、`/auth/switch-role`）
- 新建 `EmailService.java`（Redis 验证码 5min TTL + 邮件 fallback 到控制台）
- `MyWebConfig.java`：白名单加 `/auth/login`、`/auth/register`、`/auth/send-email-code`
- `pom.xml`：加 `spring-boot-starter-mail`
- `application.properties`：密钥已脱敏为占位符，真实值移至 `application-local.properties`（gitignored）

### 阶段 2 收尾（本轮完成）

- `resolveRoleId()` 从硬编码改为查库（`x_role.role_name`）
- 配置脱敏：`application.properties` 中所有密钥替换为 `${ENV_VAR:}` 占位符
- 新增 `application-local.properties`（本地密钥，gitignored）和 `.template` 模板
- `.gitignore` 加入 `**/application-local.properties`

### 关键设计决策

- 登录支持用户名或邮箱（`account` 含 `@` 按邮箱查）
- `nickname` 暂复用 `User.name`，未新增数据库列
- `activeRole` 不持久化，登录时返回首个角色
- 邮件发送失败不阻塞注册（fallback 到控制台打印验证码）
- 旧 `/user/login`、`/user/info`、`/user/register` 全部保留

### `/auth/me` 与 `menuList` 的过渡策略

`/auth/me` 当前返回 `menuList` 是**过渡方案**，目的是兼容旧前端 `getInfo` 的消费结构。

阶段 3 起，新前台路由由 `constantRoutes` 静态定义（`/home`、`/artists`、`/projects`），不依赖 `menuList` 驱动。新前台应逐步摆脱旧菜单体系：

1. 阶段 3：新前台导航完全由前端静态路由驱动，`/auth/me` 的 `menuList` 仅供旧后台消费
2. 阶段 5+：如果旧后台确认保留，给旧后台独立入口（如 `/admin`），`menuList` 只在该入口下使用
3. 最终清理：旧后台入口明确后，`/auth/me` 可以不再返回 `menuList`

---

## 当前风险

1. 旧管理端依赖 `/user/login` + `/user/info` → `menuList` → 动态路由，不能断
2. 双 Layout 共存——`MainLayout`（新前台）与 `Layout`（旧管理），路由不要搞混
3. 企划模块是全新业务——当前无企划表/接口，后续阶段再建
4. JWT 密钥仍为硬编码 `"123456"`——后续应提取到配置

---

## 配置脱敏说明

`application.properties` 中的所有密钥/密码/API Key 已替换为环境变量占位符：

```
spring.datasource.password=${DB_PASSWORD:}
alipay.privateKey=${ALIPAY_PRIVATE_KEY:}
ai.api.key=${AI_API_KEY:}
spring.mail.password=${MAIL_PASSWORD:}
```

真实值存放于 `application-local.properties`（已加入 `.gitignore`）。新开发者按 `.template` 文件创建本地副本即可。

**已泄露密钥的处理建议**（需要你手动操作）：

1. 支付宝沙箱密钥：登录支付宝开放平台 → 沙箱环境 → 重新生成密钥对
2. DashScope API Key：登录阿里云 DashScope 控制台 → 吊销旧 key → 创建新 key
3. MySQL 密码：`ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';`，然后更新 `application-local.properties`
4. 如果之前有人 fork 过仓库，旧提交历史中仍有密钥。可考虑用 `git filter-repo` 清除历史，但对毕设项目来说成本较高，轮换密钥本身已足够

---

## 旧代码删除前提

以下条件全部满足前，不删除旧登录/注册页和旧接口：

1. `/auth` 登录/注册功能可用且验证通过
2. `/auth/login` 返回结构能被 `store/modules/user.js` 正确消费
3. 旧后台管理端有明确独立入口或确认不再需要
4. 数据库迁移已执行且验证

---

## 阶段 3：新前台导航完善 ✅ 已完成

### 已完成内容

- `MainLayout.vue` TopBar 区分登录/未登录状态：
  - 已登录：显示头像 + 用户名 + 下拉菜单（个人中心、订单中心、切换身份、退出登录）
  - 未登录：显示「登录/注册」按钮跳 `/auth`
- TopBar 头像菜单接入真实 Vuex 数据：`token`、`name`、`avatar`、`roles`、`activeRole`
- 切换身份功能：调 `switchRole` API + `SET_ACTIVE_ROLE` mutation，下拉菜单显示当前身份标签
- 身份切换仅在用户拥有多个角色时显示
- 退出登录调 `store.dispatch('user/logout')` → 跳 `/auth`
- 个人中心跳 `/userinfo`，订单中心跳 `/order/ordergl`
- SiteNav 路由高亮已在阶段 1 实现（`isNavActive` 方法）

### 改动文件

| 文件 | 操作 |
|---|---|
| `artistsion-web/src/layout/MainLayout.vue` | 修改 |

---

## 后续阶段

| 阶段 | 内容 |
|---|---|
| 阶段 4 | 首页 / 画师 / 企划页面内容完善 |
| 阶段 5 | 对接真实数据 |
| 阶段 6 | 个人中心与双身份闭环 |
