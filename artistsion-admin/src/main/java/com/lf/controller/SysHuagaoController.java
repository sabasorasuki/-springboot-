package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.request.SysHuagaoAdminPatchRequest;
import com.lf.common.utils.JwtUtil;
import com.lf.common.request.SysHuagaoPublishRequest;
import com.lf.entity.SysHuagao;
import com.lf.entity.User;
import com.lf.dao.UserMapper;
import com.lf.service.RecHuagaoTrackService;
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

    @Resource
    private RecHuagaoTrackService recHuagaoTrackService;


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
            HttpServletRequest request,
            @RequestParam(value = "name",required = false) String name,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "tagId", required = false) Long tagId,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "type",required = false) String type,
            @RequestParam(value = "fenlei",required = false) String fenlei,
            @RequestParam(value = "scene", required = false) String scene,
            @RequestParam(value = "shangjiaids",required = false) String shangjiaids,
            @RequestParam(value = "status",required = false) String status,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        Page<SysHuagao> page = service.getFrontPage(name, keyword, tagId, id, type, fenlei, shangjiaids, status, pageNo, pageSize);
        populateArtistNames(page.getRecords());
        String requestId = null;
        try {
            User loginUser = resolveOptionalLoginUser(request);
            requestId = recHuagaoTrackService.trackListIfNeeded(
                    scene,
                    keyword,
                    fenlei,
                    tagId,
                    pageNo,
                    pageSize,
                    page.getTotal(),
                    page.getRecords(),
                    loginUser == null || loginUser.getId() == null ? null : Long.valueOf(loginUser.getId()),
                    sanitizeHeader(request.getHeader("X-Visitor-Id")),
                    sanitizeHeader(request.getHeader("X-Session-Id"))
            );
        } catch (Exception ignored) {
        }

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());
        if (StringUtils.hasText(requestId)) {
            data.put("requestId", requestId);
        }

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysHuagao shetuan){
        return Result.fail(20001, "该接口已废弃，请使用 /sysHuagao/publish 保存橱窗");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysHuagao shetuan){
        return Result.fail(20001, "通用更新接口已收口，请使用 /sysHuagao/publish 或 /sysHuagao/adminPatch");
    }

    @PutMapping("/adminPatch")
    public Result<?> adminPatch(@RequestBody SysHuagaoAdminPatchRequest request) {
        service.patchHuagaoAdminFields(request);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysHuagao> getById(@PathVariable("id") Long id){
        SysHuagao shetuan = service.getDetailById(id);
        populateArtistName(shetuan);
        return Result.success(shetuan);
    }

    @PostMapping("/publish")
    public Result<?> publish(HttpServletRequest request, @RequestBody SysHuagaoPublishRequest publishRequest) {
        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(request.getHeader("X-Token"), User.class);
        } catch (Exception e) {
            return Result.fail(20003, "令牌无效");
        }
        service.savePublishedHuagao(publishRequest, loginUser);
        return Result.success("保存成功");
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

    private User resolveOptionalLoginUser(HttpServletRequest request) {
        String token = request.getHeader("X-Token");
        if (!StringUtils.hasText(token)) {
            return null;
        }
        try {
            return jwtUtil.parseToken(token, User.class);
        } catch (Exception ignored) {
            return null;
        }
    }

    private String sanitizeHeader(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }



}

