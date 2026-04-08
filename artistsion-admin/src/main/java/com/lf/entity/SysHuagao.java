package com.lf.entity;

import java.math.BigDecimal;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.io.Serializable;
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
@TableName("sys_huagao")
public class SysHuagao implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * id
     */
      @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 画稿名字
     */
    private String name;

    /**
     * 封面
     */
    private String photo;

    /**
     * 价格
     */
    private BigDecimal price;

    /**
     * 分类
     */
    private String fenlei;

    private String fujin;


    /**
     * 介绍
     */
    private String content;
    private Integer zhekou;

    /**
     * 状态(上架,下架)
     */
    private String type;
    private String shangjiaids;
    private String status;


}
