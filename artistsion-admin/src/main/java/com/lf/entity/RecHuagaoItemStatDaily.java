package com.lf.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("rec_huagao_item_stat_daily")
public class RecHuagaoItemStatDaily implements Serializable {

    private static final long serialVersionUID = 1L;

    private LocalDate dt;

    private Long huagaoId;

    private Long shangjiaId;

    private Long impressionCnt;

    private Long clickDetailCnt;

    private Long favoriteCnt;

    private Long searchImpressionCnt;

    private Long filterFenleiImpressionCnt;

    private Long filterTagImpressionCnt;

    private Long searchClickDetailCnt;

    private Long searchFavoriteCnt;

    private LocalDateTime updatedAt;
}
