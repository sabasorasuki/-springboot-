package com.lf.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("rec_huagao_request_log")
public class RecHuagaoRequestLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "request_id", type = IdType.INPUT)
    private String requestId;

    private String queryKey;

    private String scene;

    private Long userId;

    private String visitorId;

    private String sessionId;

    private String keyword;

    private String normalizedKeyword;

    private String fenlei;

    private Long tagId;

    private Long pageNo;

    private Long pageSize;

    private String sortMode;

    private Integer hasSearch;

    private Integer hasFenleiFilter;

    private Integer hasTagFilter;

    private Long resultTotal;

    private Long returnedCount;

    private LocalDateTime createdAt;
}
