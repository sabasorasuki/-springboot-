-- Phase 9: 举报与审核中心
-- 执行环境: MySQL, 数据库 artistsion

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `sys_report` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `reporter_user_id` BIGINT NOT NULL COMMENT '举报人用户ID',
  `reporter_username` VARCHAR(50) DEFAULT NULL COMMENT '举报人名称（冗余）',
  `target_type` VARCHAR(20) NOT NULL COMMENT '作品/社区内容/反馈/订单',
  `target_id` BIGINT NOT NULL COMMENT '举报对象ID',
  `target_title` VARCHAR(200) DEFAULT NULL COMMENT '举报对象标题或摘要（冗余）',
  `reason` VARCHAR(100) NOT NULL COMMENT '举报原因',
  `detail` TEXT COMMENT '补充说明',
  `status` VARCHAR(20) NOT NULL DEFAULT '待处理' COMMENT '待处理/已处理/已驳回',
  `handler_user_id` BIGINT DEFAULT NULL COMMENT '处理管理员ID',
  `handler_username` VARCHAR(50) DEFAULT NULL COMMENT '处理管理员名称（冗余）',
  `handler_result` VARCHAR(500) DEFAULT NULL COMMENT '处理备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `handled_at` DATETIME DEFAULT NULL COMMENT '处理时间',
  KEY `idx_sys_report_status` (`status`),
  KEY `idx_sys_report_target_type` (`target_type`),
  KEY `idx_sys_report_created_at` (`created_at`),
  KEY `idx_sys_report_reporter_user_id` (`reporter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='举报与审核中心主表';

INSERT INTO `x_menu` (`menu_id`, `component`, `path`, `redirect`, `name`, `title`, `icon`, `parent_id`, `is_leaf`, `hidden`)
SELECT 38, 'Layout', '/report', '/report/center', 'reportCenterRoot', '举报与审核', 'form', 0, 'N', 0
WHERE NOT EXISTS (SELECT 1 FROM `x_menu` WHERE `menu_id` = 38);

INSERT INTO `x_menu` (`menu_id`, `component`, `path`, `redirect`, `name`, `title`, `icon`, `parent_id`, `is_leaf`, `hidden`)
SELECT 39, 'report/index', 'center', '', 'reportCenter', '举报与审核中心', 'form', 38, 'Y', 0
WHERE NOT EXISTS (SELECT 1 FROM `x_menu` WHERE `menu_id` = 39);

INSERT INTO `x_role_menu` (`id`, `role_id`, `menu_id`)
SELECT 564, 1, 38
WHERE NOT EXISTS (SELECT 1 FROM `x_role_menu` WHERE `id` = 564 OR (`role_id` = 1 AND `menu_id` = 38));

INSERT INTO `x_role_menu` (`id`, `role_id`, `menu_id`)
SELECT 565, 1, 39
WHERE NOT EXISTS (SELECT 1 FROM `x_role_menu` WHERE `id` = 565 OR (`role_id` = 1 AND `menu_id` = 39));
