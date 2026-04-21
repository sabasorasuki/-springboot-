package com.lf.controller;

import com.lf.common.Result;
import com.lf.common.request.SysTagAliasCreateRequest;
import com.lf.entity.SysTagAlias;
import com.lf.service.SysTagAliasService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/sysTagAlias")
public class SysTagAliasController {

    @Resource
    private SysTagAliasService sysTagAliasService;

    @GetMapping("/listByTagId/{tagId}")
    public Result<List<SysTagAlias>> listByTagId(@PathVariable("tagId") Long tagId) {
        return Result.success(sysTagAliasService.listByTagId(tagId));
    }

    @PostMapping("/add")
    public Result<?> add(@RequestBody SysTagAliasCreateRequest request) {
        sysTagAliasService.createAlias(request);
        return Result.success("添加成功");
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<?> deleteById(@PathVariable("id") Long id) {
        sysTagAliasService.deleteAlias(id);
        return Result.success("删除成功");
    }
}
