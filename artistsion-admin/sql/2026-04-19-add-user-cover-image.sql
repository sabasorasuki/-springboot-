ALTER TABLE `x_user`
ADD COLUMN `cover_image` varchar(255) DEFAULT NULL COMMENT '个人中心头图' AFTER `style_tags`;
