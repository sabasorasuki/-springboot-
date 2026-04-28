CREATE TABLE IF NOT EXISTS rec_huagao_model_version (
  model_version VARCHAR(64) NOT NULL COMMENT '模型版本',
  algorithm VARCHAR(64) NOT NULL COMMENT '算法',
  train_source VARCHAR(32) NOT NULL COMMENT '训练数据来源: synthetic/real/mixed',
  model_path VARCHAR(255) DEFAULT NULL COMMENT '模型文件路径',
  metrics_json TEXT DEFAULT NULL COMMENT '训练指标JSON',
  sample_count BIGINT NOT NULL DEFAULT 0 COMMENT '样本数',
  positive_sample_count BIGINT NOT NULL DEFAULT 0 COMMENT '正样本数',
  actor_count BIGINT NOT NULL DEFAULT 0 COMMENT '用户/访客数',
  item_count BIGINT NOT NULL DEFAULT 0 COMMENT '物品数',
  status VARCHAR(32) NOT NULL DEFAULT 'active' COMMENT '状态: active/archived/failed',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  trained_at DATETIME DEFAULT NULL COMMENT '训练完成时间',
  activated_at DATETIME DEFAULT NULL COMMENT '激活时间',
  PRIMARY KEY (model_version),
  KEY idx_rec_hg_model_status_activated (status, activated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='画稿推荐模型版本';

CREATE TABLE IF NOT EXISTS rec_huagao_user_recommendation (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  model_version VARCHAR(64) NOT NULL COMMENT '模型版本',
  actor_key VARCHAR(80) NOT NULL COMMENT '推荐对象: u:{userId}/v:{visitorId}/global',
  huagao_id BIGINT NOT NULL COMMENT '画稿ID',
  rank_no INT NOT NULL COMMENT '推荐排序，从1开始',
  score DECIMAL(18,8) NOT NULL DEFAULT 0 COMMENT '模型分',
  reason VARCHAR(255) DEFAULT NULL COMMENT '推荐原因/来源',
  generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rec_hg_user_model_rank (model_version, actor_key, rank_no),
  UNIQUE KEY uk_rec_hg_user_model_item (model_version, actor_key, huagao_id),
  KEY idx_rec_hg_user_actor_rank (actor_key, model_version, rank_no),
  KEY idx_rec_hg_user_item (huagao_id),
  KEY idx_rec_hg_user_generated (generated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='画稿离线个性化推荐结果';
