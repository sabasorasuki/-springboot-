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
 * @since 2024-03-11
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_liuyan")
public class SysLiuyan implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * id
     */
      @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 姓名
     */
    private String username;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 用户ids
     */
    private String userids;

    /**
     * 留言内容
     */
    private String content;

    /**
     * 状态(未回复,已回复)
     */
    private String status;

    /**
     * 回复内容
     */
    private String result;


}
