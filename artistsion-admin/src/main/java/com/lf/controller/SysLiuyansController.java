package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysLiuyans;
import com.lf.service.SysLiuyansService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author
 * @since 2024-01-15
 */
@RestController
@RequestMapping("/sysLiuyans")
public class SysLiuyansController {

    @Resource
    private SysLiuyansService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "name",required = false) String name,
            @RequestParam(value = "tsids",required = false) String tsids,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysLiuyans> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(name),SysLiuyans::getName,name);
        wrapper.eq(StringUtils.hasLength(tsids),SysLiuyans::getTsids,tsids);
        wrapper.orderByAsc(SysLiuyans::getId);

        Page<SysLiuyans> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysLiuyans shetuan){
        Date date = new Date();
        shetuan.setLydate(date);
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysLiuyans shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysLiuyans> getById(@PathVariable("id") Integer id){
        SysLiuyans shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysLiuyans> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }



}

