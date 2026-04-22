SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE rec_huagao_action_log ADD COLUMN event_value BIGINT DEFAULT NULL COMMENT ''事件扩展数值，例如停留毫秒'' AFTER position',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'rec_huagao_action_log'
      AND column_name = 'event_value'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN detail_view_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''详情曝光数'' AFTER click_detail_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'detail_view_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN detail_dwell_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''详情停留事件数'' AFTER detail_view_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'detail_dwell_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN detail_dwell_total_ms BIGINT NOT NULL DEFAULT 0 COMMENT ''详情停留总毫秒数'' AFTER detail_dwell_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'detail_dwell_total_ms'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN add_cart_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''加入购物车数'' AFTER favorite_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'add_cart_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN create_order_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''创建订单数'' AFTER add_cart_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'create_order_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN search_detail_view_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''搜索详情曝光数'' AFTER search_click_detail_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'search_detail_view_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN search_detail_dwell_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''搜索详情停留事件数'' AFTER search_detail_view_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'search_detail_dwell_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN search_detail_dwell_total_ms BIGINT NOT NULL DEFAULT 0 COMMENT ''搜索详情停留总毫秒数'' AFTER search_detail_dwell_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'search_detail_dwell_total_ms'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN search_add_cart_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''搜索加入购物车数'' AFTER search_favorite_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'search_add_cart_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_item_stat_daily ADD COLUMN search_create_order_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''搜索创建订单数'' AFTER search_add_cart_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_item_stat_daily' AND column_name = 'search_create_order_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_query_stat_daily ADD COLUMN detail_view_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''详情曝光数'' AFTER click_detail_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_query_stat_daily' AND column_name = 'detail_view_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_query_stat_daily ADD COLUMN detail_dwell_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''详情停留事件数'' AFTER detail_view_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_query_stat_daily' AND column_name = 'detail_dwell_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_query_stat_daily ADD COLUMN detail_dwell_total_ms BIGINT NOT NULL DEFAULT 0 COMMENT ''详情停留总毫秒数'' AFTER detail_dwell_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_query_stat_daily' AND column_name = 'detail_dwell_total_ms'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_query_stat_daily ADD COLUMN add_cart_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''加入购物车数'' AFTER favorite_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_query_stat_daily' AND column_name = 'add_cart_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(COUNT(*) = 0, 'ALTER TABLE rec_huagao_query_stat_daily ADD COLUMN create_order_cnt BIGINT NOT NULL DEFAULT 0 COMMENT ''创建订单数'' AFTER add_cart_cnt', 'SELECT 1')
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'rec_huagao_query_stat_daily' AND column_name = 'create_order_cnt'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
