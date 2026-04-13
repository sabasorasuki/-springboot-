-- Phase 5B: 企划表 + 用户资料扩展
-- 执行环境: MySQL, 数据库 artistsion

-- 1. 企划表
CREATE TABLE IF NOT EXISTS `sys_project` (
  `id`          BIGINT AUTO_INCREMENT PRIMARY KEY,
  `title`       VARCHAR(200)   NOT NULL        COMMENT '企划标题',
  `description` TEXT                            COMMENT '需求描述',
  `category`    VARCHAR(50)                     COMMENT '分类（插画/立绘/头像等）',
  `style`       VARCHAR(50)                     COMMENT '风格偏好',
  `budget_min`  DECIMAL(10,2)                   COMMENT '预算下限',
  `budget_max`  DECIMAL(10,2)                   COMMENT '预算上限',
  `deadline`    DATE                            COMMENT '截稿日期',
  `status`      VARCHAR(20) DEFAULT '招募中'    COMMENT '招募中/进行中/已完成/已关闭',
  `user_id`     BIGINT         NOT NULL         COMMENT '发布者ID',
  `username`    VARCHAR(50)                     COMMENT '发布者名称（冗余）',
  `user_avatar` VARCHAR(500)                    COMMENT '发布者头像（冗余）',
  `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企划/委托需求表';

-- 2. 用户表补充画师资料字段
ALTER TABLE `x_user`
  ADD COLUMN `bio`        VARCHAR(500) DEFAULT NULL COMMENT '个人简介' AFTER `name`,
  ADD COLUMN `style_tags` VARCHAR(200) DEFAULT NULL COMMENT '擅长风格标签（逗号分隔）' AFTER `bio`;
