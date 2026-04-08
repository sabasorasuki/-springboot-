package com.lf.entity;


import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

@Data
public class Alipays {

    private String order_number;
    private String order_detail;
    private String goods_info;
    private String order_price;
    private String orderid;
    private String status;
    private String zuoweid;

    @TableField(exist = false)
    private String pricesa;

    @TableField(exist = false)
    private String userids;

}
