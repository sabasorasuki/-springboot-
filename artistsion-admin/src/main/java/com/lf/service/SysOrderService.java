package com.lf.service;

import com.lf.entity.SysOrder;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
public interface SysOrderService extends IService<SysOrder> {

    List<SysOrder> getorder();
}
