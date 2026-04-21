package com.lf.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.request.SysTagCreateRequest;
import com.lf.common.request.SysTagUpdateRequest;
import com.lf.entity.SysTag;
import com.lf.service.SysTagService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/sysTag")
public class SysTagController {

    @Resource
    private SysTagService sysTagService;

    @GetMapping("/list")
    public Result<Map<String, Object>> getList(
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "tagType", required = false) String tagType,
            @RequestParam(value = "tagGroup", required = false) String tagGroup,
            @RequestParam(value = "status", required = false) Integer status,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "10") Long pageSize) {
        Page<SysTag> page = sysTagService.getPage(name, tagType, tagGroup, status, pageNo, pageSize);
        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());
        return Result.success(data);
    }

    @GetMapping("/getById/{id}")
    public Result<SysTag> getById(@PathVariable("id") Long id) {
        return Result.success(sysTagService.getActiveById(id));
    }

    @GetMapping("/systemOptions")
    public Result<List<SysTag>> systemOptions() {
        return Result.success(sysTagService.listEnabledSystemTags());
    }

    @PostMapping("/add")
    public Result<?> add(@RequestBody SysTagCreateRequest request) {
        sysTagService.createSystemTag(request);
        return Result.success("添加成功");
    }

    @PutMapping("/update")
    public Result<?> update(@RequestBody SysTagUpdateRequest request) {
        sysTagService.updateTag(request);
        return Result.success("修改成功");
    }
}
