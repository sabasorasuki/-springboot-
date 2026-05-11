# Artistsion 项目地图

更新时间：`2026-05-08`

## 项目定位

Artistsion 是一个画师约稿、作品展示、橱窗交易和社区内容平台。当前仍是单仓库结构：

- `artistsion-web`：Vue 2 前端，承载主站、个人中心和 admin 控制台
- `artistsion-admin`：Spring Boot 后端，提供公开内容、用户、交易、推荐、AI、管理接口
- `recsys/site_recs`：全站推荐训练，负责共享画像和分域排序
- `recsys/huagao_ltr`：旧 huagao 单域 LTR 训练，保留作历史参考
- `artistsion-admin/sql`：增量 SQL 与推荐表结构
- `docs`：当前接手文档，先读 `README.md` 和 `SITE_RECS_HANDOFF_2026-05-07.md`

## 前台信息架构

- `/home`：首页，多域推荐区块
- `/artists`：画师广场
- `/projects`：企划 / 需求广场
- `/works`：作品频道
- `/showcase`：橱窗频道，承载 `sys_huagao`
- `/publish/work`：作品 / 橱窗发布
- `/publish/project`：企划发布
- `/center/profile`、`/center/orders`、`/center/submissions`、`/center/favorites`、`/center/cart`、`/center/follows`：个人中心
- `/work/:id`、`/project/:id`、`/post/:id`：详情页

## 推荐系统

- 统一推荐接口：`GET /rec/recommendations?domain=huagao|zuopin|project|artist`
- 统一行为接口：`POST /recTrack/action`
- 推荐健康接口：`GET /rec/debug/health`
- 统一前端 API：`artistsion-web/src/api/rec.js`
- 首页、橱窗、作品、企划、画师、详情页已接入新推荐上下文。
- 橱窗订单已补推荐归因字段，购物车提交订单会回写 `create_order` 行为。
- 后台推荐健康页：`/recs/health`
- `artistsion-web/src/api/recHuagao.js` 仅保留兼容包装，内部转到新接口。
- 推荐交接文档：`docs/SITE_RECS_HANDOFF_2026-05-07.md`

## 后端关键文件

- `RecRecommendationController`、`RecTrackController`：全站推荐公开接口
- `RecRecommendationServiceImpl`、`RecTrackServiceImpl`：推荐读取、actor 兜底、曝光和行为采集
- `RecRecommendationMapper.xml`、`RecTrackMapper.xml`：通用推荐查询与写入
- `RecHuagao*`：旧 huagao 调试/兼容链路，暂留
- `MyWebConfig`：白名单与跨域

## 核心模块映射

| 模块 | 关键表 | 前端 | 后端 |
| --- | --- | --- | --- |
| 用户与权限 | `x_user`、`x_role`、`x_menu`、`x_user_role`、`x_role_menu` | `auth`、`sys`、`store/modules/user.js` | `AuthController`、`UserController`、`MenuServiceImpl` |
| 橱窗画稿 | `sys_huagao`、`sys_huagao_tag` | `showcase`、`work/detail`、`publish/work`、`center/cart` | `SysHuagaoController`、`SysHuagaoMapper.xml` |
| 作品 / 社区 | `sys_zuopin`、`sys_zuopin_tag`、`sys_pinglun`、`sys_dianzan` | `works`、`posts`、`fenxiang` | `SysZuopinController`、`SysPinglunController`、`SysDianzanController` |
| 企划 / 需求 | `sys_project`、`sys_project_application` | `projects`、`publish/project` | `SysProjectController` |
| 画师 | `x_user`、`x_user_role`、`sys_follow` | `artists`、`center/profile` | `UserController`、`SysFollowController` |
| 全站推荐 | `rec_*`、历史 `rec_huagao_*` | `home`、`showcase`、`works`、`projects`、`artists`、详情页 | `RecRecommendationController`、`RecTrackController` |
| 订单与支付 | `sys_order` | `center/orders`、`center/cart`、`order/*` | `SysOrderController`、`AliPayController` |
| 收藏与关注 | `sys_shoucang`、`sys_follow` | `center/favorites`、`center/follows` | `SysShoucangController`、`SysFollowController` |

## 推荐训练入口

- 训练代码：`recsys/site_recs/run_pipeline.py`
- 依赖文件：`recsys/site_recs/requirements.txt`
- 表结构 SQL：`artistsion-admin/sql/2026-05-07-site-recs-schema.sql`
- 订单归因 SQL：`artistsion-admin/sql/2026-05-08-order-rec-attribution.sql`
- 固定命令：`python recsys/site_recs/run_pipeline.py --domains huagao,zuopin,project,artist --source real --top-k 50`

## 本地验证命令

```powershell
cd artistsion-admin
mvn -q -DskipTests compile

cd ../artistsion-web
npm run build:prod

cd ..
python recsys/site_recs/run_pipeline.py --domains huagao,zuopin,project,artist --source real --top-k 50
```

## 注意事项

- `huagao` 当前可使用 XGBoost LTR；其他域样本量太少，当前按 baseline 排序并在 `metrics_json.fallbackRanker=true` 标记。
- `sys_huagao`、`sys_zuopin`、`sys_project` 和画师主页都已纳入推荐体系，但推荐效果仍取决于真实内容和真实行为积累。
- 作品和橱窗共用 `sys_tag` 自由标签池；作品关系在 `sys_zuopin_tag`，橱窗关系在 `sys_huagao_tag`。
- `sys_order` 的 `rec_*` 字段只负责推荐归因，不替代订单、支付或评价自身状态。
- 生产部署前必须替换数据库、JWT、支付、AI、邮件、OSS 等配置。
