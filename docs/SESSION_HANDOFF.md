# 会话交接摘要

## 当前所处阶段

阶段 1 ✅ → 阶段 2 ✅ → 阶段 3 ✅ → 阶段 4 ✅ → 阶段 5A ✅ → 阶段 5B ✅ → **阶段 6A ✅ 已完成** → **阶段 6B 兼容层清理已完成并落地**。

---

## 产品策略决策（阶段 6B 确认）

- **主站继续要求登录**：`/home`、`/artists`、`/projects`、`/work/:id`、`/artist/:id`、`/project/:id` 不开放匿名访问，`permission.js` 白名单现仅保留 `/auth`
- **旧前台入口软下线**：管理后台 `Navbar.vue` "前台"链接和注销跳转已从 `/mas` 改为 `/home`
- **第一轮旧前台兼容层清理已完成**：`/mas`、`/theList`、`/community`、`/detail`、`/details` 路由以及 `views/about/`、`AboutView.vue` 已删除
- **第二轮旧认证页清理已完成**：旧 `/login`、`/register` 路由与 `views/login/index.vue`、`views/login/register.vue` 已删除，前端仅保留统一认证页 `/auth`

---

## 阶段 6A 已完成内容

### JWT 密钥外部化

- `JwtUtil.java`：`JWT_KEY` 静态常量 → `@Value("${jwt.secret:123456}") private String jwtKey`
- `application.properties`：新增 `jwt.secret=${JWT_SECRET:123456}`
- `application-local.properties`：新增 `JWT_SECRET=123456`
- 安全技术债：默认回退值仍为 `123456`，测试环境可接受，生产部署前必须替换

### 作品详情页接线

- `SysHuagao.java`：新增 `@TableField(exist=false) artistName` 瞬态字段
- `SysHuagaoController.getById()`：通过 `userMapper` 填充画师名
- `work/detail.vue`：收藏按钮对接 `shoucangApi`（查重 + 添加/取消），购物车对接 `orderApi.add(status="购物车")`

### 3+ 角色切换修复

- `MainLayout.vue`：`promptRoleSelection()` 从纯文本 `$msgbox` 改为 `el-radio-group`

### OSS URL 集中化

- 新建 `src/utils/oss.js`（`ossDownloadUrl`/`ossUploadAction`/`ossUploadImgServer`/`ossBase`）
- 19 个视图文件共 28 处 `http://localhost:9999` 硬编码全部替换

### 旧入口软下线（6B）

- `Navbar.vue`："前台"链接 `/mas` → `/home`，注销跳转 `/mas` → `/home`

### 兼容层清理（6B 收尾）

- 第一轮：删除旧前台兼容路由 `/mas`、`/theList`、`/community`、`/detail`、`/details`
- 第一轮：删除 `artistsion-web/src/views/AboutView.vue` 与 `artistsion-web/src/views/about/`
- 第二轮：删除旧认证页路由 `/login`、`/register`
- 第二轮：删除 `artistsion-web/src/views/login/index.vue` 与 `artistsion-web/src/views/login/register.vue`
- 第二轮：`permission.js` 白名单收缩为仅保留 `/auth`
- 第二轮：旧后台个人资料页和 dashboard 中的注销后跳转统一改为 `/auth`

### 构建验证

- 后端 `mvnw compile` ✅ BUILD SUCCESS
- 前端 20 个改动文件 ✅ 零 lint 错误

### 后端

- `sys_project` 全栈 CRUD（Entity/Mapper/Service/Controller）
- `x_user` 表新增 `bio`/`style_tags` 列 → `User.java`/`ArtistVO.java` 同步
- `UserController` ARTIST_ROLE_ID 去硬编码 → `@PostConstruct` 查 `x_role` 表
- `SysOrderController` 新增 `GET /sysOrder/mine`（token 鉴权 + 角色双视角）
- 修复 `EmailService` 的 `javaMailSender` bean 名不匹配

### 前端

- `projects/index.vue` + `detail.vue`：mock → 真实 API
- `center/orders.vue`：空壳 → 双视角订单列表（买家/画师切换）
- `artists/index.vue`：bio 替代"暂无简介"
- `artists/detail.vue`：bio 段落 + styleTags 标签组
- `center/profile.vue`：新增 bio/styleTags 编辑表单
- `Navbar.vue`：个人信息链接 → `/center/profile`
- `api/project.js` 新增、`api/order.js` 新增 `getMine`

### 运行时验证

- 后端编译 ✅ + 启动 ✅（9999 端口）
- 前端构建 ✅
- SQL 迁移已执行 ✅

---

## 阶段 4 已完成内容

### 后端

- `MyWebConfig.java` 白名单补充 `/sysHuagao/tuijianlist`、`/user/artists`
- `UserController.java` 新增 `/user/artists` 端点：
  - 按画师角色(roleId=7)从 `x_user_role` 筛选用户
  - 分页查询，只返回安全字段（`ArtistVO`：id/username/name/avatar/status/workCount/recentCovers）
  - 批量聚合每个画师的上架+审核成功画稿数量和最近 3 张封面
- 新建 `vo/ArtistVO.java`

### 前端

- `/home`：轮播（`/sysLunbo/list`）+ 推荐/最新（推荐链路或 `getzuixin` 降级）+ 分类标签（`/sysFenlei/list`）+ 全部作品分页
- `/artists`：画师卡片（`/user/artists`）+ 分类筛选 + 缩略图画廊 + 分页
- `/projects`：6 条 mock 数据 + 分类筛选 + 按目标 `sys_project` schema 结构化
- 新建 `api/artist.js`

---

## 已知过渡态与技术债

| 项目 | 说明 | 状态 |
|---|---|---|
| ~~角色切换弹框~~ | ~~`$confirm` 仅适配双角色~~ | ✅ 6A 改为 `el-radio-group` |
| ~~画师简介/风格标签~~ | ~~User 表无 bio/style 字段~~ | ✅ 5B 已加 bio/style_tags |
| ~~企划后端~~ | ~~无 `sys_project` 表~~ | ✅ 5B 全栈 CRUD |
| ~~`ARTIST_ROLE_ID = 7` 硬编码~~ | ~~写死角色 ID~~ | ✅ 5B @PostConstruct 查库 |
| ~~订单前台查询~~ | ~~骨架页~~ | ✅ 5B 双视角订单列表 |
| ~~作品详情缺画师昵称~~ | ~~`shangjiaids` 未关联查画师名~~ | ✅ 6A artistName 瞬态字段 |
| ~~收藏/购物车按钮~~ | ~~按钮已渲染但未接线~~ | ✅ 6A 对接 shoucangApi/orderApi |
| ~~OSS URL 硬编码~~ | ~~28 处 `http://localhost:9999`~~ | ✅ 6A 集中化到 oss.js |
| ~~JWT 密钥硬编码~~ | ~~`"123456"` 写死在代码中~~ | ✅ 6A 外部化（回退值仍为 123456，生产需替换） |
| ~~旧前台路由残留~~ | ~~`/mas`、`/theList`、`/community`、`/detail`、`/details` 及 `views/about/`~~ | ✅ 已完成第一轮清理 |
| ~~旧认证页残留~~ | ~~`/login`、`/register` 路由与 `views/login/*`~~ | ✅ 已完成第二轮清理，仅保留 `/auth` |
| 旧后台独立入口 | 当前旧后台通过动态菜单路由访问，无独立 `/admin` 入口 | 待定 |
| 生产密钥轮换 | 支付宝/DashScope/JWT 密钥均为测试值 | 部署前处理 |
| 生产部署 | 构建产物验证、静态资源优化 | 待定 |

---

## 参考文档

- `CLAUDE.md` — 仓库总览
- `artistsion-web/CLAUDE.md` — 前端指引
- `artistsion-admin/CLAUDE.md` — 后端指引
- `docs/PROJECT_MAP.md` — 业务映射
- `docs/REFACTOR_PROGRESS.md` — 长期进度
- `docs/FRONTEND_STYLE_SPEC.md` — 前端样式规范
