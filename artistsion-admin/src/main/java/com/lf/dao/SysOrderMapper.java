package com.lf.dao;

import com.lf.entity.SysOrder;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
public interface SysOrderMapper extends BaseMapper<SysOrder> {

    @Select("SELECT DATE_FORMAT(xddate, '%Y-%m-%d') AS orderDate, SUM(price) AS totalAmount " +
            "FROM sys_order " +
            "GROUP BY orderDate")
    List<SysOrder> getorder();
}
