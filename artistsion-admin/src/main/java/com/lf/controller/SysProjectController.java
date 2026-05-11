package com.lf.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.SysProjectApplication;
import com.lf.entity.SysProject;
import com.lf.entity.User;
import com.lf.service.SysProjectApplicationService;
import com.lf.service.SysProjectService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/sysProject")
public class SysProjectController {

    @Resource
    private SysProjectService service;

    @Resource
    private SysProjectApplicationService projectApplicationService;

    @Resource
    private JwtUtil jwtUtil;

    @GetMapping("/list")
    public Result<Map<String, Object>> getList(
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "userId", required = false) Long userId,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "12") Long pageSize) {

        LambdaQueryWrapper<SysProject> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            String safeKeyword = keyword.trim();
            wrapper.and(w -> w.like(SysProject::getTitle, safeKeyword)
                    .or().like(SysProject::getDescription, safeKeyword)
                    .or().like(SysProject::getCategory, safeKeyword)
                    .or().like(SysProject::getStyle, safeKeyword)
                    .or().like(SysProject::getUsername, safeKeyword));
        }
        wrapper.eq(StringUtils.hasLength(category), SysProject::getCategory, category);
        wrapper.eq(StringUtils.hasLength(status), SysProject::getStatus, status);
        wrapper.eq(userId != null, SysProject::getUserId, userId);
        wrapper.orderByDesc(SysProject::getId);

        Page<SysProject> page = new Page<>(pageNo, pageSize);
        service.page(page, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());
        return Result.success(data);
    }

    @GetMapping("/getById/{id}")
    public Result<SysProject> getById(@PathVariable Long id) {
        SysProject project = service.getById(id);
        if (project == null) {
            return Result.fail(20001, "企划不存在");
        }
        return Result.success(project);
    }

    @PostMapping("/add")
    public Result<?> add(@RequestBody SysProject project) {
        service.save(project);
        return Result.success("发布成功");
    }

    @PutMapping("/update")
    public Result<?> update(@RequestBody SysProject project) {
        service.updateById(project);
        return Result.success("修改成功");
    }

    @PostMapping("/apply")
    public Result<?> apply(HttpServletRequest request, @RequestBody SysProjectApplication application) {
        User loginUser = resolveLoginUser(request);
        if (loginUser == null || loginUser.getId() == null) {
            return Result.fail(20003, "请先登录后再应征");
        }
        if (application == null || application.getProjectId() == null) {
            return Result.fail(20001, "企划ID不能为空");
        }

        SysProject project = service.getById(application.getProjectId());
        if (project == null) {
            return Result.fail(20001, "企划不存在");
        }
        if (!"招募中".equals(project.getStatus())) {
            return Result.fail(20001, "该企划当前不可应征");
        }
        Long applicantId = Long.valueOf(loginUser.getId());
        if (project.getUserId() != null && project.getUserId().longValue() == applicantId.longValue()) {
            return Result.fail(20001, "不能应征自己发布的企划");
        }

        long duplicated = projectApplicationService.count(new LambdaQueryWrapper<SysProjectApplication>()
                .eq(SysProjectApplication::getProjectId, application.getProjectId())
                .eq(SysProjectApplication::getApplicantId, applicantId));
        if (duplicated > 0) {
            return Result.fail(20001, "你已经应征过该企划");
        }

        SysProjectApplication saved = new SysProjectApplication();
        saved.setProjectId(application.getProjectId());
        saved.setApplicantId(applicantId);
        saved.setApplicantName(StringUtils.hasText(loginUser.getName()) ? loginUser.getName() : loginUser.getUsername());
        saved.setApplicantAvatar(loginUser.getAvatar());
        saved.setMessage(sanitizeText(application.getMessage(), 2000));
        saved.setPortfolioUrl(sanitizeText(application.getPortfolioUrl(), 255));
        saved.setStatus("待处理");
        saved.setCreatedAt(new Date());
        saved.setUpdatedAt(new Date());
        projectApplicationService.save(saved);
        return Result.success("应征已提交");
    }

    @GetMapping("/applications")
    public Result<Map<String, Object>> getApplications(
            HttpServletRequest request,
            @RequestParam(value = "projectId") Long projectId,
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "20") Long pageSize) {
        User loginUser = resolveLoginUser(request);
        if (loginUser == null || loginUser.getId() == null) {
            return Result.fail(20003, "请先登录");
        }
        SysProject project = service.getById(projectId);
        if (project == null) {
            return Result.fail(20001, "企划不存在");
        }
        if (project.getUserId() == null || project.getUserId().longValue() != loginUser.getId().longValue()) {
            return Result.fail(20001, "只能查看自己企划的应征记录");
        }

        Page<SysProjectApplication> page = new Page<>(normalizePageNo(pageNo), normalizePageSize(pageSize));
        projectApplicationService.page(page, new LambdaQueryWrapper<SysProjectApplication>()
                .eq(SysProjectApplication::getProjectId, projectId)
                .orderByDesc(SysProjectApplication::getId));

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());
        return Result.success(data);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<?> deleteById(HttpServletRequest request, @PathVariable Long id) {
        SysProject project = service.getById(id);
        if (project == null) {
            return Result.fail(20001, "企划不存在");
        }

        User loginUser = resolveLoginUser(request);

        if (loginUser == null || loginUser.getId() == null) {
            return Result.fail(20003, "未登录");
        }
        if (project.getUserId() == null || project.getUserId().longValue() != loginUser.getId().longValue()) {
            return Result.fail(20001, "只能删除自己的企划");
        }

        service.removeById(id);
        return Result.success("删除成功");
    }

    private User resolveLoginUser(HttpServletRequest request) {
        try {
            return jwtUtil.parseToken(request.getHeader("X-Token"), User.class);
        } catch (Exception e) {
            return null;
        }
    }

    private String sanitizeText(String value, int maxLength) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        if (sanitized.length() > maxLength) {
            return sanitized.substring(0, maxLength);
        }
        return sanitized;
    }

    private long normalizePageNo(Long pageNo) {
        if (pageNo == null || pageNo < 1) {
            return 1L;
        }
        return pageNo;
    }

    private long normalizePageSize(Long pageSize) {
        if (pageSize == null || pageSize < 1) {
            return 20L;
        }
        return Math.min(pageSize, 100L);
    }
}
