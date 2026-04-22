package com.lf.common.request;

import lombok.Data;

@Data
public class RecHuagaoActionTrackRequest {

    private String eventId;

    private String eventType;

    private String requestId;

    private Long huagaoId;

    private Long shangjiaId;

    private Integer position;

    private String scene;

    private String source;
}
