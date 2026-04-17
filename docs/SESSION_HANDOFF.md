# 会话交接摘要

## 当前项目状态

- 项目现在是“统一认证页 + 主站 + 个人中心 + admin 控制台”并存的一体化仓库。
- 前端当前唯一认证入口是 `/auth`；主站默认登录后进入 `/home`。
- admin 已有统一入口 `/admin`，但运行时仍复用旧后台菜单链路：`/user/info` -> `menuList` -> 动态路由。
- 举报链路已经打通：前台可发起举报，admin 可查看、处理并定位原对象。

## 已完成的大项

- 主站核心路径已稳定：`/home`、`/artists`、`/projects`、详情页、个人中心、订单页都已落地。
- 新认证页 `/auth` 已替代旧登录注册页面；注册支持邮箱验证码与初始身份选择。
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
- 前端仍保留 `/admin/<legacy-path>` 到旧后台路径的兼容映射
- 仍保留隐藏兼容页：`/userinfo`、`/fabusp`、`/myfenxiang`、`/liaotian`
- 主站和 admin 仍在同一个前端应用里，尚未物理拆分

## 下一步最优先做什么

- 优先继续收口兼容层，把个人自助流从旧 admin 路由语义里逐步迁到更明确的主站 / 个人中心路径，减少对隐藏兼容页的依赖。
- 在不破坏现有菜单链路的前提下，逐步把 admin 从 `/user/info` + `menuList` 的旧运行时依赖中解耦出来。
- 如果要继续扩平台能力，优先补“平台审核 / 控制台”方向模块，而不是再往旧混合后台塞用户自助页。

## 当前风险 / 注意事项

- `/user/info` -> `menuList` -> `require(@/views/${menu.component}.vue)` 仍是最脆弱的高耦合链路，改菜单或路径时必须同时核对数据库 `x_menu` 与页面文件路径。
- 当前前端白名单只有 `/auth`，所以虽然部分后端内容接口支持匿名访问，主站路由层面仍然是登录优先；改访问策略时要同时看 `permission.js` 和 `MyWebConfig.java`。
- `application.properties` 仍含数据库、JWT、支付、AI、邮件、文件存储等敏感配置；生产部署前必须替换默认或测试密钥。
- 支付、上传、AI、订单相关改动要额外检查现有前端 API 包装、页面硬编码和后端返回结构，避免只改一层。
- 文档首读路径现在应固定为：`CLAUDE.md` -> 子系统 `CLAUDE.md` -> `docs/PROJECT_MAP.md` -> `docs/SESSION_HANDOFF.md`
