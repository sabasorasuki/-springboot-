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
4. ~~JWT 密钥仍为硬编码 `"123456"`~~ → 阶段 6A 已外部化为 `jwt.secret=${JWT_SECRET:123456}`（`JwtUtil` 通过 `@Value` 读取）。当前测试环境默认回退值 `123456` 可接受，但仍属于后续应继续收口的安全技术债——生产部署前必须替换为强随机密钥

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

以下条件已满足，旧认证页兼容层已进入删除阶段：

1. `/auth` 登录/注册功能可用且验证通过
2. `/auth/login` 返回结构能被 `store/modules/user.js` 正确消费
3. 旧后台管理端继续沿用 `/user/login` + `/user/info` + `menuList` 动态路由链路，不依赖前端 `/login`、`/register` 页面
4. 数据库迁移已执行且验证

### 阶段 6B 收尾：旧兼容入口清理 ✅ 已完成

- 第一轮旧前台兼容层清理：
  - 删除 `/mas`、`/theList`、`/community`、`/detail`、`/details` 路由
  - 删除 `artistsion-web/src/views/AboutView.vue`
  - 删除 `artistsion-web/src/views/about/`
- 第二轮旧认证页清理：
  - 删除前端 `/login`、`/register` 路由
  - 删除 `artistsion-web/src/views/login/index.vue`
  - 删除 `artistsion-web/src/views/login/register.vue`
  - `permission.js` 白名单从 `['/login', '/register', '/auth']` 收缩为仅保留 `['/auth']`
  - 旧后台个人资料页与 dashboard 的注销后跳转改为 `/auth`

### 当前认证入口状态

- 前端仅保留统一认证页 `/auth`
- 未登录访问受保护页面统一跳转 `/auth`
- 已登录访问 `/auth` 统一跳转 `/home`
- 后端旧接口 `/user/login`、`/user/info`、`/user/register` 继续保留，供旧后台管理链路兼容使用

### 阶段 6C：旧后台入口隔离与存活清点 ✅ 已完成

#### 入口隔离

- 新增前端静态入口 `/admin`，统一作为旧后台入口，访问后进入既有后台首页 `/dashboard`
- 为了兼容历史后台路径，前端守卫新增 `/admin/<legacy-path>` 映射：
  - `/admin/sys/...` → `/sys/...`
  - `/admin/order/...` → `/order/...`
  - `/admin/shangp/...` → `/shangp/...`
  - 其他旧后台根路径同理
- 不修改后端 `x_menu` 数据，不修改 `/user/info` 返回结构，不修改动态菜单注入逻辑
- 后台壳内面包屑首页统一指向 `/admin`
- 后台壳内注销后默认跳转 `/auth?redirect=/admin`

#### 后台存活清点结论

- 明确仍在使用：
  - `views/dashboard/index.vue`：静态后台首页 `/dashboard`
  - `views/sys/user.vue`、`views/sys/role.vue`、`views/sys/route.vue`：`x_menu` 组件路径 `sys/user`、`sys/role`、`sys/route`
  - `views/userinfo/index.vue`、`views/userinfo/fabusp.vue`、`views/userinfo/myfenxiang.vue`、`views/userinfo/liaotian.vue`：静态路由 `/userinfo`、`/fabusp`、`/myfenxiang`、`/liaotian`，且被旧后台/新个人中心页内部跳转引用
  - `views/order/gouwuche.vue`、`views/order/ordergl.vue`、`views/order/orderadgl.vue`、`views/order/orderadglqb.vue`：`x_menu` 组件路径 `order/*`
  - `views/shangp/shangp.vue`、`views/shangp/shangpsh.vue`、`views/shangp/spsxj.vue`：`x_menu` 组件路径 `shangp/*`
- 待观察：
  - `views/fenxiang/*`、`views/fenlei/*`、`views/shoucang/*`、`views/liuyan/*`、`views/tongji/*`、`views/rizhi/*`、`views/lunbo/*`、`views/ai/*`
  - 依据：仍在 `x_menu` + `x_role_menu` 链路中，但不在本轮重点目录，需下一轮按真实角色/入口继续梳理
- 下一轮删除候选：
  - `views/test/test1.vue`、`views/test/test2.vue`、`views/test/test3.vue`、`views/test/test4.vue`
  - 依据：虽在 `x_menu` 中存在 `test/*` 记录，但当前 `x_role_menu` 未给任何角色分配测试模块根菜单 `menu_id=4` 或其子菜单；前端也无静态路由或页面内跳转引用
  - `views/table/*`、`views/tree/*`、`views/form/*`、`views/nested/*` 已在阶段 6D 删除，不再保留为候选

### 阶段 6D：明确死代码清理 ✅ 已完成

- 已删除前端模板残留：
  - `views/table/index.vue`
  - `views/tree/index.vue`
  - `views/form/index.vue`
  - `views/nested/**/*`
- 删除依据：
  - 未出现在 `router/index.js` 静态路由中
  - 未出现在 `artistsion.sql` 的 `x_menu.component` 菜单路径中
  - 未搜到页面内跳转、`import` 或 `require` 引用
- 暂未删除：
  - `views/test/test1.vue`、`views/test/test2.vue`、`views/test/test3.vue`、`views/test/test4.vue`
  - 原因：虽然当前 `x_role_menu` 未分配给任何角色，但 `x_menu.component` 仍保留 `test/test1-4` 组件路径记录，因此本轮不再按“明确无人引用”处理
- 构建验证：
  - 前端 `npm run build:prod` ✅ 通过

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

## 阶段 5B：后端数据扩展 + 旧页面替换 ✅ 已完成

### SQL 迁移

- `sql/2026-04-13-phase5b-project-and-user-fields.sql` 已执行
- `sys_project` 表已创建（id/title/description/category/style/budget_min/budget_max/deadline/status/user_id/username/user_avatar/created_at/updated_at）
- `x_user` 表新增 `bio`（VARCHAR 500）和 `style_tags`（VARCHAR 200）列

### 后端新增

| 文件 | 说明 |
|---|---|
| `entity/SysProject.java` | 企划实体，MyBatis-Plus 映射 |
| `dao/SysProjectMapper.java` | 继承 `BaseMapper<SysProject>` |
| `service/SysProjectService.java` | 继承 `IService<SysProject>` |
| `service/impl/SysProjectServiceImpl.java` | 继承 `ServiceImpl` |
| `controller/SysProjectController.java` | 企划 CRUD：list（分页+分类+状态过滤）、getById、add、update、deleteById |

### 后端修改

| 文件 | 变更 |
|---|---|
| `entity/User.java` | 新增 `bio`、`styleTags` 字段 |
| `vo/ArtistVO.java` | 新增 `bio`、`styleTags` 字段 |
| `controller/UserController.java` | ARTIST_ROLE_ID 去硬编码 → `@PostConstruct` 查 `x_role.role_name='画师角色'`（fallback 7）；`/user/artists` 和 `/user/artist/{id}` VO 组装加 bio/styleTags |
| `controller/SysOrderController.java` | 新增 `GET /sysOrder/mine`：从 `X-Token` 解析用户、DB 验证角色、画师→按 `shangjiaids` 过滤 / 用户→按 `userids` 过滤、排除"购物车"状态 |
| `service/EmailService.java` | 修复 `@Resource(name="javaMailSender")` → `@Resource`（bean 名不匹配导致启动失败） |

### 前端新增

| 文件 | 说明 |
|---|---|
| `api/project.js` | `getList`、`getById`、`add` |
| `api/order.js` | 新增 `getMine(params)` → `GET /sysOrder/mine` |

### 前端修改

| 文件 | 变更 |
|---|---|
| `views/projects/index.vue` | mock → 真实 `projectApi.getList()`，服务端分类过滤 + 分页加载更多 |
| `views/projects/detail.vue` | mock → 真实 `projectApi.getById()` |
| `views/center/orders.vue` | 空壳 → 双视角订单列表（买家/画师 radio 切换），接 `orderApi.getMine()` |
| `views/center/profile.vue` | 编辑表单新增 `bio` textarea + `styleTags` input，fetchProfile 回填 |
| `views/artists/index.vue` | 卡片 footer "暂无简介" → `artist.bio \|\| '暂无简介'` |
| `views/artists/detail.vue` | 头部新增 bio 段落 + styleTags 标签组（逗号分割为 chip） |
| `layout/components/Navbar.vue` | "个人信息" 链接 `/userinfo` → `/center/profile` |

### 运行时验证

- 后端 `clean compile` ✅ BUILD SUCCESS
- 后端 `spring-boot:run` ✅ 启动成功，9999 端口
- `@PostConstruct` 画师角色查库 ✅ `Total: 1`
- `GET /user/artists` ✅ 返回 bio/styleTags 字段
- `GET /sysProject/list` ✅ JWT 拦截正确生效
- `javaMailSender` bug 修复 ✅ 启动不再报错
- 前端 `build:prod` ✅ 构建成功

### 已解决的技术债

1. ~~`ARTIST_ROLE_ID = 7` 硬编码~~ → `@PostConstruct` 查库 + fallback
2. ~~画师 bio/style 字段缺失~~ → `x_user.bio` + `x_user.style_tags`
3. ~~企划无后端~~ → `sys_project` 全栈 CRUD
4. ~~订单前台无查询~~ → `/sysOrder/mine` 安全端点（token 鉴权 + 角色双视角）
5. ~~Navbar 指向旧 `/userinfo`~~ → `/center/profile`
6. ~~`javaMailSender` bean 名不匹配~~ → `@Resource` 无指定 name

---

## 阶段 6A：技术收口 ✅ 已完成

### JWT 密钥外部化

- `JwtUtil.java`：`private static final String JWT_KEY = "123456"` → `@Value("${jwt.secret:123456}") private String jwtKey`
- `application.properties`：新增 `jwt.secret=${JWT_SECRET:123456}`
- `application-local.properties`：新增 `JWT_SECRET=123456`（注释提醒生产环境替换）
- 签发（`createToken`）和解析（`parseToken`）全部切换为实例字段 `jwtKey`

> **安全技术债**：JWT 密钥已支持外部化配置，但默认回退值仍为 `123456`。当前测试环境可接受，生产部署前必须替换为强随机密钥。

### 作品详情页接线

- `SysHuagao.java`：新增 `@TableField(exist=false) private String artistName` 瞬态字段
- `SysHuagaoController.getById()`：通过 `userMapper.selectById(shangjiaids)` 填充画师名
- `work/detail.vue`：
  - 显示画师名链接
  - 收藏按钮：对接 `shoucangApi`（查重 + 添加/取消收藏）
  - 加入购物车：对接 `orderApi.add(status="购物车")`

### 3+ 角色切换修复

- `MainLayout.vue`：`promptRoleSelection()` 从 `$msgbox` 纯文本改为 `el-radio-group` 可选列表，支持任意数量角色

### OSS URL 集中化

- 新建 `src/utils/oss.js`：导出 `ossDownloadUrl(name)`、`ossUploadAction(module)`、`ossUploadImgServer`、`ossBase`
- 19 个视图文件共 28 处 `http://localhost:9999` 硬编码全部替换为集中化调用
- URL 基础来源统一为 `process.env.VUE_APP_BASE_API`

### /detail 路由评估

- 结论：**保留**。`the-course.vue` 仍在使用 `:to="'/detail?id=' + course.id"`，且遵循"不批量删旧入口"原则

### 改动文件汇总

| 文件 | 操作 |
|---|---|
| `JwtUtil.java` | 修改 |
| `application.properties` | 修改 |
| `application-local.properties` | 修改 |
| `SysHuagao.java` | 修改 |
| `SysHuagaoController.java` | 修改 |
| `work/detail.vue` | 修改 |
| `MainLayout.vue` | 修改 |
| `src/utils/oss.js` | 新增 |
| 19 个旧视图文件 | 修改（OSS URL 替换） |

---

## 后续阶段

| 阶段 | 内容 |
|---|---|
| 阶段 6B | 产品策略决策：主站登录规则、旧前台入口处置 |
| 阶段 7+ | 双身份闭环、旧后台独立入口、生产部署 |
