# Artistsion 项目地图

更新时间：`2026-04-28`

## 项目定位

Artistsion 是一个画师约稿、作品展示、橱窗交易和社区内容平台。当前仍是单仓库结构：

- `artistsion-web`：Vue 2 前端，承载主站、个人中心和 admin 控制台
- `artistsion-admin`：Spring Boot 后端，提供公开内容、用户、交易、推荐、AI、管理接口
- `recsys/huagao_ltr`：`sys_huagao` 离线 LTR 训练和推荐结果落库
- `artistsion.sql`：主库导出
- `artistsion-admin/sql`：增量 SQL 与推荐调试 SQL
- `docs`：只保留当前接手所需文档

## 当前首读顺序

1. `CLAUDE.md`
2. 对应子系统的 `CLAUDE.md`
3. `docs/README.md`
4. `docs/HUAGAO_RECS_HANDOFF_2026-04-28.md`
5. `docs/PROJECT_MAP.md`

## 前台信息架构

- `/home`：首页
- `/artists`：画师广场
- `/projects`：企划 / 需求广场
- `/works`：作品频道，偏展示
- `/showcase`：橱窗频道，承载 `sys_huagao`
- `/publish/work`：作品 / 橱窗发布
- `/publish/project`：企划发布
- `/center/profile`、`/center/orders`、`/center/submissions`、`/center/favorites`、`/center/cart`、`/center/follows`：个人中心
- `/work/:id`、`/project/:id`、`/post/:id`：详情页
- `/artist/:id`、`/userinfo`、`/fabusp`、`/myfenxiang`、`/liaotian`：兼容入口

## 前端关键文件

- `artistsion-web/src/router/index.js`：静态路由与 layout 入口
- `artistsion-web/src/permission.js`：登录守卫、动态菜单注入、admin 兼容映射
- `artistsion-web/src/utils/adminConsole.js`：admin 菜单白名单和标题覆写
- `artistsion-web/src/store/modules/user.js`：token、角色、菜单、前台显示模式
- `artistsion-web/src/layout/MainLayout.vue`：主站导航与用户入口
- `artistsion-web/src/views/showcase/index.vue`：橱窗列表和 huagao 曝光 / 点击采集
- `artistsion-web/src/views/home/index.vue`：首页推荐接入 `/recHuagao/recommendations`
- `artistsion-web/src/views/work/detail.vue`：作品 / 橱窗详情和详情行为采集
- `artistsion-web/src/api/recHuagao.js`：推荐拉取和行为上报
- `artistsion-web/src/utils/request.js`、`artistsion-web/src/utils/visitor.js`：请求头、访客和会话标识

## 后端关键文件

- `artistsion-admin/src/main/java/com/lf/controller/AuthController.java`：新认证
- `artistsion-admin/src/main/java/com/lf/controller/UserController.java`：旧登录 / 旧 `user/info` 兼容
- `artistsion-admin/src/main/java/com/lf/controller/SysHuagaoController.java`：橱窗列表、搜索与曝光采集入口
- `artistsion-admin/src/main/java/com/lf/controller/RecHuagaoRecommendationController.java`：首页推荐结果接口
- `artistsion-admin/src/main/java/com/lf/controller/RecHuagaoTrackController.java`：huagao 行为采集、调试、训练前检查
- `artistsion-admin/src/main/java/com/lf/service/impl/RecHuagaoRecommendationServiceImpl.java`：LTR 结果读取、actor 兜底、最新橱窗降级
- `artistsion-admin/src/main/java/com/lf/service/impl/RecHuagaoTrackServiceImpl.java`：huagao 采集与聚合核心逻辑
- `artistsion-admin/src/main/resources/mapper/SysHuagaoMapper.xml`：huagao 搜索 SQL
- `artistsion-admin/src/main/resources/mapper/RecHuagaoRecommendationMapper.xml`：离线推荐结果查询 SQL
- `artistsion-admin/src/main/resources/mapper/RecHuagaoDebugMapper.xml`：调试、重建校验、样本预览 / 导出 SQL
- `artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java`：白名单与跨域
- `artistsion-admin/src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`：JWT 校验

## 核心模块映射

| 模块 | 关键表 | 前端 | 后端 |
| --- | --- | --- | --- |
| 用户与权限 | `x_user`、`x_role`、`x_menu`、`x_user_role`、`x_role_menu` | `auth`、`sys`、`store/modules/user.js` | `AuthController`、`UserController`、`MenuServiceImpl` |
| 橱窗画稿 | `sys_huagao`、`sys_huagao_tag` | `showcase`、`work/detail`、`publish/work`、`center/cart` | `SysHuagaoController`、`SysHuagaoMapper.xml` |
| Huagao 推荐 | `rec_huagao_*` | `home`、`showcase`、`work/detail`、`api/recHuagao.js` | `RecHuagaoRecommendationController`、`RecHuagaoTrackController`、`RecHuagaoRecommendationServiceImpl`、`RecHuagaoTrackServiceImpl` |
| 展示作品 / 社区 | `sys_zuopin`、`sys_pinglun`、`sys_dianzan` | `works`、`posts`、`fenxiang` | `SysZuopinController` 等 |
| 企划 / 需求 | `sys_project` | `projects`、`publish/project` | `SysProjectController` |
| 订单与支付 | `sys_order` | `center/orders`、`center/cart`、`order/*` | `SysOrderController`、`AliPayController` |
| 收藏与关注 | `sys_shoucang`、`sys_follow` | `center/favorites`、`center/follows` | `SysShoucangController`、`SysFollowController` |
| 举报与反馈 | `sys_report`、`sys_liuyan`、`sys_liuyans` | `report`、`ReportDialog`、`liuyan/*` | `SysReportController`、`SysLiuyanController` |

## 当前注意事项

- 主站和 admin 仍在同一个前端应用里；admin 仍复用 `/user/info` 到 `menuList` 的旧动态菜单链路。
- “作品”主要对应 `sys_zuopin`，“橱窗”主要对应 `sys_huagao`，不要混用训练口径。
- 当前 huagao 推荐 v1 覆盖首页推荐、`/showcase`、`/work/:id` 的橱窗相关行为。
- 旧 Mahout / `user_article_operation` 已下线；推荐只保留 Huagao LTR 结果表和行为日志链路。
- 生产部署前必须替换 `application.properties` 里的数据库、JWT、支付、AI、邮件、OSS 等配置。

## 推荐训练入口

- 训练代码：`recsys/huagao_ltr/run_pipeline.py`
- 依赖文件：`recsys/huagao_ltr/requirements.txt`
- 推荐结果表 SQL：`artistsion-admin/sql/2026-04-28-rec-huagao-ltr-recommendation-schema.sql`
- 固定命令：`python recsys/huagao_ltr/run_pipeline.py --source synthetic --top-k 50`
