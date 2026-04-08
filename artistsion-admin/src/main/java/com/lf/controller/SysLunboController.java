package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysLunbo;
import com.lf.service.SysLunboService;
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
 * @since 2024-01-25
 */
@RestController
@RequestMapping("/sysLunbo")
public class SysLunboController {



    @Resource
    private SysLunboService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(@RequestParam(value = "name",required = false) String name,
                                              @RequestParam(value = "pageNo") Long pageNo,
                                              @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysLunbo> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(name),SysLunbo::getName,name);
        wrapper.orderByDesc(SysLunbo::getId);

        Page<SysLunbo> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysLunbo shetuan){
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysLunbo shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysLunbo> getById(@PathVariable("id") Integer id){
        SysLunbo shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysLunbo> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }


}

