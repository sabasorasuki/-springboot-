package com.lf.service.impl;

import com.lf.entity.SysOrder;
import com.lf.dao.SysOrderMapper;
import com.lf.service.SysOrderService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
@Service
public class SysOrderServiceImpl extends ServiceImpl<SysOrderMapper, SysOrder> implements SysOrderService {



    @Resource
    private SysOrderMapper mapper;


    @Override
    public List<SysOrder> getorder() {
        List<SysOrder> userEntityIPage = mapper.getorder();
        return userEntityIPage;
    }

}
