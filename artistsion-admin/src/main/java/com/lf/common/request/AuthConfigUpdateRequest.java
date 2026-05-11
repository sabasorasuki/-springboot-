package com.lf.common.request;

import lombok.Data;

@Data
public class AuthConfigUpdateRequest {

    private Boolean requireEmailCode;
}