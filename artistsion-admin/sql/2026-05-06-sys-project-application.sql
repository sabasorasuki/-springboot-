CREATE TABLE IF NOT EXISTS sys_project_application (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  project_id BIGINT NOT NULL COMMENT '企划ID',
  applicant_id BIGINT NOT NULL COMMENT '应征用户ID',
  applicant_name VARCHAR(100) DEFAULT NULL COMMENT '应征用户昵称',
  applicant_avatar VARCHAR(255) DEFAULT NULL COMMENT '应征用户头像',
  message TEXT DEFAULT NULL COMMENT '应征说明',
  portfolio_url VARCHAR(255) DEFAULT NULL COMMENT '作品集链接',
  status VARCHAR(32) NOT NULL DEFAULT '待处理' COMMENT '状态: 待处理/已接受/已拒绝/已撤回',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_project_applicant (project_id, applicant_id),
  KEY idx_project_application_project (project_id, created_at),
  KEY idx_project_application_applicant (applicant_id, created_at),
  KEY idx_project_application_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企划应征记录';
