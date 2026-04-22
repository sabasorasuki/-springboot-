package com.lf.dao;

import com.lf.entity.RecHuagaoItemStatDaily;
import org.apache.ibatis.annotations.Insert;

public interface RecHuagaoItemStatDailyMapper {

    @Insert({
            "<script>",
            "INSERT INTO rec_huagao_item_stat_daily (",
            "dt, huagao_id, shangjia_id, impression_cnt, click_detail_cnt, detail_view_cnt, detail_dwell_cnt, detail_dwell_total_ms, favorite_cnt, add_cart_cnt, create_order_cnt, ",
            "search_impression_cnt, filter_fenlei_impression_cnt, filter_tag_impression_cnt, ",
            "search_click_detail_cnt, search_detail_view_cnt, search_detail_dwell_cnt, search_detail_dwell_total_ms, search_favorite_cnt, search_add_cart_cnt, search_create_order_cnt",
            ") VALUES (",
            "#{dt}, #{huagaoId}, #{shangjiaId}, #{impressionCnt}, #{clickDetailCnt}, #{detailViewCnt}, #{detailDwellCnt}, #{detailDwellTotalMs}, #{favoriteCnt}, #{addCartCnt}, #{createOrderCnt}, ",
            "#{searchImpressionCnt}, #{filterFenleiImpressionCnt}, #{filterTagImpressionCnt}, ",
            "#{searchClickDetailCnt}, #{searchDetailViewCnt}, #{searchDetailDwellCnt}, #{searchDetailDwellTotalMs}, #{searchFavoriteCnt}, #{searchAddCartCnt}, #{searchCreateOrderCnt}",
            ") ON DUPLICATE KEY UPDATE ",
            "shangjia_id = COALESCE(VALUES(shangjia_id), shangjia_id), ",
            "impression_cnt = impression_cnt + VALUES(impression_cnt), ",
            "click_detail_cnt = click_detail_cnt + VALUES(click_detail_cnt), ",
            "detail_view_cnt = detail_view_cnt + VALUES(detail_view_cnt), ",
            "detail_dwell_cnt = detail_dwell_cnt + VALUES(detail_dwell_cnt), ",
            "detail_dwell_total_ms = detail_dwell_total_ms + VALUES(detail_dwell_total_ms), ",
            "favorite_cnt = favorite_cnt + VALUES(favorite_cnt), ",
            "add_cart_cnt = add_cart_cnt + VALUES(add_cart_cnt), ",
            "create_order_cnt = create_order_cnt + VALUES(create_order_cnt), ",
            "search_impression_cnt = search_impression_cnt + VALUES(search_impression_cnt), ",
            "filter_fenlei_impression_cnt = filter_fenlei_impression_cnt + VALUES(filter_fenlei_impression_cnt), ",
            "filter_tag_impression_cnt = filter_tag_impression_cnt + VALUES(filter_tag_impression_cnt), ",
            "search_click_detail_cnt = search_click_detail_cnt + VALUES(search_click_detail_cnt), ",
            "search_detail_view_cnt = search_detail_view_cnt + VALUES(search_detail_view_cnt), ",
            "search_detail_dwell_cnt = search_detail_dwell_cnt + VALUES(search_detail_dwell_cnt), ",
            "search_detail_dwell_total_ms = search_detail_dwell_total_ms + VALUES(search_detail_dwell_total_ms), ",
            "search_favorite_cnt = search_favorite_cnt + VALUES(search_favorite_cnt), ",
            "search_add_cart_cnt = search_add_cart_cnt + VALUES(search_add_cart_cnt), ",
            "search_create_order_cnt = search_create_order_cnt + VALUES(search_create_order_cnt), ",
            "updated_at = CURRENT_TIMESTAMP",
            "</script>"
    })
    int upsert(RecHuagaoItemStatDaily record);
}
