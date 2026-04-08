package com.lf.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lf.entity.SysShoucang;

import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author
 * @since 2024-01-06
 */
public interface SysShoucangService extends IService<SysShoucang> {

    List<SysShoucang> getListtuijian();

    List<SysShoucang> getorder();
}
