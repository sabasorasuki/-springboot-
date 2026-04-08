package com.lf.dao;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lf.entity.UserArticleOperation;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author hwp
 * @since 2023-03-12
 */
public interface UserArticleOperationMapper extends BaseMapper<UserArticleOperation> {

    List<UserArticleOperation> getAllUserPreference();
}
