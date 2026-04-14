/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80030
 Source Host           : localhost:3306
 Source Schema         : artistsion

 Target Server Type    : MySQL
 Target Server Version : 80030
 File Encoding         : 65001

 Date: 19/03/2026 15:53:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_dianzan
-- ----------------------------
DROP TABLE IF EXISTS `sys_dianzan`;
CREATE TABLE `sys_dianzan`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `zpids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '作品id',
  `userids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dianzan
-- ----------------------------

-- ----------------------------
-- Table structure for sys_fenlei
-- ----------------------------
DROP TABLE IF EXISTS `sys_fenlei`;
CREATE TABLE `sys_fenlei`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `fenlei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_fenlei
-- ----------------------------
INSERT INTO `sys_fenlei` VALUES (15, '商业插画类');
INSERT INTO `sys_fenlei` VALUES (16, '个人定制类‌');
INSERT INTO `sys_fenlei` VALUES (17, '艺术创作类');
INSERT INTO `sys_fenlei` VALUES (18, '‌科学记录类‌');

-- ----------------------------
-- Table structure for sys_huagao
-- ----------------------------
DROP TABLE IF EXISTS `sys_huagao`;
CREATE TABLE `sys_huagao`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名字',
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格',
  `fenlei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '介绍',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '状态(上架,下架)',
  `shangjiaids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'id',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核状态(审核成功,审核失败)',
  `zhekou` int(0) NULL DEFAULT 0 COMMENT '折扣',
  `fujin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_huagao
-- ----------------------------
INSERT INTO `sys_huagao` VALUES (5, '画稿服务1', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', 20.00, '商业插画类', '<div style=\"max-width: 100%; overflow-x: visible; font-size: 18px; line-height: 30px; color: rgb(34, 34, 34); font-family: arial;\"><p>专业画稿服务，定制您的艺术想象在艺术创作与商业设计的多元需求中，专业画稿服务正成为连接创意与现实的重要桥梁。我们依托经验丰富的画师团队，为您提供全品类、定制化的画稿创作服务，覆盖艺术创作、商业设计、教育需求等多个场景，满足您从个人兴趣到商业项目的各类画稿需求。我们的画稿服务类型丰富多元，无论是用于艺术创作的临摹性画稿、写生性画稿，还是为商业项目定制的创作性画稿，都能精准匹配您的需求。在艺术创作领域，我们可以为画家提供创作前期的推敲稿本，帮助您捕捉灵感、完善构图；在商业设计领域，我们能够承接游戏原画、广告插画、绘本画稿等定制需求，将品牌理念与创意视觉完美融合。同时，针对教育场景，我们还能提供适合临摹学习的标准化画稿，为艺术爱好者与学生提供专业的学习范本。为了保障服务质量与效率，我们建立了完善的服务流程。您只需提供具体需求与参考素材，我们的画师会在24小时内提供初步方案，您可享有2次免费修改机会，确保画稿完全符合您的预期。在交付周期上，常规画稿3-5天即可完成，加急订单最快30分钟出图，满足您的紧急需求。所有画稿均提供版权保障，商业项目画稿版权完全归您所有，让您无后顾之忧。我们坚持高性价比的定价策略，根据画稿类型、尺寸与复杂程度制定透明价格，无任何隐藏费用。A4尺寸基础画稿低至35元，商业定制画稿可根据需求提供详细报价。同时，我们支持手绘与板绘两种创作形式，无论是传统纸质画稿还是数字化电子画稿，都能为您呈现细腻生动的视觉效果。选择我们的画稿服务，不仅是选择一份专业的艺术创作，更是选择一个可靠的创意合作伙伴。我们将以严谨的创作态度、高效的服务流程，为您打造兼具艺术价值与实用功能的画稿作品，让每一份创意都能完美落地。 （AI生成）</p></div><p style=\"border: 0px; margin-top: 0.63em; margin-bottom: 1.8em; counter-reset: list-1 0 list-2 0 list-3 0 list-4 0 list-5 0 list-6 0 list-7 0 list-8 0 list-9 0; color: rgb(25, 25, 25); font-family: &quot;PingFang SC&quot;, Arial, 微软雅黑, 宋体, simsun, sans-serif;\"></p><p style=\"box-sizing: inherit; margin-top: 34px; margin-bottom: 34px; text-align: justify; color: rgb(64, 64, 64); font-family: Arial, &quot;Hiragino Sans GB&quot;, STHeiti, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft Yahei&quot;, &quot;WenQuanYi Micro Hei&quot;, sans-serif; font-size: 18px;\"></p>', '上架', '13', '审核成功', 1, '备注');
INSERT INTO `sys_huagao` VALUES (8, '画稿服务2', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', 20.00, '个人定制类‌', '<div style=\"max-width: 100%; overflow-x: visible; font-size: 18px; line-height: 30px; color: rgb(34, 34, 34); font-family: arial;\"><p>专业画稿服务，定制您的艺术想象在艺术创作与商业设计的多元需求中，专业画稿服务正成为连接创意与现实的重要桥梁。我们依托经验丰富的画师团队，为您提供全品类、定制化的画稿创作服务，覆盖艺术创作、商业设计、教育需求等多个场景，满足您从个人兴趣到商业项目的各类画稿需求。我们的画稿服务类型丰富多元，无论是用于艺术创作的临摹性画稿、写生性画稿，还是为商业项目定制的创作性画稿，都能精准匹配您的需求。在艺术创作领域，我们可以为画家提供创作前期的推敲稿本，帮助您捕捉灵感、完善构图；在商业设计领域，我们能够承接游戏原画、广告插画、绘本画稿等定制需求，将品牌理念与创意视觉完美融合。同时，针对教育场景，我们还能提供适合临摹学习的标准化画稿，为艺术爱好者与学生提供专业的学习范本。为了保障服务质量与效率，我们建立了完善的服务流程。您只需提供具体需求与参考素材，我们的画师会在24小时内提供初步方案，您可享有2次免费修改机会，确保画稿完全符合您的预期。在交付周期上，常规画稿3-5天即可完成，加急订单最快30分钟出图，满足您的紧急需求。所有画稿均提供版权保障，商业项目画稿版权完全归您所有，让您无后顾之忧。我们坚持高性价比的定价策略，根据画稿类型、尺寸与复杂程度制定透明价格，无任何隐藏费用。A4尺寸基础画稿低至35元，商业定制画稿可根据需求提供详细报价。同时，我们支持手绘与板绘两种创作形式，无论是传统纸质画稿还是数字化电子画稿，都能为您呈现细腻生动的视觉效果。选择我们的画稿服务，不仅是选择一份专业的艺术创作，更是选择一个可靠的创意合作伙伴。我们将以严谨的创作态度、高效的服务流程，为您打造兼具艺术价值与实用功能的画稿作品，让每一份创意都能完美落地。 （AI生成）</p></div><p style=\"border: 0px; margin-top: 0.63em; margin-bottom: 1.8em; counter-reset: list-1 0 list-2 0 list-3 0 list-4 0 list-5 0 list-6 0 list-7 0 list-8 0 list-9 0; color: rgb(25, 25, 25); font-family: &quot;PingFang SC&quot;, Arial, 微软雅黑, 宋体, simsun, sans-serif;\"></p><p style=\"box-sizing: inherit; margin-top: 34px; margin-bottom: 34px; text-align: justify; color: rgb(64, 64, 64); font-family: Arial, &quot;Hiragino Sans GB&quot;, STHeiti, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft Yahei&quot;, &quot;WenQuanYi Micro Hei&quot;, sans-serif; font-size: 18px;\"></p>', '上架', '13', '审核成功', 1, '备注');
INSERT INTO `sys_huagao` VALUES (10, '画稿服务3', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', 20.00, '艺术创作类', '<div style=\"max-width: 100%; overflow-x: visible; font-size: 18px; line-height: 30px; color: rgb(34, 34, 34); font-family: arial;\"><p>专业画稿服务，定制您的艺术想象在艺术创作与商业设计的多元需求中，专业画稿服务正成为连接创意与现实的重要桥梁。我们依托经验丰富的画师团队，为您提供全品类、定制化的画稿创作服务，覆盖艺术创作、商业设计、教育需求等多个场景，满足您从个人兴趣到商业项目的各类画稿需求。我们的画稿服务类型丰富多元，无论是用于艺术创作的临摹性画稿、写生性画稿，还是为商业项目定制的创作性画稿，都能精准匹配您的需求。在艺术创作领域，我们可以为画家提供创作前期的推敲稿本，帮助您捕捉灵感、完善构图；在商业设计领域，我们能够承接游戏原画、广告插画、绘本画稿等定制需求，将品牌理念与创意视觉完美融合。同时，针对教育场景，我们还能提供适合临摹学习的标准化画稿，为艺术爱好者与学生提供专业的学习范本。为了保障服务质量与效率，我们建立了完善的服务流程。您只需提供具体需求与参考素材，我们的画师会在24小时内提供初步方案，您可享有2次免费修改机会，确保画稿完全符合您的预期。在交付周期上，常规画稿3-5天即可完成，加急订单最快30分钟出图，满足您的紧急需求。所有画稿均提供版权保障，商业项目画稿版权完全归您所有，让您无后顾之忧。我们坚持高性价比的定价策略，根据画稿类型、尺寸与复杂程度制定透明价格，无任何隐藏费用。A4尺寸基础画稿低至35元，商业定制画稿可根据需求提供详细报价。同时，我们支持手绘与板绘两种创作形式，无论是传统纸质画稿还是数字化电子画稿，都能为您呈现细腻生动的视觉效果。选择我们的画稿服务，不仅是选择一份专业的艺术创作，更是选择一个可靠的创意合作伙伴。我们将以严谨的创作态度、高效的服务流程，为您打造兼具艺术价值与实用功能的画稿作品，让每一份创意都能完美落地。 （AI生成）</p></div><p style=\"border: 0px; margin-top: 0.63em; margin-bottom: 1.8em; counter-reset: list-1 0 list-2 0 list-3 0 list-4 0 list-5 0 list-6 0 list-7 0 list-8 0 list-9 0; color: rgb(25, 25, 25); font-family: &quot;PingFang SC&quot;, Arial, 微软雅黑, 宋体, simsun, sans-serif;\"></p><p style=\"box-sizing: inherit; margin-top: 34px; margin-bottom: 34px; text-align: justify; color: rgb(64, 64, 64); font-family: Arial, &quot;Hiragino Sans GB&quot;, STHeiti, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft Yahei&quot;, &quot;WenQuanYi Micro Hei&quot;, sans-serif; font-size: 18px;\"></p>', '上架', '13', '审核成功', 1, '备注');
INSERT INTO `sys_huagao` VALUES (15, '画稿服务4', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', 20.00, '‌科学记录类‌', '<div style=\"max-width: 100%; overflow-x: visible; font-size: 18px; line-height: 30px; color: rgb(34, 34, 34); font-family: arial;\"><p>专业画稿服务，定制您的艺术想象在艺术创作与商业设计的多元需求中，专业画稿服务正成为连接创意与现实的重要桥梁。我们依托经验丰富的画师团队，为您提供全品类、定制化的画稿创作服务，覆盖艺术创作、商业设计、教育需求等多个场景，满足您从个人兴趣到商业项目的各类画稿需求。我们的画稿服务类型丰富多元，无论是用于艺术创作的临摹性画稿、写生性画稿，还是为商业项目定制的创作性画稿，都能精准匹配您的需求。在艺术创作领域，我们可以为画家提供创作前期的推敲稿本，帮助您捕捉灵感、完善构图；在商业设计领域，我们能够承接游戏原画、广告插画、绘本画稿等定制需求，将品牌理念与创意视觉完美融合。同时，针对教育场景，我们还能提供适合临摹学习的标准化画稿，为艺术爱好者与学生提供专业的学习范本。为了保障服务质量与效率，我们建立了完善的服务流程。您只需提供具体需求与参考素材，我们的画师会在24小时内提供初步方案，您可享有2次免费修改机会，确保画稿完全符合您的预期。在交付周期上，常规画稿3-5天即可完成，加急订单最快30分钟出图，满足您的紧急需求。所有画稿均提供版权保障，商业项目画稿版权完全归您所有，让您无后顾之忧。我们坚持高性价比的定价策略，根据画稿类型、尺寸与复杂程度制定透明价格，无任何隐藏费用。A4尺寸基础画稿低至35元，商业定制画稿可根据需求提供详细报价。同时，我们支持手绘与板绘两种创作形式，无论是传统纸质画稿还是数字化电子画稿，都能为您呈现细腻生动的视觉效果。选择我们的画稿服务，不仅是选择一份专业的艺术创作，更是选择一个可靠的创意合作伙伴。我们将以严谨的创作态度、高效的服务流程，为您打造兼具艺术价值与实用功能的画稿作品，让每一份创意都能完美落地。 （AI生成）</p></div><p style=\"border: 0px; margin-top: 0.63em; margin-bottom: 1.8em; counter-reset: list-1 0 list-2 0 list-3 0 list-4 0 list-5 0 list-6 0 list-7 0 list-8 0 list-9 0; color: rgb(25, 25, 25); font-family: &quot;PingFang SC&quot;, Arial, 微软雅黑, 宋体, simsun, sans-serif;\"></p><p style=\"box-sizing: inherit; margin-top: 34px; margin-bottom: 34px; text-align: justify; color: rgb(64, 64, 64); font-family: Arial, &quot;Hiragino Sans GB&quot;, STHeiti, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft Yahei&quot;, &quot;WenQuanYi Micro Hei&quot;, sans-serif; font-size: 18px;\"></p>', '上架', '13', '未审核', 1, '备注');

-- ----------------------------
-- Table structure for sys_liuyan
-- ----------------------------
DROP TABLE IF EXISTS `sys_liuyan`;
CREATE TABLE `sys_liuyan`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '内容',
  `result` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复内容',
  `userids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '留言人id',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '状态(已回复,未回复)',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_liuyan
-- ----------------------------
INSERT INTO `sys_liuyan` VALUES (12, '312321321', '12312321', '13', '已回复', '213', '321');

-- ----------------------------
-- Table structure for sys_liuyans
-- ----------------------------
DROP TABLE IF EXISTS `sys_liuyans`;
CREATE TABLE `sys_liuyans`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tsids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '岗位ids',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '留言内容',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '留言人姓名',
  `lydate` datetime(0) NULL DEFAULT NULL COMMENT '留言时间',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_liuyans
-- ----------------------------
INSERT INTO `sys_liuyans` VALUES (82, '36', '31312', '用户', '2026-03-19 15:30:22', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (83, '36', '{\"msgType\":\"image\",\"file\":null,\"name\":\"图片.jpg\"}', '用户', '2026-03-19 15:30:26', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (84, '36', '{\"msgType\":\"image\",\"file\":null,\"name\":\"图片.jpg\"}', '用户', '2026-03-19 15:30:50', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (85, '36', '{\"msgType\":\"file\",\"file\":null,\"name\":\"沈.pdf\"}', '用户', '2026-03-19 15:31:22', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (86, 'undefined', '{\"msgType\":\"image\",\"file\":\"97c8922dc42e47c8bb4c76678f0a937c.jpg\",\"name\":\"e9e63a409b3cbd0fabc7b50a589f3ac1.jpg\",\"url\":\"http://localhost:9999/oss/file/download?name=97c8922dc42e47c8bb4c76678f0a937c.jpg\"}', '管理员', '2026-03-19 15:46:24', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (87, '36', '{\"msgType\":\"image\",\"file\":\"3f0ff1b7f9ab4dd2aa8b0577f37d8e81.jpg\",\"name\":\"e9e63a409b3cbd0fabc7b50a589f3ac1.jpg\",\"url\":\"http://localhost:9999/oss/file/download?name=3f0ff1b7f9ab4dd2aa8b0577f37d8e81.jpg\"}', '管理员', '2026-03-19 15:46:40', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (88, '36', '{\"msgType\":\"file\",\"file\":\"659c101e226340e6b9a4ab03de33b53e.rar\",\"name\":\"wh01.rar\",\"url\":\"http://localhost:9999/oss/file/download?name=659c101e226340e6b9a4ab03de33b53e.rar\"}', '管理员', '2026-03-19 15:46:46', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (89, '37', '1231231', '用户', '2026-03-19 15:49:33', 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');
INSERT INTO `sys_liuyans` VALUES (90, '37', '1231231', '画师', '2026-03-19 15:49:41', 'http://localhost:9999/oss/file/download?name=7ac6c5e0-30ae-4b10-bd7e-ab22aaf8cf08.png');
INSERT INTO `sys_liuyans` VALUES (91, '37', '{\"msgType\":\"image\",\"file\":\"13b00d2affb445b4bc8d6e3be9072aff.jpg\",\"name\":\"图片.jpg\",\"url\":\"http://localhost:9999/oss/file/download?name=13b00d2affb445b4bc8d6e3be9072aff.jpg\"}', '画师', '2026-03-19 15:49:46', 'http://localhost:9999/oss/file/download?name=7ac6c5e0-30ae-4b10-bd7e-ab22aaf8cf08.png');
INSERT INTO `sys_liuyans` VALUES (92, '37', '{\"msgType\":\"file\",\"file\":\"beff81d2bb1e4bc2ac54045d78c1fcb7.docx\",\"name\":\"实习证明.docx\",\"url\":\"http://localhost:9999/oss/file/download?name=beff81d2bb1e4bc2ac54045d78c1fcb7.docx\"}', '画师', '2026-03-19 15:50:00', 'http://localhost:9999/oss/file/download?name=7ac6c5e0-30ae-4b10-bd7e-ab22aaf8cf08.png');

-- ----------------------------
-- Table structure for sys_lunbo
-- ----------------------------
DROP TABLE IF EXISTS `sys_lunbo`;
CREATE TABLE `sys_lunbo`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '轮播图名称',
  `lunbo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '轮播图地址',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_lunbo
-- ----------------------------
INSERT INTO `sys_lunbo` VALUES (2, NULL, 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo');
INSERT INTO `sys_lunbo` VALUES (4, NULL, 'https://img0.baidu.com/it/u=1613648223,1131306154&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=937');

-- ----------------------------
-- Table structure for sys_order
-- ----------------------------
DROP TABLE IF EXISTS `sys_order`;
CREATE TABLE `sys_order`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名字',
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格',
  `userids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户id',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `xddate` datetime(0) NULL DEFAULT NULL COMMENT '下单日期',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `spids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'id',
  `shangjiaids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'id',
  `pingjia` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价',
  `rydate` datetime(0) NULL DEFAULT NULL,
  `ryfs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `zhekou` int(0) NULL DEFAULT 0 COMMENT '折扣',
  `fujin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_order
-- ----------------------------
INSERT INTO `sys_order` VALUES (36, '画稿服务4', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', 19.00, '7', '用户', '123123123', '322@qq.com', '2026-03-19 00:00:00', '已付款', '15', '13', NULL, NULL, NULL, 1, '备注');
INSERT INTO `sys_order` VALUES (37, '画稿服务4', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', 19.00, '7', '用户', '123131', '23232@qq.com', '2026-03-19 00:00:00', '已评价', '15', '13', '10', NULL, NULL, 1, '备注');

-- ----------------------------
-- Table structure for sys_pinglun
-- ----------------------------
DROP TABLE IF EXISTS `sys_pinglun`;
CREATE TABLE `sys_pinglun`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `wzids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文章id',
  `plname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论人姓名',
  `pldate` datetime(0) NULL DEFAULT NULL COMMENT '评论日期',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论内容',
  `plpanids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论父id',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_pinglun
-- ----------------------------
INSERT INTO `sys_pinglun` VALUES (24, '9', '用户', '2026-03-19 15:50:51', '131321', NULL, 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg');

-- ----------------------------
-- Table structure for sys_rizhi
-- ----------------------------
DROP TABLE IF EXISTS `sys_rizhi`;
CREATE TABLE `sys_rizhi`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `rizhi` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '日志内容',
  `jldate` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7005 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_rizhi
-- ----------------------------
INSERT INTO `sys_rizhi` VALUES (7123, '\"请求访问时间:2026-03-19T15:00:07.510--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7124, '\"请求访问时间:2026-03-19T15:00:07.601--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7125, '\"请求访问时间:2026-03-19T15:00:07.604--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7126, '\"请求访问时间:2026-03-19T15:00:07.604--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7127, '\"请求访问时间:2026-03-19T15:00:07.604--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysShangpin/list操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7128, '\"请求访问时间:2026-03-19T15:00:07.618--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7129, '\"请求访问时间:2026-03-19T15:00:07.670--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/13操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7130, '\"请求访问时间:2026-03-19T15:00:07.704--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysShangpin/tuijianlist操作人id:13\"', '2026-03-19 15:00:08');
INSERT INTO `sys_rizhi` VALUES (7131, '\"请求访问时间:2026-03-19T15:01:07.102--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7132, '\"请求访问时间:2026-03-19T15:01:07.149--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7133, '\"请求访问时间:2026-03-19T15:01:07.151--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysShangpin/list操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7134, '\"请求访问时间:2026-03-19T15:01:07.151--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7135, '\"请求访问时间:2026-03-19T15:01:07.151--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7136, '\"请求访问时间:2026-03-19T15:01:07.171--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7137, '\"请求访问时间:2026-03-19T15:01:07.190--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/13操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7138, '\"请求访问时间:2026-03-19T15:01:07.209--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysShangpin/tuijianlist操作人id:13\"', '2026-03-19 15:01:07');
INSERT INTO `sys_rizhi` VALUES (7139, '\"请求访问时间:2026-03-19T15:03:10.547--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7140, '\"请求访问时间:2026-03-19T15:03:10.547--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7141, '\"请求访问时间:2026-03-19T15:03:10.547--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:13\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7142, '\"请求访问时间:2026-03-19T15:03:10.547--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7143, '\"请求访问时间:2026-03-19T15:03:10.548--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:1\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7144, '\"请求访问时间:2026-03-19T15:03:10.548--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:1\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7145, '\"请求访问时间:2026-03-19T15:03:10.565--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7146, '\"请求访问时间:2026-03-19T15:03:10.568--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7147, '\"请求访问时间:2026-03-19T15:03:10.572--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7148, '\"请求访问时间:2026-03-19T15:03:10.612--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/13操作人id:13\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7149, '\"请求访问时间:2026-03-19T15:03:10.616--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7150, '\"请求访问时间:2026-03-19T15:03:10.606--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/1操作人id:1\"', '2026-03-19 15:03:11');
INSERT INTO `sys_rizhi` VALUES (7151, '\"请求访问时间:2026-03-19T15:03:34.758--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7152, '\"请求访问时间:2026-03-19T15:03:34.759--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7153, '\"请求访问时间:2026-03-19T15:03:34.758--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7154, '\"请求访问时间:2026-03-19T15:03:35.061--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7155, '\"请求访问时间:2026-03-19T15:03:35.192--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7156, '\"请求访问时间:2026-03-19T15:03:35.290--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7157, '\"请求访问时间:2026-03-19T15:03:35.290--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7158, '\"请求访问时间:2026-03-19T15:03:35.293--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7159, '\"请求访问时间:2026-03-19T15:03:35.300--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/13操作人id:13\"', '2026-03-19 15:03:35');
INSERT INTO `sys_rizhi` VALUES (7160, '\"请求访问时间:2026-03-19T15:03:35.825--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7161, '\"请求访问时间:2026-03-19T15:03:36.036--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7162, '\"请求访问时间:2026-03-19T15:03:36.038--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7163, '\"请求访问时间:2026-03-19T15:03:36.038--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7164, '\"请求访问时间:2026-03-19T15:03:36.086--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7165, '\"请求访问时间:2026-03-19T15:03:36.140--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7166, '\"请求访问时间:2026-03-19T15:03:36.366--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:03:36');
INSERT INTO `sys_rizhi` VALUES (7167, '\"请求访问时间:2026-03-19T15:03:37.644--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:03:38');
INSERT INTO `sys_rizhi` VALUES (7168, '\"请求访问时间:2026-03-19T15:03:37.647--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:1\"', '2026-03-19 15:03:38');
INSERT INTO `sys_rizhi` VALUES (7169, '\"请求访问时间:2026-03-19T15:03:37.647--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:1\"', '2026-03-19 15:03:38');
INSERT INTO `sys_rizhi` VALUES (7170, '\"请求访问时间:2026-03-19T15:03:37.668--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:03:38');
INSERT INTO `sys_rizhi` VALUES (7171, '\"请求访问时间:2026-03-19T15:03:37.696--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/1操作人id:1\"', '2026-03-19 15:03:38');
INSERT INTO `sys_rizhi` VALUES (7172, '\"请求访问时间:2026-03-19T15:10:11.722--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:10:12');
INSERT INTO `sys_rizhi` VALUES (7173, '\"请求访问时间:2026-03-19T15:10:11.964--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:10:12');
INSERT INTO `sys_rizhi` VALUES (7174, '\"请求访问时间:2026-03-19T15:10:11.966--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:13\"', '2026-03-19 15:10:12');
INSERT INTO `sys_rizhi` VALUES (7175, '\"请求访问时间:2026-03-19T15:10:11.966--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:10:12');
INSERT INTO `sys_rizhi` VALUES (7176, '\"请求访问时间:2026-03-19T15:10:11.995--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:10:12');
INSERT INTO `sys_rizhi` VALUES (7177, '\"请求访问时间:2026-03-19T15:10:12.265--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/13操作人id:13\"', '2026-03-19 15:10:12');
INSERT INTO `sys_rizhi` VALUES (7178, '\"请求访问时间:2026-03-19T15:10:12.514--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7179, '\"请求访问时间:2026-03-19T15:10:12.760--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7180, '\"请求访问时间:2026-03-19T15:10:12.760--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7181, '\"请求访问时间:2026-03-19T15:10:12.759--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7182, '\"请求访问时间:2026-03-19T15:10:12.802--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7183, '\"请求访问时间:2026-03-19T15:10:12.848--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7184, '\"请求访问时间:2026-03-19T15:10:12.946--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:10:13');
INSERT INTO `sys_rizhi` VALUES (7185, '\"请求访问时间:2026-03-19T15:10:14.326--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:10:14');
INSERT INTO `sys_rizhi` VALUES (7186, '\"请求访问时间:2026-03-19T15:10:14.330--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:1\"', '2026-03-19 15:10:14');
INSERT INTO `sys_rizhi` VALUES (7187, '\"请求访问时间:2026-03-19T15:10:14.329--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:1\"', '2026-03-19 15:10:14');
INSERT INTO `sys_rizhi` VALUES (7188, '\"请求访问时间:2026-03-19T15:10:14.352--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:10:14');
INSERT INTO `sys_rizhi` VALUES (7189, '\"请求访问时间:2026-03-19T15:10:14.376--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/1操作人id:1\"', '2026-03-19 15:10:14');
INSERT INTO `sys_rizhi` VALUES (7190, '\"请求访问时间:2026-03-19T15:22:48.299--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7191, '\"请求访问时间:2026-03-19T15:22:48.886--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7192, '\"请求访问时间:2026-03-19T15:22:48.888--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7193, '\"请求访问时间:2026-03-19T15:22:48.891--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7194, '\"请求访问时间:2026-03-19T15:22:48.888--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7195, '\"请求访问时间:2026-03-19T15:22:48.947--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7196, '\"请求访问时间:2026-03-19T15:22:48.964--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/13操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7197, '\"请求访问时间:2026-03-19T15:22:49.014--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:13\"', '2026-03-19 15:22:49');
INSERT INTO `sys_rizhi` VALUES (7198, '\"请求访问时间:2026-03-19T15:22:49.722--操作人:服务者--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:22:50');
INSERT INTO `sys_rizhi` VALUES (7199, '\"请求访问时间:2026-03-19T15:22:52.281--操作人:服务者--请求方式:POST--请求url:http://localhost:9999/user/logout操作人id:13\"', '2026-03-19 15:22:52');
INSERT INTO `sys_rizhi` VALUES (7200, '\"请求访问时间:2026-03-19T15:22:55.640--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:22:56');
INSERT INTO `sys_rizhi` VALUES (7201, '\"请求访问时间:2026-03-19T15:22:57.385--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/all操作人id:1\"', '2026-03-19 15:22:57');
INSERT INTO `sys_rizhi` VALUES (7202, '\"请求访问时间:2026-03-19T15:22:57.385--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/list操作人id:1\"', '2026-03-19 15:22:57');
INSERT INTO `sys_rizhi` VALUES (7203, '\"请求访问时间:2026-03-19T15:22:59.255--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/getUserById/13操作人id:1\"', '2026-03-19 15:22:59');
INSERT INTO `sys_rizhi` VALUES (7204, '\"请求访问时间:2026-03-19T15:23:08.109--操作人:管理员--请求方式:PUT--请求url:http://localhost:9999/user/updateUser操作人id:1\"', '2026-03-19 15:23:08');
INSERT INTO `sys_rizhi` VALUES (7205, '\"请求访问时间:2026-03-19T15:23:08.183--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/list操作人id:1\"', '2026-03-19 15:23:08');
INSERT INTO `sys_rizhi` VALUES (7206, '\"请求访问时间:2026-03-19T15:23:09.863--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/menu/getAllMenu操作人id:1\"', '2026-03-19 15:23:10');
INSERT INTO `sys_rizhi` VALUES (7207, '\"请求访问时间:2026-03-19T15:23:09.863--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/list操作人id:1\"', '2026-03-19 15:23:10');
INSERT INTO `sys_rizhi` VALUES (7208, '\"请求访问时间:2026-03-19T15:23:11.039--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/getRoleById/7操作人id:1\"', '2026-03-19 15:23:11');
INSERT INTO `sys_rizhi` VALUES (7209, '\"请求访问时间:2026-03-19T15:23:16.157--操作人:管理员--请求方式:PUT--请求url:http://localhost:9999/role/updateRole操作人id:1\"', '2026-03-19 15:23:16');
INSERT INTO `sys_rizhi` VALUES (7210, '\"请求访问时间:2026-03-19T15:23:16.185--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/list操作人id:1\"', '2026-03-19 15:23:16');
INSERT INTO `sys_rizhi` VALUES (7211, '\"请求访问时间:2026-03-19T15:23:33.002--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:23:33');
INSERT INTO `sys_rizhi` VALUES (7212, '\"请求访问时间:2026-03-19T15:23:34.150--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/list操作人id:1\"', '2026-03-19 15:23:34');
INSERT INTO `sys_rizhi` VALUES (7213, '\"请求访问时间:2026-03-19T15:23:34.150--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/menu/getAllMenu操作人id:1\"', '2026-03-19 15:23:34');
INSERT INTO `sys_rizhi` VALUES (7214, '\"请求访问时间:2026-03-19T15:23:48.764--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:23:49');
INSERT INTO `sys_rizhi` VALUES (7215, '\"请求访问时间:2026-03-19T15:23:48.850--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:23:49');
INSERT INTO `sys_rizhi` VALUES (7216, '\"请求访问时间:2026-03-19T15:23:51.076--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:23:51');
INSERT INTO `sys_rizhi` VALUES (7217, '\"请求访问时间:2026-03-19T15:23:53.422--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:23:53');
INSERT INTO `sys_rizhi` VALUES (7218, '\"请求访问时间:2026-03-19T15:23:53.457--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:23:53');
INSERT INTO `sys_rizhi` VALUES (7219, '\"请求访问时间:2026-03-19T15:23:54.329--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:23:54');
INSERT INTO `sys_rizhi` VALUES (7220, '\"请求访问时间:2026-03-19T15:23:54.559--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:23:55');
INSERT INTO `sys_rizhi` VALUES (7221, '\"请求访问时间:2026-03-19T15:23:54.646--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:23:55');
INSERT INTO `sys_rizhi` VALUES (7222, '\"请求访问时间:2026-03-19T15:23:56.213--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:23:56');
INSERT INTO `sys_rizhi` VALUES (7223, '\"请求访问时间:2026-03-19T15:23:56.356--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:23:56');
INSERT INTO `sys_rizhi` VALUES (7224, '\"请求访问时间:2026-03-19T15:23:58.267--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:23:58');
INSERT INTO `sys_rizhi` VALUES (7225, '\"请求访问时间:2026-03-19T15:23:58.476--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/menu/getAllMenu操作人id:1\"', '2026-03-19 15:23:58');
INSERT INTO `sys_rizhi` VALUES (7226, '\"请求访问时间:2026-03-19T15:23:58.476--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/list操作人id:1\"', '2026-03-19 15:23:58');
INSERT INTO `sys_rizhi` VALUES (7227, '\"请求访问时间:2026-03-19T15:25:03.782--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:1\"', '2026-03-19 15:25:04');
INSERT INTO `sys_rizhi` VALUES (7228, '\"请求访问时间:2026-03-19T15:25:07.889--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/menu/getAllMenu操作人id:1\"', '2026-03-19 15:25:08');
INSERT INTO `sys_rizhi` VALUES (7229, '\"请求访问时间:2026-03-19T15:25:07.889--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/list操作人id:1\"', '2026-03-19 15:25:08');
INSERT INTO `sys_rizhi` VALUES (7230, '\"请求访问时间:2026-03-19T15:28:41.080--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:28:41');
INSERT INTO `sys_rizhi` VALUES (7231, '\"请求访问时间:2026-03-19T15:28:41.111--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:28:41');
INSERT INTO `sys_rizhi` VALUES (7232, '\"请求访问时间:2026-03-19T15:29:01.092--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7233, '\"请求访问时间:2026-03-19T15:29:01.106--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7234, '\"请求访问时间:2026-03-19T15:29:01.106--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7235, '\"请求访问时间:2026-03-19T15:29:01.106--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7236, '\"请求访问时间:2026-03-19T15:29:01.113--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7237, '\"请求访问时间:2026-03-19T15:29:01.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7238, '\"请求访问时间:2026-03-19T15:29:01.184--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:29:01');
INSERT INTO `sys_rizhi` VALUES (7239, '\"请求访问时间:2026-03-19T15:29:02.806--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7240, '\"请求访问时间:2026-03-19T15:29:02.993--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7241, '\"请求访问时间:2026-03-19T15:29:02.992--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7242, '\"请求访问时间:2026-03-19T15:29:02.993--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7243, '\"请求访问时间:2026-03-19T15:29:02.993--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7244, '\"请求访问时间:2026-03-19T15:29:03.022--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7245, '\"请求访问时间:2026-03-19T15:29:03.039--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7246, '\"请求访问时间:2026-03-19T15:29:03.102--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:29:03');
INSERT INTO `sys_rizhi` VALUES (7247, '\"请求访问时间:2026-03-19T15:29:03.708--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:04');
INSERT INTO `sys_rizhi` VALUES (7248, '\"请求访问时间:2026-03-19T15:29:03.727--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:04');
INSERT INTO `sys_rizhi` VALUES (7249, '\"请求访问时间:2026-03-19T15:29:03.747--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:29:04');
INSERT INTO `sys_rizhi` VALUES (7250, '\"请求访问时间:2026-03-19T15:29:18.595--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:19');
INSERT INTO `sys_rizhi` VALUES (7251, '\"请求访问时间:2026-03-19T15:29:20.428--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:20');
INSERT INTO `sys_rizhi` VALUES (7252, '\"请求访问时间:2026-03-19T15:29:20.444--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:29:20');
INSERT INTO `sys_rizhi` VALUES (7253, '\"请求访问时间:2026-03-19T15:29:22.029--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:22');
INSERT INTO `sys_rizhi` VALUES (7254, '\"请求访问时间:2026-03-19T15:29:22.047--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:29:22');
INSERT INTO `sys_rizhi` VALUES (7255, '\"请求访问时间:2026-03-19T15:29:28.392--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7256, '\"请求访问时间:2026-03-19T15:29:28.399--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7257, '\"请求访问时间:2026-03-19T15:29:28.399--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7258, '\"请求访问时间:2026-03-19T15:29:28.399--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7259, '\"请求访问时间:2026-03-19T15:29:28.414--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7260, '\"请求访问时间:2026-03-19T15:29:28.422--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7261, '\"请求访问时间:2026-03-19T15:29:28.441--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:29:28');
INSERT INTO `sys_rizhi` VALUES (7262, '\"请求访问时间:2026-03-19T15:29:56.801--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:57');
INSERT INTO `sys_rizhi` VALUES (7263, '\"请求访问时间:2026-03-19T15:29:56.823--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:29:57');
INSERT INTO `sys_rizhi` VALUES (7264, '\"请求访问时间:2026-03-19T15:29:56.842--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:29:57');
INSERT INTO `sys_rizhi` VALUES (7265, '\"请求访问时间:2026-03-19T15:30:07.659--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysOrder/add操作人id:7\"', '2026-03-19 15:30:08');
INSERT INTO `sys_rizhi` VALUES (7266, '\"请求访问时间:2026-03-19T15:30:07.726--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:08');
INSERT INTO `sys_rizhi` VALUES (7267, '\"请求访问时间:2026-03-19T15:30:07.754--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:30:08');
INSERT INTO `sys_rizhi` VALUES (7268, '\"请求访问时间:2026-03-19T15:30:08.445--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:30:08');
INSERT INTO `sys_rizhi` VALUES (7269, '\"请求访问时间:2026-03-19T15:30:09.136--操作人:用户--请求方式:POST--请求url:http://localhost:9999/order/alipay操作人id:7\"', '2026-03-19 15:30:09');
INSERT INTO `sys_rizhi` VALUES (7270, '\"请求访问时间:2026-03-19T15:30:09.136--操作人:用户--请求方式:PUT--请求url:http://localhost:9999/sysOrder/update操作人id:7\"', '2026-03-19 15:30:09');
INSERT INTO `sys_rizhi` VALUES (7271, '\"请求访问时间:2026-03-19T15:30:11.850--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7272, '\"请求访问时间:2026-03-19T15:30:11.858--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7273, '\"请求访问时间:2026-03-19T15:30:11.858--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7274, '\"请求访问时间:2026-03-19T15:30:11.858--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7275, '\"请求访问时间:2026-03-19T15:30:11.871--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7276, '\"请求访问时间:2026-03-19T15:30:11.875--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7277, '\"请求访问时间:2026-03-19T15:30:11.889--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:30:12');
INSERT INTO `sys_rizhi` VALUES (7278, '\"请求访问时间:2026-03-19T15:30:15.438--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:15');
INSERT INTO `sys_rizhi` VALUES (7279, '\"请求访问时间:2026-03-19T15:30:15.644--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7280, '\"请求访问时间:2026-03-19T15:30:15.644--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7281, '\"请求访问时间:2026-03-19T15:30:15.644--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7282, '\"请求访问时间:2026-03-19T15:30:15.644--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7283, '\"请求访问时间:2026-03-19T15:30:15.680--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7284, '\"请求访问时间:2026-03-19T15:30:15.716--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7285, '\"请求访问时间:2026-03-19T15:30:15.788--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:30:16');
INSERT INTO `sys_rizhi` VALUES (7286, '\"请求访问时间:2026-03-19T15:30:16.505--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:17');
INSERT INTO `sys_rizhi` VALUES (7287, '\"请求访问时间:2026-03-19T15:30:18.208--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:18');
INSERT INTO `sys_rizhi` VALUES (7288, '\"请求访问时间:2026-03-19T15:30:18.230--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:30:18');
INSERT INTO `sys_rizhi` VALUES (7289, '\"请求访问时间:2026-03-19T15:30:19.448--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:30:19');
INSERT INTO `sys_rizhi` VALUES (7290, '\"请求访问时间:2026-03-19T15:30:19.447--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:30:19');
INSERT INTO `sys_rizhi` VALUES (7291, '\"请求访问时间:2026-03-19T15:30:19.466--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:19');
INSERT INTO `sys_rizhi` VALUES (7292, '\"请求访问时间:2026-03-19T15:30:21.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:21');
INSERT INTO `sys_rizhi` VALUES (7293, '\"请求访问时间:2026-03-19T15:30:21.951--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:7\"', '2026-03-19 15:30:22');
INSERT INTO `sys_rizhi` VALUES (7294, '\"请求访问时间:2026-03-19T15:30:21.965--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:22');
INSERT INTO `sys_rizhi` VALUES (7295, '\"请求访问时间:2026-03-19T15:30:23.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:23');
INSERT INTO `sys_rizhi` VALUES (7296, '\"请求访问时间:2026-03-19T15:30:25.444--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:25');
INSERT INTO `sys_rizhi` VALUES (7297, '\"请求访问时间:2026-03-19T15:30:25.859--操作人:用户--请求方式:POST--请求url:http://localhost:9999/oss/file/upload操作人id:7\"', '2026-03-19 15:30:26');
INSERT INTO `sys_rizhi` VALUES (7298, '\"请求访问时间:2026-03-19T15:30:25.886--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:7\"', '2026-03-19 15:30:26');
INSERT INTO `sys_rizhi` VALUES (7299, '\"请求访问时间:2026-03-19T15:30:25.898--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:26');
INSERT INTO `sys_rizhi` VALUES (7300, '\"请求访问时间:2026-03-19T15:30:27.446--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:27');
INSERT INTO `sys_rizhi` VALUES (7301, '\"请求访问时间:2026-03-19T15:30:29.453--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:29');
INSERT INTO `sys_rizhi` VALUES (7302, '\"请求访问时间:2026-03-19T15:30:31.452--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:31');
INSERT INTO `sys_rizhi` VALUES (7303, '\"请求访问时间:2026-03-19T15:30:32.255--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:30:32');
INSERT INTO `sys_rizhi` VALUES (7304, '\"请求访问时间:2026-03-19T15:30:32.272--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:13\"', '2026-03-19 15:30:32');
INSERT INTO `sys_rizhi` VALUES (7305, '\"请求访问时间:2026-03-19T15:30:33.452--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:33');
INSERT INTO `sys_rizhi` VALUES (7306, '\"请求访问时间:2026-03-19T15:30:34.042--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:30:34');
INSERT INTO `sys_rizhi` VALUES (7307, '\"请求访问时间:2026-03-19T15:30:34.044--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:13\"', '2026-03-19 15:30:34');
INSERT INTO `sys_rizhi` VALUES (7308, '\"请求访问时间:2026-03-19T15:30:34.060--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:34');
INSERT INTO `sys_rizhi` VALUES (7309, '\"请求访问时间:2026-03-19T15:30:35.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:35');
INSERT INTO `sys_rizhi` VALUES (7310, '\"请求访问时间:2026-03-19T15:30:36.066--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:36');
INSERT INTO `sys_rizhi` VALUES (7311, '\"请求访问时间:2026-03-19T15:30:37.456--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:37');
INSERT INTO `sys_rizhi` VALUES (7312, '\"请求访问时间:2026-03-19T15:30:38.047--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:38');
INSERT INTO `sys_rizhi` VALUES (7313, '\"请求访问时间:2026-03-19T15:30:39.457--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:39');
INSERT INTO `sys_rizhi` VALUES (7314, '\"请求访问时间:2026-03-19T15:30:40.036--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:40');
INSERT INTO `sys_rizhi` VALUES (7315, '\"请求访问时间:2026-03-19T15:30:41.454--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:41');
INSERT INTO `sys_rizhi` VALUES (7316, '\"请求访问时间:2026-03-19T15:30:42.038--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:42');
INSERT INTO `sys_rizhi` VALUES (7317, '\"请求访问时间:2026-03-19T15:30:43.445--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:43');
INSERT INTO `sys_rizhi` VALUES (7318, '\"请求访问时间:2026-03-19T15:30:44.043--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:44');
INSERT INTO `sys_rizhi` VALUES (7319, '\"请求访问时间:2026-03-19T15:30:45.445--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:45');
INSERT INTO `sys_rizhi` VALUES (7320, '\"请求访问时间:2026-03-19T15:30:46.044--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:46');
INSERT INTO `sys_rizhi` VALUES (7321, '\"请求访问时间:2026-03-19T15:30:47.464--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:47');
INSERT INTO `sys_rizhi` VALUES (7322, '\"请求访问时间:2026-03-19T15:30:48.050--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:48');
INSERT INTO `sys_rizhi` VALUES (7323, '\"请求访问时间:2026-03-19T15:30:49.445--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:49');
INSERT INTO `sys_rizhi` VALUES (7324, '\"请求访问时间:2026-03-19T15:30:50.042--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:50');
INSERT INTO `sys_rizhi` VALUES (7325, '\"请求访问时间:2026-03-19T15:30:50.153--操作人:用户--请求方式:POST--请求url:http://localhost:9999/oss/file/upload操作人id:7\"', '2026-03-19 15:30:50');
INSERT INTO `sys_rizhi` VALUES (7326, '\"请求访问时间:2026-03-19T15:30:50.186--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:7\"', '2026-03-19 15:30:50');
INSERT INTO `sys_rizhi` VALUES (7327, '\"请求访问时间:2026-03-19T15:30:50.199--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:50');
INSERT INTO `sys_rizhi` VALUES (7328, '\"请求访问时间:2026-03-19T15:30:51.448--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:51');
INSERT INTO `sys_rizhi` VALUES (7329, '\"请求访问时间:2026-03-19T15:30:52.046--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:52');
INSERT INTO `sys_rizhi` VALUES (7330, '\"请求访问时间:2026-03-19T15:30:53.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:53');
INSERT INTO `sys_rizhi` VALUES (7331, '\"请求访问时间:2026-03-19T15:30:54.042--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:54');
INSERT INTO `sys_rizhi` VALUES (7332, '\"请求访问时间:2026-03-19T15:30:55.445--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:55');
INSERT INTO `sys_rizhi` VALUES (7333, '\"请求访问时间:2026-03-19T15:30:56.040--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:56');
INSERT INTO `sys_rizhi` VALUES (7334, '\"请求访问时间:2026-03-19T15:30:57.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:57');
INSERT INTO `sys_rizhi` VALUES (7335, '\"请求访问时间:2026-03-19T15:30:58.049--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:30:58');
INSERT INTO `sys_rizhi` VALUES (7336, '\"请求访问时间:2026-03-19T15:30:59.453--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:30:59');
INSERT INTO `sys_rizhi` VALUES (7337, '\"请求访问时间:2026-03-19T15:31:00.052--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:00');
INSERT INTO `sys_rizhi` VALUES (7338, '\"请求访问时间:2026-03-19T15:31:01.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:01');
INSERT INTO `sys_rizhi` VALUES (7339, '\"请求访问时间:2026-03-19T15:31:02.050--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:02');
INSERT INTO `sys_rizhi` VALUES (7340, '\"请求访问时间:2026-03-19T15:31:03.444--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:03');
INSERT INTO `sys_rizhi` VALUES (7341, '\"请求访问时间:2026-03-19T15:31:04.041--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:04');
INSERT INTO `sys_rizhi` VALUES (7342, '\"请求访问时间:2026-03-19T15:31:05.448--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:05');
INSERT INTO `sys_rizhi` VALUES (7343, '\"请求访问时间:2026-03-19T15:31:06.043--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:06');
INSERT INTO `sys_rizhi` VALUES (7344, '\"请求访问时间:2026-03-19T15:31:07.453--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:07');
INSERT INTO `sys_rizhi` VALUES (7345, '\"请求访问时间:2026-03-19T15:31:08.050--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:08');
INSERT INTO `sys_rizhi` VALUES (7346, '\"请求访问时间:2026-03-19T15:31:09.453--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:09');
INSERT INTO `sys_rizhi` VALUES (7347, '\"请求访问时间:2026-03-19T15:31:10.039--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:10');
INSERT INTO `sys_rizhi` VALUES (7348, '\"请求访问时间:2026-03-19T15:31:11.449--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:11');
INSERT INTO `sys_rizhi` VALUES (7349, '\"请求访问时间:2026-03-19T15:31:12.048--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:12');
INSERT INTO `sys_rizhi` VALUES (7350, '\"请求访问时间:2026-03-19T15:31:13.445--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:13');
INSERT INTO `sys_rizhi` VALUES (7351, '\"请求访问时间:2026-03-19T15:31:14.157--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:14');
INSERT INTO `sys_rizhi` VALUES (7352, '\"请求访问时间:2026-03-19T15:31:15.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:15');
INSERT INTO `sys_rizhi` VALUES (7353, '\"请求访问时间:2026-03-19T15:31:16.041--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:16');
INSERT INTO `sys_rizhi` VALUES (7354, '\"请求访问时间:2026-03-19T15:31:17.987--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:18');
INSERT INTO `sys_rizhi` VALUES (7355, '\"请求访问时间:2026-03-19T15:31:18.041--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:18');
INSERT INTO `sys_rizhi` VALUES (7356, '\"请求访问时间:2026-03-19T15:31:19.447--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:19');
INSERT INTO `sys_rizhi` VALUES (7357, '\"请求访问时间:2026-03-19T15:31:20.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:20');
INSERT INTO `sys_rizhi` VALUES (7358, '\"请求访问时间:2026-03-19T15:31:21.457--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:21');
INSERT INTO `sys_rizhi` VALUES (7359, '\"请求访问时间:2026-03-19T15:31:22.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:22');
INSERT INTO `sys_rizhi` VALUES (7360, '\"请求访问时间:2026-03-19T15:31:22.443--操作人:用户--请求方式:POST--请求url:http://localhost:9999/oss/file/upload操作人id:7\"', '2026-03-19 15:31:22');
INSERT INTO `sys_rizhi` VALUES (7361, '\"请求访问时间:2026-03-19T15:31:22.464--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:7\"', '2026-03-19 15:31:22');
INSERT INTO `sys_rizhi` VALUES (7362, '\"请求访问时间:2026-03-19T15:31:22.475--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:22');
INSERT INTO `sys_rizhi` VALUES (7363, '\"请求访问时间:2026-03-19T15:31:23.442--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:23');
INSERT INTO `sys_rizhi` VALUES (7364, '\"请求访问时间:2026-03-19T15:31:24.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:24');
INSERT INTO `sys_rizhi` VALUES (7365, '\"请求访问时间:2026-03-19T15:31:25.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:25');
INSERT INTO `sys_rizhi` VALUES (7366, '\"请求访问时间:2026-03-19T15:31:26.144--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:26');
INSERT INTO `sys_rizhi` VALUES (7367, '\"请求访问时间:2026-03-19T15:31:28.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:28');
INSERT INTO `sys_rizhi` VALUES (7368, '\"请求访问时间:2026-03-19T15:31:28.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:28');
INSERT INTO `sys_rizhi` VALUES (7369, '\"请求访问时间:2026-03-19T15:31:30.160--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:30');
INSERT INTO `sys_rizhi` VALUES (7370, '\"请求访问时间:2026-03-19T15:31:30.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:30');
INSERT INTO `sys_rizhi` VALUES (7371, '\"请求访问时间:2026-03-19T15:31:32.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:32');
INSERT INTO `sys_rizhi` VALUES (7372, '\"请求访问时间:2026-03-19T15:31:32.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:32');
INSERT INTO `sys_rizhi` VALUES (7373, '\"请求访问时间:2026-03-19T15:31:34.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:34');
INSERT INTO `sys_rizhi` VALUES (7374, '\"请求访问时间:2026-03-19T15:31:34.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:34');
INSERT INTO `sys_rizhi` VALUES (7375, '\"请求访问时间:2026-03-19T15:31:36.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:36');
INSERT INTO `sys_rizhi` VALUES (7376, '\"请求访问时间:2026-03-19T15:31:36.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:36');
INSERT INTO `sys_rizhi` VALUES (7377, '\"请求访问时间:2026-03-19T15:31:38.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:38');
INSERT INTO `sys_rizhi` VALUES (7378, '\"请求访问时间:2026-03-19T15:31:38.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:38');
INSERT INTO `sys_rizhi` VALUES (7379, '\"请求访问时间:2026-03-19T15:31:39.457--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:39');
INSERT INTO `sys_rizhi` VALUES (7380, '\"请求访问时间:2026-03-19T15:31:40.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:40');
INSERT INTO `sys_rizhi` VALUES (7381, '\"请求访问时间:2026-03-19T15:31:41.454--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:41');
INSERT INTO `sys_rizhi` VALUES (7382, '\"请求访问时间:2026-03-19T15:31:42.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:42');
INSERT INTO `sys_rizhi` VALUES (7383, '\"请求访问时间:2026-03-19T15:31:43.451--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:43');
INSERT INTO `sys_rizhi` VALUES (7384, '\"请求访问时间:2026-03-19T15:31:44.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:44');
INSERT INTO `sys_rizhi` VALUES (7385, '\"请求访问时间:2026-03-19T15:31:45.451--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:45');
INSERT INTO `sys_rizhi` VALUES (7386, '\"请求访问时间:2026-03-19T15:31:46.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:46');
INSERT INTO `sys_rizhi` VALUES (7387, '\"请求访问时间:2026-03-19T15:31:47.448--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:47');
INSERT INTO `sys_rizhi` VALUES (7388, '\"请求访问时间:2026-03-19T15:31:48.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:48');
INSERT INTO `sys_rizhi` VALUES (7389, '\"请求访问时间:2026-03-19T15:31:49.446--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:49');
INSERT INTO `sys_rizhi` VALUES (7390, '\"请求访问时间:2026-03-19T15:31:50.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:50');
INSERT INTO `sys_rizhi` VALUES (7391, '\"请求访问时间:2026-03-19T15:31:51.448--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:51');
INSERT INTO `sys_rizhi` VALUES (7392, '\"请求访问时间:2026-03-19T15:31:52.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:52');
INSERT INTO `sys_rizhi` VALUES (7393, '\"请求访问时间:2026-03-19T15:31:53.451--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:53');
INSERT INTO `sys_rizhi` VALUES (7394, '\"请求访问时间:2026-03-19T15:31:54.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:54');
INSERT INTO `sys_rizhi` VALUES (7395, '\"请求访问时间:2026-03-19T15:31:55.447--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:55');
INSERT INTO `sys_rizhi` VALUES (7396, '\"请求访问时间:2026-03-19T15:31:56.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:56');
INSERT INTO `sys_rizhi` VALUES (7397, '\"请求访问时间:2026-03-19T15:31:57.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:57');
INSERT INTO `sys_rizhi` VALUES (7398, '\"请求访问时间:2026-03-19T15:31:58.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:31:58');
INSERT INTO `sys_rizhi` VALUES (7399, '\"请求访问时间:2026-03-19T15:31:59.450--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:31:59');
INSERT INTO `sys_rizhi` VALUES (7400, '\"请求访问时间:2026-03-19T15:32:00.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:00');
INSERT INTO `sys_rizhi` VALUES (7401, '\"请求访问时间:2026-03-19T15:32:01.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:01');
INSERT INTO `sys_rizhi` VALUES (7402, '\"请求访问时间:2026-03-19T15:32:02.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:02');
INSERT INTO `sys_rizhi` VALUES (7403, '\"请求访问时间:2026-03-19T15:32:03.444--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:03');
INSERT INTO `sys_rizhi` VALUES (7404, '\"请求访问时间:2026-03-19T15:32:04.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:04');
INSERT INTO `sys_rizhi` VALUES (7405, '\"请求访问时间:2026-03-19T15:32:05.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:05');
INSERT INTO `sys_rizhi` VALUES (7406, '\"请求访问时间:2026-03-19T15:32:06.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:06');
INSERT INTO `sys_rizhi` VALUES (7407, '\"请求访问时间:2026-03-19T15:32:07.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:07');
INSERT INTO `sys_rizhi` VALUES (7408, '\"请求访问时间:2026-03-19T15:32:08.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:08');
INSERT INTO `sys_rizhi` VALUES (7409, '\"请求访问时间:2026-03-19T15:32:09.446--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:09');
INSERT INTO `sys_rizhi` VALUES (7410, '\"请求访问时间:2026-03-19T15:32:10.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:10');
INSERT INTO `sys_rizhi` VALUES (7411, '\"请求访问时间:2026-03-19T15:32:11.451--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:11');
INSERT INTO `sys_rizhi` VALUES (7412, '\"请求访问时间:2026-03-19T15:32:12.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:12');
INSERT INTO `sys_rizhi` VALUES (7413, '\"请求访问时间:2026-03-19T15:32:13.454--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:13');
INSERT INTO `sys_rizhi` VALUES (7414, '\"请求访问时间:2026-03-19T15:32:14.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:14');
INSERT INTO `sys_rizhi` VALUES (7415, '\"请求访问时间:2026-03-19T15:32:15.452--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:15');
INSERT INTO `sys_rizhi` VALUES (7416, '\"请求访问时间:2026-03-19T15:32:16.157--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:16');
INSERT INTO `sys_rizhi` VALUES (7417, '\"请求访问时间:2026-03-19T15:32:17.450--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:17');
INSERT INTO `sys_rizhi` VALUES (7418, '\"请求访问时间:2026-03-19T15:32:18.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:18');
INSERT INTO `sys_rizhi` VALUES (7419, '\"请求访问时间:2026-03-19T15:32:19.453--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:19');
INSERT INTO `sys_rizhi` VALUES (7420, '\"请求访问时间:2026-03-19T15:32:20.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:20');
INSERT INTO `sys_rizhi` VALUES (7421, '\"请求访问时间:2026-03-19T15:32:21.451--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:21');
INSERT INTO `sys_rizhi` VALUES (7422, '\"请求访问时间:2026-03-19T15:32:22.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:22');
INSERT INTO `sys_rizhi` VALUES (7423, '\"请求访问时间:2026-03-19T15:32:23.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:23');
INSERT INTO `sys_rizhi` VALUES (7424, '\"请求访问时间:2026-03-19T15:32:24.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:24');
INSERT INTO `sys_rizhi` VALUES (7425, '\"请求访问时间:2026-03-19T15:32:25.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:25');
INSERT INTO `sys_rizhi` VALUES (7426, '\"请求访问时间:2026-03-19T15:32:26.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:26');
INSERT INTO `sys_rizhi` VALUES (7427, '\"请求访问时间:2026-03-19T15:32:27.453--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:27');
INSERT INTO `sys_rizhi` VALUES (7428, '\"请求访问时间:2026-03-19T15:32:28.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:28');
INSERT INTO `sys_rizhi` VALUES (7429, '\"请求访问时间:2026-03-19T15:32:29.447--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:29');
INSERT INTO `sys_rizhi` VALUES (7430, '\"请求访问时间:2026-03-19T15:32:30.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:30');
INSERT INTO `sys_rizhi` VALUES (7431, '\"请求访问时间:2026-03-19T15:32:31.456--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:31');
INSERT INTO `sys_rizhi` VALUES (7432, '\"请求访问时间:2026-03-19T15:32:32.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:32');
INSERT INTO `sys_rizhi` VALUES (7433, '\"请求访问时间:2026-03-19T15:32:33.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:33');
INSERT INTO `sys_rizhi` VALUES (7434, '\"请求访问时间:2026-03-19T15:32:34.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:32:34');
INSERT INTO `sys_rizhi` VALUES (7435, '\"请求访问时间:2026-03-19T15:32:35.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:35');
INSERT INTO `sys_rizhi` VALUES (7436, '\"请求访问时间:2026-03-19T15:32:36.572--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:32:37');
INSERT INTO `sys_rizhi` VALUES (7437, '\"请求访问时间:2026-03-19T15:32:36.573--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:32:37');
INSERT INTO `sys_rizhi` VALUES (7438, '\"请求访问时间:2026-03-19T15:32:36.607--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:37');
INSERT INTO `sys_rizhi` VALUES (7439, '\"请求访问时间:2026-03-19T15:32:36.742--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:32:37');
INSERT INTO `sys_rizhi` VALUES (7440, '\"请求访问时间:2026-03-19T15:32:36.742--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:32:37');
INSERT INTO `sys_rizhi` VALUES (7441, '\"请求访问时间:2026-03-19T15:32:36.760--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:37');
INSERT INTO `sys_rizhi` VALUES (7442, '\"请求访问时间:2026-03-19T15:32:39.040--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:32:39');
INSERT INTO `sys_rizhi` VALUES (7443, '\"请求访问时间:2026-03-19T15:32:39.040--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:32:39');
INSERT INTO `sys_rizhi` VALUES (7444, '\"请求访问时间:2026-03-19T15:32:39.064--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:39');
INSERT INTO `sys_rizhi` VALUES (7445, '\"请求访问时间:2026-03-19T15:32:40.566--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:32:41');
INSERT INTO `sys_rizhi` VALUES (7446, '\"请求访问时间:2026-03-19T15:32:40.566--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:32:41');
INSERT INTO `sys_rizhi` VALUES (7447, '\"请求访问时间:2026-03-19T15:32:40.584--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:41');
INSERT INTO `sys_rizhi` VALUES (7448, '\"请求访问时间:2026-03-19T15:32:42.578--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:43');
INSERT INTO `sys_rizhi` VALUES (7449, '\"请求访问时间:2026-03-19T15:32:44.576--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:45');
INSERT INTO `sys_rizhi` VALUES (7450, '\"请求访问时间:2026-03-19T15:32:46.567--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:47');
INSERT INTO `sys_rizhi` VALUES (7451, '\"请求访问时间:2026-03-19T15:32:47.650--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:32:48');
INSERT INTO `sys_rizhi` VALUES (7452, '\"请求访问时间:2026-03-19T15:32:47.650--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:32:48');
INSERT INTO `sys_rizhi` VALUES (7453, '\"请求访问时间:2026-03-19T15:32:47.665--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:48');
INSERT INTO `sys_rizhi` VALUES (7454, '\"请求访问时间:2026-03-19T15:32:49.651--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:50');
INSERT INTO `sys_rizhi` VALUES (7455, '\"请求访问时间:2026-03-19T15:32:51.660--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:52');
INSERT INTO `sys_rizhi` VALUES (7456, '\"请求访问时间:2026-03-19T15:32:53.659--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:54');
INSERT INTO `sys_rizhi` VALUES (7457, '\"请求访问时间:2026-03-19T15:32:55.659--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:56');
INSERT INTO `sys_rizhi` VALUES (7458, '\"请求访问时间:2026-03-19T15:32:57.658--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:32:58');
INSERT INTO `sys_rizhi` VALUES (7459, '\"请求访问时间:2026-03-19T15:32:59.651--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:00');
INSERT INTO `sys_rizhi` VALUES (7460, '\"请求访问时间:2026-03-19T15:33:01.650--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:02');
INSERT INTO `sys_rizhi` VALUES (7461, '\"请求访问时间:2026-03-19T15:33:03.651--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:04');
INSERT INTO `sys_rizhi` VALUES (7462, '\"请求访问时间:2026-03-19T15:33:05.650--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:06');
INSERT INTO `sys_rizhi` VALUES (7463, '\"请求访问时间:2026-03-19T15:33:07.659--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:08');
INSERT INTO `sys_rizhi` VALUES (7464, '\"请求访问时间:2026-03-19T15:33:09.659--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:10');
INSERT INTO `sys_rizhi` VALUES (7465, '\"请求访问时间:2026-03-19T15:33:11.649--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:12');
INSERT INTO `sys_rizhi` VALUES (7466, '\"请求访问时间:2026-03-19T15:33:13.659--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:14');
INSERT INTO `sys_rizhi` VALUES (7467, '\"请求访问时间:2026-03-19T15:33:15.650--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:16');
INSERT INTO `sys_rizhi` VALUES (7468, '\"请求访问时间:2026-03-19T15:33:16.067--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:33:16');
INSERT INTO `sys_rizhi` VALUES (7469, '\"请求访问时间:2026-03-19T15:33:16.067--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:13\"', '2026-03-19 15:33:16');
INSERT INTO `sys_rizhi` VALUES (7470, '\"请求访问时间:2026-03-19T15:33:16.084--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:16');
INSERT INTO `sys_rizhi` VALUES (7471, '\"请求访问时间:2026-03-19T15:33:17.971--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:18');
INSERT INTO `sys_rizhi` VALUES (7472, '\"请求访问时间:2026-03-19T15:33:18.076--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:18');
INSERT INTO `sys_rizhi` VALUES (7473, '\"请求访问时间:2026-03-19T15:33:20.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:20');
INSERT INTO `sys_rizhi` VALUES (7474, '\"请求访问时间:2026-03-19T15:33:20.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:20');
INSERT INTO `sys_rizhi` VALUES (7475, '\"请求访问时间:2026-03-19T15:33:21.664--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:22');
INSERT INTO `sys_rizhi` VALUES (7476, '\"请求访问时间:2026-03-19T15:33:22.066--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:22');
INSERT INTO `sys_rizhi` VALUES (7477, '\"请求访问时间:2026-03-19T15:33:24.144--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:24');
INSERT INTO `sys_rizhi` VALUES (7478, '\"请求访问时间:2026-03-19T15:33:24.338--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:33:24');
INSERT INTO `sys_rizhi` VALUES (7479, '\"请求访问时间:2026-03-19T15:33:24.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:33:24');
INSERT INTO `sys_rizhi` VALUES (7480, '\"请求访问时间:2026-03-19T15:33:26.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:26');
INSERT INTO `sys_rizhi` VALUES (7481, '\"请求访问时间:2026-03-19T15:33:28.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:28');
INSERT INTO `sys_rizhi` VALUES (7482, '\"请求访问时间:2026-03-19T15:33:30.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:30');
INSERT INTO `sys_rizhi` VALUES (7483, '\"请求访问时间:2026-03-19T15:33:30.531--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:33:31');
INSERT INTO `sys_rizhi` VALUES (7484, '\"请求访问时间:2026-03-19T15:33:30.755--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:33:31');
INSERT INTO `sys_rizhi` VALUES (7485, '\"请求访问时间:2026-03-19T15:33:32.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:32');
INSERT INTO `sys_rizhi` VALUES (7486, '\"请求访问时间:2026-03-19T15:33:34.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:34');
INSERT INTO `sys_rizhi` VALUES (7487, '\"请求访问时间:2026-03-19T15:33:35.751--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:33:36');
INSERT INTO `sys_rizhi` VALUES (7488, '\"请求访问时间:2026-03-19T15:33:35.768--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:33:36');
INSERT INTO `sys_rizhi` VALUES (7489, '\"请求访问时间:2026-03-19T15:33:36.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:36');
INSERT INTO `sys_rizhi` VALUES (7490, '\"请求访问时间:2026-03-19T15:33:36.858--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:33:37');
INSERT INTO `sys_rizhi` VALUES (7491, '\"请求访问时间:2026-03-19T15:33:36.860--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:33:37');
INSERT INTO `sys_rizhi` VALUES (7492, '\"请求访问时间:2026-03-19T15:33:36.878--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:37');
INSERT INTO `sys_rizhi` VALUES (7493, '\"请求访问时间:2026-03-19T15:33:38.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:38');
INSERT INTO `sys_rizhi` VALUES (7494, '\"请求访问时间:2026-03-19T15:33:38.872--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:39');
INSERT INTO `sys_rizhi` VALUES (7495, '\"请求访问时间:2026-03-19T15:33:40.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:40');
INSERT INTO `sys_rizhi` VALUES (7496, '\"请求访问时间:2026-03-19T15:33:40.871--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:41');
INSERT INTO `sys_rizhi` VALUES (7497, '\"请求访问时间:2026-03-19T15:33:42.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:42');
INSERT INTO `sys_rizhi` VALUES (7498, '\"请求访问时间:2026-03-19T15:33:42.861--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:43');
INSERT INTO `sys_rizhi` VALUES (7499, '\"请求访问时间:2026-03-19T15:33:44.064--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:44');
INSERT INTO `sys_rizhi` VALUES (7500, '\"请求访问时间:2026-03-19T15:33:45.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:45');
INSERT INTO `sys_rizhi` VALUES (7501, '\"请求访问时间:2026-03-19T15:33:46.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:46');
INSERT INTO `sys_rizhi` VALUES (7502, '\"请求访问时间:2026-03-19T15:33:47.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:47');
INSERT INTO `sys_rizhi` VALUES (7503, '\"请求访问时间:2026-03-19T15:33:48.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:48');
INSERT INTO `sys_rizhi` VALUES (7504, '\"请求访问时间:2026-03-19T15:33:48.856--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:49');
INSERT INTO `sys_rizhi` VALUES (7505, '\"请求访问时间:2026-03-19T15:33:50.068--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:50');
INSERT INTO `sys_rizhi` VALUES (7506, '\"请求访问时间:2026-03-19T15:33:51.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:51');
INSERT INTO `sys_rizhi` VALUES (7507, '\"请求访问时间:2026-03-19T15:33:52.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:52');
INSERT INTO `sys_rizhi` VALUES (7508, '\"请求访问时间:2026-03-19T15:33:53.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:53');
INSERT INTO `sys_rizhi` VALUES (7509, '\"请求访问时间:2026-03-19T15:33:54.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:54');
INSERT INTO `sys_rizhi` VALUES (7510, '\"请求访问时间:2026-03-19T15:33:55.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:55');
INSERT INTO `sys_rizhi` VALUES (7511, '\"请求访问时间:2026-03-19T15:33:56.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:56');
INSERT INTO `sys_rizhi` VALUES (7512, '\"请求访问时间:2026-03-19T15:33:57.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:57');
INSERT INTO `sys_rizhi` VALUES (7513, '\"请求访问时间:2026-03-19T15:33:58.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:33:58');
INSERT INTO `sys_rizhi` VALUES (7514, '\"请求访问时间:2026-03-19T15:33:59.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:33:59');
INSERT INTO `sys_rizhi` VALUES (7515, '\"请求访问时间:2026-03-19T15:34:00.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:00');
INSERT INTO `sys_rizhi` VALUES (7516, '\"请求访问时间:2026-03-19T15:34:01.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:01');
INSERT INTO `sys_rizhi` VALUES (7517, '\"请求访问时间:2026-03-19T15:34:02.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:02');
INSERT INTO `sys_rizhi` VALUES (7518, '\"请求访问时间:2026-03-19T15:34:03.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:03');
INSERT INTO `sys_rizhi` VALUES (7519, '\"请求访问时间:2026-03-19T15:34:04.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:04');
INSERT INTO `sys_rizhi` VALUES (7520, '\"请求访问时间:2026-03-19T15:34:05.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:05');
INSERT INTO `sys_rizhi` VALUES (7521, '\"请求访问时间:2026-03-19T15:34:06.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:06');
INSERT INTO `sys_rizhi` VALUES (7522, '\"请求访问时间:2026-03-19T15:34:07.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:07');
INSERT INTO `sys_rizhi` VALUES (7523, '\"请求访问时间:2026-03-19T15:34:08.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:08');
INSERT INTO `sys_rizhi` VALUES (7524, '\"请求访问时间:2026-03-19T15:34:09.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:09');
INSERT INTO `sys_rizhi` VALUES (7525, '\"请求访问时间:2026-03-19T15:34:10.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:10');
INSERT INTO `sys_rizhi` VALUES (7526, '\"请求访问时间:2026-03-19T15:34:11.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:11');
INSERT INTO `sys_rizhi` VALUES (7527, '\"请求访问时间:2026-03-19T15:34:12.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:12');
INSERT INTO `sys_rizhi` VALUES (7528, '\"请求访问时间:2026-03-19T15:34:13.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:13');
INSERT INTO `sys_rizhi` VALUES (7529, '\"请求访问时间:2026-03-19T15:34:14.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:14');
INSERT INTO `sys_rizhi` VALUES (7530, '\"请求访问时间:2026-03-19T15:34:15.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:15');
INSERT INTO `sys_rizhi` VALUES (7531, '\"请求访问时间:2026-03-19T15:34:16.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:16');
INSERT INTO `sys_rizhi` VALUES (7532, '\"请求访问时间:2026-03-19T15:34:17.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:17');
INSERT INTO `sys_rizhi` VALUES (7533, '\"请求访问时间:2026-03-19T15:34:18.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:18');
INSERT INTO `sys_rizhi` VALUES (7534, '\"请求访问时间:2026-03-19T15:34:19.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:19');
INSERT INTO `sys_rizhi` VALUES (7535, '\"请求访问时间:2026-03-19T15:34:20.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:20');
INSERT INTO `sys_rizhi` VALUES (7536, '\"请求访问时间:2026-03-19T15:34:21.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:21');
INSERT INTO `sys_rizhi` VALUES (7537, '\"请求访问时间:2026-03-19T15:34:22.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:22');
INSERT INTO `sys_rizhi` VALUES (7538, '\"请求访问时间:2026-03-19T15:34:23.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:23');
INSERT INTO `sys_rizhi` VALUES (7539, '\"请求访问时间:2026-03-19T15:34:24.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:24');
INSERT INTO `sys_rizhi` VALUES (7540, '\"请求访问时间:2026-03-19T15:34:25.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:25');
INSERT INTO `sys_rizhi` VALUES (7541, '\"请求访问时间:2026-03-19T15:34:26.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:26');
INSERT INTO `sys_rizhi` VALUES (7542, '\"请求访问时间:2026-03-19T15:34:27.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:27');
INSERT INTO `sys_rizhi` VALUES (7543, '\"请求访问时间:2026-03-19T15:34:28.067--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:28');
INSERT INTO `sys_rizhi` VALUES (7544, '\"请求访问时间:2026-03-19T15:34:28.856--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:29');
INSERT INTO `sys_rizhi` VALUES (7545, '\"请求访问时间:2026-03-19T15:34:30.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:30');
INSERT INTO `sys_rizhi` VALUES (7546, '\"请求访问时间:2026-03-19T15:34:31.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:31');
INSERT INTO `sys_rizhi` VALUES (7547, '\"请求访问时间:2026-03-19T15:34:32.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:32');
INSERT INTO `sys_rizhi` VALUES (7548, '\"请求访问时间:2026-03-19T15:34:33.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:33');
INSERT INTO `sys_rizhi` VALUES (7549, '\"请求访问时间:2026-03-19T15:34:34.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:34');
INSERT INTO `sys_rizhi` VALUES (7550, '\"请求访问时间:2026-03-19T15:34:35.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:35');
INSERT INTO `sys_rizhi` VALUES (7551, '\"请求访问时间:2026-03-19T15:34:36.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:36');
INSERT INTO `sys_rizhi` VALUES (7552, '\"请求访问时间:2026-03-19T15:34:37.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:37');
INSERT INTO `sys_rizhi` VALUES (7553, '\"请求访问时间:2026-03-19T15:34:38.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:38');
INSERT INTO `sys_rizhi` VALUES (7554, '\"请求访问时间:2026-03-19T15:34:39.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:39');
INSERT INTO `sys_rizhi` VALUES (7555, '\"请求访问时间:2026-03-19T15:34:40.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:40');
INSERT INTO `sys_rizhi` VALUES (7556, '\"请求访问时间:2026-03-19T15:34:41.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:41');
INSERT INTO `sys_rizhi` VALUES (7557, '\"请求访问时间:2026-03-19T15:34:42.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:42');
INSERT INTO `sys_rizhi` VALUES (7558, '\"请求访问时间:2026-03-19T15:34:43.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:43');
INSERT INTO `sys_rizhi` VALUES (7559, '\"请求访问时间:2026-03-19T15:34:44.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:44');
INSERT INTO `sys_rizhi` VALUES (7560, '\"请求访问时间:2026-03-19T15:34:45.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:45');
INSERT INTO `sys_rizhi` VALUES (7561, '\"请求访问时间:2026-03-19T15:34:46.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:46');
INSERT INTO `sys_rizhi` VALUES (7562, '\"请求访问时间:2026-03-19T15:34:47.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:47');
INSERT INTO `sys_rizhi` VALUES (7563, '\"请求访问时间:2026-03-19T15:34:48.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:48');
INSERT INTO `sys_rizhi` VALUES (7564, '\"请求访问时间:2026-03-19T15:34:49.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:49');
INSERT INTO `sys_rizhi` VALUES (7565, '\"请求访问时间:2026-03-19T15:34:50.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:50');
INSERT INTO `sys_rizhi` VALUES (7566, '\"请求访问时间:2026-03-19T15:34:51.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:51');
INSERT INTO `sys_rizhi` VALUES (7567, '\"请求访问时间:2026-03-19T15:34:52.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:52');
INSERT INTO `sys_rizhi` VALUES (7568, '\"请求访问时间:2026-03-19T15:34:53.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:53');
INSERT INTO `sys_rizhi` VALUES (7569, '\"请求访问时间:2026-03-19T15:34:54.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:54');
INSERT INTO `sys_rizhi` VALUES (7570, '\"请求访问时间:2026-03-19T15:34:55.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:55');
INSERT INTO `sys_rizhi` VALUES (7571, '\"请求访问时间:2026-03-19T15:34:56.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:56');
INSERT INTO `sys_rizhi` VALUES (7572, '\"请求访问时间:2026-03-19T15:34:57.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:57');
INSERT INTO `sys_rizhi` VALUES (7573, '\"请求访问时间:2026-03-19T15:34:58.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:34:58');
INSERT INTO `sys_rizhi` VALUES (7574, '\"请求访问时间:2026-03-19T15:34:59.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:34:59');
INSERT INTO `sys_rizhi` VALUES (7575, '\"请求访问时间:2026-03-19T15:35:00.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:00');
INSERT INTO `sys_rizhi` VALUES (7576, '\"请求访问时间:2026-03-19T15:35:01.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:01');
INSERT INTO `sys_rizhi` VALUES (7577, '\"请求访问时间:2026-03-19T15:35:02.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:02');
INSERT INTO `sys_rizhi` VALUES (7578, '\"请求访问时间:2026-03-19T15:35:03.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:03');
INSERT INTO `sys_rizhi` VALUES (7579, '\"请求访问时间:2026-03-19T15:35:04.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:04');
INSERT INTO `sys_rizhi` VALUES (7580, '\"请求访问时间:2026-03-19T15:35:05.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:05');
INSERT INTO `sys_rizhi` VALUES (7581, '\"请求访问时间:2026-03-19T15:35:06.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:06');
INSERT INTO `sys_rizhi` VALUES (7582, '\"请求访问时间:2026-03-19T15:35:07.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:07');
INSERT INTO `sys_rizhi` VALUES (7583, '\"请求访问时间:2026-03-19T15:35:08.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:08');
INSERT INTO `sys_rizhi` VALUES (7584, '\"请求访问时间:2026-03-19T15:35:09.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:09');
INSERT INTO `sys_rizhi` VALUES (7585, '\"请求访问时间:2026-03-19T15:35:10.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:10');
INSERT INTO `sys_rizhi` VALUES (7586, '\"请求访问时间:2026-03-19T15:35:11.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:11');
INSERT INTO `sys_rizhi` VALUES (7587, '\"请求访问时间:2026-03-19T15:35:12.160--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:12');
INSERT INTO `sys_rizhi` VALUES (7588, '\"请求访问时间:2026-03-19T15:35:13.163--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:13');
INSERT INTO `sys_rizhi` VALUES (7589, '\"请求访问时间:2026-03-19T15:35:14.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:14');
INSERT INTO `sys_rizhi` VALUES (7590, '\"请求访问时间:2026-03-19T15:35:15.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:15');
INSERT INTO `sys_rizhi` VALUES (7591, '\"请求访问时间:2026-03-19T15:35:16.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:16');
INSERT INTO `sys_rizhi` VALUES (7592, '\"请求访问时间:2026-03-19T15:35:17.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:17');
INSERT INTO `sys_rizhi` VALUES (7593, '\"请求访问时间:2026-03-19T15:35:18.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:18');
INSERT INTO `sys_rizhi` VALUES (7594, '\"请求访问时间:2026-03-19T15:35:19.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:19');
INSERT INTO `sys_rizhi` VALUES (7595, '\"请求访问时间:2026-03-19T15:35:20.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:20');
INSERT INTO `sys_rizhi` VALUES (7596, '\"请求访问时间:2026-03-19T15:35:21.144--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:21');
INSERT INTO `sys_rizhi` VALUES (7597, '\"请求访问时间:2026-03-19T15:35:22.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:22');
INSERT INTO `sys_rizhi` VALUES (7598, '\"请求访问时间:2026-03-19T15:35:23.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:23');
INSERT INTO `sys_rizhi` VALUES (7599, '\"请求访问时间:2026-03-19T15:35:24.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:24');
INSERT INTO `sys_rizhi` VALUES (7600, '\"请求访问时间:2026-03-19T15:35:25.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:25');
INSERT INTO `sys_rizhi` VALUES (7601, '\"请求访问时间:2026-03-19T15:35:26.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:26');
INSERT INTO `sys_rizhi` VALUES (7602, '\"请求访问时间:2026-03-19T15:35:27.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:27');
INSERT INTO `sys_rizhi` VALUES (7603, '\"请求访问时间:2026-03-19T15:35:28.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:28');
INSERT INTO `sys_rizhi` VALUES (7604, '\"请求访问时间:2026-03-19T15:35:29.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:29');
INSERT INTO `sys_rizhi` VALUES (7605, '\"请求访问时间:2026-03-19T15:35:52.160--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:35:52');
INSERT INTO `sys_rizhi` VALUES (7606, '\"请求访问时间:2026-03-19T15:35:52.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:35:52');
INSERT INTO `sys_rizhi` VALUES (7607, '\"请求访问时间:2026-03-19T15:37:01.937--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:13\"', '2026-03-19 15:37:02');
INSERT INTO `sys_rizhi` VALUES (7608, '\"请求访问时间:2026-03-19T15:37:01.937--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:37:02');
INSERT INTO `sys_rizhi` VALUES (7609, '\"请求访问时间:2026-03-19T15:37:01.957--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:02');
INSERT INTO `sys_rizhi` VALUES (7610, '\"请求访问时间:2026-03-19T15:37:01.967--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:37:02');
INSERT INTO `sys_rizhi` VALUES (7611, '\"请求访问时间:2026-03-19T15:37:01.968--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:37:02');
INSERT INTO `sys_rizhi` VALUES (7612, '\"请求访问时间:2026-03-19T15:37:01.988--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:02');
INSERT INTO `sys_rizhi` VALUES (7613, '\"请求访问时间:2026-03-19T15:37:04.022--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:37:04');
INSERT INTO `sys_rizhi` VALUES (7614, '\"请求访问时间:2026-03-19T15:37:04.040--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:37:04');
INSERT INTO `sys_rizhi` VALUES (7615, '\"请求访问时间:2026-03-19T15:37:04.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:04');
INSERT INTO `sys_rizhi` VALUES (7616, '\"请求访问时间:2026-03-19T15:37:04.814--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:37:05');
INSERT INTO `sys_rizhi` VALUES (7617, '\"请求访问时间:2026-03-19T15:37:05.113--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:37:05');
INSERT INTO `sys_rizhi` VALUES (7618, '\"请求访问时间:2026-03-19T15:37:05.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:37:05');
INSERT INTO `sys_rizhi` VALUES (7619, '\"请求访问时间:2026-03-19T15:37:06.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:06');
INSERT INTO `sys_rizhi` VALUES (7620, '\"请求访问时间:2026-03-19T15:37:06.605--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:37:07');
INSERT INTO `sys_rizhi` VALUES (7621, '\"请求访问时间:2026-03-19T15:37:06.606--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:37:07');
INSERT INTO `sys_rizhi` VALUES (7622, '\"请求访问时间:2026-03-19T15:37:06.622--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:07');
INSERT INTO `sys_rizhi` VALUES (7623, '\"请求访问时间:2026-03-19T15:37:08.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:08');
INSERT INTO `sys_rizhi` VALUES (7624, '\"请求访问时间:2026-03-19T15:37:08.609--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:09');
INSERT INTO `sys_rizhi` VALUES (7625, '\"请求访问时间:2026-03-19T15:37:10.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:10');
INSERT INTO `sys_rizhi` VALUES (7626, '\"请求访问时间:2026-03-19T15:37:10.605--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:11');
INSERT INTO `sys_rizhi` VALUES (7627, '\"请求访问时间:2026-03-19T15:37:12.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:12');
INSERT INTO `sys_rizhi` VALUES (7628, '\"请求访问时间:2026-03-19T15:37:12.609--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:13');
INSERT INTO `sys_rizhi` VALUES (7629, '\"请求访问时间:2026-03-19T15:37:14.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:14');
INSERT INTO `sys_rizhi` VALUES (7630, '\"请求访问时间:2026-03-19T15:37:15.038--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:15');
INSERT INTO `sys_rizhi` VALUES (7631, '\"请求访问时间:2026-03-19T15:37:16.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:16');
INSERT INTO `sys_rizhi` VALUES (7632, '\"请求访问时间:2026-03-19T15:37:16.618--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:17');
INSERT INTO `sys_rizhi` VALUES (7633, '\"请求访问时间:2026-03-19T15:37:18.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:18');
INSERT INTO `sys_rizhi` VALUES (7634, '\"请求访问时间:2026-03-19T15:37:18.601--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:19');
INSERT INTO `sys_rizhi` VALUES (7635, '\"请求访问时间:2026-03-19T15:37:19.942--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:20');
INSERT INTO `sys_rizhi` VALUES (7636, '\"请求访问时间:2026-03-19T15:37:21.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:21');
INSERT INTO `sys_rizhi` VALUES (7637, '\"请求访问时间:2026-03-19T15:37:21.945--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:22');
INSERT INTO `sys_rizhi` VALUES (7638, '\"请求访问时间:2026-03-19T15:37:22.618--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:23');
INSERT INTO `sys_rizhi` VALUES (7639, '\"请求访问时间:2026-03-19T15:37:23.938--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:24');
INSERT INTO `sys_rizhi` VALUES (7640, '\"请求访问时间:2026-03-19T15:37:24.611--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:25');
INSERT INTO `sys_rizhi` VALUES (7641, '\"请求访问时间:2026-03-19T15:37:25.938--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:26');
INSERT INTO `sys_rizhi` VALUES (7642, '\"请求访问时间:2026-03-19T15:37:26.613--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:27');
INSERT INTO `sys_rizhi` VALUES (7643, '\"请求访问时间:2026-03-19T15:37:27.947--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:28');
INSERT INTO `sys_rizhi` VALUES (7644, '\"请求访问时间:2026-03-19T15:37:28.606--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:29');
INSERT INTO `sys_rizhi` VALUES (7645, '\"请求访问时间:2026-03-19T15:37:30.144--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:30');
INSERT INTO `sys_rizhi` VALUES (7646, '\"请求访问时间:2026-03-19T15:37:31.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:31');
INSERT INTO `sys_rizhi` VALUES (7647, '\"请求访问时间:2026-03-19T15:37:32.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:32');
INSERT INTO `sys_rizhi` VALUES (7648, '\"请求访问时间:2026-03-19T15:37:33.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:33');
INSERT INTO `sys_rizhi` VALUES (7649, '\"请求访问时间:2026-03-19T15:37:34.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:34');
INSERT INTO `sys_rizhi` VALUES (7650, '\"请求访问时间:2026-03-19T15:37:35.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:35');
INSERT INTO `sys_rizhi` VALUES (7651, '\"请求访问时间:2026-03-19T15:37:36.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:36');
INSERT INTO `sys_rizhi` VALUES (7652, '\"请求访问时间:2026-03-19T15:37:37.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:37');
INSERT INTO `sys_rizhi` VALUES (7653, '\"请求访问时间:2026-03-19T15:37:38.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:38');
INSERT INTO `sys_rizhi` VALUES (7654, '\"请求访问时间:2026-03-19T15:37:39.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:39');
INSERT INTO `sys_rizhi` VALUES (7655, '\"请求访问时间:2026-03-19T15:37:40.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:40');
INSERT INTO `sys_rizhi` VALUES (7656, '\"请求访问时间:2026-03-19T15:37:41.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:41');
INSERT INTO `sys_rizhi` VALUES (7657, '\"请求访问时间:2026-03-19T15:37:42.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:42');
INSERT INTO `sys_rizhi` VALUES (7658, '\"请求访问时间:2026-03-19T15:37:43.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:43');
INSERT INTO `sys_rizhi` VALUES (7659, '\"请求访问时间:2026-03-19T15:37:44.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:44');
INSERT INTO `sys_rizhi` VALUES (7660, '\"请求访问时间:2026-03-19T15:37:45.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:45');
INSERT INTO `sys_rizhi` VALUES (7661, '\"请求访问时间:2026-03-19T15:37:46.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:46');
INSERT INTO `sys_rizhi` VALUES (7662, '\"请求访问时间:2026-03-19T15:37:47.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:47');
INSERT INTO `sys_rizhi` VALUES (7663, '\"请求访问时间:2026-03-19T15:37:48.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:48');
INSERT INTO `sys_rizhi` VALUES (7664, '\"请求访问时间:2026-03-19T15:37:49.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:49');
INSERT INTO `sys_rizhi` VALUES (7665, '\"请求访问时间:2026-03-19T15:37:50.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:50');
INSERT INTO `sys_rizhi` VALUES (7666, '\"请求访问时间:2026-03-19T15:37:51.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:51');
INSERT INTO `sys_rizhi` VALUES (7667, '\"请求访问时间:2026-03-19T15:37:52.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:52');
INSERT INTO `sys_rizhi` VALUES (7668, '\"请求访问时间:2026-03-19T15:37:53.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:53');
INSERT INTO `sys_rizhi` VALUES (7669, '\"请求访问时间:2026-03-19T15:37:54.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:54');
INSERT INTO `sys_rizhi` VALUES (7670, '\"请求访问时间:2026-03-19T15:37:55.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:55');
INSERT INTO `sys_rizhi` VALUES (7671, '\"请求访问时间:2026-03-19T15:37:56.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:56');
INSERT INTO `sys_rizhi` VALUES (7672, '\"请求访问时间:2026-03-19T15:37:57.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:57');
INSERT INTO `sys_rizhi` VALUES (7673, '\"请求访问时间:2026-03-19T15:37:58.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:37:58');
INSERT INTO `sys_rizhi` VALUES (7674, '\"请求访问时间:2026-03-19T15:37:59.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:37:59');
INSERT INTO `sys_rizhi` VALUES (7675, '\"请求访问时间:2026-03-19T15:38:00.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:00');
INSERT INTO `sys_rizhi` VALUES (7676, '\"请求访问时间:2026-03-19T15:38:01.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:01');
INSERT INTO `sys_rizhi` VALUES (7677, '\"请求访问时间:2026-03-19T15:38:02.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:02');
INSERT INTO `sys_rizhi` VALUES (7678, '\"请求访问时间:2026-03-19T15:38:03.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:03');
INSERT INTO `sys_rizhi` VALUES (7679, '\"请求访问时间:2026-03-19T15:38:04.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:04');
INSERT INTO `sys_rizhi` VALUES (7680, '\"请求访问时间:2026-03-19T15:38:05.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:05');
INSERT INTO `sys_rizhi` VALUES (7681, '\"请求访问时间:2026-03-19T15:38:06.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:06');
INSERT INTO `sys_rizhi` VALUES (7682, '\"请求访问时间:2026-03-19T15:38:07.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:07');
INSERT INTO `sys_rizhi` VALUES (7683, '\"请求访问时间:2026-03-19T15:38:08.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:08');
INSERT INTO `sys_rizhi` VALUES (7684, '\"请求访问时间:2026-03-19T15:38:09.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:09');
INSERT INTO `sys_rizhi` VALUES (7685, '\"请求访问时间:2026-03-19T15:38:10.144--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:10');
INSERT INTO `sys_rizhi` VALUES (7686, '\"请求访问时间:2026-03-19T15:38:11.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:11');
INSERT INTO `sys_rizhi` VALUES (7687, '\"请求访问时间:2026-03-19T15:38:12.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:12');
INSERT INTO `sys_rizhi` VALUES (7688, '\"请求访问时间:2026-03-19T15:38:13.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:13');
INSERT INTO `sys_rizhi` VALUES (7689, '\"请求访问时间:2026-03-19T15:38:14.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:14');
INSERT INTO `sys_rizhi` VALUES (7690, '\"请求访问时间:2026-03-19T15:38:15.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:15');
INSERT INTO `sys_rizhi` VALUES (7691, '\"请求访问时间:2026-03-19T15:38:16.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:16');
INSERT INTO `sys_rizhi` VALUES (7692, '\"请求访问时间:2026-03-19T15:38:17.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:17');
INSERT INTO `sys_rizhi` VALUES (7693, '\"请求访问时间:2026-03-19T15:38:18.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:18');
INSERT INTO `sys_rizhi` VALUES (7694, '\"请求访问时间:2026-03-19T15:38:19.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:19');
INSERT INTO `sys_rizhi` VALUES (7695, '\"请求访问时间:2026-03-19T15:38:20.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:20');
INSERT INTO `sys_rizhi` VALUES (7696, '\"请求访问时间:2026-03-19T15:38:21.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:21');
INSERT INTO `sys_rizhi` VALUES (7697, '\"请求访问时间:2026-03-19T15:38:22.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:22');
INSERT INTO `sys_rizhi` VALUES (7698, '\"请求访问时间:2026-03-19T15:38:23.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:23');
INSERT INTO `sys_rizhi` VALUES (7699, '\"请求访问时间:2026-03-19T15:38:24.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:24');
INSERT INTO `sys_rizhi` VALUES (7700, '\"请求访问时间:2026-03-19T15:38:25.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:25');
INSERT INTO `sys_rizhi` VALUES (7701, '\"请求访问时间:2026-03-19T15:38:26.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:26');
INSERT INTO `sys_rizhi` VALUES (7702, '\"请求访问时间:2026-03-19T15:38:27.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:27');
INSERT INTO `sys_rizhi` VALUES (7703, '\"请求访问时间:2026-03-19T15:38:28.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:28');
INSERT INTO `sys_rizhi` VALUES (7704, '\"请求访问时间:2026-03-19T15:38:29.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:29');
INSERT INTO `sys_rizhi` VALUES (7705, '\"请求访问时间:2026-03-19T15:38:52.157--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:38:52');
INSERT INTO `sys_rizhi` VALUES (7706, '\"请求访问时间:2026-03-19T15:38:52.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:38:52');
INSERT INTO `sys_rizhi` VALUES (7707, '\"请求访问时间:2026-03-19T15:39:52.160--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:39:52');
INSERT INTO `sys_rizhi` VALUES (7708, '\"请求访问时间:2026-03-19T15:39:52.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:39:52');
INSERT INTO `sys_rizhi` VALUES (7709, '\"请求访问时间:2026-03-19T15:40:34.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:34');
INSERT INTO `sys_rizhi` VALUES (7710, '\"请求访问时间:2026-03-19T15:40:34.162--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:40:34');
INSERT INTO `sys_rizhi` VALUES (7711, '\"请求访问时间:2026-03-19T15:40:34.201--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:34');
INSERT INTO `sys_rizhi` VALUES (7712, '\"请求访问时间:2026-03-19T15:40:34.586--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:40:35');
INSERT INTO `sys_rizhi` VALUES (7713, '\"请求访问时间:2026-03-19T15:40:34.587--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:13\"', '2026-03-19 15:40:35');
INSERT INTO `sys_rizhi` VALUES (7714, '\"请求访问时间:2026-03-19T15:40:34.607--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:35');
INSERT INTO `sys_rizhi` VALUES (7715, '\"请求访问时间:2026-03-19T15:40:36.144--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:36');
INSERT INTO `sys_rizhi` VALUES (7716, '\"请求访问时间:2026-03-19T15:40:36.756--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:37');
INSERT INTO `sys_rizhi` VALUES (7717, '\"请求访问时间:2026-03-19T15:40:36.830--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:40:37');
INSERT INTO `sys_rizhi` VALUES (7718, '\"请求访问时间:2026-03-19T15:40:37.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:37');
INSERT INTO `sys_rizhi` VALUES (7719, '\"请求访问时间:2026-03-19T15:40:38.051--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:38');
INSERT INTO `sys_rizhi` VALUES (7720, '\"请求访问时间:2026-03-19T15:40:38.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:38');
INSERT INTO `sys_rizhi` VALUES (7721, '\"请求访问时间:2026-03-19T15:40:38.236--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:40:38');
INSERT INTO `sys_rizhi` VALUES (7722, '\"请求访问时间:2026-03-19T15:40:39.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:39');
INSERT INTO `sys_rizhi` VALUES (7723, '\"请求访问时间:2026-03-19T15:40:40.416--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:40');
INSERT INTO `sys_rizhi` VALUES (7724, '\"请求访问时间:2026-03-19T15:40:40.492--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:41');
INSERT INTO `sys_rizhi` VALUES (7725, '\"请求访问时间:2026-03-19T15:40:40.694--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:40:41');
INSERT INTO `sys_rizhi` VALUES (7726, '\"请求访问时间:2026-03-19T15:40:41.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:41');
INSERT INTO `sys_rizhi` VALUES (7727, '\"请求访问时间:2026-03-19T15:40:42.330--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:40:42');
INSERT INTO `sys_rizhi` VALUES (7728, '\"请求访问时间:2026-03-19T15:40:42.331--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:40:42');
INSERT INTO `sys_rizhi` VALUES (7729, '\"请求访问时间:2026-03-19T15:40:42.347--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:42');
INSERT INTO `sys_rizhi` VALUES (7730, '\"请求访问时间:2026-03-19T15:40:43.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:43');
INSERT INTO `sys_rizhi` VALUES (7731, '\"请求访问时间:2026-03-19T15:40:44.335--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:44');
INSERT INTO `sys_rizhi` VALUES (7732, '\"请求访问时间:2026-03-19T15:40:45.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:45');
INSERT INTO `sys_rizhi` VALUES (7733, '\"请求访问时间:2026-03-19T15:40:46.327--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:46');
INSERT INTO `sys_rizhi` VALUES (7734, '\"请求访问时间:2026-03-19T15:40:47.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:47');
INSERT INTO `sys_rizhi` VALUES (7735, '\"请求访问时间:2026-03-19T15:40:48.330--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:48');
INSERT INTO `sys_rizhi` VALUES (7736, '\"请求访问时间:2026-03-19T15:40:49.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:49');
INSERT INTO `sys_rizhi` VALUES (7737, '\"请求访问时间:2026-03-19T15:40:51.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:51');
INSERT INTO `sys_rizhi` VALUES (7738, '\"请求访问时间:2026-03-19T15:40:51.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:51');
INSERT INTO `sys_rizhi` VALUES (7739, '\"请求访问时间:2026-03-19T15:40:53.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:53');
INSERT INTO `sys_rizhi` VALUES (7740, '\"请求访问时间:2026-03-19T15:40:53.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:53');
INSERT INTO `sys_rizhi` VALUES (7741, '\"请求访问时间:2026-03-19T15:40:55.157--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:55');
INSERT INTO `sys_rizhi` VALUES (7742, '\"请求访问时间:2026-03-19T15:40:55.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:55');
INSERT INTO `sys_rizhi` VALUES (7743, '\"请求访问时间:2026-03-19T15:40:57.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:57');
INSERT INTO `sys_rizhi` VALUES (7744, '\"请求访问时间:2026-03-19T15:40:57.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:57');
INSERT INTO `sys_rizhi` VALUES (7745, '\"请求访问时间:2026-03-19T15:40:58.329--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:40:58');
INSERT INTO `sys_rizhi` VALUES (7746, '\"请求访问时间:2026-03-19T15:40:59.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:40:59');
INSERT INTO `sys_rizhi` VALUES (7747, '\"请求访问时间:2026-03-19T15:41:00.329--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:00');
INSERT INTO `sys_rizhi` VALUES (7748, '\"请求访问时间:2026-03-19T15:41:01.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:01');
INSERT INTO `sys_rizhi` VALUES (7749, '\"请求访问时间:2026-03-19T15:41:03.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:03');
INSERT INTO `sys_rizhi` VALUES (7750, '\"请求访问时间:2026-03-19T15:41:03.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:03');
INSERT INTO `sys_rizhi` VALUES (7751, '\"请求访问时间:2026-03-19T15:41:05.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:05');
INSERT INTO `sys_rizhi` VALUES (7752, '\"请求访问时间:2026-03-19T15:41:05.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:05');
INSERT INTO `sys_rizhi` VALUES (7753, '\"请求访问时间:2026-03-19T15:41:07.154--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:07');
INSERT INTO `sys_rizhi` VALUES (7754, '\"请求访问时间:2026-03-19T15:41:07.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:07');
INSERT INTO `sys_rizhi` VALUES (7755, '\"请求访问时间:2026-03-19T15:41:09.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:09');
INSERT INTO `sys_rizhi` VALUES (7756, '\"请求访问时间:2026-03-19T15:41:09.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:09');
INSERT INTO `sys_rizhi` VALUES (7757, '\"请求访问时间:2026-03-19T15:41:11.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:11');
INSERT INTO `sys_rizhi` VALUES (7758, '\"请求访问时间:2026-03-19T15:41:11.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:11');
INSERT INTO `sys_rizhi` VALUES (7759, '\"请求访问时间:2026-03-19T15:41:13.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:13');
INSERT INTO `sys_rizhi` VALUES (7760, '\"请求访问时间:2026-03-19T15:41:13.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:13');
INSERT INTO `sys_rizhi` VALUES (7761, '\"请求访问时间:2026-03-19T15:41:15.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:15');
INSERT INTO `sys_rizhi` VALUES (7762, '\"请求访问时间:2026-03-19T15:41:15.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:15');
INSERT INTO `sys_rizhi` VALUES (7763, '\"请求访问时间:2026-03-19T15:41:17.148--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:17');
INSERT INTO `sys_rizhi` VALUES (7764, '\"请求访问时间:2026-03-19T15:41:17.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:17');
INSERT INTO `sys_rizhi` VALUES (7765, '\"请求访问时间:2026-03-19T15:41:19.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:19');
INSERT INTO `sys_rizhi` VALUES (7766, '\"请求访问时间:2026-03-19T15:41:19.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:19');
INSERT INTO `sys_rizhi` VALUES (7767, '\"请求访问时间:2026-03-19T15:41:21.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:21');
INSERT INTO `sys_rizhi` VALUES (7768, '\"请求访问时间:2026-03-19T15:41:21.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:21');
INSERT INTO `sys_rizhi` VALUES (7769, '\"请求访问时间:2026-03-19T15:41:23.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:23');
INSERT INTO `sys_rizhi` VALUES (7770, '\"请求访问时间:2026-03-19T15:41:23.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:23');
INSERT INTO `sys_rizhi` VALUES (7771, '\"请求访问时间:2026-03-19T15:41:24.330--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:24');
INSERT INTO `sys_rizhi` VALUES (7772, '\"请求访问时间:2026-03-19T15:41:25.163--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:25');
INSERT INTO `sys_rizhi` VALUES (7773, '\"请求访问时间:2026-03-19T15:41:26.329--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:26');
INSERT INTO `sys_rizhi` VALUES (7774, '\"请求访问时间:2026-03-19T15:41:27.144--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:27');
INSERT INTO `sys_rizhi` VALUES (7775, '\"请求访问时间:2026-03-19T15:41:33.444--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:33');
INSERT INTO `sys_rizhi` VALUES (7776, '\"请求访问时间:2026-03-19T15:41:33.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:33');
INSERT INTO `sys_rizhi` VALUES (7777, '\"请求访问时间:2026-03-19T15:41:33.455--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:41:33');
INSERT INTO `sys_rizhi` VALUES (7778, '\"请求访问时间:2026-03-19T15:41:33.455--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:41:33');
INSERT INTO `sys_rizhi` VALUES (7779, '\"请求访问时间:2026-03-19T15:43:22.076--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7780, '\"请求访问时间:2026-03-19T15:43:22.077--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7781, '\"请求访问时间:2026-03-19T15:43:22.077--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7782, '\"请求访问时间:2026-03-19T15:43:22.076--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7783, '\"请求访问时间:2026-03-19T15:43:22.079--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7784, '\"请求访问时间:2026-03-19T15:43:22.080--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7785, '\"请求访问时间:2026-03-19T15:43:22.099--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7786, '\"请求访问时间:2026-03-19T15:43:22.106--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7787, '\"请求访问时间:2026-03-19T15:43:22.107--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7788, '\"请求访问时间:2026-03-19T15:43:22.107--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7789, '\"请求访问时间:2026-03-19T15:43:22.111--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7790, '\"请求访问时间:2026-03-19T15:43:22.117--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7791, '\"请求访问时间:2026-03-19T15:43:22.121--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7792, '\"请求访问时间:2026-03-19T15:43:22.126--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7793, '\"请求访问时间:2026-03-19T15:43:22.130--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7794, '\"请求访问时间:2026-03-19T15:43:22.136--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7795, '\"请求访问时间:2026-03-19T15:43:22.138--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7796, '\"请求访问时间:2026-03-19T15:43:22.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7797, '\"请求访问时间:2026-03-19T15:43:22.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7798, '\"请求访问时间:2026-03-19T15:43:22.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7799, '\"请求访问时间:2026-03-19T15:43:22.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7800, '\"请求访问时间:2026-03-19T15:43:22.165--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7801, '\"请求访问时间:2026-03-19T15:43:22.167--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7802, '\"请求访问时间:2026-03-19T15:43:22.174--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7803, '\"请求访问时间:2026-03-19T15:43:22.176--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7804, '\"请求访问时间:2026-03-19T15:43:22.183--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7805, '\"请求访问时间:2026-03-19T15:43:22.186--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7806, '\"请求访问时间:2026-03-19T15:43:22.193--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7807, '\"请求访问时间:2026-03-19T15:43:22.195--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7808, '\"请求访问时间:2026-03-19T15:43:22.202--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7809, '\"请求访问时间:2026-03-19T15:43:22.206--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7810, '\"请求访问时间:2026-03-19T15:43:22.213--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7811, '\"请求访问时间:2026-03-19T15:43:22.216--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7812, '\"请求访问时间:2026-03-19T15:43:22.223--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7813, '\"请求访问时间:2026-03-19T15:43:22.227--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7814, '\"请求访问时间:2026-03-19T15:43:22.234--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7815, '\"请求访问时间:2026-03-19T15:43:22.238--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7816, '\"请求访问时间:2026-03-19T15:43:22.244--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7817, '\"请求访问时间:2026-03-19T15:43:22.248--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7818, '\"请求访问时间:2026-03-19T15:43:22.254--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7819, '\"请求访问时间:2026-03-19T15:43:22.259--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7820, '\"请求访问时间:2026-03-19T15:43:22.271--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7821, '\"请求访问时间:2026-03-19T15:43:22.279--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7822, '\"请求访问时间:2026-03-19T15:43:22.285--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7823, '\"请求访问时间:2026-03-19T15:43:22.297--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7824, '\"请求访问时间:2026-03-19T15:43:22.300--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7825, '\"请求访问时间:2026-03-19T15:43:22.314--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7826, '\"请求访问时间:2026-03-19T15:43:22.314--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7827, '\"请求访问时间:2026-03-19T15:43:22.328--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7828, '\"请求访问时间:2026-03-19T15:43:22.329--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7829, '\"请求访问时间:2026-03-19T15:43:22.342--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7830, '\"请求访问时间:2026-03-19T15:43:22.344--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7831, '\"请求访问时间:2026-03-19T15:43:22.354--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7832, '\"请求访问时间:2026-03-19T15:43:22.357--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7833, '\"请求访问时间:2026-03-19T15:43:22.368--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7834, '\"请求访问时间:2026-03-19T15:43:22.372--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7835, '\"请求访问时间:2026-03-19T15:43:22.381--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7836, '\"请求访问时间:2026-03-19T15:43:22.385--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7837, '\"请求访问时间:2026-03-19T15:43:22.395--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7838, '\"请求访问时间:2026-03-19T15:43:22.400--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7839, '\"请求访问时间:2026-03-19T15:43:22.408--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7840, '\"请求访问时间:2026-03-19T15:43:22.413--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7841, '\"请求访问时间:2026-03-19T15:43:22.422--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7842, '\"请求访问时间:2026-03-19T15:43:22.429--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7843, '\"请求访问时间:2026-03-19T15:43:22.436--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7844, '\"请求访问时间:2026-03-19T15:43:22.443--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7845, '\"请求访问时间:2026-03-19T15:43:22.450--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7846, '\"请求访问时间:2026-03-19T15:43:22.458--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7847, '\"请求访问时间:2026-03-19T15:43:22.464--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7848, '\"请求访问时间:2026-03-19T15:43:22.476--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7849, '\"请求访问时间:2026-03-19T15:43:22.481--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:22');
INSERT INTO `sys_rizhi` VALUES (7850, '\"请求访问时间:2026-03-19T15:43:22.494--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7851, '\"请求访问时间:2026-03-19T15:43:22.496--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7852, '\"请求访问时间:2026-03-19T15:43:22.508--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7853, '\"请求访问时间:2026-03-19T15:43:22.507--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7854, '\"请求访问时间:2026-03-19T15:43:22.521--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7855, '\"请求访问时间:2026-03-19T15:43:22.521--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7856, '\"请求访问时间:2026-03-19T15:43:22.533--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7857, '\"请求访问时间:2026-03-19T15:43:22.533--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7858, '\"请求访问时间:2026-03-19T15:43:22.544--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7859, '\"请求访问时间:2026-03-19T15:43:22.545--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7860, '\"请求访问时间:2026-03-19T15:43:22.556--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7861, '\"请求访问时间:2026-03-19T15:43:22.556--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7862, '\"请求访问时间:2026-03-19T15:43:22.566--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7863, '\"请求访问时间:2026-03-19T15:43:22.567--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7864, '\"请求访问时间:2026-03-19T15:43:22.577--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7865, '\"请求访问时间:2026-03-19T15:43:22.578--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7866, '\"请求访问时间:2026-03-19T15:43:22.589--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7867, '\"请求访问时间:2026-03-19T15:43:22.600--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7868, '\"请求访问时间:2026-03-19T15:43:22.611--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7869, '\"请求访问时间:2026-03-19T15:43:22.622--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7870, '\"请求访问时间:2026-03-19T15:43:22.635--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7871, '\"请求访问时间:2026-03-19T15:43:22.644--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7872, '\"请求访问时间:2026-03-19T15:43:22.654--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7873, '\"请求访问时间:2026-03-19T15:43:22.664--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7874, '\"请求访问时间:2026-03-19T15:43:22.672--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7875, '\"请求访问时间:2026-03-19T15:43:22.682--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7876, '\"请求访问时间:2026-03-19T15:43:22.691--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7877, '\"请求访问时间:2026-03-19T15:43:22.702--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7878, '\"请求访问时间:2026-03-19T15:43:22.714--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7879, '\"请求访问时间:2026-03-19T15:43:22.728--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7880, '\"请求访问时间:2026-03-19T15:43:22.741--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:23');
INSERT INTO `sys_rizhi` VALUES (7881, '\"请求访问时间:2026-03-19T15:43:24.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:24');
INSERT INTO `sys_rizhi` VALUES (7882, '\"请求访问时间:2026-03-19T15:43:24.783--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:1\"', '2026-03-19 15:43:25');
INSERT INTO `sys_rizhi` VALUES (7883, '\"请求访问时间:2026-03-19T15:43:26.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:26');
INSERT INTO `sys_rizhi` VALUES (7884, '\"请求访问时间:2026-03-19T15:43:28.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:28');
INSERT INTO `sys_rizhi` VALUES (7885, '\"请求访问时间:2026-03-19T15:43:28.965--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:1\"', '2026-03-19 15:43:29');
INSERT INTO `sys_rizhi` VALUES (7886, '\"请求访问时间:2026-03-19T15:43:28.965--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:43:29');
INSERT INTO `sys_rizhi` VALUES (7887, '\"请求访问时间:2026-03-19T15:43:28.989--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:43:29');
INSERT INTO `sys_rizhi` VALUES (7888, '\"请求访问时间:2026-03-19T15:43:30.144--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:30');
INSERT INTO `sys_rizhi` VALUES (7889, '\"请求访问时间:2026-03-19T15:43:30.978--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:43:31');
INSERT INTO `sys_rizhi` VALUES (7890, '\"请求访问时间:2026-03-19T15:43:31.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:31');
INSERT INTO `sys_rizhi` VALUES (7891, '\"请求访问时间:2026-03-19T15:43:32.964--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:43:33');
INSERT INTO `sys_rizhi` VALUES (7892, '\"请求访问时间:2026-03-19T15:43:33.167--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:33');
INSERT INTO `sys_rizhi` VALUES (7893, '\"请求访问时间:2026-03-19T15:43:34.964--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:43:35');
INSERT INTO `sys_rizhi` VALUES (7894, '\"请求访问时间:2026-03-19T15:43:36.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:36');
INSERT INTO `sys_rizhi` VALUES (7895, '\"请求访问时间:2026-03-19T15:43:36.969--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:43:37');
INSERT INTO `sys_rizhi` VALUES (7896, '\"请求访问时间:2026-03-19T15:43:37.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:37');
INSERT INTO `sys_rizhi` VALUES (7897, '\"请求访问时间:2026-03-19T15:43:38.969--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:43:39');
INSERT INTO `sys_rizhi` VALUES (7898, '\"请求访问时间:2026-03-19T15:43:39.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:39');
INSERT INTO `sys_rizhi` VALUES (7899, '\"请求访问时间:2026-03-19T15:43:40.287--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:43:40');
INSERT INTO `sys_rizhi` VALUES (7900, '\"请求访问时间:2026-03-19T15:43:40.372--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:43:40');
INSERT INTO `sys_rizhi` VALUES (7901, '\"请求访问时间:2026-03-19T15:43:41.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:41');
INSERT INTO `sys_rizhi` VALUES (7902, '\"请求访问时间:2026-03-19T15:43:43.165--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:43');
INSERT INTO `sys_rizhi` VALUES (7903, '\"请求访问时间:2026-03-19T15:43:45.164--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:45');
INSERT INTO `sys_rizhi` VALUES (7904, '\"请求访问时间:2026-03-19T15:43:47.166--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:47');
INSERT INTO `sys_rizhi` VALUES (7905, '\"请求访问时间:2026-03-19T15:43:49.165--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:49');
INSERT INTO `sys_rizhi` VALUES (7906, '\"请求访问时间:2026-03-19T15:43:51.350--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:51');
INSERT INTO `sys_rizhi` VALUES (7907, '\"请求访问时间:2026-03-19T15:43:53.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:53');
INSERT INTO `sys_rizhi` VALUES (7908, '\"请求访问时间:2026-03-19T15:43:56.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:56');
INSERT INTO `sys_rizhi` VALUES (7909, '\"请求访问时间:2026-03-19T15:43:58.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:43:58');
INSERT INTO `sys_rizhi` VALUES (7910, '\"请求访问时间:2026-03-19T15:43:59.723--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:00');
INSERT INTO `sys_rizhi` VALUES (7911, '\"请求访问时间:2026-03-19T15:43:59.737--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:44:00');
INSERT INTO `sys_rizhi` VALUES (7912, '\"请求访问时间:2026-03-19T15:43:59.737--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:44:00');
INSERT INTO `sys_rizhi` VALUES (7913, '\"请求访问时间:2026-03-19T15:43:59.771--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:00');
INSERT INTO `sys_rizhi` VALUES (7914, '\"请求访问时间:2026-03-19T15:44:02.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:02');
INSERT INTO `sys_rizhi` VALUES (7915, '\"请求访问时间:2026-03-19T15:44:04.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:04');
INSERT INTO `sys_rizhi` VALUES (7916, '\"请求访问时间:2026-03-19T15:44:04.577--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:05');
INSERT INTO `sys_rizhi` VALUES (7917, '\"请求访问时间:2026-03-19T15:44:04.682--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:05');
INSERT INTO `sys_rizhi` VALUES (7918, '\"请求访问时间:2026-03-19T15:44:06.016--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:06');
INSERT INTO `sys_rizhi` VALUES (7919, '\"请求访问时间:2026-03-19T15:44:08.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:08');
INSERT INTO `sys_rizhi` VALUES (7920, '\"请求访问时间:2026-03-19T15:44:10.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:10');
INSERT INTO `sys_rizhi` VALUES (7921, '\"请求访问时间:2026-03-19T15:44:11.731--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:12');
INSERT INTO `sys_rizhi` VALUES (7922, '\"请求访问时间:2026-03-19T15:44:13.007--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:13');
INSERT INTO `sys_rizhi` VALUES (7923, '\"请求访问时间:2026-03-19T15:44:13.128--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:13');
INSERT INTO `sys_rizhi` VALUES (7924, '\"请求访问时间:2026-03-19T15:44:13.737--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:14');
INSERT INTO `sys_rizhi` VALUES (7925, '\"请求访问时间:2026-03-19T15:44:15.946--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:44:16');
INSERT INTO `sys_rizhi` VALUES (7926, '\"请求访问时间:2026-03-19T15:44:15.946--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:44:16');
INSERT INTO `sys_rizhi` VALUES (7927, '\"请求访问时间:2026-03-19T15:44:15.955--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:16');
INSERT INTO `sys_rizhi` VALUES (7928, '\"请求访问时间:2026-03-19T15:44:15.971--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:16');
INSERT INTO `sys_rizhi` VALUES (7929, '\"请求访问时间:2026-03-19T15:44:17.948--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:18');
INSERT INTO `sys_rizhi` VALUES (7930, '\"请求访问时间:2026-03-19T15:44:19.947--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:20');
INSERT INTO `sys_rizhi` VALUES (7931, '\"请求访问时间:2026-03-19T15:44:21.597--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:44:22');
INSERT INTO `sys_rizhi` VALUES (7932, '\"请求访问时间:2026-03-19T15:44:21.597--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:44:22');
INSERT INTO `sys_rizhi` VALUES (7933, '\"请求访问时间:2026-03-19T15:44:21.616--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:22');
INSERT INTO `sys_rizhi` VALUES (7934, '\"请求访问时间:2026-03-19T15:44:21.632--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:22');
INSERT INTO `sys_rizhi` VALUES (7935, '\"请求访问时间:2026-03-19T15:44:24.044--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:24');
INSERT INTO `sys_rizhi` VALUES (7936, '\"请求访问时间:2026-03-19T15:44:24.130--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:44:24');
INSERT INTO `sys_rizhi` VALUES (7937, '\"请求访问时间:2026-03-19T15:44:24.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:24');
INSERT INTO `sys_rizhi` VALUES (7938, '\"请求访问时间:2026-03-19T15:44:26.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:26');
INSERT INTO `sys_rizhi` VALUES (7939, '\"请求访问时间:2026-03-19T15:44:28.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:28');
INSERT INTO `sys_rizhi` VALUES (7940, '\"请求访问时间:2026-03-19T15:44:30.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:30');
INSERT INTO `sys_rizhi` VALUES (7941, '\"请求访问时间:2026-03-19T15:44:32.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:32');
INSERT INTO `sys_rizhi` VALUES (7942, '\"请求访问时间:2026-03-19T15:44:34.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:34');
INSERT INTO `sys_rizhi` VALUES (7943, '\"请求访问时间:2026-03-19T15:44:36.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:36');
INSERT INTO `sys_rizhi` VALUES (7944, '\"请求访问时间:2026-03-19T15:44:38.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:38');
INSERT INTO `sys_rizhi` VALUES (7945, '\"请求访问时间:2026-03-19T15:44:39.931--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:40');
INSERT INTO `sys_rizhi` VALUES (7946, '\"请求访问时间:2026-03-19T15:44:42.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:42');
INSERT INTO `sys_rizhi` VALUES (7947, '\"请求访问时间:2026-03-19T15:44:44.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:44');
INSERT INTO `sys_rizhi` VALUES (7948, '\"请求访问时间:2026-03-19T15:44:46.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:46');
INSERT INTO `sys_rizhi` VALUES (7949, '\"请求访问时间:2026-03-19T15:44:48.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:48');
INSERT INTO `sys_rizhi` VALUES (7950, '\"请求访问时间:2026-03-19T15:44:50.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:50');
INSERT INTO `sys_rizhi` VALUES (7951, '\"请求访问时间:2026-03-19T15:44:52.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:52');
INSERT INTO `sys_rizhi` VALUES (7952, '\"请求访问时间:2026-03-19T15:44:54.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:54');
INSERT INTO `sys_rizhi` VALUES (7953, '\"请求访问时间:2026-03-19T15:44:56.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:56');
INSERT INTO `sys_rizhi` VALUES (7954, '\"请求访问时间:2026-03-19T15:44:58.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:44:58');
INSERT INTO `sys_rizhi` VALUES (7955, '\"请求访问时间:2026-03-19T15:45:00.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:00');
INSERT INTO `sys_rizhi` VALUES (7956, '\"请求访问时间:2026-03-19T15:45:02.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:02');
INSERT INTO `sys_rizhi` VALUES (7957, '\"请求访问时间:2026-03-19T15:45:04.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:04');
INSERT INTO `sys_rizhi` VALUES (7958, '\"请求访问时间:2026-03-19T15:45:06.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:06');
INSERT INTO `sys_rizhi` VALUES (7959, '\"请求访问时间:2026-03-19T15:45:08.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:08');
INSERT INTO `sys_rizhi` VALUES (7960, '\"请求访问时间:2026-03-19T15:45:10.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:10');
INSERT INTO `sys_rizhi` VALUES (7961, '\"请求访问时间:2026-03-19T15:45:12.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:12');
INSERT INTO `sys_rizhi` VALUES (7962, '\"请求访问时间:2026-03-19T15:45:14.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:14');
INSERT INTO `sys_rizhi` VALUES (7963, '\"请求访问时间:2026-03-19T15:45:16.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:16');
INSERT INTO `sys_rizhi` VALUES (7964, '\"请求访问时间:2026-03-19T15:45:18.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:18');
INSERT INTO `sys_rizhi` VALUES (7965, '\"请求访问时间:2026-03-19T15:45:20.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:20');
INSERT INTO `sys_rizhi` VALUES (7966, '\"请求访问时间:2026-03-19T15:45:22.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:22');
INSERT INTO `sys_rizhi` VALUES (7967, '\"请求访问时间:2026-03-19T15:45:24.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:24');
INSERT INTO `sys_rizhi` VALUES (7968, '\"请求访问时间:2026-03-19T15:45:26.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:26');
INSERT INTO `sys_rizhi` VALUES (7969, '\"请求访问时间:2026-03-19T15:45:28.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:28');
INSERT INTO `sys_rizhi` VALUES (7970, '\"请求访问时间:2026-03-19T15:45:30.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:45:30');
INSERT INTO `sys_rizhi` VALUES (7971, '\"请求访问时间:2026-03-19T15:46:06.914--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:46:07');
INSERT INTO `sys_rizhi` VALUES (7972, '\"请求访问时间:2026-03-19T15:46:06.938--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:46:07');
INSERT INTO `sys_rizhi` VALUES (7973, '\"请求访问时间:2026-03-19T15:46:06.938--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:7\"', '2026-03-19 15:46:07');
INSERT INTO `sys_rizhi` VALUES (7974, '\"请求访问时间:2026-03-19T15:46:06.955--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:07');
INSERT INTO `sys_rizhi` VALUES (7975, '\"请求访问时间:2026-03-19T15:46:09.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:09');
INSERT INTO `sys_rizhi` VALUES (7976, '\"请求访问时间:2026-03-19T15:46:09.586--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:46:10');
INSERT INTO `sys_rizhi` VALUES (7977, '\"请求访问时间:2026-03-19T15:46:09.686--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:46:10');
INSERT INTO `sys_rizhi` VALUES (7978, '\"请求访问时间:2026-03-19T15:46:11.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:11');
INSERT INTO `sys_rizhi` VALUES (7979, '\"请求访问时间:2026-03-19T15:46:13.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:13');
INSERT INTO `sys_rizhi` VALUES (7980, '\"请求访问时间:2026-03-19T15:46:15.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:15');
INSERT INTO `sys_rizhi` VALUES (7981, '\"请求访问时间:2026-03-19T15:46:17.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:17');
INSERT INTO `sys_rizhi` VALUES (7982, '\"请求访问时间:2026-03-19T15:46:19.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:19');
INSERT INTO `sys_rizhi` VALUES (7983, '\"请求访问时间:2026-03-19T15:46:21.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:21');
INSERT INTO `sys_rizhi` VALUES (7984, '\"请求访问时间:2026-03-19T15:46:23.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:23');
INSERT INTO `sys_rizhi` VALUES (7985, '\"请求访问时间:2026-03-19T15:46:24.476--操作人:管理员--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:1\"', '2026-03-19 15:46:24');
INSERT INTO `sys_rizhi` VALUES (7986, '\"请求访问时间:2026-03-19T15:46:25.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:25');
INSERT INTO `sys_rizhi` VALUES (7987, '\"请求访问时间:2026-03-19T15:46:27.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:27');
INSERT INTO `sys_rizhi` VALUES (7988, '\"请求访问时间:2026-03-19T15:46:29.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:29');
INSERT INTO `sys_rizhi` VALUES (7989, '\"请求访问时间:2026-03-19T15:46:31.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:31');
INSERT INTO `sys_rizhi` VALUES (7990, '\"请求访问时间:2026-03-19T15:46:33.107--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:33');
INSERT INTO `sys_rizhi` VALUES (7991, '\"请求访问时间:2026-03-19T15:46:35.148--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:35');
INSERT INTO `sys_rizhi` VALUES (7992, '\"请求访问时间:2026-03-19T15:46:35.308--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:1\"', '2026-03-19 15:46:35');
INSERT INTO `sys_rizhi` VALUES (7993, '\"请求访问时间:2026-03-19T15:46:36.747--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:46:37');
INSERT INTO `sys_rizhi` VALUES (7994, '\"请求访问时间:2026-03-19T15:46:36.747--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:1\"', '2026-03-19 15:46:37');
INSERT INTO `sys_rizhi` VALUES (7995, '\"请求访问时间:2026-03-19T15:46:36.769--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:37');
INSERT INTO `sys_rizhi` VALUES (7996, '\"请求访问时间:2026-03-19T15:46:37.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:37');
INSERT INTO `sys_rizhi` VALUES (7997, '\"请求访问时间:2026-03-19T15:46:38.750--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:39');
INSERT INTO `sys_rizhi` VALUES (7998, '\"请求访问时间:2026-03-19T15:46:39.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:39');
INSERT INTO `sys_rizhi` VALUES (7999, '\"请求访问时间:2026-03-19T15:46:40.354--操作人:管理员--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:1\"', '2026-03-19 15:46:40');
INSERT INTO `sys_rizhi` VALUES (8000, '\"请求访问时间:2026-03-19T15:46:40.369--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:40');
INSERT INTO `sys_rizhi` VALUES (8001, '\"请求访问时间:2026-03-19T15:46:40.749--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:41');
INSERT INTO `sys_rizhi` VALUES (8002, '\"请求访问时间:2026-03-19T15:46:41.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:41');
INSERT INTO `sys_rizhi` VALUES (8003, '\"请求访问时间:2026-03-19T15:46:42.746--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:43');
INSERT INTO `sys_rizhi` VALUES (8004, '\"请求访问时间:2026-03-19T15:46:43.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:43');
INSERT INTO `sys_rizhi` VALUES (8005, '\"请求访问时间:2026-03-19T15:46:44.751--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:45');
INSERT INTO `sys_rizhi` VALUES (8006, '\"请求访问时间:2026-03-19T15:46:45.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:45');
INSERT INTO `sys_rizhi` VALUES (8007, '\"请求访问时间:2026-03-19T15:46:45.826--操作人:管理员--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:1\"', '2026-03-19 15:46:46');
INSERT INTO `sys_rizhi` VALUES (8008, '\"请求访问时间:2026-03-19T15:46:45.844--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:46');
INSERT INTO `sys_rizhi` VALUES (8009, '\"请求访问时间:2026-03-19T15:46:46.743--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:47');
INSERT INTO `sys_rizhi` VALUES (8010, '\"请求访问时间:2026-03-19T15:46:47.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:47');
INSERT INTO `sys_rizhi` VALUES (8011, '\"请求访问时间:2026-03-19T15:46:48.744--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:49');
INSERT INTO `sys_rizhi` VALUES (8012, '\"请求访问时间:2026-03-19T15:46:49.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:49');
INSERT INTO `sys_rizhi` VALUES (8013, '\"请求访问时间:2026-03-19T15:46:50.748--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:51');
INSERT INTO `sys_rizhi` VALUES (8014, '\"请求访问时间:2026-03-19T15:46:51.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:51');
INSERT INTO `sys_rizhi` VALUES (8015, '\"请求访问时间:2026-03-19T15:46:52.749--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:53');
INSERT INTO `sys_rizhi` VALUES (8016, '\"请求访问时间:2026-03-19T15:46:53.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:53');
INSERT INTO `sys_rizhi` VALUES (8017, '\"请求访问时间:2026-03-19T15:46:54.758--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:55');
INSERT INTO `sys_rizhi` VALUES (8018, '\"请求访问时间:2026-03-19T15:46:55.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:55');
INSERT INTO `sys_rizhi` VALUES (8019, '\"请求访问时间:2026-03-19T15:46:56.754--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:57');
INSERT INTO `sys_rizhi` VALUES (8020, '\"请求访问时间:2026-03-19T15:46:57.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:57');
INSERT INTO `sys_rizhi` VALUES (8021, '\"请求访问时间:2026-03-19T15:46:58.746--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:46:59');
INSERT INTO `sys_rizhi` VALUES (8022, '\"请求访问时间:2026-03-19T15:46:59.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:46:59');
INSERT INTO `sys_rizhi` VALUES (8023, '\"请求访问时间:2026-03-19T15:47:00.758--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:01');
INSERT INTO `sys_rizhi` VALUES (8024, '\"请求访问时间:2026-03-19T15:47:01.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:01');
INSERT INTO `sys_rizhi` VALUES (8025, '\"请求访问时间:2026-03-19T15:47:02.751--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:03');
INSERT INTO `sys_rizhi` VALUES (8026, '\"请求访问时间:2026-03-19T15:47:03.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:03');
INSERT INTO `sys_rizhi` VALUES (8027, '\"请求访问时间:2026-03-19T15:47:04.752--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:05');
INSERT INTO `sys_rizhi` VALUES (8028, '\"请求访问时间:2026-03-19T15:47:05.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:05');
INSERT INTO `sys_rizhi` VALUES (8029, '\"请求访问时间:2026-03-19T15:47:06.753--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:07');
INSERT INTO `sys_rizhi` VALUES (8030, '\"请求访问时间:2026-03-19T15:47:07.157--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:07');
INSERT INTO `sys_rizhi` VALUES (8031, '\"请求访问时间:2026-03-19T15:47:08.757--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:09');
INSERT INTO `sys_rizhi` VALUES (8032, '\"请求访问时间:2026-03-19T15:47:09.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:09');
INSERT INTO `sys_rizhi` VALUES (8033, '\"请求访问时间:2026-03-19T15:47:10.758--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:11');
INSERT INTO `sys_rizhi` VALUES (8034, '\"请求访问时间:2026-03-19T15:47:11.151--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:11');
INSERT INTO `sys_rizhi` VALUES (8035, '\"请求访问时间:2026-03-19T15:47:12.750--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:1\"', '2026-03-19 15:47:13');
INSERT INTO `sys_rizhi` VALUES (8036, '\"请求访问时间:2026-03-19T15:47:13.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:13');
INSERT INTO `sys_rizhi` VALUES (8037, '\"请求访问时间:2026-03-19T15:47:13.495--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/all操作人id:1\"', '2026-03-19 15:47:14');
INSERT INTO `sys_rizhi` VALUES (8038, '\"请求访问时间:2026-03-19T15:47:13.495--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/list操作人id:1\"', '2026-03-19 15:47:14');
INSERT INTO `sys_rizhi` VALUES (8039, '\"请求访问时间:2026-03-19T15:47:15.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:15');
INSERT INTO `sys_rizhi` VALUES (8040, '\"请求访问时间:2026-03-19T15:47:17.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:17');
INSERT INTO `sys_rizhi` VALUES (8041, '\"请求访问时间:2026-03-19T15:47:19.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:19');
INSERT INTO `sys_rizhi` VALUES (8042, '\"请求访问时间:2026-03-19T15:47:21.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:21');
INSERT INTO `sys_rizhi` VALUES (8043, '\"请求访问时间:2026-03-19T15:47:23.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:23');
INSERT INTO `sys_rizhi` VALUES (8044, '\"请求访问时间:2026-03-19T15:47:24.942--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:25');
INSERT INTO `sys_rizhi` VALUES (8045, '\"请求访问时间:2026-03-19T15:47:26.944--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:27');
INSERT INTO `sys_rizhi` VALUES (8046, '\"请求访问时间:2026-03-19T15:47:29.120--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:47:29');
INSERT INTO `sys_rizhi` VALUES (8047, '\"请求访问时间:2026-03-19T15:47:29.121--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/36操作人id:13\"', '2026-03-19 15:47:29');
INSERT INTO `sys_rizhi` VALUES (8048, '\"请求访问时间:2026-03-19T15:47:29.139--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:29');
INSERT INTO `sys_rizhi` VALUES (8049, '\"请求访问时间:2026-03-19T15:47:29.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:29');
INSERT INTO `sys_rizhi` VALUES (8050, '\"请求访问时间:2026-03-19T15:47:31.151--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:31');
INSERT INTO `sys_rizhi` VALUES (8051, '\"请求访问时间:2026-03-19T15:47:31.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:31');
INSERT INTO `sys_rizhi` VALUES (8052, '\"请求访问时间:2026-03-19T15:47:31.454--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/list操作人id:1\"', '2026-03-19 15:47:31');
INSERT INTO `sys_rizhi` VALUES (8053, '\"请求访问时间:2026-03-19T15:47:31.454--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/menu/getAllMenu操作人id:1\"', '2026-03-19 15:47:31');
INSERT INTO `sys_rizhi` VALUES (8054, '\"请求访问时间:2026-03-19T15:47:32.475--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/role/getRoleById/7操作人id:1\"', '2026-03-19 15:47:32');
INSERT INTO `sys_rizhi` VALUES (8055, '\"请求访问时间:2026-03-19T15:47:33.150--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:33');
INSERT INTO `sys_rizhi` VALUES (8056, '\"请求访问时间:2026-03-19T15:47:33.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:33');
INSERT INTO `sys_rizhi` VALUES (8057, '\"请求访问时间:2026-03-19T15:47:34.646--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/menu/getAllMenu操作人id:1\"', '2026-03-19 15:47:35');
INSERT INTO `sys_rizhi` VALUES (8058, '\"请求访问时间:2026-03-19T15:47:35.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:35');
INSERT INTO `sys_rizhi` VALUES (8059, '\"请求访问时间:2026-03-19T15:47:35.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:35');
INSERT INTO `sys_rizhi` VALUES (8060, '\"请求访问时间:2026-03-19T15:47:37.065--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:1\"', '2026-03-19 15:47:37');
INSERT INTO `sys_rizhi` VALUES (8061, '\"请求访问时间:2026-03-19T15:47:37.094--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysFenlei/list操作人id:1\"', '2026-03-19 15:47:37');
INSERT INTO `sys_rizhi` VALUES (8062, '\"请求访问时间:2026-03-19T15:47:37.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:37');
INSERT INTO `sys_rizhi` VALUES (8063, '\"请求访问时间:2026-03-19T15:47:37.146--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:37');
INSERT INTO `sys_rizhi` VALUES (8064, '\"请求访问时间:2026-03-19T15:47:39.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:39');
INSERT INTO `sys_rizhi` VALUES (8065, '\"请求访问时间:2026-03-19T15:47:39.153--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:39');
INSERT INTO `sys_rizhi` VALUES (8066, '\"请求访问时间:2026-03-19T15:47:41.157--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:41');
INSERT INTO `sys_rizhi` VALUES (8067, '\"请求访问时间:2026-03-19T15:47:41.156--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:41');
INSERT INTO `sys_rizhi` VALUES (8068, '\"请求访问时间:2026-03-19T15:47:41.519--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:1\"', '2026-03-19 15:47:42');
INSERT INTO `sys_rizhi` VALUES (8069, '\"请求访问时间:2026-03-19T15:47:43.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:43');
INSERT INTO `sys_rizhi` VALUES (8070, '\"请求访问时间:2026-03-19T15:47:43.145--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:43');
INSERT INTO `sys_rizhi` VALUES (8071, '\"请求访问时间:2026-03-19T15:47:44.216--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysRizhi/list操作人id:1\"', '2026-03-19 15:47:44');
INSERT INTO `sys_rizhi` VALUES (8072, '\"请求访问时间:2026-03-19T15:47:45.149--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:45');
INSERT INTO `sys_rizhi` VALUES (8073, '\"请求访问时间:2026-03-19T15:47:45.149--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:45');
INSERT INTO `sys_rizhi` VALUES (8074, '\"请求访问时间:2026-03-19T15:47:45.987--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:1\"', '2026-03-19 15:47:46');
INSERT INTO `sys_rizhi` VALUES (8075, '\"请求访问时间:2026-03-19T15:47:47.145--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:47');
INSERT INTO `sys_rizhi` VALUES (8076, '\"请求访问时间:2026-03-19T15:47:47.144--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:47');
INSERT INTO `sys_rizhi` VALUES (8077, '\"请求访问时间:2026-03-19T15:47:48.939--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:47:49');
INSERT INTO `sys_rizhi` VALUES (8078, '\"请求访问时间:2026-03-19T15:47:49.158--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:49');
INSERT INTO `sys_rizhi` VALUES (8079, '\"请求访问时间:2026-03-19T15:47:50.486--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:47:50');
INSERT INTO `sys_rizhi` VALUES (8080, '\"请求访问时间:2026-03-19T15:47:50.509--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8081, '\"请求访问时间:2026-03-19T15:47:50.509--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8082, '\"请求访问时间:2026-03-19T15:47:50.510--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8083, '\"请求访问时间:2026-03-19T15:47:50.515--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8084, '\"请求访问时间:2026-03-19T15:47:50.567--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8085, '\"请求访问时间:2026-03-19T15:47:50.612--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8086, '\"请求访问时间:2026-03-19T15:47:51.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:51');
INSERT INTO `sys_rizhi` VALUES (8087, '\"请求访问时间:2026-03-19T15:47:53.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:53');
INSERT INTO `sys_rizhi` VALUES (8088, '\"请求访问时间:2026-03-19T15:47:54.119--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysLiuyan/list操作人id:1\"', '2026-03-19 15:47:54');
INSERT INTO `sys_rizhi` VALUES (8089, '\"请求访问时间:2026-03-19T15:47:55.112--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:47:55');
INSERT INTO `sys_rizhi` VALUES (8090, '\"请求访问时间:2026-03-19T15:47:56.704--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:47:57');
INSERT INTO `sys_rizhi` VALUES (8091, '\"请求访问时间:2026-03-19T15:47:56.724--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyan/list操作人id:13\"', '2026-03-19 15:47:57');
INSERT INTO `sys_rizhi` VALUES (8092, '\"请求访问时间:2026-03-19T15:48:03.301--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:48:03');
INSERT INTO `sys_rizhi` VALUES (8093, '\"请求访问时间:2026-03-19T15:48:03.338--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:13\"', '2026-03-19 15:48:03');
INSERT INTO `sys_rizhi` VALUES (8094, '\"请求访问时间:2026-03-19T15:48:04.752--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysHuagao/getById/15操作人id:13\"', '2026-03-19 15:48:05');
INSERT INTO `sys_rizhi` VALUES (8095, '\"请求访问时间:2026-03-19T15:48:04.752--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysFenlei/list操作人id:13\"', '2026-03-19 15:48:05');
INSERT INTO `sys_rizhi` VALUES (8096, '\"请求访问时间:2026-03-19T15:48:04.751--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:48:05');
INSERT INTO `sys_rizhi` VALUES (8097, '\"请求访问时间:2026-03-19T15:48:11.445--操作人:画师--请求方式:PUT--请求url:http://localhost:9999/sysHuagao/update操作人id:13\"', '2026-03-19 15:48:11');
INSERT INTO `sys_rizhi` VALUES (8098, '\"请求访问时间:2026-03-19T15:48:12.001--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:48:12');
INSERT INTO `sys_rizhi` VALUES (8099, '\"请求访问时间:2026-03-19T15:48:12.034--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:13\"', '2026-03-19 15:48:12');
INSERT INTO `sys_rizhi` VALUES (8100, '\"请求访问时间:2026-03-19T15:48:17.161--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:1\"', '2026-03-19 15:48:17');
INSERT INTO `sys_rizhi` VALUES (8101, '\"请求访问时间:2026-03-19T15:48:18.274--操作人:管理员--请求方式:PUT--请求url:http://localhost:9999/sysHuagao/update操作人id:1\"', '2026-03-19 15:48:18');
INSERT INTO `sys_rizhi` VALUES (8102, '\"请求访问时间:2026-03-19T15:48:18.288--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:1\"', '2026-03-19 15:48:18');
INSERT INTO `sys_rizhi` VALUES (8103, '\"请求访问时间:2026-03-19T15:48:24.274--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:48:24');
INSERT INTO `sys_rizhi` VALUES (8104, '\"请求访问时间:2026-03-19T15:48:24.284--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysFenlei/list操作人id:7\"', '2026-03-19 15:48:24');
INSERT INTO `sys_rizhi` VALUES (8105, '\"请求访问时间:2026-03-19T15:48:24.992--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:48:25');
INSERT INTO `sys_rizhi` VALUES (8106, '\"请求访问时间:2026-03-19T15:48:25.224--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:48:25');
INSERT INTO `sys_rizhi` VALUES (8107, '\"请求访问时间:2026-03-19T15:48:25.532--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:48:26');
INSERT INTO `sys_rizhi` VALUES (8108, '\"请求访问时间:2026-03-19T15:48:26.328--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:48:26');
INSERT INTO `sys_rizhi` VALUES (8109, '\"请求访问时间:2026-03-19T15:48:26.347--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:48:26');
INSERT INTO `sys_rizhi` VALUES (8110, '\"请求访问时间:2026-03-19T15:48:26.370--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:48:26');
INSERT INTO `sys_rizhi` VALUES (8111, '\"请求访问时间:2026-03-19T15:48:34.418--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysOrder/add操作人id:7\"', '2026-03-19 15:48:34');
INSERT INTO `sys_rizhi` VALUES (8112, '\"请求访问时间:2026-03-19T15:48:34.476--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:48:34');
INSERT INTO `sys_rizhi` VALUES (8113, '\"请求访问时间:2026-03-19T15:48:34.499--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:48:35');
INSERT INTO `sys_rizhi` VALUES (8114, '\"请求访问时间:2026-03-19T15:48:36.465--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/37操作人id:7\"', '2026-03-19 15:48:36');
INSERT INTO `sys_rizhi` VALUES (8115, '\"请求访问时间:2026-03-19T15:48:37.649--操作人:用户--请求方式:POST--请求url:http://localhost:9999/order/alipay操作人id:7\"', '2026-03-19 15:48:38');
INSERT INTO `sys_rizhi` VALUES (8116, '\"请求访问时间:2026-03-19T15:48:37.649--操作人:用户--请求方式:PUT--请求url:http://localhost:9999/sysOrder/update操作人id:7\"', '2026-03-19 15:48:38');
INSERT INTO `sys_rizhi` VALUES (8117, '\"请求访问时间:2026-03-19T15:49:23.421--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:49:23');
INSERT INTO `sys_rizhi` VALUES (8118, '\"请求访问时间:2026-03-19T15:49:23.509--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8119, '\"请求访问时间:2026-03-19T15:49:23.511--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8120, '\"请求访问时间:2026-03-19T15:49:23.512--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8121, '\"请求访问时间:2026-03-19T15:49:23.512--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8122, '\"请求访问时间:2026-03-19T15:49:23.536--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8123, '\"请求访问时间:2026-03-19T15:49:23.573--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8124, '\"请求访问时间:2026-03-19T15:49:23.848--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:49:24');
INSERT INTO `sys_rizhi` VALUES (8125, '\"请求访问时间:2026-03-19T15:49:24.633--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:49:25');
INSERT INTO `sys_rizhi` VALUES (8126, '\"请求访问时间:2026-03-19T15:49:26.647--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:49:27');
INSERT INTO `sys_rizhi` VALUES (8127, '\"请求访问时间:2026-03-19T15:49:26.668--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:49:27');
INSERT INTO `sys_rizhi` VALUES (8128, '\"请求访问时间:2026-03-19T15:49:28.544--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/37操作人id:7\"', '2026-03-19 15:49:29');
INSERT INTO `sys_rizhi` VALUES (8129, '\"请求访问时间:2026-03-19T15:49:28.544--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:49:29');
INSERT INTO `sys_rizhi` VALUES (8130, '\"请求访问时间:2026-03-19T15:49:28.566--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:29');
INSERT INTO `sys_rizhi` VALUES (8131, '\"请求访问时间:2026-03-19T15:49:30.550--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:31');
INSERT INTO `sys_rizhi` VALUES (8132, '\"请求访问时间:2026-03-19T15:49:32.542--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:33');
INSERT INTO `sys_rizhi` VALUES (8133, '\"请求访问时间:2026-03-19T15:49:32.578--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:7\"', '2026-03-19 15:49:33');
INSERT INTO `sys_rizhi` VALUES (8134, '\"请求访问时间:2026-03-19T15:49:32.594--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:33');
INSERT INTO `sys_rizhi` VALUES (8135, '\"请求访问时间:2026-03-19T15:49:34.538--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:35');
INSERT INTO `sys_rizhi` VALUES (8136, '\"请求访问时间:2026-03-19T15:49:36.225--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:49:36');
INSERT INTO `sys_rizhi` VALUES (8137, '\"请求访问时间:2026-03-19T15:49:36.242--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:13\"', '2026-03-19 15:49:36');
INSERT INTO `sys_rizhi` VALUES (8138, '\"请求访问时间:2026-03-19T15:49:37.155--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:37');
INSERT INTO `sys_rizhi` VALUES (8139, '\"请求访问时间:2026-03-19T15:49:38.850--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:49:39');
INSERT INTO `sys_rizhi` VALUES (8140, '\"请求访问时间:2026-03-19T15:49:38.850--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/37操作人id:13\"', '2026-03-19 15:49:39');
INSERT INTO `sys_rizhi` VALUES (8141, '\"请求访问时间:2026-03-19T15:49:38.867--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:39');
INSERT INTO `sys_rizhi` VALUES (8142, '\"请求访问时间:2026-03-19T15:49:39.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:39');
INSERT INTO `sys_rizhi` VALUES (8143, '\"请求访问时间:2026-03-19T15:49:40.850--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:41');
INSERT INTO `sys_rizhi` VALUES (8144, '\"请求访问时间:2026-03-19T15:49:41.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:41');
INSERT INTO `sys_rizhi` VALUES (8145, '\"请求访问时间:2026-03-19T15:49:41.368--操作人:画师--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:13\"', '2026-03-19 15:49:41');
INSERT INTO `sys_rizhi` VALUES (8146, '\"请求访问时间:2026-03-19T15:49:41.380--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:41');
INSERT INTO `sys_rizhi` VALUES (8147, '\"请求访问时间:2026-03-19T15:49:42.847--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:43');
INSERT INTO `sys_rizhi` VALUES (8148, '\"请求访问时间:2026-03-19T15:49:43.152--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:43');
INSERT INTO `sys_rizhi` VALUES (8149, '\"请求访问时间:2026-03-19T15:49:44.851--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:45');
INSERT INTO `sys_rizhi` VALUES (8150, '\"请求访问时间:2026-03-19T15:49:45.150--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:45');
INSERT INTO `sys_rizhi` VALUES (8151, '\"请求访问时间:2026-03-19T15:49:45.961--操作人:画师--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:13\"', '2026-03-19 15:49:46');
INSERT INTO `sys_rizhi` VALUES (8152, '\"请求访问时间:2026-03-19T15:49:45.973--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:46');
INSERT INTO `sys_rizhi` VALUES (8153, '\"请求访问时间:2026-03-19T15:49:46.847--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:47');
INSERT INTO `sys_rizhi` VALUES (8154, '\"请求访问时间:2026-03-19T15:49:47.147--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:47');
INSERT INTO `sys_rizhi` VALUES (8155, '\"请求访问时间:2026-03-19T15:49:48.541--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:49');
INSERT INTO `sys_rizhi` VALUES (8156, '\"请求访问时间:2026-03-19T15:49:49.153--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:49');
INSERT INTO `sys_rizhi` VALUES (8157, '\"请求访问时间:2026-03-19T15:49:50.553--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:51');
INSERT INTO `sys_rizhi` VALUES (8158, '\"请求访问时间:2026-03-19T15:49:50.847--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:51');
INSERT INTO `sys_rizhi` VALUES (8159, '\"请求访问时间:2026-03-19T15:49:52.796--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:53');
INSERT INTO `sys_rizhi` VALUES (8160, '\"请求访问时间:2026-03-19T15:49:53.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:53');
INSERT INTO `sys_rizhi` VALUES (8161, '\"请求访问时间:2026-03-19T15:49:54.858--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:55');
INSERT INTO `sys_rizhi` VALUES (8162, '\"请求访问时间:2026-03-19T15:49:55.160--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:55');
INSERT INTO `sys_rizhi` VALUES (8163, '\"请求访问时间:2026-03-19T15:49:56.858--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:57');
INSERT INTO `sys_rizhi` VALUES (8164, '\"请求访问时间:2026-03-19T15:49:57.158--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:57');
INSERT INTO `sys_rizhi` VALUES (8165, '\"请求访问时间:2026-03-19T15:49:58.859--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:49:59');
INSERT INTO `sys_rizhi` VALUES (8166, '\"请求访问时间:2026-03-19T15:49:59.159--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:49:59');
INSERT INTO `sys_rizhi` VALUES (8167, '\"请求访问时间:2026-03-19T15:50:00.487--操作人:画师--请求方式:POST--请求url:http://localhost:9999/sysLiuyans/add操作人id:13\"', '2026-03-19 15:50:00');
INSERT INTO `sys_rizhi` VALUES (8168, '\"请求访问时间:2026-03-19T15:50:00.499--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:01');
INSERT INTO `sys_rizhi` VALUES (8169, '\"请求访问时间:2026-03-19T15:50:00.846--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:01');
INSERT INTO `sys_rizhi` VALUES (8170, '\"请求访问时间:2026-03-19T15:50:01.154--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:50:01');
INSERT INTO `sys_rizhi` VALUES (8171, '\"请求访问时间:2026-03-19T15:50:02.546--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:50:03');
INSERT INTO `sys_rizhi` VALUES (8172, '\"请求访问时间:2026-03-19T15:50:03.146--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:03');
INSERT INTO `sys_rizhi` VALUES (8173, '\"请求访问时间:2026-03-19T15:50:04.540--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:50:05');
INSERT INTO `sys_rizhi` VALUES (8174, '\"请求访问时间:2026-03-19T15:50:05.147--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:05');
INSERT INTO `sys_rizhi` VALUES (8175, '\"请求访问时间:2026-03-19T15:50:06.540--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:50:07');
INSERT INTO `sys_rizhi` VALUES (8176, '\"请求访问时间:2026-03-19T15:50:07.155--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:07');
INSERT INTO `sys_rizhi` VALUES (8177, '\"请求访问时间:2026-03-19T15:50:08.542--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:50:09');
INSERT INTO `sys_rizhi` VALUES (8178, '\"请求访问时间:2026-03-19T15:50:09.159--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:09');
INSERT INTO `sys_rizhi` VALUES (8179, '\"请求访问时间:2026-03-19T15:50:10.541--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:7\"', '2026-03-19 15:50:11');
INSERT INTO `sys_rizhi` VALUES (8180, '\"请求访问时间:2026-03-19T15:50:11.152--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:11');
INSERT INTO `sys_rizhi` VALUES (8181, '\"请求访问时间:2026-03-19T15:50:12.162--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:12');
INSERT INTO `sys_rizhi` VALUES (8182, '\"请求访问时间:2026-03-19T15:50:12.193--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:50:12');
INSERT INTO `sys_rizhi` VALUES (8183, '\"请求访问时间:2026-03-19T15:50:13.156--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysLiuyans/list操作人id:13\"', '2026-03-19 15:50:13');
INSERT INTO `sys_rizhi` VALUES (8184, '\"请求访问时间:2026-03-19T15:50:15.297--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:50:15');
INSERT INTO `sys_rizhi` VALUES (8185, '\"请求访问时间:2026-03-19T15:50:15.312--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:13\"', '2026-03-19 15:50:15');
INSERT INTO `sys_rizhi` VALUES (8186, '\"请求访问时间:2026-03-19T15:50:15.945--操作人:画师--请求方式:PUT--请求url:http://localhost:9999/sysOrder/update操作人id:13\"', '2026-03-19 15:50:16');
INSERT INTO `sys_rizhi` VALUES (8187, '\"请求访问时间:2026-03-19T15:50:15.959--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:13\"', '2026-03-19 15:50:16');
INSERT INTO `sys_rizhi` VALUES (8188, '\"请求访问时间:2026-03-19T15:50:18.278--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:18');
INSERT INTO `sys_rizhi` VALUES (8189, '\"请求访问时间:2026-03-19T15:50:18.296--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:50:18');
INSERT INTO `sys_rizhi` VALUES (8190, '\"请求访问时间:2026-03-19T15:50:18.933--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/getById/37操作人id:7\"', '2026-03-19 15:50:19');
INSERT INTO `sys_rizhi` VALUES (8191, '\"请求访问时间:2026-03-19T15:50:22.602--操作人:用户--请求方式:PUT--请求url:http://localhost:9999/sysOrder/update操作人id:7\"', '2026-03-19 15:50:23');
INSERT INTO `sys_rizhi` VALUES (8192, '\"请求访问时间:2026-03-19T15:50:22.622--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:50:23');
INSERT INTO `sys_rizhi` VALUES (8193, '\"请求访问时间:2026-03-19T15:50:22.628--操作人:用户--请求方式:POST--请求url:http://localhost:9999/userArticleOperation/add操作人id:7\"', '2026-03-19 15:50:23');
INSERT INTO `sys_rizhi` VALUES (8194, '\"请求访问时间:2026-03-19T15:50:24.204--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8195, '\"请求访问时间:2026-03-19T15:50:24.209--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8196, '\"请求访问时间:2026-03-19T15:50:24.209--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8197, '\"请求访问时间:2026-03-19T15:50:24.209--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8198, '\"请求访问时间:2026-03-19T15:50:24.230--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8199, '\"请求访问时间:2026-03-19T15:50:24.239--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8200, '\"请求访问时间:2026-03-19T15:50:24.253--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:50:24');
INSERT INTO `sys_rizhi` VALUES (8201, '\"请求访问时间:2026-03-19T15:50:25.837--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:26');
INSERT INTO `sys_rizhi` VALUES (8202, '\"请求访问时间:2026-03-19T15:50:28.367--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:28');
INSERT INTO `sys_rizhi` VALUES (8203, '\"请求访问时间:2026-03-19T15:50:28.386--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLiuyan/list操作人id:7\"', '2026-03-19 15:50:28');
INSERT INTO `sys_rizhi` VALUES (8204, '\"请求访问时间:2026-03-19T15:50:29.508--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:30');
INSERT INTO `sys_rizhi` VALUES (8205, '\"请求访问时间:2026-03-19T15:50:29.532--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysShoucang/list操作人id:7\"', '2026-03-19 15:50:30');
INSERT INTO `sys_rizhi` VALUES (8206, '\"请求访问时间:2026-03-19T15:50:31.626--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:32');
INSERT INTO `sys_rizhi` VALUES (8207, '\"请求访问时间:2026-03-19T15:50:31.647--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:50:32');
INSERT INTO `sys_rizhi` VALUES (8208, '\"请求访问时间:2026-03-19T15:50:31.961--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:32');
INSERT INTO `sys_rizhi` VALUES (8209, '\"请求访问时间:2026-03-19T15:50:31.984--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:7\"', '2026-03-19 15:50:32');
INSERT INTO `sys_rizhi` VALUES (8210, '\"请求访问时间:2026-03-19T15:50:34.173--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:34');
INSERT INTO `sys_rizhi` VALUES (8211, '\"请求访问时间:2026-03-19T15:50:34.198--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:34');
INSERT INTO `sys_rizhi` VALUES (8212, '\"请求访问时间:2026-03-19T15:50:35.766--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysFenlei/list操作人id:7\"', '2026-03-19 15:50:36');
INSERT INTO `sys_rizhi` VALUES (8213, '\"请求访问时间:2026-03-19T15:50:35.767--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/getById/9操作人id:7\"', '2026-03-19 15:50:36');
INSERT INTO `sys_rizhi` VALUES (8214, '\"请求访问时间:2026-03-19T15:50:35.766--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:36');
INSERT INTO `sys_rizhi` VALUES (8215, '\"请求访问时间:2026-03-19T15:50:38.698--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:39');
INSERT INTO `sys_rizhi` VALUES (8216, '\"请求访问时间:2026-03-19T15:50:38.734--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:39');
INSERT INTO `sys_rizhi` VALUES (8217, '\"请求访问时间:2026-03-19T15:50:42.107--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:50:42');
INSERT INTO `sys_rizhi` VALUES (8218, '\"请求访问时间:2026-03-19T15:50:42.129--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:13\"', '2026-03-19 15:50:42');
INSERT INTO `sys_rizhi` VALUES (8219, '\"请求访问时间:2026-03-19T15:50:47.090--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8220, '\"请求访问时间:2026-03-19T15:50:47.102--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8221, '\"请求访问时间:2026-03-19T15:50:47.102--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8222, '\"请求访问时间:2026-03-19T15:50:47.102--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8223, '\"请求访问时间:2026-03-19T15:50:47.110--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8224, '\"请求访问时间:2026-03-19T15:50:47.138--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8225, '\"请求访问时间:2026-03-19T15:50:47.195--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:50:47');
INSERT INTO `sys_rizhi` VALUES (8226, '\"请求访问时间:2026-03-19T15:50:47.920--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:48');
INSERT INTO `sys_rizhi` VALUES (8227, '\"请求访问时间:2026-03-19T15:50:49.276--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:49');
INSERT INTO `sys_rizhi` VALUES (8228, '\"请求访问时间:2026-03-19T15:50:49.278--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:49');
INSERT INTO `sys_rizhi` VALUES (8229, '\"请求访问时间:2026-03-19T15:50:49.278--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysPinglun/list操作人id:7\"', '2026-03-19 15:50:49');
INSERT INTO `sys_rizhi` VALUES (8230, '\"请求访问时间:2026-03-19T15:50:49.300--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:49');
INSERT INTO `sys_rizhi` VALUES (8231, '\"请求访问时间:2026-03-19T15:50:50.967--操作人:用户--请求方式:POST--请求url:http://localhost:9999/sysPinglun/add操作人id:7\"', '2026-03-19 15:50:51');
INSERT INTO `sys_rizhi` VALUES (8232, '\"请求访问时间:2026-03-19T15:50:50.981--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:51');
INSERT INTO `sys_rizhi` VALUES (8233, '\"请求访问时间:2026-03-19T15:50:51.761--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8234, '\"请求访问时间:2026-03-19T15:50:52.314--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8235, '\"请求访问时间:2026-03-19T15:50:52.313--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8236, '\"请求访问时间:2026-03-19T15:50:52.314--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8237, '\"请求访问时间:2026-03-19T15:50:52.314--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysLunbo/list操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8238, '\"请求访问时间:2026-03-19T15:50:52.340--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8239, '\"请求访问时间:2026-03-19T15:50:52.356--操作人:用户--请求方式:GET--请求url:http://localhost:9999/userArticleOperation/recommendations/7操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8240, '\"请求访问时间:2026-03-19T15:50:52.369--操作人:用户--请求方式:GET--请求url:http://localhost:9999/sysHuagao/tuijianlist操作人id:7\"', '2026-03-19 15:50:52');
INSERT INTO `sys_rizhi` VALUES (8241, '\"请求访问时间:2026-03-19T15:50:53.093--操作人:用户--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:7\"', '2026-03-19 15:50:53');
INSERT INTO `sys_rizhi` VALUES (8242, '\"请求访问时间:2026-03-19T15:51:05.906--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysZuopin/list操作人id:1\"', '2026-03-19 15:51:06');
INSERT INTO `sys_rizhi` VALUES (8243, '\"请求访问时间:2026-03-19T15:51:07.619--操作人:管理员--请求方式:GET--请求url:http://localhost:9999/sysOrder/list操作人id:1\"', '2026-03-19 15:51:08');
INSERT INTO `sys_rizhi` VALUES (8244, '\"请求访问时间:2026-03-19T15:51:57.863--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:51:58');
INSERT INTO `sys_rizhi` VALUES (8245, '\"请求访问时间:2026-03-19T15:51:57.877--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:13\"', '2026-03-19 15:51:58');
INSERT INTO `sys_rizhi` VALUES (8246, '\"请求访问时间:2026-03-19T15:51:59.331--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysHuagao/getById/15操作人id:13\"', '2026-03-19 15:51:59');
INSERT INTO `sys_rizhi` VALUES (8247, '\"请求访问时间:2026-03-19T15:51:59.331--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:51:59');
INSERT INTO `sys_rizhi` VALUES (8248, '\"请求访问时间:2026-03-19T15:51:59.331--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysFenlei/list操作人id:13\"', '2026-03-19 15:51:59');
INSERT INTO `sys_rizhi` VALUES (8249, '\"请求访问时间:2026-03-19T15:52:26.857--操作人:画师--请求方式:PUT--请求url:http://localhost:9999/sysHuagao/update操作人id:13\"', '2026-03-19 15:52:27');
INSERT INTO `sys_rizhi` VALUES (8250, '\"请求访问时间:2026-03-19T15:52:27.402--操作人:画师--请求方式:GET--请求url:http://localhost:9999/user/info操作人id:13\"', '2026-03-19 15:52:27');
INSERT INTO `sys_rizhi` VALUES (8251, '\"请求访问时间:2026-03-19T15:52:27.421--操作人:画师--请求方式:GET--请求url:http://localhost:9999/sysHuagao/list操作人id:13\"', '2026-03-19 15:52:27');

-- ----------------------------
-- Table structure for sys_shoucang
-- ----------------------------
DROP TABLE IF EXISTS `sys_shoucang`;
CREATE TABLE `sys_shoucang`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `wzids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'id',
  `userids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收藏人id',
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面',
  `fenlei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类',
  `price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '价格',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_shoucang
-- ----------------------------

-- ----------------------------
-- Table structure for sys_zuopin
-- ----------------------------
DROP TABLE IF EXISTS `sys_zuopin`;
CREATE TABLE `sys_zuopin`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标题',
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面',
  `fbdate` datetime(0) NULL DEFAULT NULL COMMENT '发布日期',
  `userids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户id',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '帖子内容',
  `dznum` int(0) NULL DEFAULT 0 COMMENT '点赞数量',
  `fenlei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_zuopin
-- ----------------------------
INSERT INTO `sys_zuopin` VALUES (9, '画稿展示', 'https://f1-seo.v3mh.com/social/007e7e5a2944619cab7e38777a417b82-watermark.seo', '2026-03-19 00:00:00', '7', '用户', '<div style=\"max-width: 100%; overflow-x: visible; font-size: 18px; line-height: 30px; color: rgb(34, 34, 34); font-family: arial;\"><p>专业画稿服务，定制您的艺术想象在艺术创作与商业设计的多元需求中，专业画稿服务正成为连接创意与现实的重要桥梁。我们依托经验丰富的画师团队，为您提供全品类、定制化的画稿创作服务，覆盖艺术创作、商业设计、教育需求等多个场景，满足您从个人兴趣到商业项目的各类画稿需求。我们的画稿服务类型丰富多元，无论是用于艺术创作的临摹性画稿、写生性画稿，还是为商业项目定制的创作性画稿，都能精准匹配您的需求。在艺术创作领域，我们可以为画家提供创作前期的推敲稿本，帮助您捕捉灵感、完善构图；在商业设计领域，我们能够承接游戏原画、广告插画、绘本画稿等定制需求，将品牌理念与创意视觉完美融合。同时，针对教育场景，我们还能提供适合临摹学习的标准化画稿，为艺术爱好者与学生提供专业的学习范本。为了保障服务质量与效率，我们建立了完善的服务流程。您只需提供具体需求与参考素材，我们的画师会在24小时内提供初步方案，您可享有2次免费修改机会，确保画稿完全符合您的预期。在交付周期上，常规画稿3-5天即可完成，加急订单最快30分钟出图，满足您的紧急需求。所有画稿均提供版权保障，商业项目画稿版权完全归您所有，让您无后顾之忧。我们坚持高性价比的定价策略，根据画稿类型、尺寸与复杂程度制定透明价格，无任何隐藏费用。A4尺寸基础画稿低至35元，商业定制画稿可根据需求提供详细报价。同时，我们支持手绘与板绘两种创作形式，无论是传统纸质画稿还是数字化电子画稿，都能为您呈现细腻生动的视觉效果。选择我们的画稿服务，不仅是选择一份专业的艺术创作，更是选择一个可靠的创意合作伙伴。我们将以严谨的创作态度、高效的服务流程，为您打造兼具艺术价值与实用功能的画稿作品，让每一份创意都能完美落地。 （AI生成）</p></div><p style=\"border: 0px; margin-top: 0.63em; margin-bottom: 1.8em; counter-reset: list-1 0 list-2 0 list-3 0 list-4 0 list-5 0 list-6 0 list-7 0 list-8 0 list-9 0; color: rgb(25, 25, 25); font-family: &quot;PingFang SC&quot;, Arial, 微软雅黑, 宋体, simsun, sans-serif;\"></p><p style=\"box-sizing: inherit; margin-top: 34px; margin-bottom: 34px; text-align: justify; color: rgb(64, 64, 64); font-family: Arial, &quot;Hiragino Sans GB&quot;, STHeiti, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft Yahei&quot;, &quot;WenQuanYi Micro Hei&quot;, sans-serif; font-size: 18px;\"></p>', 21, NULL);

-- ----------------------------
-- Table structure for user_article_operation
-- ----------------------------
DROP TABLE IF EXISTS `user_article_operation`;
CREATE TABLE `user_article_operation`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `user_id` int(0) NULL DEFAULT NULL,
  `article_id` int(0) NULL DEFAULT NULL,
  `operation_type` int(0) NULL DEFAULT NULL COMMENT '打分(1-5分)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1364 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_article_operation
-- ----------------------------
INSERT INTO `user_article_operation` VALUES (1211, 7, 1, 15);
INSERT INTO `user_article_operation` VALUES (1212, 7, 2, 10);
INSERT INTO `user_article_operation` VALUES (1213, 7, 3, 5);
INSERT INTO `user_article_operation` VALUES (1214, 7, 1, 15);
INSERT INTO `user_article_operation` VALUES (1215, 7, 4, 15);
INSERT INTO `user_article_operation` VALUES (1216, 8, 1, 15);
INSERT INTO `user_article_operation` VALUES (1217, 8, 2, 15);
INSERT INTO `user_article_operation` VALUES (1218, 8, 3, 10);
INSERT INTO `user_article_operation` VALUES (1219, 8, 5, 5);
INSERT INTO `user_article_operation` VALUES (1220, 8, 4, 10);
INSERT INTO `user_article_operation` VALUES (1221, 12, 1, 15);
INSERT INTO `user_article_operation` VALUES (1222, 12, 2, 10);
INSERT INTO `user_article_operation` VALUES (1223, 12, 3, 5);
INSERT INTO `user_article_operation` VALUES (1224, 12, 4, 15);
INSERT INTO `user_article_operation` VALUES (1225, 12, 5, 10);
INSERT INTO `user_article_operation` VALUES (1226, 7, 11, 15);
INSERT INTO `user_article_operation` VALUES (1227, 7, 12, 10);
INSERT INTO `user_article_operation` VALUES (1228, 7, 13, 5);
INSERT INTO `user_article_operation` VALUES (1229, 7, 11, 15);
INSERT INTO `user_article_operation` VALUES (1230, 7, 14, 15);
INSERT INTO `user_article_operation` VALUES (1231, 8, 11, 15);
INSERT INTO `user_article_operation` VALUES (1232, 8, 12, 15);
INSERT INTO `user_article_operation` VALUES (1233, 8, 13, 10);
INSERT INTO `user_article_operation` VALUES (1234, 8, 15, 5);
INSERT INTO `user_article_operation` VALUES (1235, 8, 14, 10);
INSERT INTO `user_article_operation` VALUES (1236, 12, 11, 15);
INSERT INTO `user_article_operation` VALUES (1237, 12, 12, 10);
INSERT INTO `user_article_operation` VALUES (1238, 12, 13, 5);
INSERT INTO `user_article_operation` VALUES (1239, 12, 14, 15);
INSERT INTO `user_article_operation` VALUES (1240, 12, 15, 10);
INSERT INTO `user_article_operation` VALUES (1241, 7, 21, 15);
INSERT INTO `user_article_operation` VALUES (1242, 7, 22, 10);
INSERT INTO `user_article_operation` VALUES (1243, 7, 23, 5);
INSERT INTO `user_article_operation` VALUES (1244, 7, 21, 15);
INSERT INTO `user_article_operation` VALUES (1245, 7, 24, 15);
INSERT INTO `user_article_operation` VALUES (1246, 8, 21, 15);
INSERT INTO `user_article_operation` VALUES (1247, 8, 22, 15);
INSERT INTO `user_article_operation` VALUES (1248, 8, 23, 10);
INSERT INTO `user_article_operation` VALUES (1249, 8, 25, 5);
INSERT INTO `user_article_operation` VALUES (1250, 8, 24, 10);
INSERT INTO `user_article_operation` VALUES (1251, 12, 21, 15);
INSERT INTO `user_article_operation` VALUES (1252, 12, 22, 10);
INSERT INTO `user_article_operation` VALUES (1253, 12, 23, 5);
INSERT INTO `user_article_operation` VALUES (1254, 12, 24, 15);
INSERT INTO `user_article_operation` VALUES (1255, 12, 25, 10);
INSERT INTO `user_article_operation` VALUES (1256, 8, 31, 15);
INSERT INTO `user_article_operation` VALUES (1257, 8, 32, 10);
INSERT INTO `user_article_operation` VALUES (1258, 8, 33, 5);
INSERT INTO `user_article_operation` VALUES (1259, 8, 31, 15);
INSERT INTO `user_article_operation` VALUES (1260, 8, 34, 15);
INSERT INTO `user_article_operation` VALUES (1261, 7, 31, 15);
INSERT INTO `user_article_operation` VALUES (1262, 7, 32, 15);
INSERT INTO `user_article_operation` VALUES (1263, 7, 33, 10);
INSERT INTO `user_article_operation` VALUES (1264, 7, 35, 5);
INSERT INTO `user_article_operation` VALUES (1265, 7, 34, 10);
INSERT INTO `user_article_operation` VALUES (1266, 12, 31, 15);
INSERT INTO `user_article_operation` VALUES (1267, 12, 32, 10);
INSERT INTO `user_article_operation` VALUES (1268, 12, 33, 5);
INSERT INTO `user_article_operation` VALUES (1269, 12, 34, 15);
INSERT INTO `user_article_operation` VALUES (1270, 12, 35, 10);
INSERT INTO `user_article_operation` VALUES (1271, 8, 41, 15);
INSERT INTO `user_article_operation` VALUES (1272, 8, 42, 10);
INSERT INTO `user_article_operation` VALUES (1273, 8, 43, 5);
INSERT INTO `user_article_operation` VALUES (1274, 8, 41, 15);
INSERT INTO `user_article_operation` VALUES (1275, 8, 44, 15);
INSERT INTO `user_article_operation` VALUES (1276, 7, 41, 15);
INSERT INTO `user_article_operation` VALUES (1277, 7, 42, 15);
INSERT INTO `user_article_operation` VALUES (1278, 7, 43, 10);
INSERT INTO `user_article_operation` VALUES (1279, 7, 45, 5);
INSERT INTO `user_article_operation` VALUES (1280, 7, 44, 10);
INSERT INTO `user_article_operation` VALUES (1281, 12, 41, 15);
INSERT INTO `user_article_operation` VALUES (1282, 12, 42, 10);
INSERT INTO `user_article_operation` VALUES (1283, 12, 43, 5);
INSERT INTO `user_article_operation` VALUES (1284, 12, 44, 15);
INSERT INTO `user_article_operation` VALUES (1285, 12, 45, 10);
INSERT INTO `user_article_operation` VALUES (1286, 8, 51, 15);
INSERT INTO `user_article_operation` VALUES (1287, 8, 52, 10);
INSERT INTO `user_article_operation` VALUES (1288, 8, 53, 5);
INSERT INTO `user_article_operation` VALUES (1289, 8, 51, 15);
INSERT INTO `user_article_operation` VALUES (1290, 8, 54, 15);
INSERT INTO `user_article_operation` VALUES (1291, 7, 51, 15);
INSERT INTO `user_article_operation` VALUES (1292, 7, 52, 15);
INSERT INTO `user_article_operation` VALUES (1293, 7, 53, 10);
INSERT INTO `user_article_operation` VALUES (1294, 7, 55, 5);
INSERT INTO `user_article_operation` VALUES (1295, 7, 54, 10);
INSERT INTO `user_article_operation` VALUES (1296, 12, 51, 15);
INSERT INTO `user_article_operation` VALUES (1297, 12, 52, 10);
INSERT INTO `user_article_operation` VALUES (1298, 12, 53, 5);
INSERT INTO `user_article_operation` VALUES (1299, 12, 54, 15);
INSERT INTO `user_article_operation` VALUES (1300, 12, 55, 10);
INSERT INTO `user_article_operation` VALUES (1301, 12, 61, 15);
INSERT INTO `user_article_operation` VALUES (1302, 12, 62, 10);
INSERT INTO `user_article_operation` VALUES (1303, 12, 63, 5);
INSERT INTO `user_article_operation` VALUES (1304, 12, 61, 15);
INSERT INTO `user_article_operation` VALUES (1305, 12, 64, 15);
INSERT INTO `user_article_operation` VALUES (1306, 7, 61, 15);
INSERT INTO `user_article_operation` VALUES (1307, 7, 62, 15);
INSERT INTO `user_article_operation` VALUES (1308, 7, 63, 10);
INSERT INTO `user_article_operation` VALUES (1309, 7, 65, 5);
INSERT INTO `user_article_operation` VALUES (1310, 7, 64, 10);
INSERT INTO `user_article_operation` VALUES (1311, 8, 61, 15);
INSERT INTO `user_article_operation` VALUES (1312, 8, 62, 10);
INSERT INTO `user_article_operation` VALUES (1313, 8, 63, 5);
INSERT INTO `user_article_operation` VALUES (1314, 8, 64, 15);
INSERT INTO `user_article_operation` VALUES (1315, 8, 65, 10);
INSERT INTO `user_article_operation` VALUES (1316, 12, 71, 15);
INSERT INTO `user_article_operation` VALUES (1317, 12, 72, 10);
INSERT INTO `user_article_operation` VALUES (1318, 12, 73, 5);
INSERT INTO `user_article_operation` VALUES (1319, 12, 71, 15);
INSERT INTO `user_article_operation` VALUES (1320, 12, 74, 15);
INSERT INTO `user_article_operation` VALUES (1321, 7, 71, 15);
INSERT INTO `user_article_operation` VALUES (1322, 7, 72, 15);
INSERT INTO `user_article_operation` VALUES (1323, 7, 73, 10);
INSERT INTO `user_article_operation` VALUES (1324, 7, 75, 5);
INSERT INTO `user_article_operation` VALUES (1325, 7, 74, 10);
INSERT INTO `user_article_operation` VALUES (1326, 8, 71, 15);
INSERT INTO `user_article_operation` VALUES (1327, 8, 72, 10);
INSERT INTO `user_article_operation` VALUES (1328, 8, 73, 5);
INSERT INTO `user_article_operation` VALUES (1329, 8, 74, 15);
INSERT INTO `user_article_operation` VALUES (1330, 8, 75, 10);
INSERT INTO `user_article_operation` VALUES (1331, 12, 81, 15);
INSERT INTO `user_article_operation` VALUES (1332, 12, 82, 10);
INSERT INTO `user_article_operation` VALUES (1333, 12, 83, 5);
INSERT INTO `user_article_operation` VALUES (1334, 12, 81, 15);
INSERT INTO `user_article_operation` VALUES (1335, 12, 84, 15);
INSERT INTO `user_article_operation` VALUES (1336, 7, 81, 15);
INSERT INTO `user_article_operation` VALUES (1337, 7, 82, 15);
INSERT INTO `user_article_operation` VALUES (1338, 7, 83, 10);
INSERT INTO `user_article_operation` VALUES (1339, 7, 85, 5);
INSERT INTO `user_article_operation` VALUES (1340, 7, 84, 10);
INSERT INTO `user_article_operation` VALUES (1341, 8, 81, 15);
INSERT INTO `user_article_operation` VALUES (1342, 8, 82, 10);
INSERT INTO `user_article_operation` VALUES (1343, 8, 83, 5);
INSERT INTO `user_article_operation` VALUES (1344, 8, 84, 15);
INSERT INTO `user_article_operation` VALUES (1345, 8, 85, 10);
INSERT INTO `user_article_operation` VALUES (1346, 7, 22, 15);
INSERT INTO `user_article_operation` VALUES (1347, 7, 22, 15);
INSERT INTO `user_article_operation` VALUES (1348, 7, 21, 15);
INSERT INTO `user_article_operation` VALUES (1349, 7, 20, 10);
INSERT INTO `user_article_operation` VALUES (1350, 7, 18, 5);
INSERT INTO `user_article_operation` VALUES (1351, 7, 23, 10);
INSERT INTO `user_article_operation` VALUES (1352, 7, 24, 15);
INSERT INTO `user_article_operation` VALUES (1353, 7, 25, 10);
INSERT INTO `user_article_operation` VALUES (1354, 7, 26, 15);
INSERT INTO `user_article_operation` VALUES (1355, 7, 27, 10);
INSERT INTO `user_article_operation` VALUES (1356, 7, 28, 10);
INSERT INTO `user_article_operation` VALUES (1357, 7, 29, 15);
INSERT INTO `user_article_operation` VALUES (1358, 7, 30, 10);
INSERT INTO `user_article_operation` VALUES (1359, 7, 31, 10);
INSERT INTO `user_article_operation` VALUES (1360, 7, 32, 10);
INSERT INTO `user_article_operation` VALUES (1361, 7, 33, 10);
INSERT INTO `user_article_operation` VALUES (1362, 7, 34, 10);
INSERT INTO `user_article_operation` VALUES (1363, 7, 35, 10);
INSERT INTO `user_article_operation` VALUES (1364, 7, 37, 10);

-- ----------------------------
-- Table structure for x_menu
-- ----------------------------
DROP TABLE IF EXISTS `x_menu`;
CREATE TABLE `x_menu`  (
  `menu_id` int(0) NOT NULL AUTO_INCREMENT,
  `component` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `path` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `redirect` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `parent_id` int(0) NULL DEFAULT NULL,
  `is_leaf` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hidden` tinyint(1) NULL DEFAULT NULL,
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of x_menu
-- ----------------------------
INSERT INTO `x_menu` VALUES (1, 'Layout', '/sys', '/sys/list', 'sysManage', '系统管理', 'userManage', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (2, 'sys/user', 'user', NULL, 'userList', '用户列表', 'user', 1, 'Y', 0);
INSERT INTO `x_menu` VALUES (3, 'sys/role', 'role', NULL, 'roleList', '角色列表', 'roleManage', 1, 'Y', 0);
INSERT INTO `x_menu` VALUES (8, 'sys/route', 'route', NULL, 'routeList', '菜单列表', 'routeManage', 1, 'Y', 0);
INSERT INTO `x_menu` VALUES (9, 'shangp/shangpsh', 'shangpsh', '', 'shangpsh', '画稿服务审核', 'form', 20, 'Y', 0);
INSERT INTO `x_menu` VALUES (10, 'order/orderadglqb', 'orderadglqb', '', 'orderadglqb', '全部订单', 'form', 26, 'Y', 0);
INSERT INTO `x_menu` VALUES (13, 'Layout', '/fenlei', '/fenlei/fenlei', 'fenlei', '分类管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (14, 'fenlei/fenlei', 'fenlei', '', 'fenlei', '分类列表', 'form', 13, 'Y', 0);
INSERT INTO `x_menu` VALUES (15, 'Layout', '/shoucang', '/shoucang/shoucang', 'shoucang', '收藏管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (16, 'shoucang/shoucang', 'shoucang', '', 'shoucang', '我的收藏', 'form', 15, 'Y', 0);
INSERT INTO `x_menu` VALUES (17, 'Layout', '/liuyan', '/liuyan/liuyan', 'liuyan', '反馈管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (18, 'liuyan/liuyan', 'liuyan', '', 'liuyan', '反馈列表', 'form', 17, 'Y', 0);
INSERT INTO `x_menu` VALUES (19, 'liuyan/liuyanyh', 'liuyanyh', '', 'liuyanyh', '我的反馈', 'form', 17, 'Y', 0);
INSERT INTO `x_menu` VALUES (20, 'Layout', '/shangp', '/shangp/shangp', 'shangp', '画稿服务管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (21, 'shangp/shangp', 'shangp', '', 'shangp', '画稿服务列表', 'form', 20, 'Y', 0);
INSERT INTO `x_menu` VALUES (22, 'shangp/spsxj', 'spsxj', '', 'spsxj', '画稿服务上下架', 'form', 20, 'Y', 0);
INSERT INTO `x_menu` VALUES (23, 'Layout', '/fenxiang', '/fenxiang/fenxiang', 'fenxiang', '发布帖子', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (24, 'fenxiang/fenxiang', 'fenxiang', '', 'fenxiang', '帖子列表', 'form', 23, 'Y', 0);
INSERT INTO `x_menu` VALUES (25, 'fenxiang/fenxiangad', 'fenxiangad', '', 'fenxiangad', '帖子管理', 'form', 23, 'Y', 0);
INSERT INTO `x_menu` VALUES (26, 'Layout', '/order', '/order/gouwuche', 'order', '订单管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (27, 'order/gouwuche', 'gouwuche', '', 'gouwuche', '购物车', 'form', 26, 'Y', 0);
INSERT INTO `x_menu` VALUES (28, 'order/ordergl', 'ordergl', '', 'ordergl', '我的订单', 'form', 26, 'Y', 0);
INSERT INTO `x_menu` VALUES (29, 'order/orderadgl', 'orderadgl', '', 'orderadgl', '所有订单', 'form', 26, 'Y', 0);
INSERT INTO `x_menu` VALUES (30, 'Layout', '/tongji', '/tongji/tongji', 'tongji', '统计管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (31, 'tongji/tongji', 'tongji', '', 'tongji', '统计分析', 'form', 30, 'Y', 0);
INSERT INTO `x_menu` VALUES (32, 'Layout', '/rizhi', '/rizhi/rizhi', 'rizhi', '日志管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (33, 'rizhi/rizhi', 'rizhi', NULL, 'rizhi', '日志列表', 'form', 32, 'Y', 0);
INSERT INTO `x_menu` VALUES (34, 'Layout', '/lunbo', '/lunbo/lunbo', 'lunbo', '轮播管理', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (35, 'lunbo/lunbo', 'lunbo', '', 'lunbo', '轮播列表', 'form', 34, 'Y', 0);
INSERT INTO `x_menu` VALUES (36, 'Layout', '/ai', '/ai/ai', 'ai', '智能AI', 'form', 0, 'N', 0);
INSERT INTO `x_menu` VALUES (37, 'ai/ai', 'ai', '', 'ai', 'AI助手', 'form', 36, 'Y', 0);

-- ----------------------------
-- Table structure for x_role
-- ----------------------------
DROP TABLE IF EXISTS `x_role`;
CREATE TABLE `x_role`  (
  `role_id` int(0) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `role_desc` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of x_role
-- ----------------------------
INSERT INTO `x_role` VALUES (1, 'admin', '超级管理员');
INSERT INTO `x_role` VALUES (3, '用户角色', '用户角色');
INSERT INTO `x_role` VALUES (7, '画师角色', '画师角色');

-- ----------------------------
-- Table structure for x_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `x_role_menu`;
CREATE TABLE `x_role_menu`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `role_id` int(0) NULL DEFAULT NULL,
  `menu_id` int(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 555 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of x_role_menu
-- ----------------------------
INSERT INTO `x_role_menu` VALUES (524, 1, 1);
INSERT INTO `x_role_menu` VALUES (525, 1, 2);
INSERT INTO `x_role_menu` VALUES (526, 1, 3);
INSERT INTO `x_role_menu` VALUES (527, 1, 8);
INSERT INTO `x_role_menu` VALUES (528, 1, 13);
INSERT INTO `x_role_menu` VALUES (529, 1, 14);
INSERT INTO `x_role_menu` VALUES (530, 1, 18);
INSERT INTO `x_role_menu` VALUES (531, 1, 9);
INSERT INTO `x_role_menu` VALUES (532, 1, 25);
INSERT INTO `x_role_menu` VALUES (533, 1, 10);
INSERT INTO `x_role_menu` VALUES (534, 1, 30);
INSERT INTO `x_role_menu` VALUES (535, 1, 31);
INSERT INTO `x_role_menu` VALUES (536, 1, 32);
INSERT INTO `x_role_menu` VALUES (537, 1, 33);
INSERT INTO `x_role_menu` VALUES (538, 1, 34);
INSERT INTO `x_role_menu` VALUES (539, 1, 35);
INSERT INTO `x_role_menu` VALUES (540, 1, 17);
INSERT INTO `x_role_menu` VALUES (541, 1, 20);
INSERT INTO `x_role_menu` VALUES (542, 1, 23);
INSERT INTO `x_role_menu` VALUES (543, 1, 26);
INSERT INTO `x_role_menu` VALUES (544, 3, 15);
INSERT INTO `x_role_menu` VALUES (545, 3, 16);
INSERT INTO `x_role_menu` VALUES (546, 3, 19);
INSERT INTO `x_role_menu` VALUES (547, 3, 24);
INSERT INTO `x_role_menu` VALUES (548, 3, 27);
INSERT INTO `x_role_menu` VALUES (549, 3, 28);
INSERT INTO `x_role_menu` VALUES (550, 3, 36);
INSERT INTO `x_role_menu` VALUES (551, 3, 37);
INSERT INTO `x_role_menu` VALUES (552, 3, 17);
INSERT INTO `x_role_menu` VALUES (553, 3, 23);
INSERT INTO `x_role_menu` VALUES (554, 3, 26);
INSERT INTO `x_role_menu` VALUES (555, 7, 19);
INSERT INTO `x_role_menu` VALUES (556, 7, 21);
INSERT INTO `x_role_menu` VALUES (557, 7, 22);
INSERT INTO `x_role_menu` VALUES (558, 7, 24);
INSERT INTO `x_role_menu` VALUES (559, 7, 29);
INSERT INTO `x_role_menu` VALUES (560, 7, 17);
INSERT INTO `x_role_menu` VALUES (561, 7, 20);
INSERT INTO `x_role_menu` VALUES (562, 7, 23);
INSERT INTO `x_role_menu` VALUES (563, 7, 26);

-- ----------------------------
-- Table structure for x_user
-- ----------------------------
DROP TABLE IF EXISTS `x_user`;
CREATE TABLE `x_user`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `status` int(0) NULL DEFAULT NULL,
  `avatar` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `deleted` int(0) NULL DEFAULT 0,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_x_user_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of x_user
-- ----------------------------
INSERT INTO `x_user` VALUES (1, 'admin', '$2a$10$V09HdXM81mNBcnGPQq02iOGqpMsMAKgby/HWjQcI7UaxbvJf7rVjq', 'super@aliyun.com', '15555587436', 1, 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg', 0, '管理员');
INSERT INTO `x_user` VALUES (7, 'yonghu', '$2a$10$897BnVc8MPnIhWFsGfCvUOzAkTO4I8t2U0bS9AW84.pamWogk7JTm', 'wuhang@88.com', '15555587436', 1, 'https://wulaoda-education.oss-cn-beijing.aliyuncs.com/photo/2023/07/13/9778a94b942848adabf800d8677200cf.jpg', 0, '用户');
INSERT INTO `x_user` VALUES (8, '123123', '$2a$10$iIN58hgKA9RcuBwKZ8qbauxpBQbjVZMXNbhFPrInwgEyUIbcdwSwG', NULL, NULL, 1, 'http://localhost:9999/oss/file/download?name=7ac6c5e0-30ae-4b10-bd7e-ab22aaf8cf08.png', 1, '12312');
INSERT INTO `x_user` VALUES (13, 'huashi', '$2a$10$iIN58hgKA9RcuBwKZ8qbauxpBQbjVZMXNbhFPrInwgEyUIbcdwSwG', 'huashi@qq.com', '1232131231', 1, 'http://localhost:9999/oss/file/download?name=7ac6c5e0-30ae-4b10-bd7e-ab22aaf8cf08.png', 0, '画师');

-- ----------------------------
-- Table structure for x_user_role
-- ----------------------------
DROP TABLE IF EXISTS `x_user_role`;
CREATE TABLE `x_user_role`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `user_id` int(0) NULL DEFAULT NULL,
  `role_id` int(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of x_user_role
-- ----------------------------
INSERT INTO `x_user_role` VALUES (1, 1, 1);
INSERT INTO `x_user_role` VALUES (13, 11, 3);
INSERT INTO `x_user_role` VALUES (14, 7, 3);
INSERT INTO `x_user_role` VALUES (22, 13, 7);

SET FOREIGN_KEY_CHECKS = 1;
