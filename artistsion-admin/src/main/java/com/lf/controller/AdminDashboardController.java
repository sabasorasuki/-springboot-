package com.lf.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.exception.BusinessException;
import com.lf.common.utils.JwtUtil;
import com.lf.dao.UserMapper;
import com.lf.entity.SysFenlei;
import com.lf.entity.SysHuagao;
import com.lf.entity.SysLiuyan;
import com.lf.entity.SysLunbo;
import com.lf.entity.SysOrder;
import com.lf.entity.SysRizhi;
import com.lf.entity.User;
import com.lf.service.SysFenleiService;
import com.lf.service.SysHuagaoService;
import com.lf.service.SysLiuyanService;
import com.lf.service.SysLunboService;
import com.lf.service.SysOrderService;
import com.lf.service.SysRizhiService;
import com.lf.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/adminDashboard")
public class AdminDashboardController {

    @Resource
    private JwtUtil jwtUtil;

    @Resource
    private UserMapper userMapper;

    @Resource
    private UserService userService;

    @Resource
    private SysHuagaoService sysHuagaoService;

    @Resource
    private SysOrderService sysOrderService;

    @Resource
    private SysLiuyanService sysLiuyanService;

    @Resource
    private SysFenleiService sysFenleiService;

    @Resource
    private SysLunboService sysLunboService;

    @Resource
    private SysRizhiService sysRizhiService;

    @GetMapping("/summary")
    public Result<Map<String, Object>> getSummary(@RequestHeader("X-Token") String token) {
        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(token, User.class);
        } catch (Exception e) {
            throw new BusinessException(20003, "登录信息无效，请重新登录");
        }

        if (loginUser == null || loginUser.getId() == null) {
            throw new BusinessException(20003, "登录信息无效，请重新登录");
        }

        ensureAdmin(loginUser.getId());

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("userTotal", userService.count(new LambdaQueryWrapper<User>().eq(User::getDeleted, 0)));
        metrics.put("workTotal", sysHuagaoService.count());
        metrics.put("orderTotal", sysOrderService.count(new LambdaQueryWrapper<SysOrder>().ne(SysOrder::getStatus, "购物车")));
        metrics.put("pendingWorkTotal", sysHuagaoService.count(new LambdaQueryWrapper<SysHuagao>().eq(SysHuagao::getStatus, "未审核")));
        metrics.put("pendingFeedbackTotal", sysLiuyanService.count(new LambdaQueryWrapper<SysLiuyan>().eq(SysLiuyan::getStatus, "未回复")));
        metrics.put("categoryTotal", sysFenleiService.count());
        metrics.put("bannerTotal", sysLunboService.count());

        Map<String, Object> data = new HashMap<>();
        data.put("metrics", metrics);
        data.put("pendingWorks", getPendingWorks());
        data.put("recentOrders", getRecentOrders());
        data.put("recentLogs", getRecentLogs());

        return Result.success(data);
    }

    private void ensureAdmin(Integer userId) {
        List<String> roles = userMapper.getRoleNamesByUserId(userId);
        if (roles == null || !roles.contains("admin")) {
            throw new BusinessException(20008, "当前身份无管理员权限");
        }
    }

    private List<SysHuagao> getPendingWorks() {
        Page<SysHuagao> page = new Page<>(1, 5);
        LambdaQueryWrapper<SysHuagao> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysHuagao::getStatus, "未审核").orderByDesc(SysHuagao::getId);
        sysHuagaoService.page(page, wrapper);
        return page.getRecords();
    }

    private List<SysOrder> getRecentOrders() {
        Page<SysOrder> page = new Page<>(1, 5);
        LambdaQueryWrapper<SysOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.ne(SysOrder::getStatus, "购物车").orderByDesc(SysOrder::getId);
        sysOrderService.page(page, wrapper);
        return page.getRecords();
    }

    private List<SysRizhi> getRecentLogs() {
        Page<SysRizhi> page = new Page<>(1, 5);
        LambdaQueryWrapper<SysRizhi> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(SysRizhi::getId);
        sysRizhiService.page(page, wrapper);
        return page.getRecords();
    }
}
