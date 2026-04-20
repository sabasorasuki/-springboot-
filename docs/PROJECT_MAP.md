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

## 当前前台信息架构（已扩展）
### 主站一级频道
- `/home`：首页
- `/artists`：画师广场
- `/projects`：企划 / 需求广场
- `/works`：作品频道（纯展示）
- `/showcase`：橱窗频道（有价格的画稿展示）

### 发布入口
- `/publish/work`：投稿页（当前承载作品 / 橱窗发布）
- `/publish/project`：发布企划 / 需求页

### 个人中心
- `/center/profile`：当前个人中心首页
- `/center/orders`：订单
- `/center/submissions`：投稿管理
- `/center/favorites`：收藏
- `/center/cart`：购物车
- `/center/follows`：关注 / 好友 / 粉丝

### 详情页
- `/work/:id`：作品 / 橱窗详情页
- `/project/:id`：企划详情页
- `/post/:id`：帖子详情页

### 仍保留的兼容 / 旧语义路径
- `/artist/:id`：当前仍是“他人主页”入口，尚未并入统一个人中心
- `/userinfo`
- `/fabusp`
- `/myfenxiang`
- `/liaotian`

> 注意：当前“自己主页”与“他人主页”仍未完全统一。下一步目标是把 `profile` 收口成统一的个人中心承载页，并让 `/artist/:id` 变为兼容跳转壳。

## 前端关键路径
- `artistsion-web/src/router/index.js`：静态路由与两套 layout 入口
- `artistsion-web/src/permission.js`：登录守卫、动态菜单注入、`/admin` 兼容映射
- `artistsion-web/src/utils/adminConsole.js`：admin 菜单白名单、admin-only 路径、标题覆写
- `artistsion-web/src/store/modules/user.js`：token、角色、`menuList`、前台显示模式状态
- `artistsion-web/src/layout/MainLayout.vue`：主站导航、头像区、前台快捷入口
- `artistsion-web/src/views/home`、`artists`、`projects`、`works`、`showcase`、`work`、`posts`、`center`、`publish`：主站、发布页、个人中心
- `artistsion-web/src/views/dashboard`、`sys`、`report`、`shangp/shangpsh`、`order/orderadglqb`、`fenxiang/fenxiangad`、`liuyan/liuyan`、`fenlei`、`tongji`、`rizhi`、`lunbo`：admin 核心页
- `artistsion-web/src/components/ReportDialog`：前台举报统一组件

## 后端关键路径
- `artistsion-admin/src/main/java/com/lf/controller/AuthController.java`：新认证
- `artistsion-admin/src/main/java/com/lf/controller/UserController.java`：旧登录 / 旧 `user/info` 兼容与公开画师接口
- `artistsion-admin/src/main/java/com/lf/controller/AdminDashboardController.java`：admin 看板汇总
- `artistsion-admin/src/main/java/com/lf/controller/SysReportController.java`：举报闭环
- `artistsion-admin/src/main/java/com/lf/controller/SysFollowController.java`：关注 / 粉丝 / 好友接口
- `artistsion-admin/src/main/java/com/lf/service/impl/MenuServiceImpl.java`：角色菜单树
- `artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java`：白名单与跨域
- `artistsion-admin/src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`：JWT 校验
- `artistsion-admin/src/main/resources/mapper`：SQL 映射

## 核心数据表与业务模块映射
| 模块 | 关键表 | 前端 | 后端 |
| --- | --- | --- | --- |
| 用户与权限 | `x_user`、`x_role`、`x_menu`、`x_user_role`、`x_role_menu` | `auth`、`sys`、`store/modules/user.js`、`permission.js` | `AuthController`、`UserController`、`MenuServiceImpl` |
| 作品 / 委托 / 橱窗 | `sys_huagao` | `work`、`showcase`、`publish/work`、`center/cart`、`home` | `SysHuagaoController` |
| 纯展示作品 / 社区内容 | `sys_zuopin` | `works`、`posts`、`fenxiang`、`publish/work`、`home` | `SysZuopinController` |
| 企划 / 需求 | 现有企划相关表与接口链路 | `projects`、`publish/project`、`center/submissions`、`center/favorites` | 对应 project controller / service |
| 订单与支付 | `sys_order` | `center/orders`、`order/*`、`center/cart` | `SysOrderController`、`AliPayController` |
| 关注关系 | `sys_follow` | `center/follows`、`api/follow.js`、`center/profile` | `SysFollowController` |
| 举报审核 | `sys_report` | `report`、`ReportDialog` | `SysReportController` |
| 反馈 / 工单 | `sys_liuyan`、`sys_liuyans` | `liuyan/*` | `SysLiuyanController`、`SysLiuyansController` |
| 分类 / 运营 / 日志 | `sys_fenlei`、`sys_lunbo`、`sys_rizhi` | `fenlei`、`lunbo`、`tongji`、`rizhi` | 对应 controller |
| 推荐 | `user_article_operation` | `home`、`src/api/tuijian.js` | `UserArticleOperationController` |
| AI 助手 | 无专用业务主表 | `ai/ai.vue` | `AliAiController` |

## 当前前台与 admin 的关系
- 主站统一从 `/auth` 登录后进入 `/home`
- admin 统一入口是 `/admin`，内部实际落到 `/dashboard`
- admin 当前没有改后端菜单表结构，而是在前端基于 `/user/info` -> `menuList` 做白名单收敛
- 普通用户 / 画师自助流仍与 admin 共存于同一前端应用，只是 admin 主菜单不再暴露这些页
- 当前前台已引入“显示模式（artist / client）”概念，但它只是 UI 过滤器，不是后端真实权限切换
- 因此凡是改认证、菜单、角色、admin 边界的任务，都必须同时检查前端路由、守卫、菜单数据和后端权限链路

## 当前最容易误解的产品语义
- “作品” = 纯展示内容，使用 `sys_zuopin` 语义
- “橱窗” = 有价格的画稿展示，优先沿用 `sys_huagao` 语义
- “企划” = 需求发布
- “购物车”当前是前台收口页，但是否为独立购物车模型仍需谨慎核对底层订单实现
- “画师 / 用户切换”当前只应该作为前台显示模式，不应扩展成真实权限系统

## 文档使用建议
静态地图只描述“当前仓库结构”和“模块归属”，不替代最新任务状态。  
具体本轮已做完什么、还有哪些缺口、下一步先修什么，请看 `docs/SESSION_HANDOFF.md`。
