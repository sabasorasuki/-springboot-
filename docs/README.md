# Docs Index

更新时间：`2026-05-07`

## 当前主线

推荐系统已经从 `sys_huagao` 单域闭环升级为“全站共享兴趣画像 + 各内容域独立排序”：

- `huagao`：橱窗画稿，样本达标时使用 XGBoost LTR。
- `zuopin`：作品 / 社区内容，当前使用画像匹配 + 热度 + 新鲜度 baseline。
- `project`：企划 / 委托需求，当前使用画像匹配 + 招募状态 + 新鲜度 baseline。
- `artist`：画师，当前使用关注、作品/橱窗互动和发布活跃度 baseline。

请先读：

- `HUAGAO_RECS_HANDOFF_2026-04-28.md`
- `PROJECT_MAP.md`

## 当前状态

- 新接口：`GET /rec/recommendations`、`POST /recTrack/action`。
- 新训练入口：`python recsys/site_recs/run_pipeline.py --domains huagao,zuopin,project,artist --source real --top-k 50`。
- 新通用表：`rec_request_log`、`rec_impression_log`、`rec_action_log`、`rec_actor_profile`、`rec_model_version`、`rec_user_recommendation`。
- 旧 `rec_huagao_*` 暂留为历史兼容和回填来源。
- 旧 Mahout / `user_article_operation` 已下线，不再作为推荐入口。

## 文档状态

当前 `docs` 只保留：

- `README.md`：文档索引
- `HUAGAO_RECS_HANDOFF_2026-04-28.md`：推荐任务交接，现已记录全站推荐升级
- `PROJECT_MAP.md`：项目结构与关键文件地图
