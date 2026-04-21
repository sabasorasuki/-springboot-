package com.lf.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.lf.common.request.SysTagCreateRequest;
import com.lf.common.request.SysTagUpdateRequest;
import com.lf.entity.SysTag;

public interface SysTagService extends IService<SysTag> {

    Page<SysTag> getPage(String name, String tagType, String tagGroup, Integer status, Long pageNo, Long pageSize);

    SysTag getActiveById(Long id);

    SysTag createSystemTag(SysTagCreateRequest request);

    SysTag updateTag(SysTagUpdateRequest request);
}
