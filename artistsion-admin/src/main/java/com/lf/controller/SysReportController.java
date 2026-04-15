package com.lf.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.exception.BusinessException;
import com.lf.common.utils.JwtUtil;
import com.lf.dao.UserMapper;
import com.lf.entity.SysHuagao;
import com.lf.entity.SysLiuyan;
import com.lf.entity.SysOrder;
import com.lf.entity.SysReport;
import com.lf.entity.SysZuopin;
import com.lf.entity.User;
import com.lf.service.SysHuagaoService;
import com.lf.service.SysLiuyanService;
import com.lf.service.SysOrderService;
import com.lf.service.SysReportService;
import com.lf.service.SysZuopinService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/sysReport")
public class SysReportController {

    private static final Set<String> TARGET_TYPES = new HashSet<>(Arrays.asList("作品", "社区内容", "反馈", "订单"));
    private static final Set<String> HANDLE_STATUS = new HashSet<>(Arrays.asList("待处理", "已处理", "已驳回"));

    @Resource
    private SysReportService service;

    @Resource
    private JwtUtil jwtUtil;

    @Resource
    private UserMapper userMapper;

    @Resource
    private SysHuagaoService sysHuagaoService;

    @Resource
    private SysZuopinService sysZuopinService;

    @Resource
    private SysLiuyanService sysLiuyanService;

    @Resource
    private SysOrderService sysOrderService;

    @GetMapping("/list")
    public Result<Map<String, Object>> getList(
            @RequestHeader("X-Token") String token,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "targetType", required = false) String targetType,
            @RequestParam(value = "reason", required = false) String reason,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "10") Long pageSize) {

        ensureAdmin(token);

        LambdaQueryWrapper<SysReport> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StringUtils.hasLength(status), SysReport::getStatus, status);
        wrapper.eq(StringUtils.hasLength(targetType), SysReport::getTargetType, targetType);
        wrapper.eq(StringUtils.hasLength(reason), SysReport::getReason, reason);
        wrapper.and(StringUtils.hasLength(keyword), item -> item
                .like(SysReport::getTargetTitle, keyword)
                .or()
                .like(SysReport::getDetail, keyword)
                .or()
                .like(SysReport::getReporterUsername, keyword)
                .or()
                .like(SysReport::getHandlerResult, keyword));
        wrapper.orderByDesc(SysReport::getId);

        Page<SysReport> page = new Page<>(pageNo, pageSize);
        service.page(page, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());
        return Result.success(data);
    }

    @GetMapping("/getById/{id}")
    public Result<SysReport> getById(@RequestHeader("X-Token") String token, @PathVariable Long id) {
        ensureAdmin(token);
        SysReport report = service.getById(id);
        if (report == null) {
            throw new BusinessException(20001, "举报记录不存在");
        }
        return Result.success(report);
    }

    @PostMapping("/add")
    public Result<?> add(@RequestHeader("X-Token") String token, @RequestBody SysReport request) {
        User currentUser = requireLogin(token);
        validateCreateRequest(request);

        SysReport report = new SysReport();
        report.setReporterUserId(currentUser.getId().longValue());
        report.setReporterUsername(resolveDisplayName(currentUser));
        report.setTargetType(request.getTargetType());
        report.setTargetId(request.getTargetId());
        report.setTargetTitle(resolveTargetTitle(request.getTargetType(), request.getTargetId()));
        report.setReason(request.getReason());
        report.setDetail(request.getDetail());
        report.setStatus("待处理");
        report.setCreatedAt(new Date());
        report.setHandledAt(null);
        report.setHandlerUserId(null);
        report.setHandlerUsername(null);
        report.setHandlerResult(null);

        service.save(report);
        return Result.success("举报已提交");
    }

    @PutMapping("/handle")
    public Result<?> handle(@RequestHeader("X-Token") String token, @RequestBody SysReport request) {
        User adminUser = ensureAdmin(token);
        if (request.getId() == null) {
            throw new BusinessException(20001, "缺少举报记录 ID");
        }
        if (!StringUtils.hasLength(request.getStatus()) || !HANDLE_STATUS.contains(request.getStatus()) || "待处理".equals(request.getStatus())) {
            throw new BusinessException(20001, "请选择有效的处理状态");
        }
        if (!StringUtils.hasLength(request.getHandlerResult())) {
            throw new BusinessException(20001, "请填写处理备注");
        }

        SysReport report = service.getById(request.getId());
        if (report == null) {
            throw new BusinessException(20001, "举报记录不存在");
        }

        report.setStatus(request.getStatus());
        report.setHandlerResult(request.getHandlerResult().trim());
        report.setHandlerUserId(adminUser.getId().longValue());
        report.setHandlerUsername(resolveDisplayName(adminUser));
        report.setHandledAt(new Date());
        service.updateById(report);

        return Result.success("处理结果已更新");
    }

    private void validateCreateRequest(SysReport request) {
        if (request.getTargetId() == null) {
            throw new BusinessException(20001, "缺少举报对象 ID");
        }
        if (!StringUtils.hasLength(request.getTargetType()) || !TARGET_TYPES.contains(request.getTargetType())) {
            throw new BusinessException(20001, "举报对象类型不支持");
        }
        if (!StringUtils.hasLength(request.getReason())) {
            throw new BusinessException(20001, "请选择举报原因");
        }
    }

    private User ensureAdmin(String token) {
        User currentUser = requireLogin(token);
        List<String> roles = userMapper.getRoleNamesByUserId(currentUser.getId());
        if (roles == null || !roles.contains("admin")) {
            throw new BusinessException(20008, "当前身份无管理员权限");
        }
        return currentUser;
    }

    private User requireLogin(String token) {
        try {
            User loginUser = jwtUtil.parseToken(token, User.class);
            if (loginUser == null || loginUser.getId() == null) {
                throw new BusinessException(20003, "登录信息无效，请重新登录");
            }
            User dbUser = userMapper.selectById(loginUser.getId());
            if (dbUser == null) {
                throw new BusinessException(20003, "用户不存在，请重新登录");
            }
            return dbUser;
        } catch (BusinessException ex) {
            throw ex;
        } catch (Exception e) {
            throw new BusinessException(20003, "登录信息无效，请重新登录");
        }
    }

    private String resolveDisplayName(User user) {
        return StringUtils.hasLength(user.getName()) ? user.getName() : user.getUsername();
    }

    private String resolveTargetTitle(String targetType, Long targetId) {
        switch (targetType) {
            case "作品":
                SysHuagao huagao = sysHuagaoService.getById(targetId);
                if (huagao == null) {
                    throw new BusinessException(20001, "举报作品不存在");
                }
                return huagao.getName();
            case "社区内容":
                SysZuopin zuopin = sysZuopinService.getById(targetId);
                if (zuopin == null) {
                    throw new BusinessException(20001, "举报内容不存在");
                }
                return zuopin.getTitle();
            case "反馈":
                SysLiuyan liuyan = sysLiuyanService.getById(targetId);
                if (liuyan == null) {
                    throw new BusinessException(20001, "举报反馈不存在");
                }
                return abbreviate(liuyan.getContent(), 40);
            case "订单":
                SysOrder order = sysOrderService.getById(targetId);
                if (order == null) {
                    throw new BusinessException(20001, "举报订单不存在");
                }
                return order.getName();
            default:
                throw new BusinessException(20001, "举报对象类型不支持");
        }
    }

    private String abbreviate(String content, int maxLength) {
        if (!StringUtils.hasLength(content)) {
            return "未提供对象摘要";
        }
        if (content.length() <= maxLength) {
            return content;
        }
        return content.substring(0, maxLength) + "...";
    }
}
