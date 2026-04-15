package com.lf.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.dao.SysReportMapper;
import com.lf.entity.SysReport;
import com.lf.service.SysReportService;
import org.springframework.stereotype.Service;

@Service
public class SysReportServiceImpl extends ServiceImpl<SysReportMapper, SysReport> implements SysReportService {
}
