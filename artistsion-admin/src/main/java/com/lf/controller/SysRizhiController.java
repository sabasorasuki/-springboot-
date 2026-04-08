package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysRizhi;
import com.lf.service.SysRizhiService;
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
 * @since 2024-02-28
 */
@RestController
@RequestMapping("/sysRizhi")
public class SysRizhiController {


    @Resource
    private SysRizhiService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "rizhi",required = false) String rizhi,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysRizhi> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(rizhi),SysRizhi::getRizhi,rizhi);
        wrapper.like(StringUtils.hasLength(id),SysRizhi::getId,id);
        wrapper.orderByDesc(SysRizhi::getId);

        Page<SysRizhi> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysRizhi shetuan){
        Date date = new Date();
        shetuan.setJldate(date);
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysRizhi shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysRizhi> getById(@PathVariable("id") Integer id){
        SysRizhi shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysRizhi> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }


}

