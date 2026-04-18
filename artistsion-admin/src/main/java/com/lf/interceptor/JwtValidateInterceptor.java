package com.lf.interceptor;

import com.alibaba.fastjson2.JSON;
import com.lf.common.Result;
import com.lf.common.utils.JwtUtil;
import com.lf.dao.UserMapper;
import com.lf.entity.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component
@Slf4j
public class JwtValidateInterceptor implements HandlerInterceptor {
    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserMapper userMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String token = request.getHeader("X-Token");
        log.debug("{} 待验证 token: {}", request.getRequestURI(), token != null);
        if (token != null) {
            try {
                User loginUser = jwtUtil.parseToken(token, User.class);
                if (loginUser != null && loginUser.getId() != null) {
                    User dbUser = userMapper.selectById(loginUser.getId());
                    if (isActiveUser(dbUser)) {
                        log.debug("{} 放行...", request.getRequestURI());
                        return true;
                    }
                }
                log.warn("{} token 对应用户不存在或已失效", request.getRequestURI());
            } catch (Exception e) {
                log.warn("{} token 校验失败: {}", request.getRequestURI(), e.getMessage());
            }
        }
        log.debug(request.getRequestURI() + " 禁止访问...");
        response.setContentType("application/json;charset=utf-8");
        response.getWriter().write(JSON.toJSONString(Result.fail(20003, "jwt令牌无效，请重新登录")));
        return false;
    }

    private boolean isActiveUser(User user) {
        if (user == null) {
            return false;
        }
        if (user.getDeleted() != null && user.getDeleted() == 1) {
            return false;
        }
        return user.getStatus() == null || user.getStatus() == 1;
    }
}
