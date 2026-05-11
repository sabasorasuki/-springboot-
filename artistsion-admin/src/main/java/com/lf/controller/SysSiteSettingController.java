package com.lf.controller;

import com.lf.common.Result;
import com.lf.common.request.AuthConfigUpdateRequest;
import com.lf.service.SysSiteSettingService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.Map;

@Api(tags = {"站点设置"})
@RestController
@RequestMapping("/sysSiteSetting")
public class SysSiteSettingController {

    @Resource
    private SysSiteSettingService sysSiteSettingService;

    @ApiOperation("获取认证配置")
    @GetMapping("/auth-config")
    public Result<Map<String, Object>> getAuthConfig() {
        return Result.success(sysSiteSettingService.getAuthConfig());
    }

    @ApiOperation("更新认证配置")
    @PutMapping("/auth-config")
    public Result<?> updateAuthConfig(@RequestBody AuthConfigUpdateRequest request) {
        sysSiteSettingService.updateAuthConfig(request);
        return Result.success("认证配置已更新");
    }
}