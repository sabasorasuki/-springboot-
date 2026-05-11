ALTER TABLE sys_order
  ADD COLUMN rec_request_id VARCHAR(64) DEFAULT NULL COMMENT '推荐请求ID' AFTER fujin,
  ADD COLUMN rec_position INT DEFAULT NULL COMMENT '推荐曝光位置' AFTER rec_request_id,
  ADD COLUMN rec_scene VARCHAR(50) DEFAULT NULL COMMENT '推荐场景' AFTER rec_position,
  ADD COLUMN rec_source VARCHAR(50) DEFAULT NULL COMMENT '推荐来源' AFTER rec_scene,
  ADD COLUMN rec_model_version VARCHAR(64) DEFAULT NULL COMMENT '推荐模型版本' AFTER rec_source;

CREATE INDEX idx_sys_order_rec_request ON sys_order (rec_request_id);
