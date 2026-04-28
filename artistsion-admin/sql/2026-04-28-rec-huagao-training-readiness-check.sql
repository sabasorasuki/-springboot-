SET @date_from = '2026-04-22';
SET @date_to = '2026-04-28';

WITH request_scope AS (
    SELECT *
    FROM rec_huagao_request_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
),
impression_scope AS (
    SELECT *
    FROM rec_huagao_impression_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
),
action_scope AS (
    SELECT *
    FROM rec_huagao_action_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
),
action_summary AS (
    SELECT
        request_id,
        huagao_id,
        SUM(CASE WHEN event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
        SUM(CASE WHEN event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
        SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_cart_cnt,
        SUM(CASE WHEN event_type = 'create_order' THEN 1 ELSE 0 END) AS create_order_cnt
    FROM action_scope
    GROUP BY request_id, huagao_id
),
sample_scope AS (
    SELECT
        r.request_id,
        i.huagao_id,
        CASE
            WHEN COALESCE(a.create_order_cnt, 0) > 0 THEN 4
            WHEN COALESCE(a.add_cart_cnt, 0) > 0 THEN 3
            WHEN COALESCE(a.favorite_cnt, 0) > 0 THEN 2
            WHEN COALESCE(a.click_detail_cnt, 0) > 0 THEN 1
            ELSE 0
        END AS relevance
    FROM request_scope r
    INNER JOIN impression_scope i ON i.request_id = r.request_id
    LEFT JOIN action_summary a ON a.request_id = i.request_id AND a.huagao_id = i.huagao_id
)
SELECT
    @date_from AS date_from,
    @date_to AS date_to,
    (SELECT MIN(created_at) FROM request_scope) AS first_request_at,
    (SELECT MAX(created_at) FROM request_scope) AS last_request_at,
    (SELECT COUNT(*) FROM request_scope) AS request_count,
    (SELECT COUNT(DISTINCT DATE(created_at)) FROM request_scope) AS active_day_count,
    (SELECT COUNT(DISTINCT query_key) FROM request_scope) AS query_count,
    (SELECT COUNT(DISTINCT user_id) FROM request_scope) AS user_count,
    (SELECT COUNT(DISTINCT visitor_id) FROM request_scope) AS visitor_count,
    (SELECT COUNT(DISTINCT session_id) FROM request_scope) AS session_count,
    (SELECT COUNT(DISTINCT CASE
        WHEN user_id IS NOT NULL THEN CONCAT('u:', user_id)
        WHEN visitor_id IS NOT NULL AND visitor_id <> '' THEN CONCAT('v:', visitor_id)
        ELSE NULL
    END) FROM request_scope) AS actor_count,
    COALESCE((SELECT SUM(has_search) FROM request_scope), 0) AS search_request_count,
    COALESCE((SELECT SUM(has_fenlei_filter) FROM request_scope), 0) AS fenlei_filter_request_count,
    COALESCE((SELECT SUM(has_tag_filter) FROM request_scope), 0) AS tag_filter_request_count,
    COALESCE((SELECT SUM(returned_count) FROM request_scope), 0) AS returned_item_count,
    (SELECT COUNT(*) FROM impression_scope) AS impression_count,
    (SELECT COUNT(DISTINCT huagao_id) FROM impression_scope) AS huagao_count,
    (SELECT COUNT(*) FROM action_scope) AS action_count,
    (SELECT COUNT(*) FROM sample_scope) AS sample_count,
    (SELECT COUNT(*) FROM sample_scope WHERE relevance > 0) AS positive_sample_count,
    (SELECT COUNT(DISTINCT relevance) FROM sample_scope) AS label_level_count;

WITH action_summary AS (
    SELECT
        request_id,
        huagao_id,
        SUM(CASE WHEN event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
        SUM(CASE WHEN event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
        SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_cart_cnt,
        SUM(CASE WHEN event_type = 'create_order' THEN 1 ELSE 0 END) AS create_order_cnt
    FROM rec_huagao_action_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
    GROUP BY request_id, huagao_id
),
sample_scope AS (
    SELECT
        r.request_id,
        i.huagao_id,
        CASE
            WHEN COALESCE(a.create_order_cnt, 0) > 0 THEN 4
            WHEN COALESCE(a.add_cart_cnt, 0) > 0 THEN 3
            WHEN COALESCE(a.favorite_cnt, 0) > 0 THEN 2
            WHEN COALESCE(a.click_detail_cnt, 0) > 0 THEN 1
            ELSE 0
        END AS relevance,
        CASE
            WHEN COALESCE(a.create_order_cnt, 0) > 0 THEN 'create_order'
            WHEN COALESCE(a.add_cart_cnt, 0) > 0 THEN 'add_to_cart'
            WHEN COALESCE(a.favorite_cnt, 0) > 0 THEN 'favorite'
            WHEN COALESCE(a.click_detail_cnt, 0) > 0 THEN 'click_detail'
            ELSE 'impression'
        END AS label_source
    FROM rec_huagao_request_log r
    INNER JOIN rec_huagao_impression_log i ON i.request_id = r.request_id
    LEFT JOIN action_summary a ON a.request_id = i.request_id AND a.huagao_id = i.huagao_id
    WHERE DATE(r.created_at) BETWEEN @date_from AND @date_to
)
SELECT
    relevance,
    label_source,
    COUNT(*) AS sample_count,
    COUNT(DISTINCT request_id) AS request_count,
    COUNT(DISTINCT huagao_id) AS huagao_count
FROM sample_scope
GROUP BY relevance, label_source
ORDER BY relevance ASC;

SELECT
    event_type,
    COUNT(*) AS event_count,
    COUNT(DISTINCT request_id) AS request_count,
    COUNT(DISTINCT huagao_id) AS huagao_count,
    COALESCE(SUM(event_value), 0) AS event_value_total
FROM rec_huagao_action_log
WHERE DATE(created_at) BETWEEN @date_from AND @date_to
GROUP BY event_type
ORDER BY event_count DESC, event_type ASC;

WITH request_daily AS (
    SELECT
        DATE(created_at) AS dt,
        COUNT(*) AS request_count,
        SUM(has_search) AS search_request_count
    FROM rec_huagao_request_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
    GROUP BY DATE(created_at)
),
impression_daily AS (
    SELECT
        DATE(created_at) AS dt,
        COUNT(*) AS impression_count,
        COUNT(DISTINCT huagao_id) AS huagao_count
    FROM rec_huagao_impression_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
    GROUP BY DATE(created_at)
),
action_daily AS (
    SELECT
        DATE(created_at) AS dt,
        COUNT(*) AS action_count
    FROM rec_huagao_action_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
    GROUP BY DATE(created_at)
),
keyset AS (
    SELECT dt FROM request_daily
    UNION
    SELECT dt FROM impression_daily
    UNION
    SELECT dt FROM action_daily
)
SELECT
    k.dt,
    COALESCE(r.request_count, 0) AS request_count,
    COALESCE(r.search_request_count, 0) AS search_request_count,
    COALESCE(i.impression_count, 0) AS impression_count,
    COALESCE(i.huagao_count, 0) AS huagao_count,
    COALESCE(a.action_count, 0) AS action_count
FROM keyset k
LEFT JOIN request_daily r ON r.dt = k.dt
LEFT JOIN impression_daily i ON i.dt = k.dt
LEFT JOIN action_daily a ON a.dt = k.dt
ORDER BY k.dt ASC;

SELECT 'impression_without_request' AS check_key, COUNT(*) AS issue_count
FROM rec_huagao_impression_log i
LEFT JOIN rec_huagao_request_log r ON r.request_id = i.request_id
WHERE DATE(i.created_at) BETWEEN @date_from AND @date_to
  AND r.request_id IS NULL
UNION ALL
SELECT 'action_without_request' AS check_key, COUNT(*) AS issue_count
FROM rec_huagao_action_log a
LEFT JOIN rec_huagao_request_log r ON r.request_id = a.request_id
WHERE DATE(a.created_at) BETWEEN @date_from AND @date_to
  AND a.request_id IS NOT NULL
  AND r.request_id IS NULL
UNION ALL
SELECT 'action_without_impression' AS check_key, COUNT(*) AS issue_count
FROM rec_huagao_action_log a
LEFT JOIN rec_huagao_impression_log i ON i.request_id = a.request_id AND i.huagao_id = a.huagao_id
WHERE DATE(a.created_at) BETWEEN @date_from AND @date_to
  AND a.request_id IS NOT NULL
  AND i.id IS NULL
UNION ALL
SELECT 'request_without_identity' AS check_key, COUNT(*) AS issue_count
FROM rec_huagao_request_log r
WHERE DATE(r.created_at) BETWEEN @date_from AND @date_to
  AND r.user_id IS NULL
  AND (r.visitor_id IS NULL OR r.visitor_id = '')
UNION ALL
SELECT 'action_without_identity' AS check_key, COUNT(*) AS issue_count
FROM rec_huagao_action_log a
WHERE DATE(a.created_at) BETWEEN @date_from AND @date_to
  AND a.user_id IS NULL
  AND (a.visitor_id IS NULL OR a.visitor_id = '')
UNION ALL
SELECT 'invalid_detail_dwell' AS check_key, COUNT(*) AS issue_count
FROM rec_huagao_action_log a
WHERE DATE(a.created_at) BETWEEN @date_from AND @date_to
  AND a.event_type = 'detail_dwell'
  AND (a.event_value IS NULL OR a.event_value <= 0)
UNION ALL
SELECT 'duplicate_event_id' AS check_key, COUNT(*) AS issue_count
FROM (
    SELECT event_id
    FROM rec_huagao_action_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
    GROUP BY event_id
    HAVING COUNT(*) > 1
) duplicated_actions
UNION ALL
SELECT 'duplicate_impression_pair' AS check_key, COUNT(*) AS issue_count
FROM (
    SELECT request_id, huagao_id
    FROM rec_huagao_impression_log
    WHERE DATE(created_at) BETWEEN @date_from AND @date_to
    GROUP BY request_id, huagao_id
    HAVING COUNT(*) > 1
) duplicated_impressions;
