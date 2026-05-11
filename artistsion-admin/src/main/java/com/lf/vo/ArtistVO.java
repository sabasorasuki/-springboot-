package com.lf.vo;

import lombok.Data;

import java.util.List;

/**
 * 画师页公开展示数据，不包含敏感字段（email/phone/password等）。
 */
@Data
public class ArtistVO {

    private Integer id;
    private String username;
    private String name;
    private String avatar;
    private Integer status;
    private String bio;
    private String styleTags;
    /** 该画师已上架画稿数量 */
    private Long workCount;
    /** 最近作品封面（列表页最多9张） */
    private List<String> recentCovers;
}
