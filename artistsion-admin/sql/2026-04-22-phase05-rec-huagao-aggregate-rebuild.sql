SET @target_dt = '2026-04-22';

DROP TEMPORARY TABLE IF EXISTS tmp_rec_hg_item_daily_raw;
CREATE TEMPORARY TABLE tmp_rec_hg_item_daily_raw AS
WITH impression_raw AS (
    SELECT
        DATE(i.created_at) AS dt,
        i.huagao_id,
        MAX(i.shangjia_id) AS shangjia_id,
        COUNT(*) AS impression_cnt,
        SUM(CASE WHEN i.keyword IS NOT NULL AND i.keyword <> '' THEN 1 ELSE 0 END) AS search_impression_cnt,
        SUM(CASE WHEN i.fenlei IS NOT NULL AND i.fenlei <> '' THEN 1 ELSE 0 END) AS filter_fenlei_impression_cnt,
        SUM(CASE WHEN i.tag_id IS NOT NULL THEN 1 ELSE 0 END) AS filter_tag_impression_cnt
    FROM rec_huagao_impression_log i
    WHERE DATE(i.created_at) = @target_dt
    GROUP BY DATE(i.created_at), i.huagao_id
),
action_raw AS (
    SELECT
        DATE(a.created_at) AS dt,
        a.huagao_id,
        MAX(a.shangjia_id) AS shangjia_id,
        SUM(CASE WHEN a.event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
        SUM(CASE WHEN a.event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
        SUM(CASE WHEN a.event_type = 'click_detail' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_click_detail_cnt,
        SUM(CASE WHEN a.event_type = 'favorite' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_favorite_cnt
    FROM rec_huagao_action_log a
    LEFT JOIN rec_huagao_request_log r ON r.request_id = a.request_id
    WHERE DATE(a.created_at) = @target_dt
    GROUP BY DATE(a.created_at), a.huagao_id
),
keyset AS (
    SELECT dt, huagao_id FROM impression_raw
    UNION
    SELECT dt, huagao_id FROM action_raw
)
SELECT
    k.dt,
    k.huagao_id,
    COALESCE(i.shangjia_id, a.shangjia_id) AS shangjia_id,
    COALESCE(i.impression_cnt, 0) AS impression_cnt,
    COALESCE(a.click_detail_cnt, 0) AS click_detail_cnt,
    COALESCE(a.favorite_cnt, 0) AS favorite_cnt,
    COALESCE(i.search_impression_cnt, 0) AS search_impression_cnt,
    COALESCE(i.filter_fenlei_impression_cnt, 0) AS filter_fenlei_impression_cnt,
    COALESCE(i.filter_tag_impression_cnt, 0) AS filter_tag_impression_cnt,
    COALESCE(a.search_click_detail_cnt, 0) AS search_click_detail_cnt,
    COALESCE(a.search_favorite_cnt, 0) AS search_favorite_cnt
FROM keyset k
LEFT JOIN impression_raw i ON i.dt = k.dt AND i.huagao_id = k.huagao_id
LEFT JOIN action_raw a ON a.dt = k.dt AND a.huagao_id = k.huagao_id;

DROP TEMPORARY TABLE IF EXISTS tmp_rec_hg_query_daily_raw;
CREATE TEMPORARY TABLE tmp_rec_hg_query_daily_raw AS
WITH request_raw AS (
    SELECT
        DATE(r.created_at) AS dt,
        r.query_key,
        MAX(r.scene) AS scene,
        MAX(r.keyword) AS keyword,
        MAX(r.normalized_keyword) AS normalized_keyword,
        MAX(r.fenlei) AS fenlei,
        MAX(r.tag_id) AS tag_id,
        MAX(r.has_search) AS has_search,
        MAX(r.has_fenlei_filter) AS has_fenlei_filter,
        MAX(r.has_tag_filter) AS has_tag_filter,
        COUNT(*) AS request_cnt
    FROM rec_huagao_request_log r
    WHERE DATE(r.created_at) = @target_dt
    GROUP BY DATE(r.created_at), r.query_key
),
impression_raw AS (
    SELECT
        DATE(i.created_at) AS dt,
        r.query_key,
        COUNT(*) AS impression_cnt
    FROM rec_huagao_impression_log i
    INNER JOIN rec_huagao_request_log r ON r.request_id = i.request_id
    WHERE DATE(i.created_at) = @target_dt
    GROUP BY DATE(i.created_at), r.query_key
),
action_raw AS (
    SELECT
        DATE(a.created_at) AS dt,
        r.query_key,
        SUM(CASE WHEN a.event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
        SUM(CASE WHEN a.event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt
    FROM rec_huagao_action_log a
    INNER JOIN rec_huagao_request_log r ON r.request_id = a.request_id
    WHERE DATE(a.created_at) = @target_dt
    GROUP BY DATE(a.created_at), r.query_key
),
keyset AS (
    SELECT dt, query_key FROM request_raw
    UNION
    SELECT dt, query_key FROM impression_raw
    UNION
    SELECT dt, query_key FROM action_raw
)
SELECT
    k.dt,
    k.query_key,
    rq.scene,
    rq.keyword,
    rq.normalized_keyword,
    rq.fenlei,
    rq.tag_id,
    COALESCE(rq.has_search, 0) AS has_search,
    COALESCE(rq.has_fenlei_filter, 0) AS has_fenlei_filter,
    COALESCE(rq.has_tag_filter, 0) AS has_tag_filter,
    COALESCE(rq.request_cnt, 0) AS request_cnt,
    COALESCE(ir.impression_cnt, 0) AS impression_cnt,
    COALESCE(ar.click_detail_cnt, 0) AS click_detail_cnt,
    COALESCE(ar.favorite_cnt, 0) AS favorite_cnt
FROM keyset k
LEFT JOIN request_raw rq ON rq.dt = k.dt AND rq.query_key = k.query_key
LEFT JOIN impression_raw ir ON ir.dt = k.dt AND ir.query_key = k.query_key
LEFT JOIN action_raw ar ON ar.dt = k.dt AND ar.query_key = k.query_key;

START TRANSACTION;

DELETE FROM rec_huagao_item_stat_daily WHERE dt = @target_dt;
INSERT INTO rec_huagao_item_stat_daily (
    dt, huagao_id, shangjia_id, impression_cnt, click_detail_cnt, favorite_cnt,
    search_impression_cnt, filter_fenlei_impression_cnt, filter_tag_impression_cnt,
    search_click_detail_cnt, search_favorite_cnt
)
SELECT
    dt, huagao_id, shangjia_id, impression_cnt, click_detail_cnt, favorite_cnt,
    search_impression_cnt, filter_fenlei_impression_cnt, filter_tag_impression_cnt,
    search_click_detail_cnt, search_favorite_cnt
FROM tmp_rec_hg_item_daily_raw;

DELETE FROM rec_huagao_query_stat_daily WHERE dt = @target_dt;
INSERT INTO rec_huagao_query_stat_daily (
    dt, query_key, scene, keyword, normalized_keyword, fenlei, tag_id,
    has_search, has_fenlei_filter, has_tag_filter,
    request_cnt, impression_cnt, click_detail_cnt, favorite_cnt
)
SELECT
    dt, query_key, scene, keyword, normalized_keyword, fenlei, tag_id,
    has_search, has_fenlei_filter, has_tag_filter,
    request_cnt, impression_cnt, click_detail_cnt, favorite_cnt
FROM tmp_rec_hg_query_daily_raw;

COMMIT;

SELECT * FROM rec_huagao_item_stat_daily WHERE dt = @target_dt ORDER BY huagao_id;
SELECT * FROM rec_huagao_query_stat_daily WHERE dt = @target_dt ORDER BY query_key;
