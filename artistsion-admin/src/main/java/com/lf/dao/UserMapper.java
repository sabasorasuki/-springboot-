package com.lf.dao;

import com.lf.entity.User;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author
 * @since 2023-07-10
 */
public interface UserMapper extends BaseMapper<User> {

    List<String> getRoleNamesByUserId(Integer userId);

    Integer countByUsernameIncludeDeleted(@Param("username") String username,
                                          @Param("excludeId") Integer excludeId);


    //@Select("SELECT DATE_FORMAT(createdate, '%Y-%m-%d') AS orderDate, SUM(totalprice) AS totalAmount " +
    //        "FROM sys_order " +
    //        "GROUP BY orderDate")
    //List<SysOrder> getorder();

}
