package com.lf.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lf.common.request.SysHuagaoPublishRequest;
import com.lf.entity.SysHuagao;
import com.lf.entity.User;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
public interface SysHuagaoService extends IService<SysHuagao> {

    SysHuagao getDetailById(Long id);

    SysHuagao savePublishedHuagao(SysHuagaoPublishRequest request, User loginUser);
}
