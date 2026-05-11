package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.AuthConfigUpdateRequest;
import com.lf.dao.SysSiteSettingMapper;
import com.lf.entity.SysSiteSetting;
import com.lf.service.SysSiteSettingService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Map;

@Service
public class SysSiteSettingServiceImpl extends ServiceImpl<SysSiteSettingMapper, SysSiteSetting> implements SysSiteSettingService {

    private static final String REGISTER_REQUIRE_EMAIL_CODE_KEY = "auth.register.require_email_code";
    private static final String REGISTER_REQUIRE_EMAIL_CODE_DESC = "注册时是否强制校验邮箱验证码";

    @Override
    public boolean isRegisterEmailCodeRequired() {
        SysSiteSetting setting = getByKey(REGISTER_REQUIRE_EMAIL_CODE_KEY);
        if (setting == null || !StringUtils.hasText(setting.getSettingValue())) {
            return true;
        }
        String value = setting.getSettingValue().trim();
        return "1".equals(value) || "true".equalsIgnoreCase(value);
    }

    @Override
    public Map<String, Object> getRegisterOptions() {
        Map<String, Object> data = new HashMap<>();
        data.put("requireEmailCode", isRegisterEmailCodeRequired());
        return data;
    }

    @Override
    public Map<String, Object> getAuthConfig() {
        Map<String, Object> data = getRegisterOptions();
        data.put("settingKey", REGISTER_REQUIRE_EMAIL_CODE_KEY);
        data.put("description", REGISTER_REQUIRE_EMAIL_CODE_DESC);
        return data;
    }

    @Override
    public void updateAuthConfig(AuthConfigUpdateRequest request) {
        if (request == null || request.getRequireEmailCode() == null) {
            throw new BusinessException(20001, "开关参数不能为空");
        }

        SysSiteSetting setting = getByKey(REGISTER_REQUIRE_EMAIL_CODE_KEY);
        if (setting == null) {
            setting = new SysSiteSetting();
            setting.setSettingKey(REGISTER_REQUIRE_EMAIL_CODE_KEY);
            setting.setDescription(REGISTER_REQUIRE_EMAIL_CODE_DESC);
            setting.setSettingValue(toStoredValue(request.getRequireEmailCode()));
            save(setting);
            return;
        }

        setting.setSettingValue(toStoredValue(request.getRequireEmailCode()));
        setting.setDescription(REGISTER_REQUIRE_EMAIL_CODE_DESC);
        updateById(setting);
    }

    private SysSiteSetting getByKey(String settingKey) {
        LambdaQueryWrapper<SysSiteSetting> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysSiteSetting::getSettingKey, settingKey).last("LIMIT 1");
        return getOne(wrapper, false);
    }

    private String toStoredValue(Boolean enabled) {
        return Boolean.TRUE.equals(enabled) ? "1" : "0";
    }
}