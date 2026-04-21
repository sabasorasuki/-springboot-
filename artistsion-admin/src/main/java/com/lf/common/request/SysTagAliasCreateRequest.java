package com.lf.common.request;

import lombok.Data;

@Data
public class SysTagAliasCreateRequest {

    private Long tagId;

    private String aliasName;
}
