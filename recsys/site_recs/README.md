# Site Recs Pipeline

全站推荐 v1：共享兴趣画像 + 分域独立排序。

固定命令：

```powershell
python recsys/site_recs/run_pipeline.py --domains huagao,zuopin,project,artist --source real --top-k 50
```

流程：

1. 创建 `rec_*` 通用推荐表。
2. 回填旧 `rec_huagao_*` 日志和现有业务行为。
3. 构建 `rec_actor_profile` 共享画像。
4. 分域生成推荐：
   - `huagao` 样本达标时使用 XGBoost LTR。
   - `zuopin`、`project`、`artist` 当前使用可解释 baseline。
5. 写入 `rec_model_version` 和 `rec_user_recommendation`。

样本不足的域不会阻断训练，会在 `metrics_json.fallbackRanker=true` 中标记。
