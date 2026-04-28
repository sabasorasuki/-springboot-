# SysHuagao 个性化推荐 Handoff

更新时间：`2026-04-28`

## 当前目标

当前主线只覆盖 `sys_huagao` 橱窗画稿：

1. 保持搜索、列表、详情、收藏、购物车、下单行为采集可用。
2. 用 XGBoost Learning-to-Rank 训练离线推荐结果。
3. 通过 `GET /recHuagao/recommendations` 给首页提供推荐。
4. 新链路验证后，再物理删除旧 Mahout 协同过滤。

暂不纳入：`sys_zuopin`、社区帖子、企划、画师主页、售前咨询。

## 已完成

### 搜索与行为采集

- `/sysHuagao/list` 支持固定分类和关键词搜索。
- `/showcase`、`/work/:id` 已采集：
  - `impression`
  - `click_detail`
  - `detail_view`
  - `detail_dwell`
  - `favorite`
  - `add_to_cart`
  - `create_order`
- 首页推荐列表现在也纳入 `scene=home` 的曝光和点击采集。

标签口径固定为：

- `create_order = 4`
- `add_to_cart = 3`
- `favorite = 2`
- `click_detail = 1`
- `impression = 0`

### LTR 推荐闭环

新增结果表：

- `rec_huagao_model_version`
- `rec_huagao_user_recommendation`

新增 SQL：

- `artistsion-admin/sql/2026-04-28-rec-huagao-ltr-recommendation-schema.sql`
- `artistsion-admin/sql/2026-04-28-rec-huagao-legacy-cf-removal.sql`

新增训练目录：

- `recsys/huagao_ltr/`

固定演示命令：

```bash
python recsys/huagao_ltr/run_pipeline.py --source synthetic --top-k 50
```

Pipeline 做的事：

- 创建推荐结果表。
- 在 active `sys_huagao` 少于阈值时补充 `fujin='synthetic_ltr'` 的模拟画稿。
- 生成 `syn_` 前缀的 request、impression、action 日志。
- 使用 `XGBRanker(objective='rank:ndcg')` 训练。
- 输出 `ndcg@5`、`ndcg@10`、`map@10`、样本数、正样本数、用户数、物品数。
- 写入 `u:*`、`v:*` 和 `global` 推荐结果。

### 推荐服务接入

新增接口：

```http
GET /recHuagao/recommendations?pageNo=1&pageSize=12&scene=home
```

返回：

```json
{
  "total": 12,
  "rows": [],
  "requestId": "rec_hg_...",
  "modelVersion": "ltr_xgb_...",
  "fallback": false
}
```

读取顺序：

1. 登录用户：`actor_key = u:{userId}`
2. 匿名访客：`actor_key = v:{visitorId}`
3. 全局兜底：`actor_key = global`
4. 仍无结果：最新上架橱窗

首页已改为请求新接口；后端无模型、无表、无结果时自动降级到最新上架橱窗。

### 旧协同过滤状态

旧 Mahout / `user_article_operation` 前台入口已断开：

- 首页不再调用 `/userArticleOperation/recommendations/{userid}`。
- 订单评价成功后不再写 `/userArticleOperation/add`。
- `artistsion-web/src/api/tuijian.js` 已删除。

后端暂留：

- `UserArticleOperation*`
- `UserArticleOperationMapper.xml`
- Mahout 依赖
- `/userArticleOperation/**` 白名单
- `user_article_operation` 表

等 LTR 推荐接口构建和端到端验证通过后，再执行第二轮物理删除。

## 待验证

推荐上线前至少完成：

1. 执行推荐结果表 SQL。
2. 安装 Python 依赖：`pip install -r recsys/huagao_ltr/requirements.txt`。
3. 运行 synthetic pipeline，确认每个 actor 至少 12 条推荐。
4. `mvn -q -DskipTests compile` 通过。
5. `npm run build:prod` 通过。
6. 首页登录、匿名、无模型三种状态都能渲染 `rows`。
7. 点击首页推荐卡片后，详情页能收到 `requestId`、`position`、`scene=home`。

## 关键文件

后端：

- `artistsion-admin/src/main/java/com/lf/controller/RecHuagaoRecommendationController.java`
- `artistsion-admin/src/main/java/com/lf/service/impl/RecHuagaoRecommendationServiceImpl.java`
- `artistsion-admin/src/main/resources/mapper/RecHuagaoRecommendationMapper.xml`
- `artistsion-admin/src/main/java/com/lf/service/impl/RecHuagaoTrackServiceImpl.java`
- `artistsion-admin/src/main/resources/mapper/RecHuagaoDebugMapper.xml`

前端：

- `artistsion-web/src/views/home/index.vue`
- `artistsion-web/src/views/showcase/index.vue`
- `artistsion-web/src/views/work/detail.vue`
- `artistsion-web/src/api/recHuagao.js`
- `artistsion-web/src/utils/visitor.js`

训练：

- `recsys/huagao_ltr/run_pipeline.py`
- `recsys/huagao_ltr/requirements.txt`
- `recsys/huagao_ltr/README.md`

SQL：

- `artistsion-admin/sql/2026-04-22-phase0-rec-huagao-event-schema.sql`
- `artistsion-admin/sql/2026-04-22-phase05-rec-huagao-aggregate-rebuild.sql`
- `artistsion-admin/sql/2026-04-28-rec-huagao-training-readiness-check.sql`
- `artistsion-admin/sql/2026-04-28-rec-huagao-ltr-recommendation-schema.sql`
- `artistsion-admin/sql/2026-04-28-rec-huagao-legacy-cf-removal.sql`

## 下一步

优先顺序：

1. 跑通 synthetic pipeline 和首页推荐端到端。
2. 确认 `trainingReadiness`、`rebuildCheck`、孤儿 request/action/impression 检查为 0。
3. 验证通过后删除旧 Mahout 后端代码、依赖、白名单和旧表。
4. 推荐闭环稳定后，再补全首页、橱窗、作品/社区、企划、画师主页、个人中心的主路径。
