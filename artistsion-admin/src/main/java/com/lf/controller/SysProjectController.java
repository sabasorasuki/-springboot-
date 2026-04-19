package com.lf.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysProject;
import com.lf.service.SysProjectService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/sysProject")
public class SysProjectController {

    @Resource
    private SysProjectService service;

    @GetMapping("/list")
    public Result<Map<String, Object>> getList(
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "userId", required = false) Long userId,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "12") Long pageSize) {

        LambdaQueryWrapper<SysProject> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasLength(category), SysProject::getCategory, category);
        wrapper.eq(StringUtils.hasLength(status), SysProject::getStatus, status);
        wrapper.eq(userId != null, SysProject::getUserId, userId);
        wrapper.orderByDesc(SysProject::getId);

        Page<SysProject> page = new Page<>(pageNo, pageSize);
        service.page(page, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());
        return Result.success(data);
    }

    @GetMapping("/getById/{id}")
    public Result<SysProject> getById(@PathVariable Long id) {
        SysProject project = service.getById(id);
        if (project == null) {
            return Result.fail(20001, "企划不存在");
        }
        return Result.success(project);
    }

    @PostMapping("/add")
    public Result<?> add(@RequestBody SysProject project) {
        service.save(project);
        return Result.success("发布成功");
    }

    @PutMapping("/update")
    public Result<?> update(@RequestBody SysProject project) {
        service.updateById(project);
        return Result.success("修改成功");
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<?> deleteById(@PathVariable Long id) {
        service.removeById(id);
        return Result.success("删除成功");
    }
}
