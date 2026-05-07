package com.lf.dao;

import org.apache.ibatis.annotations.Param;

import java.util.Map;

public interface RecTrackMapper {

    int insertRequestLog(@Param("row") Map<String, Object> row);

    int insertImpressionLog(@Param("row") Map<String, Object> row);

    int insertActionLog(@Param("row") Map<String, Object> row);
}
