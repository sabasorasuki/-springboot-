package com.lf.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.util.Date;

/**
 * <p>
 *
 * </p>
 *
 * @author
 * @since 2024-01-06
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_shoucang")
public class SysShoucang implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * id
     */
      @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 姓名
     */
    private String title;

    /**
     * id
     */
    private String wzids;
    private String photo;

    /**
     * 收藏人id
     */
    private String userids;

    private String fenlei;

    /**
     *
     */
    private String price;

    @TableField(exist = false)
    private String titlecount;


    @TableField(exist = false)
    private String totalAmount;

    @TableField(exist = false)
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date orderDate;


}
