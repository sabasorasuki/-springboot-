package com.lf.dao;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lf.entity.SysShoucang;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author
 * @since 2024-01-06
 */
public interface SysShoucangMapper extends BaseMapper<SysShoucang> {

    @Select("SELECT * FROM sys_shoucang GROUP BY title ORDER BY COUNT(id) DESC LIMIT 6")
    List<SysShoucang> getListtuijian();


    @Select("SELECT DATE_FORMAT(fbdate, '%Y-%m-%d') AS orderDate, COUNT(*) AS totalAmount FROM sys_shoucang GROUP BY orderDate ORDER BY orderDate")
    List<SysShoucang> getorder();

}
