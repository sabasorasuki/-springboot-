CREATE TABLE IF NOT EXISTS rec_request_log (
  request_id VARCHAR(64) NOT NULL COMMENT '请求ID',
  domain VARCHAR(32) NOT NULL COMMENT '内容域: huagao/zuopin/project/artist',
  query_key VARCHAR(64) DEFAULT NULL COMMENT '查询上下文哈希',
  scene VARCHAR(50) NOT NULL COMMENT '场景',
  user_id BIGINT DEFAULT NULL COMMENT '用户ID',
  visitor_id VARCHAR(64) DEFAULT NULL COMMENT '匿名访客ID',
  session_id VARCHAR(64) DEFAULT NULL COMMENT '会话ID',
  keyword VARCHAR(255) DEFAULT NULL COMMENT '搜索词',
  category VARCHAR(100) DEFAULT NULL COMMENT '分类/风格筛选',
  tag_id BIGINT DEFAULT NULL COMMENT '系统标签筛选ID',
  page_no BIGINT NOT NULL COMMENT '页码',
  page_size BIGINT NOT NULL COMMENT '分页大小',
  sort_mode VARCHAR(50) NOT NULL COMMENT '排序模式',
  result_total BIGINT NOT NULL DEFAULT 0 COMMENT '命中总数',
  returned_count BIGINT NOT NULL DEFAULT 0 COMMENT '本页返回数',
  fallback TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否降级',
  model_version VARCHAR(64) DEFAULT NULL COMMENT '模型版本',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (request_id),
  KEY idx_rec_req_domain_scene_created (domain, scene, created_at),
  KEY idx_rec_req_user_created (user_id, created_at),
  KEY idx_rec_req_visitor_created (visitor_id, created_at),
  KEY idx_rec_req_model (domain, model_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全站推荐请求日志';

CREATE TABLE IF NOT EXISTS rec_impression_log (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  request_id VARCHAR(64) NOT NULL COMMENT '请求ID',
  domain VARCHAR(32) NOT NULL COMMENT '内容域',
  item_id BIGINT NOT NULL COMMENT '内容ID',
  author_id BIGINT DEFAULT NULL COMMENT '作者/发布者ID',
  position INT NOT NULL COMMENT '曝光位置',
  page_no BIGINT NOT NULL COMMENT '页码',
  page_size BIGINT NOT NULL COMMENT '分页大小',
  scene VARCHAR(50) NOT NULL COMMENT '场景',
  model_version VARCHAR(64) DEFAULT NULL COMMENT '模型版本',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rec_imp_req_domain_item (request_id, domain, item_id),
  KEY idx_rec_imp_domain_item_created (domain, item_id, created_at),
  KEY idx_rec_imp_scene_created (scene, created_at),
  KEY idx_rec_imp_req (request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全站推荐曝光日志';

CREATE TABLE IF NOT EXISTS rec_action_log (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  event_id VARCHAR(64) NOT NULL COMMENT '事件幂等ID',
  event_type VARCHAR(50) NOT NULL COMMENT '事件类型',
  domain VARCHAR(32) NOT NULL COMMENT '内容域',
  request_id VARCHAR(64) DEFAULT NULL COMMENT '请求ID',
  item_id BIGINT NOT NULL COMMENT '内容ID',
  author_id BIGINT DEFAULT NULL COMMENT '作者/发布者ID',
  user_id BIGINT DEFAULT NULL COMMENT '用户ID',
  visitor_id VARCHAR(64) DEFAULT NULL COMMENT '匿名访客ID',
  session_id VARCHAR(64) DEFAULT NULL COMMENT '会话ID',
  position INT DEFAULT NULL COMMENT '曝光位置',
  event_value BIGINT DEFAULT NULL COMMENT '事件数值',
  scene VARCHAR(50) DEFAULT NULL COMMENT '场景',
  source VARCHAR(50) DEFAULT NULL COMMENT '来源',
  model_version VARCHAR(64) DEFAULT NULL COMMENT '模型版本',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rec_action_event (event_id),
  KEY idx_rec_action_domain_item_created (domain, item_id, created_at),
  KEY idx_rec_action_type_created (event_type, created_at),
  KEY idx_rec_action_req (request_id),
  KEY idx_rec_action_actor_created (user_id, visitor_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全站推荐行为日志';

CREATE TABLE IF NOT EXISTS rec_actor_profile (
  actor_key VARCHAR(80) NOT NULL COMMENT '推荐对象: u:{userId}/v:{visitorId}/global',
  profile_json MEDIUMTEXT DEFAULT NULL COMMENT '画像JSON',
  summary VARCHAR(512) DEFAULT NULL COMMENT '画像摘要',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (actor_key),
  KEY idx_rec_actor_profile_updated (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全站共享兴趣画像';

CREATE TABLE IF NOT EXISTS rec_model_version (
  model_version VARCHAR(64) NOT NULL COMMENT '模型版本',
  domain VARCHAR(32) NOT NULL COMMENT '内容域',
  algorithm VARCHAR(64) NOT NULL COMMENT '算法',
  train_source VARCHAR(32) NOT NULL COMMENT '训练数据来源',
  model_path VARCHAR(255) DEFAULT NULL COMMENT '模型文件路径',
  metrics_json MEDIUMTEXT DEFAULT NULL COMMENT '训练指标JSON',
  sample_count BIGINT NOT NULL DEFAULT 0 COMMENT '样本数',
  positive_sample_count BIGINT NOT NULL DEFAULT 0 COMMENT '正样本数',
  actor_count BIGINT NOT NULL DEFAULT 0 COMMENT '用户/访客数',
  item_count BIGINT NOT NULL DEFAULT 0 COMMENT '物品数',
  status VARCHAR(32) NOT NULL DEFAULT 'active' COMMENT '状态: active/archived/failed',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  trained_at DATETIME DEFAULT NULL COMMENT '训练完成时间',
  activated_at DATETIME DEFAULT NULL COMMENT '激活时间',
  PRIMARY KEY (model_version),
  KEY idx_rec_model_domain_status_activated (domain, status, activated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全站推荐模型版本';

CREATE TABLE IF NOT EXISTS rec_user_recommendation (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  model_version VARCHAR(64) NOT NULL COMMENT '模型版本',
  domain VARCHAR(32) NOT NULL COMMENT '内容域',
  actor_key VARCHAR(80) NOT NULL COMMENT '推荐对象: u:{userId}/v:{visitorId}/global',
  item_id BIGINT NOT NULL COMMENT '内容ID',
  rank_no INT NOT NULL COMMENT '推荐排序，从1开始',
  score DECIMAL(18,8) NOT NULL DEFAULT 0 COMMENT '模型分',
  reason VARCHAR(255) DEFAULT NULL COMMENT '推荐原因/来源',
  generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rec_user_domain_model_rank (domain, model_version, actor_key, rank_no),
  UNIQUE KEY uk_rec_user_domain_model_item (domain, model_version, actor_key, item_id),
  KEY idx_rec_user_actor_rank (domain, actor_key, model_version, rank_no),
  KEY idx_rec_user_item (domain, item_id),
  KEY idx_rec_user_generated (generated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全站离线推荐结果';
