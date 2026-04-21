package com.lf.common.request;

import lombok.Data;

@Data
public class SysTagCreateRequest {

    private String name;

    private String tagGroup;

    private Integer status;
}
