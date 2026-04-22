SET NAMES utf8mb4;

-- =========================================================
-- Phase 2 / Huagao legacy category retire
-- 范围：
-- 1. 仅处理 sys_huagao 的 legacy 分类映射与下线
-- 2. 不处理 sys_zuopin
-- 3. 不处理 sys_huagao.fenlei = '' 的空字符串数据
-- =========================================================

DROP TEMPORARY TABLE IF EXISTS `tmp_phase2_huagao_legacy_map`;
CREATE TEMPORARY TABLE `tmp_phase2_huagao_legacy_map` (
  `old_fenlei` VARCHAR(50) NOT NULL,
  `new_fenlei` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`old_fenlei`)
) ENGINE=Memory DEFAULT CHARSET=utf8mb4;

INSERT INTO `tmp_phase2_huagao_legacy_map` (`old_fenlei`, `new_fenlei`) VALUES
('商业插画类', '平面设计'),
('个人定制类', '立绘'),
('艺术创作类', '立绘'),
('科学记录类', '平面设计');

START TRANSACTION;

-- ---------------------------------------------------------
-- 1) 执行前预检查
-- ---------------------------------------------------------
SELECT
  m.`old_fenlei`,
  m.`new_fenlei`,
  COUNT(h.`id`) AS `huagao_count`
FROM `tmp_phase2_huagao_legacy_map` m
LEFT JOIN `sys_huagao` h
  ON h.`fenlei` = m.`old_fenlei`
GROUP BY m.`old_fenlei`, m.`new_fenlei`
ORDER BY m.`old_fenlei`;

SELECT
  m.`old_fenlei`,
  m.`new_fenlei`,
  sf.`id` AS `target_category_id`,
  sf.`code`,
  sf.`status`,
  sf.`is_fixed`,
  sf.`deleted`
FROM `tmp_phase2_huagao_legacy_map` m
LEFT JOIN `sys_fenlei` sf
  ON sf.`fenlei` = m.`new_fenlei`
 AND sf.`is_fixed` = 1
 AND sf.`status` = 1
 AND sf.`deleted` = 0
ORDER BY m.`old_fenlei`;

-- ---------------------------------------------------------
-- 2) 映射 sys_huagao.fenlei
-- ---------------------------------------------------------
UPDATE `sys_huagao` h
JOIN `tmp_phase2_huagao_legacy_map` m
  ON h.`fenlei` = m.`old_fenlei`
SET h.`fenlei` = m.`new_fenlei`;

-- ---------------------------------------------------------
-- 3) 下线 sys_fenlei 中对应 legacy 分类
-- ---------------------------------------------------------
UPDATE `sys_fenlei` sf
JOIN `tmp_phase2_huagao_legacy_map` m
  ON sf.`fenlei` = m.`old_fenlei`
SET
  sf.`status` = 0,
  sf.`deleted` = 1,
  sf.`updated_at` = CURRENT_TIMESTAMP
WHERE sf.`is_fixed` = 0
  AND sf.`deleted` = 0;

-- ---------------------------------------------------------
-- 4) 回归校验
-- ---------------------------------------------------------
SELECT
  h.`fenlei`,
  COUNT(*) AS `cnt`
FROM `sys_huagao` h
WHERE h.`fenlei` IN ('商业插画类', '个人定制类', '艺术创作类', '科学记录类')
GROUP BY h.`fenlei`
ORDER BY h.`fenlei`;

SELECT
  sf.`id`,
  sf.`fenlei`,
  sf.`status`,
  sf.`is_fixed`,
  sf.`deleted`
FROM `sys_fenlei` sf
WHERE sf.`fenlei` IN ('商业插画类', '个人定制类', '艺术创作类', '科学记录类')
ORDER BY sf.`id`;

SELECT
  sf.`id`,
  sf.`fenlei`,
  sf.`code`,
  sf.`sort`
FROM `sys_fenlei` sf
WHERE sf.`is_fixed` = 1
  AND sf.`status` = 1
  AND sf.`deleted` = 0
ORDER BY sf.`sort`, sf.`id`;

COMMIT;

DROP TEMPORARY TABLE IF EXISTS `tmp_phase2_huagao_legacy_map`;
