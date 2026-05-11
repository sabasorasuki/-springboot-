CREATE TABLE IF NOT EXISTS sys_zuopin_tag (
  id BIGINT NOT NULL AUTO_INCREMENT,
  zuopin_id BIGINT NOT NULL COMMENT '作品ID',
  tag_id BIGINT NOT NULL COMMENT '标签ID',
  tag_source VARCHAR(20) NOT NULL COMMENT '标签来源：free',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_zuopin_tag (zuopin_id, tag_id),
  KEY idx_sys_zuopin_tag_tag_id_zuopin_id (tag_id, zuopin_id),
  KEY idx_sys_zuopin_tag_zuopin_source (zuopin_id, tag_source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='作品标签关联表';
