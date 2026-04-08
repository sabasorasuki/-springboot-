    package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysDianzan;
import com.lf.service.SysDianzanService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author
 * @since 2024-02-05
 */
@RestController
@RequestMapping("/sysDianzan")
public class SysDianzanController {


    @Resource
    private SysDianzanService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "zpids",required = false) String zpids,
            @RequestParam(value = "userids",required = false) String userids,
                                              @RequestParam(value = "pageNo") Long pageNo,
                                              @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysDianzan> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasLength(zpids),SysDianzan::getZpids,zpids);
        wrapper.eq(StringUtils.hasLength(userids),SysDianzan::getUserids,userids);
        wrapper.orderByDesc(SysDianzan::getId);

        Page<SysDianzan> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysDianzan shetuan){
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysDianzan shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysDianzan> getById(@PathVariable("id") Integer id){
        SysDianzan shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysDianzan> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }



}

