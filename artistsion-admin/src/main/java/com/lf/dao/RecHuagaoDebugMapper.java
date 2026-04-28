package com.lf.dao;

import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface RecHuagaoDebugMapper {

    List<Map<String, Object>> selectItemDailyRebuildCheck(@Param("dt") LocalDate dt);

    List<Map<String, Object>> selectQueryDailyRebuildCheck(@Param("dt") LocalDate dt);

    List<Map<String, Object>> selectTrainingSamplePreview(@Param("dateFrom") LocalDate dateFrom,
                                                          @Param("dateTo") LocalDate dateTo,
                                                          @Param("limit") Integer limit);

    Map<String, Object> selectTrainingReadinessSummary(@Param("dateFrom") LocalDate dateFrom,
                                                       @Param("dateTo") LocalDate dateTo);

    List<Map<String, Object>> selectTrainingLabelDistribution(@Param("dateFrom") LocalDate dateFrom,
                                                              @Param("dateTo") LocalDate dateTo);

    List<Map<String, Object>> selectTrainingEventDistribution(@Param("dateFrom") LocalDate dateFrom,
                                                              @Param("dateTo") LocalDate dateTo);

    List<Map<String, Object>> selectTrainingDailyTrend(@Param("dateFrom") LocalDate dateFrom,
                                                       @Param("dateTo") LocalDate dateTo);

    List<Map<String, Object>> selectTrainingQualityChecks(@Param("dateFrom") LocalDate dateFrom,
                                                          @Param("dateTo") LocalDate dateTo);
}
