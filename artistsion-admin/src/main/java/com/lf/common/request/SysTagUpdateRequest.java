package com.lf.common.request;

import lombok.Data;

@Data
public class SysTagUpdateRequest {

    private Long id;

    private String name;

    private String tagGroup;

    private Integer status;
}
