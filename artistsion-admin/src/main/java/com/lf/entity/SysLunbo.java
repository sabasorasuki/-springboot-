package com.lf.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

/**
 * <p>
 *
 * </p>
 *
 * @author
 * @since 2024-01-25
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_lunbo")
public class SysLunbo implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * id
     */
      @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 轮播图
     */
    private String lunbo;

    /**
     * 轮播图姓名
     */
    private String name;


}
