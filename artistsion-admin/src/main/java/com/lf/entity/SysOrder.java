package com.lf.entity;

import java.math.BigDecimal;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;

import java.io.Serializable;
import java.util.Date;

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
@TableName("sys_order")
public class SysOrder implements Serializable {

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
     * 用户id
     */
    private String userids;
    private String pingjia;

    /**
     * 姓名
     */
    private String username;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 地址
     */
    private String address;

    /**
     * 下单日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date xddate;

    private Integer zhekou;
    /**
     * 下单日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date rydate;


    private String status;
    private String ryfs;
    private String fujin;



    /**
     * 画稿id
     */
    private String spids;
    private String shangjiaids;


    @TableField(exist = false)
    private String totalAmount;

    @TableField(exist = false)
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date orderDate;


}
