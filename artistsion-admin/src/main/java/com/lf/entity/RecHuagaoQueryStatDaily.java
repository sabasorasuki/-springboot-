package com.lf.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("rec_huagao_query_stat_daily")
public class RecHuagaoQueryStatDaily implements Serializable {

    private static final long serialVersionUID = 1L;

    private LocalDate dt;

    private String queryKey;

    private String scene;

    private String keyword;

    private String normalizedKeyword;

    private String fenlei;

    private Long tagId;

    private Integer hasSearch;

    private Integer hasFenleiFilter;

    private Integer hasTagFilter;

    private Long requestCnt;

    private Long impressionCnt;

    private Long clickDetailCnt;

    private Long detailViewCnt;

    private Long detailDwellCnt;

    private Long detailDwellTotalMs;

    private Long favoriteCnt;

    private Long addCartCnt;

    private Long createOrderCnt;

    private LocalDateTime updatedAt;
}
