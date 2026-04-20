package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.SysHuagao;
import com.lf.entity.User;
import com.lf.dao.UserMapper;
import com.lf.service.SysHuagaoService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

    @Resource
    private JwtUtil jwtUtil;


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
        populateArtistNames(page.getRecords());

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
        populateArtistNames(page.getRecords());
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
        populateArtistNames(page.getRecords());

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
        populateArtistName(shetuan);
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysHuagao> deleteById(HttpServletRequest request, @PathVariable("id") Integer id){
        SysHuagao huagao = service.getById(id);
        if (huagao == null) {
            return Result.fail(20001, "投稿不存在");
        }

        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(request.getHeader("X-Token"), User.class);
        } catch (Exception e) {
            return Result.fail(20003, "令牌无效");
        }

        if (loginUser == null || loginUser.getId() == null) {
            return Result.fail(20003, "未登录");
        }
        if (!String.valueOf(loginUser.getId()).equals(huagao.getShangjiaids())) {
            return Result.fail(20001, "只能删除自己的投稿");
        }

        service.removeById(id);
        return Result.success("删除成功");
    }

    private void populateArtistNames(List<SysHuagao> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        Set<Integer> artistIds = new LinkedHashSet<>();
        for (SysHuagao record : records) {
            Integer artistId = parseArtistId(record);
            if (artistId != null) {
                artistIds.add(artistId);
            }
        }

        if (artistIds.isEmpty()) {
            return;
        }

        List<User> artists = userMapper.selectBatchIds(artistIds);
        Map<Integer, String> artistNames = new HashMap<>();
        for (User artist : artists) {
            if (artist == null || artist.getId() == null) {
                continue;
            }
            artistNames.put(artist.getId(), resolveArtistName(artist));
        }

        for (SysHuagao record : records) {
            Integer artistId = parseArtistId(record);
            if (artistId != null) {
                record.setArtistName(artistNames.get(artistId));
            }
        }
    }

    private void populateArtistName(SysHuagao record) {
        Integer artistId = parseArtistId(record);
        if (artistId == null) {
            return;
        }
        User artist = userMapper.selectById(artistId);
        if (artist != null) {
            record.setArtistName(resolveArtistName(artist));
        }
    }

    private Integer parseArtistId(SysHuagao record) {
        if (record == null || !StringUtils.hasLength(record.getShangjiaids())) {
            return null;
        }
        try {
            return Integer.parseInt(record.getShangjiaids());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private String resolveArtistName(User artist) {
        if (artist == null) {
            return null;
        }
        return StringUtils.hasLength(artist.getName()) ? artist.getName() : artist.getUsername();
    }



}

