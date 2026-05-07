package com.lf.common.request;

import lombok.Data;

@Data
public class RecActionTrackRequest {

    private String eventId;

    private String eventType;

    private String domain;

    private String requestId;

    private Long itemId;

    private Long authorId;

    private Integer position;

    private Long eventValue;

    private String scene;

    private String source;

    private String modelVersion;
}
