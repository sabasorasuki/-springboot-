package com.lf.dao;

import com.lf.entity.RecHuagaoItemStatDaily;
import org.apache.ibatis.annotations.Insert;

public interface RecHuagaoItemStatDailyMapper {

    @Insert({
            "<script>",
            "INSERT INTO rec_huagao_item_stat_daily (",
            "dt, huagao_id, shangjia_id, impression_cnt, click_detail_cnt, favorite_cnt, ",
            "search_impression_cnt, filter_fenlei_impression_cnt, filter_tag_impression_cnt, ",
            "search_click_detail_cnt, search_favorite_cnt",
            ") VALUES (",
            "#{dt}, #{huagaoId}, #{shangjiaId}, #{impressionCnt}, #{clickDetailCnt}, #{favoriteCnt}, ",
            "#{searchImpressionCnt}, #{filterFenleiImpressionCnt}, #{filterTagImpressionCnt}, ",
            "#{searchClickDetailCnt}, #{searchFavoriteCnt}",
            ") ON DUPLICATE KEY UPDATE ",
            "shangjia_id = COALESCE(VALUES(shangjia_id), shangjia_id), ",
            "impression_cnt = impression_cnt + VALUES(impression_cnt), ",
            "click_detail_cnt = click_detail_cnt + VALUES(click_detail_cnt), ",
            "favorite_cnt = favorite_cnt + VALUES(favorite_cnt), ",
            "search_impression_cnt = search_impression_cnt + VALUES(search_impression_cnt), ",
            "filter_fenlei_impression_cnt = filter_fenlei_impression_cnt + VALUES(filter_fenlei_impression_cnt), ",
            "filter_tag_impression_cnt = filter_tag_impression_cnt + VALUES(filter_tag_impression_cnt), ",
            "search_click_detail_cnt = search_click_detail_cnt + VALUES(search_click_detail_cnt), ",
            "search_favorite_cnt = search_favorite_cnt + VALUES(search_favorite_cnt), ",
            "updated_at = CURRENT_TIMESTAMP",
            "</script>"
    })
    int upsert(RecHuagaoItemStatDaily record);
}
