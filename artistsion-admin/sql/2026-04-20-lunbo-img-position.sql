-- Add image position column to carousel table
ALTER TABLE `sys_lunbo`
  ADD COLUMN `img_position` VARCHAR(32) DEFAULT 'center' COMMENT '图片位置 (CSS object-position)';
