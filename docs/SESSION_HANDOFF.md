# 会话交接摘要

## 当前所处阶段

阶段 1 ✅ → 阶段 2 ✅ → 阶段 3 ✅ → 阶段 4 ✅ → 阶段 5A ✅ → 阶段 5B ✅ → **阶段 6A ✅ 已完成** → **阶段 6B 兼容层清理已完成并落地** → **阶段 6C 旧后台入口隔离与存活清点已完成** → **阶段 6D 明确死代码清理已完成** → **阶段 6E 旧后台菜单表与遗留模块审计已完成** → **阶段 6F 断链修复与 test 僵尸菜单清理已完成** → **阶段 7A admin 控制台信息架构方案已定义** → **阶段 7B admin 菜单收敛与 P0 页面改造已完成**。

---

## 产品策略决策（阶段 6B 确认）

- **主站继续要求登录**：`/home`、`/artists`、`/projects`、`/work/:id`、`/artist/:id`、`/project/:id` 不开放匿名访问，`permission.js` 白名单现仅保留 `/auth`
- **旧前台入口软下线**：管理后台 `Navbar.vue` "前台"链接和注销跳转已从 `/mas` 改为 `/home`
- **第一轮旧前台兼容层清理已完成**：`/mas`、`/theList`、`/community`、`/detail`、`/details` 路由以及 `views/about/`、`AboutView.vue` 已删除
- **第二轮旧认证页清理已完成**：旧 `/login`、`/register` 路由与 `views/login/index.vue`、`views/login/register.vue` 已删除，前端仅保留统一认证页 `/auth`
- **第三轮后台入口隔离已完成**：新增旧后台入口 `/admin`，内部仍复用原有 `/dashboard`、动态菜单、`/user/info`、`x_menu`、`menuList` 链路
- **后台兼容策略**：`/#/admin` 作为后台统一入口；`/#/admin/<旧后台路径>` 会在前端守卫中映射回原始后台路由，旧 `/dashboard`、`/sys/*`、`/order/*`、`/shangp/*` 等地址继续保留兼容

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

### 后台入口隔离（6C）

- 新增 `/admin` 静态入口，访问后重定向到旧后台首页 `/dashboard`
- 新增 `/admin/<legacy-path>` 兼容映射，例如 `/admin/order/ordergl` → `/order/ordergl`
- `x_menu` 中的 `component`、`path`、`redirect` 数据不做修改，动态菜单继续按旧路径注入
- `/user/info`、`MenuService.getMenuListByUserId(...)`、前端 `require(@/views/${menu.component}.vue)` 链路保持不变
- 后台壳内的面包屑首页入口改为 `/admin`
- 旧后台壳内的注销后默认回到 `/auth?redirect=/admin`

### 遗留页面清理与菜单审计（6D / 6E）

- 第四轮已删除模板残留：
  - `views/table/index.vue`
  - `views/tree/index.vue`
  - `views/form/index.vue`
  - `views/nested/**/*`
- 第五轮已确认真实存活模块：
  - `views/fenxiang/*`、`views/fenlei/*`、`views/shoucang/*`、`views/liuyan/*`、`views/tongji/*`、`views/rizhi/*`、`views/lunbo/*`、`views/ai/*`
  - 依据：`x_menu` 有记录、`x_role_menu` 有角色分配、页面文件存在，且由 `/user/info` + `menuList` + 动态 `require()` 链路可正常拉起
- 第五轮已确认僵尸菜单：
  - `views/test/test1.vue`、`views/test/test2.vue`、`views/test/test3.vue`、`views/test/test4.vue`
  - 依据：`x_menu.component` 仍保留 `test/test1-4`，但当前 `x_role_menu` 未给任何角色分配测试模块
- 第五轮重点审计目录中暂未发现“孤儿页面”
- 新发现的高优先级风险：
  - `views/shoucang/shoucang.vue` 内部仍跳转 `name: 'myfatie'`，仓库中未发现对应路由，需单独修复

### 断链修复与 test 清理（6F）

- 收藏页断链已修复：
  - `views/shoucang/shoucang.vue` 不再跳转不存在的 `myfatie`
  - 修复依据：收藏记录的 `wzids` 来源于 `work.id`，因此真实目标应为 `/work/:id`（`WorkDetail`）
  - 当前收藏列表已补充“查看作品”入口，直接进入真实作品详情页
- test 僵尸菜单已清理：
  - 已删除 `artistsion.sql` 中 `x_menu` 的 test 菜单记录：`menu_id=4/5/6/7/12`
  - 已删除 `views/test/test1.vue`、`views/test/test2.vue`、`views/test/test3.vue`、`views/test/test4.vue`
  - 已复核：`x_role_menu` 原本就没有 test 菜单角色分配，前端源码也没有静态路由或 `import/require` 残留

### admin 控制台重构方向（7A）

- 已确认未来 `/admin` 的目标不是继续承载混合型旧页面，而是收敛为“管理员控制台”
- 当前确认保留的管理能力：
  - `views/sys/*` 用户/角色/菜单权限
  - `views/fenlei/fenlei.vue` 分类管理
  - `views/shangp/shangpsh.vue` 作品审核
  - `views/order/orderadglqb.vue` 交易订单总览
  - `views/fenxiang/fenxiangad.vue` 社区内容管理
  - `views/liuyan/liuyan.vue` 反馈工单
  - `views/tongji/tongji.vue`、`views/rizhi/rizhi.vue`、`views/lunbo/lunbo.vue`
- 当前确认应迁出 admin 的用户自助页：
  - `views/userinfo/*`
  - `views/order/gouwuche.vue`、`views/order/ordergl.vue`、`views/order/orderadgl.vue`
  - `views/shangp/shangp.vue`、`views/shangp/spsxj.vue`
  - `views/fenxiang/fenxiang.vue`
  - `views/shoucang/shoucang.vue`
  - `views/liuyan/liuyanyh.vue`
  - `views/ai/ai.vue`
- 下一轮建议优先做：
  - 阶段 1 信息架构收敛：先明确 admin 菜单只保留管理能力
  - 阶段 2 菜单与路由收敛：减少侧边栏中的用户自助页，但暂不破坏 `/user/info` / `menuList` / `x_menu` 链路

### admin 控制台第一阶段代码改造（7B）

- admin 菜单收敛已真正接入运行时：
  - `permission.js` 在 admin 角色下会先 clone `/user/info` 返回的 `menuList`，再做前端侧过滤与标题/redirect 覆写
  - 收敛目标是“先让 admin 看起来像 admin”，不改 `/user/info` 返回结构，不改 `MenuService`，不改 `/admin` 兼容入口
- 本轮已从 admin 主菜单收敛掉的自助页：
  - `order/gouwuche`
  - `order/ordergl`
  - `order/orderadgl`
  - `shangp/shangp`
  - `shangp/spsxj`
  - `fenxiang/fenxiang`
  - `shoucang/shoucang`
  - `liuyan/liuyanyh`
  - `ai/ai`
- 本轮兼容保留但不再承担首页/主菜单职责的页面：
  - `views/userinfo/index.vue`：改为隐藏的“管理员账号设置”页，从 `Navbar` 头像菜单进入
  - `views/userinfo/fabusp.vue`、`views/userinfo/myfenxiang.vue`、`views/userinfo/liaotian.vue`：仍为隐藏兼容路由，保留给旧流转使用
- dashboard 已改造成真正的管理看板：
  - 聚合用户、作品、订单、反馈、分类、轮播、日志数据
  - 当前展示 7 张统计卡片 + 待审核作品 / 最近订单 / 最近操作日志三块概览面板
  - 数据全部来自现有列表接口
  - 待处理反馈数因后端缺少专用聚合接口，当前按已拉取反馈列表估算
- 四个核心页面已完成管理员语义改造：
  - `shangpsh.vue`：作品审核
  - `orderadglqb.vue`：交易订单总览
  - `fenxiangad.vue`：社区内容管理
  - `liuyan.vue`：反馈工单
  - 本轮主要修改标题、说明、按钮、表头、提示文案，保留原有主逻辑
- 顺手修复：
  - `api/order.js` 恢复 `/sysOrder/list` 的真实搜索参数 `name`，订单页搜索重新可用
- 构建验证：
  - 前端 `npm run build:prod` ✅ 通过
  - 没有新增编译错误
  - 仍仅有既有 webpack 包体积 warning 与 `Browserslist` 提示

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
| 后台入口与新前台混杂 | 旧后台此前主要依赖 `/dashboard` 和各类旧根路径直接访问 | ✅ 已完成入口隔离，统一入口改为 `/admin`，旧路径保留兼容 |
| 菜单驱动后台页面 | `/sys/*`、`/order/*`、`/shangp/*`、`/fenxiang/*` 等仍由 `/user/info` + `menuList` 驱动 | 保留，`fenxiang/fenlei/shoucang/liuyan/tongji/rizhi/lunbo/ai` 已确认真实存活 |
| admin 信息架构 | 旧后台仍混有管理员页面与用户自助页 | ✅ 7A 已完成分类；下一轮开始收敛 admin 菜单 |
| 模板残留清理 | `views/table/*`、`views/tree/*`、`views/form/*`、`views/nested/*` | ✅ 已完成第四轮删除，源码内未见路由/菜单/跳转/import 引用 |
| ~~测试模块残留~~ | ~~`test/test1-4` 仍存在于 `x_menu.component` 记录中，但当前未分配给任何角色~~ | ✅ 6F 已删除 SQL 菜单残留与页面文件 |
| ~~收藏页内部跳转~~ | ~~`views/shoucang/shoucang.vue` 仍跳转到 `name: 'myfatie'`~~ | ✅ 6F 已修复为 `/work/:id` |
| ~~旧后台独立入口~~ | ~~当前旧后台通过动态菜单路由访问，无独立 `/admin` 入口~~ | ✅ 已完成，统一入口为 `/admin` |
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
