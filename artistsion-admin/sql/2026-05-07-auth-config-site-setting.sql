CREATE TABLE IF NOT EXISTS `sys_site_setting` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `setting_key` VARCHAR(100) NOT NULL,
  `setting_value` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_site_setting_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站点设置';

INSERT INTO `sys_site_setting` (`setting_key`, `setting_value`, `description`)
VALUES ('auth.register.require_email_code', '1', '注册时是否强制校验邮箱验证码')
ON DUPLICATE KEY UPDATE
  `description` = VALUES(`description`);