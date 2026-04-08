package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysLiuyan;
import com.lf.service.SysLiuyanService;
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
 * @since 2024-03-11
 */
@RestController
@RequestMapping("/sysLiuyan")
public class SysLiuyanController {




    @Resource
    private SysLiuyanService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "userids",required = false) String userids,
            @RequestParam(value = "username",required = false) String username,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysLiuyan> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(username),SysLiuyan::getUsername,username);
        wrapper.eq(StringUtils.hasLength(userids),SysLiuyan::getUserids,userids);
        wrapper.eq(StringUtils.hasLength(id),SysLiuyan::getId,id);
        wrapper.orderByDesc(SysLiuyan::getId);

        Page<SysLiuyan> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysLiuyan shetuan){
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysLiuyan shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysLiuyan> getById(@PathVariable("id") Integer id){
        SysLiuyan shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysLiuyan> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }





}

