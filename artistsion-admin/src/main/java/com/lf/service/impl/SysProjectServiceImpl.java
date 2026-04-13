package com.lf.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.dao.SysProjectMapper;
import com.lf.entity.SysProject;
import com.lf.service.SysProjectService;
import org.springframework.stereotype.Service;

@Service
public class SysProjectServiceImpl extends ServiceImpl<SysProjectMapper, SysProject> implements SysProjectService {
}
