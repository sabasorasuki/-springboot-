SET NAMES utf8mb4;

-- =========================================================
-- Phase 1 / Schema
-- 分类与标签基础表设计（仅接 sys_huagao）
-- 说明：
-- 1. “全部”为前端虚拟分类，不落库
-- 2. normalized_name 为标签归一化核心字段，必须保留
-- 3. 本阶段不接 sys_zuopin 标签体系
-- 4. 保持与现有项目风格一致：不强加外键，靠业务层维护关联
-- =========================================================

-- ---------------------------------------------------------
-- 1) 扩展现有分类表 sys_fenlei
-- ---------------------------------------------------------
ALTER TABLE `sys_fenlei`
  ADD COLUMN `code` VARCHAR(50) DEFAULT NULL COMMENT '分类编码；固定分类使用稳定 code，旧分类可为空' AFTER `fenlei`,
  ADD COLUMN `sort` INT NOT NULL DEFAULT 0 COMMENT '排序值，越小越靠前' AFTER `code`,
  ADD COLUMN `status` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '状态：1启用 0禁用' AFTER `sort`,
  ADD COLUMN `is_fixed` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否固定分类：1是 0否' AFTER `status`,
  ADD COLUMN `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `is_fixed`,
  ADD COLUMN `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `created_at`,
  ADD COLUMN `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否 1是' AFTER `updated_at`,
  ADD UNIQUE KEY `uk_sys_fenlei_code_deleted` (`code`, `deleted`),
  ADD KEY `idx_sys_fenlei_status_sort` (`status`, `sort`, `id`),
  ADD KEY `idx_sys_fenlei_name_deleted` (`fenlei`, `deleted`);

-- ---------------------------------------------------------
-- 2) 标签字典表 sys_tag
-- tag_type: system / free
-- tag_group: 风格 / 人物 / 构图 / 情绪 / 发型发色 / 服装 / 场景 / 配色 / 用途 / 生产属性
-- normalized_name: 标签归一化名称，用于 trim / lowercase / alias merge / dedupe
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sys_tag` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT '标签展示名',
  `normalized_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_bin NOT NULL COMMENT '归一化名称',
  `tag_type` VARCHAR(20) NOT NULL COMMENT '标签类型：system/free',
  `tag_group` VARCHAR(30) DEFAULT NULL COMMENT '标签分组，仅 system 标签使用',
  `status` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '状态：1启用 0禁用',
  `use_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '使用次数',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_tag_normalized_deleted` (`normalized_name`, `deleted`),
  KEY `idx_sys_tag_type_group_status` (`tag_type`, `tag_group`, `status`, `deleted`),
  KEY `idx_sys_tag_use_count` (`use_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签字典表';

-- ---------------------------------------------------------
-- 3) 标签别名表 sys_tag_alias
-- 一个 alias 最终归并到一个 canonical tag
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sys_tag_alias` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `tag_id` BIGINT NOT NULL COMMENT '归属标签ID',
  `alias_name` VARCHAR(50) NOT NULL COMMENT '别名展示名',
  `normalized_name` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_bin NOT NULL COMMENT '归一化别名',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_tag_alias_normalized` (`normalized_name`),
  KEY `idx_sys_tag_alias_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签别名表';

-- ---------------------------------------------------------
-- 4) 画稿标签关联表 sys_huagao_tag
-- 仅接 sys_huagao
-- tag_source: system / free
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sys_huagao_tag` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `huagao_id` BIGINT NOT NULL COMMENT '画稿ID',
  `tag_id` BIGINT NOT NULL COMMENT '标签ID',
  `tag_source` VARCHAR(20) NOT NULL COMMENT '标签来源：system/free',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sys_huagao_tag` (`huagao_id`, `tag_id`),
  KEY `idx_sys_huagao_tag_tag_id_huagao_id` (`tag_id`, `huagao_id`),
  KEY `idx_sys_huagao_tag_huagao_source` (`huagao_id`, `tag_source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='画稿标签关联表';

-- ---------------------------------------------------------
-- 5) 给 sys_huagao 补基础索引
-- 说明：
-- - 仍然保留现有 fenlei 字符串字段，不在 Phase 1 改成 category_id
-- - 后续 Phase 4 的列表筛选 / 搜索会直接受益
-- ---------------------------------------------------------
ALTER TABLE `sys_huagao`
  ADD KEY `idx_sys_huagao_fenlei` (`fenlei`),
  ADD KEY `idx_sys_huagao_public_list` (`status`, `type`, `fenlei`, `id`);
