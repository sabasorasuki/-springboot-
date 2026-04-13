package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysHuagao;
import com.lf.entity.User;
import com.lf.dao.UserMapper;
import com.lf.service.SysHuagaoService;
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
 * @since 2024-02-16
 */
@RestController
@RequestMapping("/sysHuagao")
public class SysHuagaoController {

    
    @Resource
    private SysHuagaoService service;

    @Resource
    private UserMapper userMapper;


    @GetMapping("/tuijianlist")
    public Result<Map<String, Object>> getTuijianList(
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "id", required = false) String id,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "fenlei", required = false) String fenlei,
            @RequestParam(value = "shangjiaids", required = false) String shangjiaids,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "tuijian", required = false) List<String> tuijian, // 新增接收数组参数
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize) {

        LambdaQueryWrapper<SysHuagao> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(name), SysHuagao::getName, name);
        wrapper.eq(StringUtils.hasLength(id), SysHuagao::getId, id);
        wrapper.eq(StringUtils.hasLength(shangjiaids), SysHuagao::getShangjiaids, shangjiaids);
        wrapper.eq(StringUtils.hasLength(status), SysHuagao::getStatus, status);
        wrapper.like(StringUtils.hasLength(type), SysHuagao::getType, type);
        wrapper.like(StringUtils.hasLength(fenlei), SysHuagao::getFenlei, fenlei);

        // 如果 tuijian 不为空，查询 `tuijian` 中包含的画稿
        if (tuijian != null && !tuijian.isEmpty()) {
            wrapper.in(SysHuagao::getId, tuijian); // 根据主键 ID 列表查询
        }

        wrapper.orderByDesc(SysHuagao::getId);

        Page<SysHuagao> page = new Page<>(pageNo, pageSize);
        service.page(page, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());

        return Result.success(data);
    }


    @GetMapping("/getzuixin")
    public Result<Map<String,Object>> getzuixin(){
        LambdaQueryWrapper<SysHuagao> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysHuagao::getStatus, "审核成功");
        wrapper.eq(SysHuagao::getType, "上架");
        wrapper.orderByDesc(SysHuagao::getId);
        Page<SysHuagao> page = new Page<>(1,3);
        service.page(page, wrapper);
        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "name",required = false) String name,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "type",required = false) String type,
            @RequestParam(value = "fenlei",required = false) String fenlei,
            @RequestParam(value = "shangjiaids",required = false) String shangjiaids,
            @RequestParam(value = "status",required = false) String status,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysHuagao> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(name), SysHuagao::getName,name);
        wrapper.eq(StringUtils.hasLength(id), SysHuagao::getId,id);
        wrapper.eq(StringUtils.hasLength(shangjiaids), SysHuagao::getShangjiaids,shangjiaids);
        wrapper.eq(StringUtils.hasLength(status), SysHuagao::getStatus,status);
        wrapper.like(StringUtils.hasLength(type), SysHuagao::getType,type);
        wrapper.like(StringUtils.hasLength(fenlei), SysHuagao::getFenlei,fenlei);
        wrapper.orderByDesc(SysHuagao::getId);

        Page<SysHuagao> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysHuagao shetuan){
        service.save(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysHuagao shetuan){
        service.updateById(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysHuagao> getById(@PathVariable("id") Integer id){
        SysHuagao shetuan = service.getById(id);
        if (shetuan != null && StringUtils.hasLength(shetuan.getShangjiaids())) {
            try {
                User artist = userMapper.selectById(Integer.parseInt(shetuan.getShangjiaids()));
                if (artist != null) {
                    shetuan.setArtistName(artist.getName() != null ? artist.getName() : artist.getUsername());
                }
            } catch (NumberFormatException ignored) {}
        }
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysHuagao> deleteById(@PathVariable("id") Integer id){
        service.removeById(id);
        return Result.success("删除成功");
    }



}

