package com.lf.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("rec_huagao_impression_log")
public class RecHuagaoImpressionLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String requestId;

    private Long huagaoId;

    private Long shangjiaId;

    private Integer position;

    private Long pageNo;

    private Long pageSize;

    private String scene;

    private String keyword;

    private String normalizedKeyword;

    private String fenlei;

    private Long tagId;

    private Integer searchScore;

    private LocalDateTime createdAt;
}
