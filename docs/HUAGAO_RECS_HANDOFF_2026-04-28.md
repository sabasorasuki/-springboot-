# 全站个性化推荐 Handoff

更新时间：`2026-05-07`

## 当前目标

推荐系统已从 `sys_huagao` 单域闭环升级为：

- 全站共享兴趣画像
- `huagao`、`zuopin`、`project`、`artist` 分域独立排序
- 离线预计算推荐结果落库
- 前端统一推荐上下文和行为上报

旧 `rec_huagao_*` 暂留，作为 huagao 历史日志回填来源和调试链路。

## 已完成

- 新增通用表：
  - `rec_request_log`
  - `rec_impression_log`
  - `rec_action_log`
  - `rec_actor_profile`
  - `rec_model_version`
  - `rec_user_recommendation`
- 新增接口：
  - `GET /rec/recommendations?domain=huagao|zuopin|project|artist&pageNo=1&pageSize=12&scene=home`
  - `POST /recTrack/action`
- 新增训练目录：
  - `recsys/site_recs`
- 首页已改成多推荐区块：
  - 推荐橱窗
  - 推荐作品
  - 推荐企划
  - 推荐画师
- `/showcase`、`/works`、`/projects`、`/artists` 默认接入对应 domain 推荐。
- `/work/:id`、`/post/:id`、`/project/:id`、画师关注行为写入统一行为日志。

## 行为和标签口径

统一行为权重：

- `impression = 0`
- `click_detail/detail_view = 1`
- `favorite/like/comment/follow = 2`
- `add_to_cart/apply_project = 3`
- `create_order = 4`

共享画像使用：

- 内容域偏好
- 分类 / 风格 / 标签偏好
- 作者 / 画师偏好
- 物品互动偏好

## 当前训练结果

最近训练命令：

```powershell
python recsys/site_recs/run_pipeline.py --domains huagao,zuopin,project,artist --source real --top-k 50
```

当前 active 模型：

- `huagao`：`site_real_20260507175702_huagao`，`xgboost_ltr`，样本 `623`，正样本 `16`
- `zuopin`：`site_real_20260507175702_zuopin`，`baseline`，正样本 `4`
- `project`：`site_real_20260507175702_project`，`baseline`
- `artist`：`site_real_20260507175702_artist`，`baseline`，正样本 `1`

说明：作品、企划、画师域当前真实数据量很小，因此按计划使用 baseline，并在指标中标记 `fallbackRanker=true`。

## 关键文件

后端：

- `artistsion-admin/src/main/java/com/lf/controller/RecRecommendationController.java`
- `artistsion-admin/src/main/java/com/lf/controller/RecTrackController.java`
- `artistsion-admin/src/main/java/com/lf/service/impl/RecRecommendationServiceImpl.java`
- `artistsion-admin/src/main/java/com/lf/service/impl/RecTrackServiceImpl.java`
- `artistsion-admin/src/main/resources/mapper/RecRecommendationMapper.xml`
- `artistsion-admin/src/main/resources/mapper/RecTrackMapper.xml`

前端：

- `artistsion-web/src/api/rec.js`
- `artistsion-web/src/views/home/index.vue`
- `artistsion-web/src/views/showcase/index.vue`
- `artistsion-web/src/views/works/index.vue`
- `artistsion-web/src/views/projects/index.vue`
- `artistsion-web/src/views/artists/index.vue`
- `artistsion-web/src/views/work/detail.vue`
- `artistsion-web/src/views/posts/detail.vue`
- `artistsion-web/src/views/projects/detail.vue`
- `artistsion-web/src/views/center/profile.vue`

训练：

- `recsys/site_recs/run_pipeline.py`
- `recsys/site_recs/requirements.txt`
- `recsys/site_recs/README.md`

SQL：

- `artistsion-admin/sql/2026-05-07-site-recs-schema.sql`

## 下一步

1. 补更多真实 `sys_zuopin`、`sys_project`、画师数据，避免作品/企划/画师域长期只有 baseline。
2. 给购物车结算链路补推荐归因字段，使加购后的最终下单也能稳定回流同一个 `requestId`。
3. 增加 admin 推荐健康页，展示 active 模型、样本量、fallback 状态、各域推荐覆盖率。
4. 样本达标后，把 `zuopin`、`project`、`artist` 域逐步切到独立 LTR。
