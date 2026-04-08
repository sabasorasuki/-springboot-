package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysZuopin;
import com.lf.service.SysZuopinService;
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
 * @since 2024-02-16
 */
@RestController
@RequestMapping("/sysZuopin")
public class SysZuopinController {



    @Resource
    private SysZuopinService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "title",required = false) String title,
            @RequestParam(value = "fenlei",required = false) String fenlei,
            @RequestParam(value = "userids",required = false) String userids,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysZuopin> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(title),SysZuopin::getTitle,title);
        wrapper.like(StringUtils.hasLength(fenlei),SysZuopin::getFenlei,fenlei);
        wrapper.eq(StringUtils.hasLength(userids),SysZuopin::getUserids,userids);
        wrapper.eq(StringUtils.hasLength(id),SysZuopin::getId,id);
        wrapper.orderByDesc(SysZuopin::getId);

        Page<SysZuopin> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysZuopin shetuan){
        Date date = new Date();
        shetuan.setFbdate(date);
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysZuopin shetuan){

        if(shetuan.getDianzan().equals("点赞")){
            SysZuopin zuopin = service.getById(shetuan.getId());
            shetuan.setDznum( zuopin.getDznum()+1);
        }

        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysZuopin> getById(@PathVariable("id") Integer id){
        SysZuopin shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysZuopin> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }




}

