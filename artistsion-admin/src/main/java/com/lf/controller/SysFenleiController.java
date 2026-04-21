package com.lf.controller;


import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.SysFenleiUpdateRequest;
import com.lf.entity.SysFenlei;
import com.lf.service.SysFenleiService;
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
 * @since 2024-02-16
 */
@RestController
@RequestMapping("/sysFenlei")
public class SysFenleiController {






    @Resource
    private SysFenleiService service;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "fenlei",required = false) String fenlei,
            @RequestParam(value = "status", required = false) Integer status,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "10") Long pageSize){
        Page<SysFenlei> page = service.getPage(fenlei, status, pageNo, pageSize);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysFenlei category){
        throw new BusinessException(20001, "分类管理暂不支持新增分类");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysFenleiUpdateRequest request){
        service.updateCategory(request);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysFenlei> getById(@PathVariable("id") Long id){
        SysFenlei category = service.getActiveById(id);
        return Result.success(category);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysFenlei> deleteById(@PathVariable("id") Long id){
        throw new BusinessException(20001, "分类管理暂不支持删除分类，请使用启用或禁用");
    }




}

