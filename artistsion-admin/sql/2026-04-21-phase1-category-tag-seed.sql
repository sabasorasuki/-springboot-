SET NAMES utf8mb4;

-- =========================================================
-- Phase 1 / Seed
-- 说明：
-- 1. 先清洗分类脏字符
-- 2. 对命中固定分类的旧分类进行“升级”，不是盲插
-- 3. 仅补插仍缺失的固定分类
-- 4. 旧分类继续保留，不在 Phase 1 下线
-- 5. “全部”不落库
-- =========================================================

DROP TEMPORARY TABLE IF EXISTS `tmp_phase1_fixed_category`;
CREATE TEMPORARY TABLE `tmp_phase1_fixed_category` (
  `code` VARCHAR(50) NOT NULL,
  `fenlei` VARCHAR(50) NOT NULL,
  `sort` INT NOT NULL,
  `match_key` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`code`),
  UNIQUE KEY `uk_tmp_phase1_fixed_match_key` (`match_key`)
) ENGINE=Memory DEFAULT CHARSET=utf8mb4;

INSERT INTO `tmp_phase1_fixed_category` (`code`, `fenlei`, `sort`, `match_key`) VALUES
('avatar', '头像', 10, '头像'),
('q_fullbody', 'Q版全身', 20, 'q版全身'),
('half_body', '半身像', 30, '半身像'),
('standing_illustration', '立绘', 40, '立绘'),
('combo_sheet', '组合页', 50, '组合页'),
('costume_design', '服设', 60, '服设'),
('wallpaper', '壁纸', 70, '壁纸'),
('emoji_pack', '表情包', 80, '表情包'),
('live2d', 'Live2D', 90, 'live2d'),
('graphic_design', '平面设计', 100, '平面设计');

START TRANSACTION;

-- ---------------------------------------------------------
-- 1) 清洗 sys_fenlei 分类文本脏字符
-- 处理对象：
-- - ZERO WIDTH SPACE        U+200B
-- - ZERO WIDTH NON-JOINER   U+200C
-- - ZERO WIDTH JOINER       U+200D
-- - BOM / ZERO WIDTH NBSP   U+FEFF
-- - NBSP                    U+00A0
-- - 全角空格、回车、换行、Tab
-- ---------------------------------------------------------
UPDATE `sys_fenlei`
SET `fenlei` = TRIM(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(`fenlei`,
                    CONVERT(0xE2808B USING utf8mb4), ''
                  ),
                  CONVERT(0xE2808C USING utf8mb4), ''
                ),
                CONVERT(0xE2808D USING utf8mb4), ''
              ),
              CONVERT(0xEFBBBF USING utf8mb4), ''
            ),
            CONVERT(0xC2A0 USING utf8mb4), ''
          ),
          '　', ''
        ),
        CHAR(13), ''
      ),
      CHAR(10), ''
    ),
    CHAR(9), ''
  )
)
WHERE `fenlei` IS NOT NULL;

-- ---------------------------------------------------------
-- 2) 清洗 sys_huagao.fenlei 脏字符
-- 仅接 sys_huagao，不处理 sys_zuopin
-- ---------------------------------------------------------
UPDATE `sys_huagao`
SET `fenlei` = TRIM(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(`fenlei`,
                    CONVERT(0xE2808B USING utf8mb4), ''
                  ),
                  CONVERT(0xE2808C USING utf8mb4), ''
                ),
                CONVERT(0xE2808D USING utf8mb4), ''
              ),
              CONVERT(0xEFBBBF USING utf8mb4), ''
            ),
            CONVERT(0xC2A0 USING utf8mb4), ''
          ),
          '　', ''
        ),
        CHAR(13), ''
      ),
      CHAR(10), ''
    ),
    CHAR(9), ''
  )
)
WHERE `fenlei` IS NOT NULL;

-- ---------------------------------------------------------
-- 3) 对命中固定分类的旧 sys_fenlei，先选一条 canonical 记录保留
-- 规则：
-- - 以清洗后的名称命中固定分类
-- - 同名多条时，只保留 id 最小的一条升级为固定分类
-- - 其余“清洗后同名”的重复记录做软删除，避免重复分类
-- ---------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `tmp_phase1_fixed_existing`;
CREATE TEMPORARY TABLE `tmp_phase1_fixed_existing` AS
SELECT
  fc.`code`,
  MIN(sf.`id`) AS `keep_id`
FROM `tmp_phase1_fixed_category` fc
JOIN `sys_fenlei` sf
  ON LOWER(sf.`fenlei`) = fc.`match_key`
 AND sf.`deleted` = 0
GROUP BY fc.`code`;

-- 升级 canonical 记录为固定分类
UPDATE `sys_fenlei` sf
JOIN `tmp_phase1_fixed_existing` fe
  ON sf.`id` = fe.`keep_id`
JOIN `tmp_phase1_fixed_category` fc
  ON fe.`code` = fc.`code`
SET
  sf.`fenlei` = fc.`fenlei`,
  sf.`code` = fc.`code`,
  sf.`sort` = fc.`sort`,
  sf.`status` = 1,
  sf.`is_fixed` = 1,
  sf.`deleted` = 0,
  sf.`updated_at` = CURRENT_TIMESTAMP;

-- 对“清洗后同名”的重复旧分类做软删除，避免前台出现重复固定分类
UPDATE `sys_fenlei` sf
JOIN `tmp_phase1_fixed_category` fc
  ON LOWER(sf.`fenlei`) = fc.`match_key`
JOIN `tmp_phase1_fixed_existing` fe
  ON fe.`code` = fc.`code`
SET
  sf.`code` = NULL,
  sf.`status` = 0,
  sf.`is_fixed` = 0,
  sf.`deleted` = 1,
  sf.`updated_at` = CURRENT_TIMESTAMP
WHERE sf.`id` <> fe.`keep_id`
  AND sf.`deleted` = 0;

-- ---------------------------------------------------------
-- 4) 同步把 sys_huagao 中命中的固定分类文本归一为标准展示名
-- 例如：live2d -> Live2D
-- ---------------------------------------------------------
UPDATE `sys_huagao` h
JOIN `tmp_phase1_fixed_category` fc
  ON LOWER(h.`fenlei`) = fc.`match_key`
SET h.`fenlei` = fc.`fenlei`
WHERE h.`fenlei` IS NOT NULL;

-- ---------------------------------------------------------
-- 5) 旧分类继续保留：只补 metadata，不下线
-- 说明：
-- - 这里只处理仍然存活的非固定分类
-- - code 保持 NULL，表示 legacy / 历史分类
-- - sort 后置，避免把固定分类挤到后面
-- ---------------------------------------------------------
UPDATE `sys_fenlei`
SET
  `sort` = CASE
    WHEN `sort` = 0 THEN 1000 + `id`
    ELSE `sort`
  END,
  `status` = 1,
  `is_fixed` = 0,
  `deleted` = 0,
  `updated_at` = CURRENT_TIMESTAMP
WHERE `deleted` = 0
  AND (`code` IS NULL OR `is_fixed` = 0);

-- ---------------------------------------------------------
-- 6) 只补插仍不存在的固定分类
-- 规则：
-- - 如果已通过“升级旧分类”得到固定分类，则不再插入
-- - 避免盲插造成同名重复分类
-- ---------------------------------------------------------
INSERT INTO `sys_fenlei`
(`fenlei`, `code`, `sort`, `status`, `is_fixed`, `deleted`)
SELECT
  fc.`fenlei`,
  fc.`code`,
  fc.`sort`,
  1,
  1,
  0
FROM `tmp_phase1_fixed_category` fc
LEFT JOIN `sys_fenlei` sf
  ON sf.`code` = fc.`code`
 AND sf.`deleted` = 0
WHERE sf.`id` IS NULL;

-- 固定分类再做一次标准化兜底
UPDATE `sys_fenlei` sf
JOIN `tmp_phase1_fixed_category` fc
  ON sf.`code` = fc.`code`
 AND sf.`deleted` = 0
SET
  sf.`fenlei` = fc.`fenlei`,
  sf.`sort` = fc.`sort`,
  sf.`status` = 1,
  sf.`is_fixed` = 1,
  sf.`updated_at` = CURRENT_TIMESTAMP;

-- ---------------------------------------------------------
-- 7) 导入 100 个系统标签
-- normalized_name 为归一化后的唯一键：
-- - trim 后保存
-- - 英文统一小写
-- - 混合词保留中文，英文字母小写
-- ---------------------------------------------------------
INSERT INTO `sys_tag`
(`name`, `normalized_name`, `tag_type`, `tag_group`, `status`, `use_count`, `deleted`)
VALUES
-- A. 风格
('二次元', '二次元', 'system', '风格', 1, 0, 0),
('日系', '日系', 'system', '风格', 1, 0, 0),
('国风', '国风', 'system', '风格', 1, 0, 0),
('韩系', '韩系', 'system', '风格', 1, 0, 0),
('厚涂', '厚涂', 'system', '风格', 1, 0, 0),
('平涂', '平涂', 'system', '风格', 1, 0, 0),
('赛璐璐', '赛璐璐', 'system', '风格', 1, 0, 0),
('水彩风', '水彩风', 'system', '风格', 1, 0, 0),
('写实风', '写实风', 'system', '风格', 1, 0, 0),
('Q版', 'q版', 'system', '风格', 1, 0, 0),

-- B. 人物
('少女', '少女', 'system', '人物', 1, 0, 0),
('少年', '少年', 'system', '人物', 1, 0, 0),
('御姐', '御姐', 'system', '人物', 1, 0, 0),
('正太', '正太', 'system', '人物', 1, 0, 0),
('萝莉', '萝莉', 'system', '人物', 1, 0, 0),
('男角色', '男角色', 'system', '人物', 1, 0, 0),
('女角色', '女角色', 'system', '人物', 1, 0, 0),
('双人', '双人', 'system', '人物', 1, 0, 0),
('多人', '多人', 'system', '人物', 1, 0, 0),
('兽设', '兽设', 'system', '人物', 1, 0, 0),

-- C. 构图
('头部特写', '头部特写', 'system', '构图', 1, 0, 0),
('胸像', '胸像', 'system', '构图', 1, 0, 0),
('半身', '半身', 'system', '构图', 1, 0, 0),
('全身', '全身', 'system', '构图', 1, 0, 0),
('双人构图', '双人构图', 'system', '构图', 1, 0, 0),
('多人构图', '多人构图', 'system', '构图', 1, 0, 0),
('单人立绘', '单人立绘', 'system', '构图', 1, 0, 0),
('组合页', '组合页', 'system', '构图', 1, 0, 0),
('大头贴', '大头贴', 'system', '构图', 1, 0, 0),
('证件风', '证件风', 'system', '构图', 1, 0, 0),

-- D. 情绪
('微笑', '微笑', 'system', '情绪', 1, 0, 0),
('冷脸', '冷脸', 'system', '情绪', 1, 0, 0),
('害羞', '害羞', 'system', '情绪', 1, 0, 0),
('哭泣', '哭泣', 'system', '情绪', 1, 0, 0),
('生气', '生气', 'system', '情绪', 1, 0, 0),
('惊讶', '惊讶', 'system', '情绪', 1, 0, 0),
('元气', '元气', 'system', '情绪', 1, 0, 0),
('治愈', '治愈', 'system', '情绪', 1, 0, 0),
('高冷', '高冷', 'system', '情绪', 1, 0, 0),
('病娇感', '病娇感', 'system', '情绪', 1, 0, 0),

-- E. 发型发色
('长发', '长发', 'system', '发型发色', 1, 0, 0),
('短发', '短发', 'system', '发型发色', 1, 0, 0),
('双马尾', '双马尾', 'system', '发型发色', 1, 0, 0),
('马尾', '马尾', 'system', '发型发色', 1, 0, 0),
('麻花辫', '麻花辫', 'system', '发型发色', 1, 0, 0),
('公主切', '公主切', 'system', '发型发色', 1, 0, 0),
('黑发', '黑发', 'system', '发型发色', 1, 0, 0),
('白发', '白发', 'system', '发型发色', 1, 0, 0),
('金发', '金发', 'system', '发型发色', 1, 0, 0),
('挑染', '挑染', 'system', '发型发色', 1, 0, 0),

-- F. 服装
('制服', '制服', 'system', '服装', 1, 0, 0),
('水手服', '水手服', 'system', '服装', 1, 0, 0),
('JK', 'jk', 'system', '服装', 1, 0, 0),
('女仆', '女仆', 'system', '服装', 1, 0, 0),
('和服', '和服', 'system', '服装', 1, 0, 0),
('洛丽塔', '洛丽塔', 'system', '服装', 1, 0, 0),
('礼服', '礼服', 'system', '服装', 1, 0, 0),
('私服', '私服', 'system', '服装', 1, 0, 0),
('战斗服', '战斗服', 'system', '服装', 1, 0, 0),
('偶像服', '偶像服', 'system', '服装', 1, 0, 0),

-- G. 场景
('纯色背景', '纯色背景', 'system', '场景', 1, 0, 0),
('透明背景', '透明背景', 'system', '场景', 1, 0, 0),
('室内', '室内', 'system', '场景', 1, 0, 0),
('教室', '教室', 'system', '场景', 1, 0, 0),
('街道', '街道', 'system', '场景', 1, 0, 0),
('夜景', '夜景', 'system', '场景', 1, 0, 0),
('花海', '花海', 'system', '场景', 1, 0, 0),
('星空', '星空', 'system', '场景', 1, 0, 0),
('水面', '水面', 'system', '场景', 1, 0, 0),
('幻想场景', '幻想场景', 'system', '场景', 1, 0, 0),

-- H. 配色
('粉色系', '粉色系', 'system', '配色', 1, 0, 0),
('蓝色系', '蓝色系', 'system', '配色', 1, 0, 0),
('黑白系', '黑白系', 'system', '配色', 1, 0, 0),
('红黑配色', '红黑配色', 'system', '配色', 1, 0, 0),
('冷色调', '冷色调', 'system', '配色', 1, 0, 0),
('暖色调', '暖色调', 'system', '配色', 1, 0, 0),
('高饱和', '高饱和', 'system', '配色', 1, 0, 0),
('低饱和', '低饱和', 'system', '配色', 1, 0, 0),
('柔和配色', '柔和配色', 'system', '配色', 1, 0, 0),
('霓虹感', '霓虹感', 'system', '配色', 1, 0, 0),

-- I. 用途
('头像可用', '头像可用', 'system', '用途', 1, 0, 0),
('社媒头像', '社媒头像', 'system', '用途', 1, 0, 0),
('直播封面', '直播封面', 'system', '用途', 1, 0, 0),
('手机壁纸', '手机壁纸', 'system', '用途', 1, 0, 0),
('桌面壁纸', '桌面壁纸', 'system', '用途', 1, 0, 0),
('表情包', '表情包', 'system', '用途', 1, 0, 0),
('立绘展示', '立绘展示', 'system', '用途', 1, 0, 0),
('Live2D拆件稿', 'live2d拆件稿', 'system', '用途', 1, 0, 0),
('服设参考', '服设参考', 'system', '用途', 1, 0, 0),
('宣传海报', '宣传海报', 'system', '用途', 1, 0, 0),

-- J. 生产属性
('原创', '原创', 'system', '生产属性', 1, 0, 0),
('OC', 'oc', 'system', '生产属性', 1, 0, 0),
('同人', '同人', 'system', '生产属性', 1, 0, 0),
('VTuber', 'vtuber', 'system', '生产属性', 1, 0, 0),
('可商用', '可商用', 'system', '生产属性', 1, 0, 0),
('非商用', '非商用', 'system', '生产属性', 1, 0, 0),
('含背景', '含背景', 'system', '生产属性', 1, 0, 0),
('透明底', '透明底', 'system', '生产属性', 1, 0, 0),
('高精细', '高精细', 'system', '生产属性', 1, 0, 0),
('简约风', '简约风', 'system', '生产属性', 1, 0, 0)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `tag_type` = VALUES(`tag_type`),
  `tag_group` = VALUES(`tag_group`),
  `status` = VALUES(`status`),
  `deleted` = 0,
  `updated_at` = CURRENT_TIMESTAMP;

COMMIT;

DROP TEMPORARY TABLE IF EXISTS `tmp_phase1_fixed_existing`;
DROP TEMPORARY TABLE IF EXISTS `tmp_phase1_fixed_category`;
