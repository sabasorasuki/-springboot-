package com.lf.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.lf.common.request.SysFenleiUpdateRequest;
import com.lf.entity.SysFenlei;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
public interface SysFenleiService extends IService<SysFenlei> {

    Page<SysFenlei> getPage(String fenlei, Integer status, Long pageNo, Long pageSize);

    SysFenlei getActiveById(Long id);

    void updateCategory(SysFenleiUpdateRequest request);
}
