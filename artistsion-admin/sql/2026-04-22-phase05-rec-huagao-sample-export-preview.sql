SET @date_from = '2026-04-22';
SET @date_to = '2026-04-22';
SET @preview_limit = 100;
SET @safe_preview_limit = LEAST(GREATEST(COALESCE(@preview_limit, 100), 1), 500);

WITH action_summary AS (
    SELECT
        request_id,
        huagao_id,
        SUM(CASE WHEN event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
        SUM(CASE WHEN event_type = 'detail_view' THEN 1 ELSE 0 END) AS detail_view_cnt,
        SUM(CASE WHEN event_type = 'detail_dwell' THEN 1 ELSE 0 END) AS detail_dwell_cnt,
        SUM(CASE WHEN event_type = 'detail_dwell' THEN COALESCE(event_value, 0) ELSE 0 END) AS detail_dwell_total_ms,
        SUM(CASE WHEN event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
        SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_cart_cnt,
        SUM(CASE WHEN event_type = 'create_order' THEN 1 ELSE 0 END) AS create_order_cnt,
        MIN(CASE WHEN event_type = 'click_detail' THEN created_at END) AS first_click_detail_at,
        MIN(CASE WHEN event_type = 'detail_view' THEN created_at END) AS first_detail_view_at,
        MIN(CASE WHEN event_type = 'favorite' THEN created_at END) AS first_favorite_at,
        MIN(CASE WHEN event_type = 'add_to_cart' THEN created_at END) AS first_add_to_cart_at,
        MIN(CASE WHEN event_type = 'create_order' THEN created_at END) AS first_create_order_at
    FROM rec_huagao_action_log
    GROUP BY request_id, huagao_id
),
ranked_preview AS (
    SELECT
        r.request_id,
        r.scene,
        r.user_id,
        r.visitor_id,
        r.session_id,
        r.keyword,
        r.normalized_keyword,
        r.fenlei,
        r.tag_id,
        r.page_no,
        r.page_size,
        r.sort_mode,
        r.has_search,
        r.has_fenlei_filter,
        r.has_tag_filter,
        i.huagao_id,
        i.shangjia_id,
        i.position,
        i.search_score,
        i.created_at AS impression_at,
        COALESCE(a.click_detail_cnt, 0) AS click_detail_cnt,
        COALESCE(a.detail_view_cnt, 0) AS detail_view_cnt,
        COALESCE(a.detail_dwell_cnt, 0) AS detail_dwell_cnt,
        COALESCE(a.detail_dwell_total_ms, 0) AS detail_dwell_total_ms,
        COALESCE(a.favorite_cnt, 0) AS favorite_cnt,
        COALESCE(a.add_cart_cnt, 0) AS add_cart_cnt,
        COALESCE(a.create_order_cnt, 0) AS create_order_cnt,
        a.first_click_detail_at,
        a.first_detail_view_at,
        a.first_favorite_at,
        a.first_add_to_cart_at,
        a.first_create_order_at,
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
        END AS label_source,
        ROW_NUMBER() OVER (ORDER BY r.created_at DESC, i.position ASC) AS rn
    FROM rec_huagao_request_log r
    INNER JOIN rec_huagao_impression_log i ON i.request_id = r.request_id
    LEFT JOIN action_summary a ON a.request_id = i.request_id AND a.huagao_id = i.huagao_id
    WHERE DATE(r.created_at) BETWEEN @date_from AND @date_to
)
SELECT
    request_id,
    scene,
    user_id,
    visitor_id,
    session_id,
    keyword,
    normalized_keyword,
    fenlei,
    tag_id,
    page_no,
    page_size,
    sort_mode,
    has_search,
    has_fenlei_filter,
    has_tag_filter,
    huagao_id,
    shangjia_id,
    position,
    search_score,
    impression_at,
    click_detail_cnt,
    detail_view_cnt,
    detail_dwell_cnt,
    detail_dwell_total_ms,
    favorite_cnt,
    add_cart_cnt,
    create_order_cnt,
    first_click_detail_at,
    first_detail_view_at,
    first_favorite_at,
    first_add_to_cart_at,
    first_create_order_at,
    relevance,
    label_source
FROM ranked_preview
WHERE rn <= @safe_preview_limit
ORDER BY rn;
