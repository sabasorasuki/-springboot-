package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysOrder;
import com.lf.service.SysOrderService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
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
@RequestMapping("/sysOrder")
public class SysOrderController {



    @Resource
    private SysOrderService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "name",required = false) String name,
            @RequestParam(value = "userids",required = false) String userids,
            @RequestParam(value = "shangjiaids",required = false) String shangjiaids,
            @RequestParam(value = "status",required = false) String status,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasLength(shangjiaids),SysOrder::getShangjiaids,shangjiaids);
        wrapper.eq(StringUtils.hasLength(userids),SysOrder::getUserids,userids);
        wrapper.like(StringUtils.hasLength(name),SysOrder::getName,name);
        if(!status.equals("购物车1")){
            wrapper.eq(StringUtils.hasLength(status),SysOrder::getStatus,status);
        }else {
            wrapper.ne(StringUtils.hasLength(status), SysOrder::getStatus, "购物车");
        }

        wrapper.orderByDesc(SysOrder::getId);

        Page<SysOrder> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysOrder shetuan){
        Date now = new Date();
        shetuan.setXddate(now);
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysOrder shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }

    @GetMapping("/getorder")
    public Result<List<SysOrder>> getorder(){
        List<SysOrder> roleList = service.getorder();
        return Result.success(roleList);
    }



    @GetMapping("/getById/{id}")
    public Result<SysOrder> getById(@PathVariable("id") Integer id){
        SysOrder shetuan = service.getById(id);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysOrder> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }


}

