-- 为新认证系统准备的字段变更
-- 执行前请备份数据库
-- 本脚本可选执行：当前 nickname 暂时用 name 字段代替，active_role 暂时在前端管理

-- 新增 nickname 字段（显示昵称，区别于 username 登录名）
ALTER TABLE x_user ADD COLUMN nickname VARCHAR(50) DEFAULT NULL COMMENT '昵称' AFTER name;

-- 新增 active_role 字段（当前激活身份，client 或 artist）
ALTER TABLE x_user ADD COLUMN active_role VARCHAR(20) DEFAULT 'client' COMMENT '当前激活身份' AFTER nickname;
