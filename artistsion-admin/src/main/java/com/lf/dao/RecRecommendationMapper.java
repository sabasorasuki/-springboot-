package com.lf.dao;

import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface RecRecommendationMapper {

    String selectActiveModelVersion(@Param("domain") String domain);

    Long countAvailableRecommendations(@Param("domain") String domain,
                                       @Param("modelVersion") String modelVersion,
                                       @Param("actorKey") String actorKey);

    List<Map<String, Object>> selectAvailableRecommendations(@Param("domain") String domain,
                                                             @Param("modelVersion") String modelVersion,
                                                             @Param("actorKey") String actorKey,
                                                             @Param("offset") Long offset,
                                                             @Param("limit") Long limit);

    Long countFallbackItems(@Param("domain") String domain);

    List<Map<String, Object>> selectFallbackItems(@Param("domain") String domain,
                                                  @Param("offset") Long offset,
                                                  @Param("limit") Long limit);

    List<Map<String, Object>> selectModelHealth();

    List<Map<String, Object>> selectLogHealth();
}
