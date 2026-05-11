package com.lf.controller;

import com.lf.common.Result;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.User;
import com.lf.service.RecRecommendationService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/rec")
public class RecRecommendationController {

    @Resource
    private RecRecommendationService recRecommendationService;

    @Resource
    private JwtUtil jwtUtil;

    @GetMapping("/recommendations")
    public Result<Map<String, Object>> recommendations(
            HttpServletRequest request,
            @RequestParam(value = "domain", required = false, defaultValue = "huagao") String domain,
            @RequestParam(value = "pageNo", required = false) Long pageNo,
            @RequestParam(value = "pageSize", required = false) Long pageSize,
            @RequestParam(value = "scene", required = false) String scene) {
        User loginUser = resolveOptionalLoginUser(request);
        Integer userId = loginUser == null ? null : loginUser.getId();
        return Result.success(recRecommendationService.getRecommendations(
                domain,
                userId,
                sanitizeHeader(request.getHeader("X-Visitor-Id")),
                sanitizeHeader(request.getHeader("X-Session-Id")),
                scene,
                pageNo,
                pageSize
        ));
    }

    @GetMapping("/debug/health")
    public Result<Map<String, Object>> health() {
        return Result.success(recRecommendationService.getHealth());
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
