# Artistsion 重构进度记录

## 1. 项目目标

将当前"公开页 + 用户中心 + 后台管理"三合一的 vue-admin-template 风格前端，重构为面向终端用户的画师委托平台前台站。

最终产品形态：

- 统一认证页 `/auth`（登录 + 注册合一）
- 双层导航前台首页 `/home`（作品推荐）
- 画师发现页 `/artists`
- 企划大厅 `/projects`
- 双身份模型（客户 client / 画师 artist），同一账号可拥有两个身份
- 旧后台管理端保留，但不再作为默认入口

---

## 2. 当前已确认现状

### 前端

- Vue 2 SPA，基于 vue-admin-template 改造
- 旧 Layout：左侧 sidebar + 顶部 navbar
- 默认路由 `/` → `/dashboard`（个人资料页，非内容首页）
- `permission.js` 中白名单：`/login`、`/register`、`/auth`、`/mas`、`/theList`、`/community`
- 登录后 `store/modules/user.js` 调 `/user/info` 拿 `{ name, avatar, menuList }`
- `permission.js` 中 `myFilterAsyncRoutes()` 将 `menuList` 映射为动态路由注入
- 旧登录页 `/login` 使用用户名 + 密码 + 前端本地验证码
- 旧注册页 `/register` 单角色二选一（用户/画师）

### 后端

- Spring Boot 2.7.13 + MyBatis-Plus + MySQL + Redis + JWT
- `User` 实体已有字段：`id`、`username`、`password`、`email`、`phone`、`status`、`avatar`、`deleted`、`name`；非映射字段 `roleIdList`、`role`
- `/user/info` 在拦截器白名单中被放行（拦截器只读 `X-Token` 请求头），该接口本身要求 `token` 查询参数并从中解析用户信息——这是两层独立逻辑，不要混淆
- `/user/login` 返回 `{ token }`
- **无** `nickname`、`active_role` 字段（需要作为改造方案新增，不是已有字段）
- **无** `spring-boot-starter-mail` 依赖（邮件发送是新增基础能力）

---

## 3. 阶段 1：入口调整与路由准备 ✅ 已完成

### 目标

让新前台路由骨架就位，新旧 Layout 共存，旧系统完全不受影响。

### 已完成内容

- 新建 `src/layout/MainLayout.vue`：双层顶部导航（logo + 搜索 + 头像 / 首页 + 画师 + 企划），无左侧 sidebar
- 新增 `/auth` 路由 → `views/auth/index.vue`（左右分栏认证占位页，登录/注册卡片切换）
- 新增 `/home` 路由 → `views/home/index.vue`（首页占位，作品网格 + 热门标签）
- 新增 `/artists` 路由 → `views/artists/index.vue`（画师发现占位，画师卡片 + 筛选标签）
- 新增 `/projects` 路由 → `views/projects/index.vue`（企划大厅占位，企划卡片列表）
- 新建 `src/api/auth.js`（新认证接口函数签名，不实际调用）
- `permission.js` 白名单加 `/auth`；已登录访问 `/auth` 重定向 `/home`；未登录非白名单页重定向 `/auth`

### 改动文件

| 文件 | 操作 |
|---|---|
| `artistsion-web/src/layout/MainLayout.vue` | 新建 |
| `artistsion-web/src/views/auth/index.vue` | 新建 |
| `artistsion-web/src/views/home/index.vue` | 新建 |
| `artistsion-web/src/views/artists/index.vue` | 新建 |
| `artistsion-web/src/views/projects/index.vue` | 新建 |
| `artistsion-web/src/api/auth.js` | 新建 |
| `artistsion-web/src/router/index.js` | 修改：import MainLayout，新增 4 条静态路由 |
| `artistsion-web/src/permission.js` | 修改：白名单、重定向目标 |

### 保留不动的旧系统范围

- `src/layout/index.vue` 及其子组件（Sidebar、Navbar、TagsView 等）
- `src/views/dashboard/index.vue`
- `src/views/sys/*`、`src/views/shangp/*`、`src/views/order/*`、`src/views/fenxiang/*` 等所有管理页
- `permission.js` 中已有的动态菜单注入逻辑 `myFilterAsyncRoutes()`
- `store/modules/user.js` 旧 login/getInfo 完整保留
- 后端所有代码（无改动）
- 数据库（无字段变更）
- 旧 `/login`、`/register` 路由及页面

---

## 4. 已知注意点

- **根路径 `/` 的默认行为仍需阶段 2 收口**：当前 `/` 仍然 redirect 到 `/dashboard`（旧后台），阶段 2 必须修正为——未登录访问 `/` 跳 `/auth`，已登录访问 `/` 进入 `/home`，不应继续默认落到旧 `/dashboard`
- `/user/info` 的两层逻辑不要混淆：拦截器白名单放行是一层，接口本身解析 token query 参数是另一层
- `nickname`、`active_role` 不是已有字段，需要作为改造方案在阶段 2 评估是否落表
- 邮件发送是新增基础能力，需要补 `spring-boot-starter-mail` 或先做 mock
- 旧管理端仍依赖 `/user/login` + `/user/info` + 动态菜单链路，改造期间必须保留

---

## 5. 阶段 2：认证系统重构 ✅ 已完成

### 目标

- 修正根路径 `/` 默认行为
- `/auth` 页面实现真实登录/注册
- 后端新增 `/auth/*` 接口（login、register、send-email-code、me、switch-role）
- 登录支持用户名或邮箱
- 注册支持邮箱验证码
- 旧接口保留兼容

### 待办

1. 复核并修正 `/` 的默认入口行为
2. 后端新增 `AuthController`
3. 评估并执行 `User` 实体字段变更（nickname、active_role）
4. 邮件验证码能力（真实发信或 mock）
5. 前端 `/auth` 页接入真实登录/注册
6. `store/modules/user.js` 新增 roles/activeRole 状态
7. 验证新旧登录流程均可用

---

## 6. 当前风险

1. 邮件发送依赖不存在，需补依赖或 mock
2. 旧管理端兼容——旧 login + info + 动态菜单链路不能断
3. 双 Layout 共存——新前台 `MainLayout`、旧管理 `Layout`，路由必须明确区分
4. 企划模块是全新业务——当前无企划表/接口，后续阶段再建
5. 前后端字段耦合——改接口返回结构时必须同步前端消费端

---

## 7. 旧代码删除的前提条件

以下条件全部满足前，不得删除旧登录/注册页和旧接口：

1. `/auth` 页面登录/注册功能完整可用且经过验证
2. 新 `/auth/login` 接口返回结构能被 `store/modules/user.js` 正确消费
3. 新 `/auth/me` 能替代旧 `/user/info` 提供 menuList（或新前台不再依赖 menuList）
4. 旧后台管理端明确有独立入口或已确认不再需要
5. 数据库迁移脚本已就绪且经过测试

---

## 后续阶段预告

| 阶段 | 内容 |
|---|---|
| 阶段 3 | 新前台主站导航与头像菜单完善 |
| 阶段 4 | 首页 / 画师 / 企划静态页面完善 |
| 阶段 5 | 对接真实数据 |
| 阶段 6 | 个人中心与双身份闭环 |
# Artistsion 重构进度记录

## 项目目标
将当前混合式后台模板前端，重构为画师交易平台前台站。
核心目标：
- 统一 `/auth` 认证页
- 新前台主站：首页 / 画师 / 企划
- 一个账号支持客户 / 画师双身份
- 新前台使用独立 `MainLayout`
- 旧后台管理端先保留，不立即删除

---

## 已确认的项目现状
- 前端当前是 Vue 2，来源于 vue-admin-template
- 旧系统登录后依赖 `/user/info -> menuList -> 动态注入路由`
- 旧 Layout 是 sidebar + navbar
- 旧默认首页原本是 `/dashboard`
- 当前目标是让新前台逐步接管主入口，旧后台先保留兼容

---

## 阶段 1：前台入口骨架
### 目标
建立新前台骨架，不破坏旧后台。

### 已完成
- 新增 `src/layout/MainLayout.vue`
- 新增 `src/views/auth/index.vue`
- 新增 `src/views/home/index.vue`
- 新增 `src/views/artists/index.vue`
- 新增 `src/views/projects/index.vue`
- 新增 `src/api/auth.js`
- `src/router/index.js` 已加入新前台路由
- `src/permission.js` 已将未登录 fallback 改为 `/auth`
- 已登录访问 `/auth` 会跳 `/home`

### 当前已知注意点
- 旧 `/login`、`/register` 仍保留，仅作兼容
- 旧后台 Layout、动态菜单、`/dashboard`、管理页均保留
- `store/modules/user.js` 仍为旧登录态逻辑
- 后端、数据库本阶段未改动
- **根路径 `/` 的最终默认行为需要在阶段 2 再核对**
  - 未登录访问 `/` 应进入 `/auth`
  - 已登录访问 `/` 应进入 `/home`
  - 不应继续默认落到旧 `/dashboard`

### 阶段 1 验收结论
- 新前台骨架已建立
- 旧后台未被破坏
- 可以进入阶段 2

---

## 阶段 2：认证系统重构
### 目标
实现真正可用的 `/auth` 页面和新认证链路。

### 待完成
- `/auth` 页实现登录 / 注册切换
- 登录支持“用户名或邮箱 + 密码”
- 注册支持“邮箱 + 邮箱验证码”
- 新增或重构 `/auth/*` 后端接口
- 设计双身份返回结构：`roles`、`activeRole`
- 复核并收口根路径 `/` 默认入口逻辑

### 当前风险
- 后端暂无确认可直接发送邮件的能力
- 旧 `/user/login`、`/user/info` 仍要保留兼容
- 不能让旧后台依赖的新接口结构被破坏

---

## 后续阶段预告
### 阶段 3
- 新前台主站导航与头像菜单完善

### 阶段 4
- 首页 / 画师 / 企划静态页面完善

### 阶段 5
- 对接真实数据

### 阶段 6
- 个人中心与双身份闭环

---

## 不要删除的内容（当前阶段）
- 旧 `src/layout/index.vue`
- 旧 `src/views/dashboard/*`
- 旧 `src/views/sys/*`
- 旧动态菜单逻辑
- 旧 `/user/info` 相关链路

---

## 删除旧代码的前提
只有在以下条件满足后，才开始清理旧代码：
1. 新前台已成为默认入口
2. `/auth` 已稳定替代旧登录注册页
3. 新前台首页 / 画师 / 企划 / 个人中心已可用
4. 若旧后台仍保留，则必须先明确其保留范围
5. 所有动态菜单依赖已核对，不会误删运行时加载页面