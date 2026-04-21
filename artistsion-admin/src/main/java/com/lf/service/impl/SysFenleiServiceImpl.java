package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.SysFenleiUpdateRequest;
import com.lf.dao.SysFenleiMapper;
import com.lf.entity.SysFenlei;
import com.lf.service.SysFenleiService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
@Service
public class SysFenleiServiceImpl extends ServiceImpl<SysFenleiMapper, SysFenlei> implements SysFenleiService {

    @Override
    public Page<SysFenlei> getPage(String fenlei, Integer status, Long pageNo, Long pageSize) {
        LambdaQueryWrapper<SysFenlei> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFenlei::getDeleted, 0);
        wrapper.like(StringUtils.hasText(fenlei), SysFenlei::getFenlei, fenlei);
        wrapper.eq(status != null, SysFenlei::getStatus, status);
        wrapper.orderByAsc(SysFenlei::getSort)
                .orderByAsc(SysFenlei::getId);

        Page<SysFenlei> page = new Page<>(pageNo, pageSize);
        page(page, wrapper);
        return page;
    }

    @Override
    public SysFenlei getActiveById(Long id) {
        if (id == null) {
            throw new BusinessException(20001, "分类ID不能为空");
        }
        LambdaQueryWrapper<SysFenlei> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFenlei::getId, id)
                .eq(SysFenlei::getDeleted, 0)
                .last("LIMIT 1");
        SysFenlei category = getOne(wrapper, false);
        if (category == null) {
            throw new BusinessException(20001, "分类不存在");
        }
        return category;
    }

    @Override
    public void updateCategory(SysFenleiUpdateRequest request) {
        if (request == null) {
            throw new BusinessException(20001, "更新参数不能为空");
        }
        if (request.getId() == null) {
            throw new BusinessException(20001, "分类ID不能为空");
        }
        if (request.getSort() == null || request.getSort() < 0) {
            throw new BusinessException(20001, "排序值必须大于等于0");
        }
        if (request.getStatus() == null || (request.getStatus() != 0 && request.getStatus() != 1)) {
            throw new BusinessException(20001, "分类状态不合法");
        }

        SysFenlei category = getActiveById(request.getId());
        category.setSort(request.getSort());
        category.setStatus(request.getStatus());
        updateById(category);
    }
}
