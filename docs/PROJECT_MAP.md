# 项目静态地图

## 产品定位

Artistsion 是一个画师约稿 / 作品交易 / 社区内容平台。当前仍是单仓库、单前端、单后端结构：

- 一个 Vue 2 前端同时承载主站、个人中心和 admin 控制台
- 一个 Spring Boot 后端同时提供公开内容、用户自助、平台管理、支付、推荐、AI 能力

## 仓库结构

- `artistsion-web`：前端应用
- `artistsion-admin`：后端应用
- `artistsion.sql`：主数据库导出
- `artistsion-admin/sql`：增量 SQL 补丁
- `docs/PROJECT_MAP.md`：静态结构
- `docs/SESSION_HANDOFF.md`：当前动态状态

## 前端关键路径

- `artistsion-web/src/router/index.js`：静态路由与两套 layout 入口
- `artistsion-web/src/permission.js`：登录守卫、动态菜单注入、`/admin` 兼容映射
- `artistsion-web/src/utils/adminConsole.js`：admin 菜单白名单、admin-only 路径、标题覆写
- `artistsion-web/src/store/modules/user.js`：token、角色、`menuList`、身份切换状态
- `artistsion-web/src/views/home`、`artists`、`projects`、`work`、`posts`、`center`：主站与个人中心
- `artistsion-web/src/views/dashboard`、`sys`、`report`、`shangp/shangpsh`、`order/orderadglqb`、`fenxiang/fenxiangad`、`liuyan/liuyan`、`fenlei`、`tongji`、`rizhi`、`lunbo`：admin 核心页
- `artistsion-web/src/components/ReportDialog`：前台举报统一组件

## 后端关键路径

- `artistsion-admin/src/main/java/com/lf/controller/AuthController.java`：新认证
- `artistsion-admin/src/main/java/com/lf/controller/UserController.java`：旧登录 / 旧 `user/info` 兼容与公开画师接口
- `artistsion-admin/src/main/java/com/lf/controller/AdminDashboardController.java`：admin 看板汇总
- `artistsion-admin/src/main/java/com/lf/controller/SysReportController.java`：举报闭环
- `artistsion-admin/src/main/java/com/lf/service/impl/MenuServiceImpl.java`：角色菜单树
- `artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java`：白名单与跨域
- `artistsion-admin/src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`：JWT 校验
- `artistsion-admin/src/main/resources/mapper`：SQL 映射

## 核心数据表与业务模块映射

| 模块 | 关键表 | 前端 | 后端 |
| --- | --- | --- | --- |
| 用户与权限 | `x_user`、`x_role`、`x_menu`、`x_user_role`、`x_role_menu` | `auth`、`sys`、`store/modules/user.js`、`permission.js` | `AuthController`、`UserController`、`MenuServiceImpl` |
| 作品 / 委托 | `sys_huagao` | `work`、`shangp`、`home` | `SysHuagaoController` |
| 社区内容 | `sys_zuopin` | `posts`、`fenxiang`、`home` | `SysZuopinController` |
| 订单与支付 | `sys_order` | `center/orders`、`order/*` | `SysOrderController`、`AliPayController` |
| 反馈 / 工单 | `sys_liuyan`、`sys_liuyans` | `liuyan/*` | `SysLiuyanController`、`SysLiuyansController` |
| 举报审核 | `sys_report` | `report`、`ReportDialog` | `SysReportController` |
| 分类 / 运营 / 日志 | `sys_fenlei`、`sys_lunbo`、`sys_rizhi` | `fenlei`、`lunbo`、`tongji`、`rizhi` | 对应 controller |
| 推荐 | `user_article_operation` | `home`、`src/api/tuijian.js` | `UserArticleOperationController` |
| AI 助手 | 无专用业务主表 | `ai/ai.vue` | `AliAiController` |

## 当前前台与 admin 的关系

- 主站统一从 `/auth` 登录后进入 `/home`
- admin 统一入口是 `/admin`，内部实际落到 `/dashboard`
- admin 当前没有改后端菜单表结构，而是在前端基于 `/user/info` -> `menuList` 做白名单收敛
- 普通用户 / 画师自助流仍与 admin 共存于同一前端应用，只是 admin 主菜单不再暴露这些页
- 因此凡是改认证、菜单、角色、admin 边界的任务，都必须同时检查前端路由、守卫、菜单数据和后端权限链路
