package com.lf.controller;

import com.lf.common.Result;
import com.lf.common.request.RecActionTrackRequest;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.User;
import com.lf.service.RecTrackService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/recTrack")
public class RecTrackController {

    @Resource
    private RecTrackService recTrackService;

    @Resource
    private JwtUtil jwtUtil;

    @PostMapping("/action")
    public Result<?> trackAction(HttpServletRequest request,
                                 @RequestBody RecActionTrackRequest trackRequest) {
        User loginUser = resolveOptionalLoginUser(request);
        Long userId = loginUser == null || loginUser.getId() == null ? null : Long.valueOf(loginUser.getId());
        recTrackService.trackAction(
                trackRequest,
                userId,
                sanitizeHeader(request.getHeader("X-Visitor-Id")),
                sanitizeHeader(request.getHeader("X-Session-Id"))
        );
        return Result.success("记录成功");
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
