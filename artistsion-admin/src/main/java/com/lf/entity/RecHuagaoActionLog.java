package com.lf.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("rec_huagao_action_log")
public class RecHuagaoActionLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String eventId;

    private String eventType;

    private String requestId;

    private Long huagaoId;

    private Long shangjiaId;

    private Long userId;

    private String visitorId;

    private String sessionId;

    private Integer position;

    private Long eventValue;

    private String scene;

    private String source;

    private LocalDateTime createdAt;
}
