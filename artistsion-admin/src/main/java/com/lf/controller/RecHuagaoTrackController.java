package com.lf.controller;

import com.lf.common.Result;
import com.lf.common.request.RecHuagaoActionTrackRequest;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.User;
import com.lf.service.RecHuagaoTrackService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/recHuagaoTrack")
public class RecHuagaoTrackController {

    @Resource
    private RecHuagaoTrackService recHuagaoTrackService;

    @Resource
    private JwtUtil jwtUtil;

    @PostMapping("/action")
    public Result<?> trackAction(HttpServletRequest request,
                                 @RequestBody RecHuagaoActionTrackRequest trackRequest) {
        User loginUser = resolveOptionalLoginUser(request);
        Long userId = loginUser == null || loginUser.getId() == null ? null : Long.valueOf(loginUser.getId());
        recHuagaoTrackService.trackAction(
                trackRequest,
                userId,
                sanitizeHeader(request.getHeader("X-Visitor-Id")),
                sanitizeHeader(request.getHeader("X-Session-Id"))
        );
        return Result.success("记录成功");
    }

    @GetMapping("/debug/request/{requestId}")
    public Result<Map<String, Object>> getRequestDebug(@PathVariable("requestId") String requestId) {
        return Result.success(recHuagaoTrackService.getRequestDebug(requestId));
    }

    @GetMapping("/debug/rebuildCheck")
    public Result<Map<String, Object>> getDailyRebuildCheck(
            @RequestParam(value = "dt", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dt) {
        return Result.success(recHuagaoTrackService.getDailyRebuildCheck(dt));
    }

    @GetMapping("/debug/samplePreview")
    public Result<Map<String, Object>> getTrainingSamplePreview(
            @RequestParam(value = "dateFrom", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(value = "dateTo", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo,
            @RequestParam(value = "limit", required = false) Integer limit) {
        return Result.success(recHuagaoTrackService.getTrainingSamplePreview(dateFrom, dateTo, limit));
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
