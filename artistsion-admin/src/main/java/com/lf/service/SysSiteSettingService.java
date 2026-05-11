package com.lf.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lf.common.request.AuthConfigUpdateRequest;
import com.lf.entity.SysSiteSetting;

import java.util.Map;

public interface SysSiteSettingService extends IService<SysSiteSetting> {

    boolean isRegisterEmailCodeRequired();

    Map<String, Object> getRegisterOptions();

    Map<String, Object> getAuthConfig();

    void updateAuthConfig(AuthConfigUpdateRequest request);
}