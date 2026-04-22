package com.lf.dao;

import com.lf.entity.RecHuagaoQueryStatDaily;
import org.apache.ibatis.annotations.Insert;

public interface RecHuagaoQueryStatDailyMapper {

    @Insert({
            "<script>",
            "INSERT INTO rec_huagao_query_stat_daily (",
            "dt, query_key, scene, keyword, normalized_keyword, fenlei, tag_id, ",
            "has_search, has_fenlei_filter, has_tag_filter, ",
            "request_cnt, impression_cnt, click_detail_cnt, favorite_cnt",
            ") VALUES (",
            "#{dt}, #{queryKey}, #{scene}, #{keyword}, #{normalizedKeyword}, #{fenlei}, #{tagId}, ",
            "#{hasSearch}, #{hasFenleiFilter}, #{hasTagFilter}, ",
            "#{requestCnt}, #{impressionCnt}, #{clickDetailCnt}, #{favoriteCnt}",
            ") ON DUPLICATE KEY UPDATE ",
            "scene = VALUES(scene), ",
            "keyword = COALESCE(VALUES(keyword), keyword), ",
            "normalized_keyword = COALESCE(VALUES(normalized_keyword), normalized_keyword), ",
            "fenlei = COALESCE(VALUES(fenlei), fenlei), ",
            "tag_id = COALESCE(VALUES(tag_id), tag_id), ",
            "has_search = GREATEST(has_search, VALUES(has_search)), ",
            "has_fenlei_filter = GREATEST(has_fenlei_filter, VALUES(has_fenlei_filter)), ",
            "has_tag_filter = GREATEST(has_tag_filter, VALUES(has_tag_filter)), ",
            "request_cnt = request_cnt + VALUES(request_cnt), ",
            "impression_cnt = impression_cnt + VALUES(impression_cnt), ",
            "click_detail_cnt = click_detail_cnt + VALUES(click_detail_cnt), ",
            "favorite_cnt = favorite_cnt + VALUES(favorite_cnt), ",
            "updated_at = CURRENT_TIMESTAMP",
            "</script>"
    })
    int upsert(RecHuagaoQueryStatDaily record);
}
