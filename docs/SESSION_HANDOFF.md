# 会话交接摘要

## 当前项目状态
- 项目现在是“统一认证页 + 主站 + 个人中心 + admin 控制台”并存的一体化仓库。
- 前端当前唯一认证入口是 `/auth`；主站默认登录后进入 `/home`。
- admin 已有统一入口 `/admin`，但运行时仍复用旧后台菜单链路：`/user/info` -> `menuList` -> 动态路由。
- 举报链路已经打通：前台可发起举报，admin 可查看、处理并定位原对象。
- 前台已完成一轮较大扩展：新增了作品、橱窗、投稿发布、企划发布、收藏、购物车、关注页等能力，但个人中心与入口逻辑仍有一轮 Hotfix 待收口。

## 已完成的大项
- 主站一级频道已扩展为：`/home`、`/artists`、`/projects`、`/works`、`/showcase`。
- 发布能力已拆出：
  - `/publish/work`
  - `/publish/project`
- 个人中心已新增：
  - `/center/submissions`
  - `/center/favorites`
  - `/center/cart`
  - `/center/follows`
  - `/center/orders`
- 收藏页已恢复 `作品 / 橱窗 / 企划` 三个分类。
- 关注系统已打通：
  - `/sysFollow/follow`
  - `/sysFollow/unfollow`
  - `/sysFollow/following`
  - `/sysFollow/followers`
  - `/sysFollow/friends`
  - `/sysFollow/check`
  - `/sysFollow/count`
- 橱窗发布已改为直接上架，不再走审核流。
- 头像下拉中的真实 `switchRole` 入口已被移除，前台保留的是显示模式层逻辑，而非真实角色切换。
- admin 菜单已收敛为控制台语义，`dashboard` 已改造成真实管理看板。
- `GET /adminDashboard/summary` 已落地，admin 首页改为聚合数据接口驱动。
- 举报中心已落地：`sys_report`、`/sysReport/*`、`src/views/report/index.vue`、`src/components/ReportDialog` 都已接通。
- 用户名唯一性修复、OSS URL 集中化、作品详情收藏/购物车接线等关键补洞已完成。

## 当前 admin 已完成到什么程度
- 已具备控制台首页、用户与权限、作品审核、订单总览、社区内容管理、反馈工单、举报审核、分类、统计、日志、轮播运营。
- `src/utils/adminConsole.js` 已成为 admin 菜单白名单、标题覆写、admin-only 路径判断的单一事实源。
- 非 admin 身份访问 `/admin`、`/dashboard`、`/sys/*`、`/report/*` 等会被前端守卫拦回 `/home`。
- `views/userinfo/index.vue` 已降级为隐藏的“管理员账号设置”页，不再承担 dashboard 职责。

## 当前仍保留的兼容层
- 后端仍保留旧 admin 运行时链路：`/user/login`、`/user/info?token=...`、`MenuServiceImpl.getMenuListByUserId()`、`x_menu`
- 前端仍保留 `/admin/` 到旧后台路径的兼容映射
- 仍保留隐藏兼容页：`/userinfo`、`/fabusp`、`/myfenxiang`、`/liaotian`
- 主站和 admin 仍在同一个前端应用里，尚未物理拆分
- `/artist/:id` 仍是“他人主页”路径，尚未并入统一个人中心

## 当前最关键的未收口问题
下面这些不是“可选优化”，而是当前前台产品规则里最优先的一轮 Hotfix：

### 1. 个人中心路由未统一
- 当前自己仍走 `/center/profile`
- 他人仍走 `/artist/:id`
- 目标应改为统一个人中心承载页，例如 `/center/profile/:id?`
- `/artist/:id` 最终应作为兼容跳转壳，而不是独立语义主页

### 2. 个人中心主页面结构仍不符合目标
当前 `center/profile` 还没有真正收口成“资料头部 + 统计信息 + 分类内容区”的完整结构。  
下一步应至少补齐：
- 头像
- 昵称
- 简介 / 地区
- 关注数
- 粉丝数
- 作品 / 投稿数
- 编辑个人资料入口（仅自己）
- 身份切换入口（仅自己）

### 3. 身份切换应该放在个人中心，不应放在头像下拉
产品最新要求是：
- 下拉只保留导航行为
- 显示模式切换应放到个人中心资料区
- 仍然只做 UI 过滤器，不做真实权限切换

### 4. 顶栏主按钮应改成“单按钮”，不再带下拉
最新产品要求：
- `artist` 模式：只显示“投稿”
- `client` 模式：只显示“发布需求”
- 投稿页内部再选择“作品 / 橱窗”
- 不要在顶栏用 dropdown 让用户二次选择

## 下一步最优先做什么
按优先级顺序：

### P0：Hotfix 统一个人中心与入口行为
1. 统一 `profile` 路由与“别人主页”承载页
2. 重做个人中心资料区和一级分类结构
3. 把显示模式切换从头像下拉移到个人中心
4. 把顶栏主按钮改成单按钮
5. 把投稿类型选择移动到投稿页内部

### P1：个人中心体验收口
- 自己视角：投稿 / 收藏 / 购物车 / 订单
- 他人视角：主页 / 作品 / 橱窗 / 企划（按公开内容显示）
- 统一作者跳转入口都落到同一套路由

### P2：数据与语义校准
- 检查收藏页当前基于 `price` / `fenlei` 的前端分类是否足够稳
- 检查购物车是否只是“待支付订单收口页”，避免文案和底层模型错位
- 检查关注页与 profile 统计区的联动是否覆盖自己 / 他人两种视角

## 当前风险 / 注意事项
- `/user/info` -> `menuList` -> `require(@/views/${menu.component}.vue)` 仍是最脆弱的高耦合链路，改菜单或路径时必须同时核对数据库 `x_menu` 与页面文件路径。
- 当前前端白名单只有 `/auth`，所以虽然部分后端内容接口支持匿名访问，主站路由层面仍然是登录优先；改访问策略时要同时看 `permission.js` 和 `MyWebConfig.java`。
- `application.properties` 仍含数据库、JWT、支付、AI、邮件、文件存储等敏感配置；生产部署前必须替换默认或测试密钥。
- 支付、上传、AI、订单相关改动要额外检查现有前端 API 包装、页面硬编码和后端返回结构，避免只改一层。
- 当前前台新增功能较多，但信息架构还在收口期；不要把“看起来可用”等同于“产品规则已完全收口”。

## 文档首读顺序
固定为：
1. `CLAUDE.md`
2. 对应子系统 `CLAUDE.md`
3. `docs/PROJECT_MAP.md`
4. `docs/SESSION_HANDOFF.md`
