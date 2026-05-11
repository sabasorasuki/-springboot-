package com.lf.service;

import com.lf.entity.SysZuopin;
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
public interface SysZuopinService extends IService<SysZuopin> {

    boolean saveWithTags(SysZuopin zuopin);

    boolean updateWithTags(SysZuopin zuopin);

    SysZuopin getDetailById(Long id);

    void fillTagInfo(List<SysZuopin> zuopinList);
}
