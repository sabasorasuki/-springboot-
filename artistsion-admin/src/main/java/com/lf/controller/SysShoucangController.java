package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysShoucang;
import com.lf.service.SysShoucangService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author
 * @since 2024-01-06
 */
@RestController
@RequestMapping("/sysShoucang")
public class SysShoucangController {



    @Resource
    private SysShoucangService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "title",required = false) String title,
            @RequestParam(value = "userids",required = false) String userids,
            @RequestParam(value = "wzids",required = false) String wzids,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysShoucang> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(title),SysShoucang::getTitle,title);
        wrapper.eq(StringUtils.hasLength(userids),SysShoucang::getUserids,userids);
        wrapper.eq(StringUtils.hasLength(wzids),SysShoucang::getWzids,wzids);
        wrapper.orderByDesc(SysShoucang::getId);

        Page<SysShoucang> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }




    @GetMapping("/getListtuijian")
    public Result<List<SysShoucang>> getListtuijian(){
        List<SysShoucang> roleList = service.getListtuijian();
        return Result.success(roleList);
    }


    @GetMapping("/getorder")
    public Result<List<SysShoucang>> getorder(){
        List<SysShoucang> roleList = service.getorder();
        return Result.success(roleList);
    }

    @PostMapping("/add")
    public Result<?> add(@RequestBody SysShoucang shetuan){
        LambdaQueryWrapper<SysShoucang> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasLength(shetuan.getUserids()), SysShoucang::getUserids, shetuan.getUserids());
        wrapper.eq(StringUtils.hasLength(shetuan.getWzids()), SysShoucang::getWzids, shetuan.getWzids());
        if (StringUtils.hasLength(shetuan.getUserids()) && StringUtils.hasLength(shetuan.getWzids()) && service.count(wrapper) > 0) {
            return Result.success("已收藏");
        }
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysShoucang shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysShoucang> getById(@PathVariable("id") Integer id){
        SysShoucang shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysShoucang> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }



}

