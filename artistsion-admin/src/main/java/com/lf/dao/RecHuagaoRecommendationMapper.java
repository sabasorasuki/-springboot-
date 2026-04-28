package com.lf.dao;

import com.lf.entity.SysHuagao;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface RecHuagaoRecommendationMapper {

    String selectActiveModelVersion();

    Long countAvailableRecommendations(@Param("modelVersion") String modelVersion,
                                       @Param("actorKey") String actorKey);

    List<SysHuagao> selectAvailableRecommendations(@Param("modelVersion") String modelVersion,
                                                   @Param("actorKey") String actorKey,
                                                   @Param("offset") long offset,
                                                   @Param("limit") long limit);
}
