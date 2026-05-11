# 全站个性化推荐交接

更新时间：`2026-05-08`

## 当前结论

推荐系统已经从 `sys_huagao` 单域升级为“全站共享兴趣画像 + 分域独立排序”。

- `huagao`：橱窗画稿，当前 active 模型使用 XGBoost LTR。
- `zuopin`：作品 / 社区内容，当前样本少，使用 baseline 排序。
- `project`：企划 / 委托需求，当前样本少，使用 baseline 排序。
- `artist`：画师，当前样本少，使用 baseline 排序。

旧 `rec_huagao_*` 表和代码暂留，作为历史日志回填、调试和回滚来源；前台新业务入口优先走统一 `rec_*` 链路。

## 已落地

- 通用推荐表：
  - `rec_request_log`
  - `rec_impression_log`
  - `rec_action_log`
  - `rec_actor_profile`
  - `rec_model_version`
  - `rec_user_recommendation`
- 统一接口：
  - `GET /rec/recommendations?domain=huagao|zuopin|project|artist&pageNo=1&pageSize=12&scene=home`
  - `POST /recTrack/action`
  - `GET /rec/debug/health`
- 训练入口：
  - `recsys/site_recs/run_pipeline.py`
- 订单归因：
  - `sys_order` 已新增 `rec_request_id`、`rec_position`、`rec_scene`、`rec_source`、`rec_model_version`
  - 详情页加入购物车 / 立即下单会携带推荐上下文
  - 个人中心购物车“提交订单”会把购物车状态改为待付款，并由后端写入 `create_order` 行为
- 内容标签：
  - 橱窗自由标签继续写入 `sys_tag` + `sys_huagao_tag`
  - 作品发布已补自由标签输入，写入 `sys_tag` + `sys_zuopin_tag`
  - 全站训练的 `zuopin` 物品特征会读取作品分类和自由标签
- 前端入口：
  - 首页四个推荐区块：橱窗、作品、企划、画师
  - `/showcase`、`/works`、`/projects`、`/artists` 默认接入对应 domain 推荐
  - `/work/:id`、`/post/:id`、`/project/:id`、画师关注行为写入统一行为日志
  - 后台 `/recs/health` 推荐健康页展示 active 模型、覆盖和日志回流

## 行为口径

统一行为权重：

- `impression = 0`
- `click_detail/detail_view = 1`
- `favorite/like/comment/follow = 2`
- `add_to_cart/apply_project = 3`
- `create_order = 4`

共享画像主要使用：

- 内容域偏好
- 分类 / 风格 / 标签偏好
- 作者 / 画师偏好
- 物品互动偏好

## 最近训练

命令：

```powershell
python recsys/site_recs/run_pipeline.py --domains huagao,zuopin,project,artist --source real --top-k 50
```

最近一次 active 模型：

| domain | model version | ranker | 样本 | 正样本 |
| --- | --- | --- | ---: | ---: |
| `huagao` | `site_real_20260508204415_huagao` | `xgboost_ltr` | 743 | 16 |
| `zuopin` | `site_real_20260508204415_zuopin` | `baseline` | 0 | 4 |
| `project` | `site_real_20260508204415_project` | `baseline` | 0 | 0 |
| `artist` | `site_real_20260508204415_artist` | `baseline` | 0 | 1 |

说明：作品、企划、画师域当前真实数据太少，`metrics_json.fallbackRanker=true` 是预期状态，不代表接口失败。
`huagao` 本次指标：`ndcg@5=0.100431`、`ndcg@10=0.087257`、`map@10=0.3`。

## 验证记录

已验证：

- `mvn -q -DskipTests compile`
- `npm run build:prod`
- `python -m py_compile recsys/site_recs/run_pipeline.py`
- 匿名四个 domain 推荐接口均返回可渲染 rows
- `123123 / 123123` 登录态 huagao 推荐返回 `fallback=false`
- `/recTrack/action` 行为上报成功
- `/rec/debug/health` 返回 4 个 active domain 模型和日志统计
- 购物车推荐归因烟测通过：测试订单从 `购物车` 更新为 `待付款` 后写出 `create_order`，且带回同一个 `requestId`
- `2026-05-08 20:44` 真实数据全站训练完成，active 模型为 `site_real_20260508204415_*`
- 测试产生的 `api_smoke_*` / `codex_smoke_*` 日志已清理

## 关键文件

后端：

- `artistsion-admin/src/main/java/com/lf/controller/RecRecommendationController.java`
- `artistsion-admin/src/main/java/com/lf/controller/RecTrackController.java`
- `artistsion-admin/src/main/java/com/lf/controller/SysOrderController.java`
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

训练与 SQL：

- `recsys/site_recs/run_pipeline.py`
- `recsys/site_recs/requirements.txt`
- `artistsion-admin/sql/2026-05-07-site-recs-schema.sql`
- `artistsion-admin/sql/2026-05-08-order-rec-attribution.sql`
- `artistsion-admin/sql/2026-05-08-zuopin-free-tags.sql`

## 下一步

1. 补真实作品、企划、画师数据，让非 huagao 域脱离长期 baseline。
2. 把支付成功、订单评价、企划应征、评论等更深层行为继续统一到 `POST /recTrack/action`。
3. 扩展 admin 推荐健康页，增加训练触发、阈值告警和最近一次训练日志查看。
4. 样本达标后，把 `zuopin`、`project`、`artist` 逐步切到独立 LTR。
