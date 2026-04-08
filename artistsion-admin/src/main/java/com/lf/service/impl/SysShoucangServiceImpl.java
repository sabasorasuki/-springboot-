package com.lf.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.dao.SysShoucangMapper;
import com.lf.entity.SysShoucang;
import com.lf.service.SysShoucangService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author
 * @since 2024-01-06
 */
@Service
public class SysShoucangServiceImpl extends ServiceImpl<SysShoucangMapper, SysShoucang> implements SysShoucangService {

    @Resource
    private  SysShoucangMapper mapper;

    @Override
    public List<SysShoucang> getListtuijian() {
        List<SysShoucang> userEntityIPage = mapper.getListtuijian();
        return userEntityIPage;
    }

    @Override
    public List<SysShoucang> getorder() {
        List<SysShoucang> userEntityIPage = mapper.getorder();
        return userEntityIPage;
    }
}
