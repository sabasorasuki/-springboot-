# Docs Index

更新时间：`2026-04-28`

## 当前主线

当前执行任务是 `sys_huagao` 个性化推荐闭环：行为采集、XGBoost LTR 训练、离线推荐结果落库、首页推荐接入。请先读：

- `HUAGAO_RECS_HANDOFF_2026-04-28.md`
- `PROJECT_MAP.md`

## 文档状态

已删除早期前台重构 brief、样式说明、旧 session handoff 和 archive 里的过期交接，避免和当前 huagao 推荐任务互相干扰。

当前 `docs` 只保留：

- `README.md`：文档索引
- `HUAGAO_RECS_HANDOFF_2026-04-28.md`：当前推荐任务交接
- `PROJECT_MAP.md`：项目结构与关键文件地图

## 当前判断

- `sys_huagao` 搜索和主行为采集已完成。
- 首页推荐已切到 `/recHuagao/recommendations`，无模型时降级最新上架橱窗。
- `recsys/huagao_ltr` 已提供 synthetic LTR 训练和离线结果落库。
- 旧 Mahout 前台入口已断开；后端兼容代码和旧表等待新链路验证后再删。
- 下一步是执行推荐表 SQL、跑 synthetic pipeline，并完成前后端构建与端到端验证。
