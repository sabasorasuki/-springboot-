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

## 阶段 4：首页 / 画师 / 企划页面内容 ✅ 已完成

### 首页 `/home`

- 顶部轮播区：接 `/sysLunbo/list` 真实数据，`el-carousel` 展示
- 推荐作品网格：已登录走推荐链路（`/userArticleOperation/recommendations/{userId}` → `/sysHuagao/tuijianlist`），未登录降级 `/sysHuagao/getzuixin`
- 热门分类标签：接 `/sysFenlei/list` 真实数据，点击预留筛选入口
- 全部作品浏览：接 `/sysHuagao/list`（上架 + 审核成功），支持分页加载更多
- 卡片展示：封面图 + 标题 + 分类标签 + 价格，4 列网格 + 响应式

### 画师页 `/artists`

- 后端新增 `/user/artists` 安全公开接口（`ArtistVO`：id/username/name/avatar/status/workCount/recentCovers）
- 不暴露 email/phone/password，不复用 `/user/list`
- 分类筛选栏：接 `/sysFenlei/list` 真实分类数据
- 画师卡片：头像 + 名字 + 作品数 + 3 张作品缩略图 + 简介占位
- 分页组件支持翻页
- 简介/风格标签字段待后续 Phase 5 补充用户资料表字段

### 企划页 `/projects`

- 使用前端静态 mock 数据（6 条示例企划）
- 卡片结构按目标 `sys_project` 表 schema 设计：标题、描述、分类、风格、预算区间、截止日期、状态、发布者信息
- 分类筛选功能可用
- 状态标签样式（招募中/进行中/已完成/已关闭）
- 代码注释中记录了完整目标表结构，后续建表后替换数据源

### 后端改动

| 文件 | 操作 | 说明 |
|---|---|---|
| `MyWebConfig.java` | 修改 | 白名单补 `/sysHuagao/tuijianlist`、`/user/artists` |
| `UserController.java` | 修改 | 新增 `/user/artists` 端点（分页、按画师角色过滤、聚合作品数和缩略图） |
| `vo/ArtistVO.java` | 新增 | 画师安全投影 VO |

### 前端改动

| 文件 | 操作 | 说明 |
|---|---|---|
| `views/home/index.vue` | 重写 | 轮播 + 推荐/最新 + 分类 + 全部作品 |
| `views/artists/index.vue` | 重写 | 真实画师数据 + 筛选 + 缩略图 |
| `views/projects/index.vue` | 重写 | 静态 mock + 目标 schema 注释 |
| `api/artist.js` | 新增 | `/user/artists` 前端封装 |

### 已知过渡态

1. **角色切换弹框**：当前 `$confirm` 仅适配双角色，角色 ≥3 时需改为可选列表
2. **个人中心/订单中心**：仍跳旧页面 `/userinfo`、`/order/ordergl`，后续阶段改造
3. **画师简介/风格标签**：User 表无 bio/style 字段，当前占位显示"暂无简介"
4. **作品/画师详情页**：点击卡片目前仅弹 toast，详情页在后续阶段实现
5. **企划后端**：无 `sys_project` 表，当前纯前端 mock
6. **`ARTIST_ROLE_ID = 7` 硬编码**：`UserController.getArtistList()` 中画师角色 ID 写死为 `7`，与 `AuthController.resolveRoleId()` 的查库方式不一致。当前可接受，阶段 5/6 应改为按角色名查库（`x_role.role_name = '画师角色'`），保持与认证模块一致

---

## 阶段 5A：详情页 + 个人中心骨架 ✅ 已完成

### 后端

- `UserController.java` 新增 `GET /user/artist/{id}` 单画师详情端点：
  - 校验用户存在 + 启用 + 拥有画师角色
  - 返回 `ArtistVO` 安全投影（id/username/name/avatar/status/workCount/recentCovers）
  - 聚合上架+审核成功画稿数量及最近 3 张封面

### 前端路由

- `router/index.js` 新增 5 条 MainLayout 路由：`/work/:id`、`/artist/:id`、`/project/:id`、`/center/profile`、`/center/orders`

### 新页面

| 文件 | 说明 |
|---|---|
| `views/work/detail.vue` | 作品详情（真实数据，`huagao.getById`）：大图 + 标题 + 分类 + 价格/折扣 + 作者链接 + 富文本介绍 + 附件 |
| `views/artists/detail.vue` | 画师详情（`artist.getById` + `huagao.getList` by shangjiaids）：头像 + 名称 + 作品数 + 接稿状态 + 作品网格分页 |
| `views/projects/detail.vue` | 企划详情（从共享 mockProjects 取数据）：标题 + 描述 + 分类/风格 + 预算 + 截止日 + 发布者 + 状态 |
| `views/center/profile.vue` | 个人中心（卡片式）：头像名片 + 编辑资料表单（`updateMyUser`）+ 快捷入口（订单/发布/分享/消息） |
| `views/center/orders.vue` | 订单骨架页（`el-empty` 占位） |

### Store / API

- `store/modules/user.js`：新增 `userId` 状态 + `SET_USER_ID` mutation + `getInfo` 中从 `data.userList.id` 提取
- `store/getters.js`：新增 `userId` getter
- `api/artist.js`：新增 `getById(id)` 方法（`/user/artist/${id}`）

### 接线更新

- `views/home/index.vue`：`goWorkDetail` 从 toast 改为 `$router.push('/work/' + id)`
- `views/artists/index.vue`：`goArtistDetail` 从 toast 改为 `$router.push('/artist/' + id)`
- `views/projects/index.vue`：`goDetail` 从 toast 改为 `$router.push('/project/' + id)`
- `MainLayout.vue`：头像菜单 center → `/center/profile`，orders → `/center/orders`

### 约束与决策

1. **未修改 `permission.js`** — 所有新页面均需登录后访问，无匿名/公开前缀变更
2. 企划详情使用前端 mock 数据，后端建表后替换
3. 订单页为纯骨架，不接旧订单数据
4. 作品详情的"收藏""加入购物车"按钮已渲染，功能接线留待 5B

### 已知技术债

1. **`ARTIST_ROLE_ID = 7` 硬编码**：`UserController` 中 `/user/artists` 和 `/user/artist/{id}` 均依赖 `private static final int ARTIST_ROLE_ID = 7`。与 `AuthController.resolveRoleId()` 的查库方式不一致。应在阶段 5B 或 6 统一改为按角色名查库（`x_role.role_name = '画师角色'`）
2. **画师简介/风格标签**：User 表仍无 bio/style 字段，画师详情页暂无简介区
3. **作品详情缺画师名**：`SysHuagao` 仅存 `shangjiaids`（画师 userId），详情页未关联查出画师昵称

---

## 后续阶段

| 阶段 | 内容 |
|---|---|
| 阶段 5B | 后端数据扩展（企划建表、User 资料字段、订单前台查询）、旧页面替换 |
| 阶段 6 | 双身份闭环、轮换密钥、生产部署 |
