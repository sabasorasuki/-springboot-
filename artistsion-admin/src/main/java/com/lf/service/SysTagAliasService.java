package com.lf.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lf.common.request.SysTagAliasCreateRequest;
import com.lf.entity.SysTagAlias;

import java.util.List;

public interface SysTagAliasService extends IService<SysTagAlias> {

    List<SysTagAlias> listByTagId(Long tagId);

    SysTagAlias createAlias(SysTagAliasCreateRequest request);

    void deleteAlias(Long id);
}
