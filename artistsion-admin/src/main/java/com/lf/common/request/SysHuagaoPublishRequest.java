package com.lf.common.request;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class SysHuagaoPublishRequest {

    private Long id;

    private String name;

    private String photo;

    private BigDecimal price;

    private String fenlei;

    private String fujin;

    private String content;

    private Integer zhekou;

    private String type;

    private String status;

    private List<Long> systemTagIds;

    private List<String> freeTagNames;
}
