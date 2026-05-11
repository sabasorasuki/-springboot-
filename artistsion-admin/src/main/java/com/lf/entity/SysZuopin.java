package com.lf.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * <p>
 *
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_zuopin")
public class SysZuopin implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * id
     */
      @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 标题
     */
    private String title;

    /**
     * 封面
     */
    private String photo;

    /**
     * 发布日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date fbdate;

    /**
     * 用户id
     */
    private String userids;

    /**
     * 用户名
     */
    private String username;

    /**
     * 帖子内容
     */
    private String content;

    /**
     * 点赞数量
     */
    private Integer dznum;

    /**
     * 分类
     */
    private String fenlei;


    @TableField(exist = false)
    private String dianzan;

    @TableField(exist = false)
    private List<String> freeTagNames = new ArrayList<>();

}
