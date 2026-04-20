package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.utils.JwtUtil;
import com.lf.dao.UserMapper;
import com.lf.entity.SysOrder;
import com.lf.entity.User;
import com.lf.service.SysOrderService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
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

    @Resource
    private JwtUtil jwtUtil;

    @Resource
    private UserMapper userMapper;

    /**
     * 我的订单 — 从 X-Token 解析当前用户，按 role 参数决定视角。
     * role=画师角色 → 按 shangjiaids 过滤（我卖出的）
     * role=用户角色 或缺省 → 按 userids 过滤（我买入的）
     */
    @GetMapping("/mine")
    public Result<Map<String, Object>> getMyOrders(
            HttpServletRequest request,
            @RequestParam(value = "role", required = false) String role,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "10") Long pageSize) {

        String token = request.getHeader("X-Token");
        if (token == null) {
            return Result.fail(20003, "未登录");
        }
        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(token, User.class);
        } catch (Exception e) {
            return Result.fail(20003, "令牌无效");
        }
        // 从数据库确认用户角色，不信任前端传来的 role 是否合法
        String userId = String.valueOf(loginUser.getId());
        List<String> userRoles = userMapper.getRoleNamesByUserId(loginUser.getId());

        LambdaQueryWrapper<SysOrder> wrapper = new LambdaQueryWrapper<>();
        if ("画师角色".equals(role) && userRoles.contains("画师角色")) {
            wrapper.eq(SysOrder::getShangjiaids, userId);
        } else {
            wrapper.eq(SysOrder::getUserids, userId);
        }
        wrapper.ne(SysOrder::getStatus, "购物车");
        wrapper.orderByDesc(SysOrder::getId);

        Page<SysOrder> page = new Page<>(pageNo, pageSize);
        service.page(page, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());
        return Result.success(data);
    }


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "name",required = false) String name,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "userids",required = false) String userids,
            @RequestParam(value = "shangjiaids",required = false) String shangjiaids,
            @RequestParam(value = "status",required = false) String status,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasLength(shangjiaids),SysOrder::getShangjiaids,shangjiaids);
        wrapper.eq(StringUtils.hasLength(userids),SysOrder::getUserids,userids);
        wrapper.eq(StringUtils.hasLength(id),SysOrder::getId,id);
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
        if ("购物车".equals(shetuan.getStatus())
                && StringUtils.hasLength(shetuan.getUserids())
                && StringUtils.hasLength(shetuan.getSpids())) {
            LambdaQueryWrapper<SysOrder> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(SysOrder::getUserids, shetuan.getUserids());
            wrapper.eq(SysOrder::getSpids, shetuan.getSpids());
            wrapper.eq(SysOrder::getStatus, "购物车");
            if (service.count(wrapper) > 0) {
                return Result.success("该橱窗已在购物车中");
            }
        }
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

