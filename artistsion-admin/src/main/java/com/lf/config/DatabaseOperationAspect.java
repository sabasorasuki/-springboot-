package com.lf.config;

import com.alibaba.fastjson2.JSON;
import com.lf.entity.SysRizhi;
import com.lf.entity.User;
import com.lf.service.SysRizhiService;
import com.lf.service.UserService;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

@Aspect
@Component
public class DatabaseOperationAspect {

    @Resource
    private UserService userService;

    @Resource
    private SysRizhiService rizhiService;


    @Before("execution(* com.lf.controller.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs(); // 获取方法参数
        long startTime = System.currentTimeMillis(); // 获取当前时间作为方法开始时间


        Integer userId = null;

        String userName = null;

        // 获取请求参数
        String params = Arrays.toString(joinPoint.getArgs());



        LocalDateTime now = LocalDateTime.now();

        System.out.println("--------请求前置日志输出开始--------");

        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();

        HttpServletRequest request = Objects.requireNonNull(attributes).getRequest();

        String token = request.getHeader("X-Token");
        if(token != null){



            Map<String, Object> userInfo = userService.getUserInfo(token);
            Object userListObj = userInfo.get("userList");
            if (userListObj != null) {
                User userList = (User) userListObj;
                // 使用userList中的字段进行操作
                System.out.println(userList+"123131");
                userName = userList.getName();
                userId = userList.getId();

            }
            System.out.println(request.getRequestURI() +" 待验证："+token);



            System.out.println("请求访问时间: {}"+now);
            // 获取请求url
            String requestUrl = request.getRequestURL().toString();


            System.out.println("请求url: {}"+ requestUrl);

            System.out.println("请求姓名: {}"+ userName);

            // 获取method
            System.out.println("请求方式: {}"+request.getMethod());

            System.out.println("请求参数列表: {}"+ params);

            System.out.println("操作人ID: {}"+ userId);

            String jsonString = JSON.toJSONString("请求访问时间:"+now+"--操作人:"+userName+
                    "--请求方式:"+request.getMethod()+"--请求url:"+requestUrl+"操作人id:"+userId);
            System.out.println(jsonString);

            Date currentDate = new Date();

            SysRizhi sysRizhi = new SysRizhi();
            sysRizhi.setRizhi(jsonString);
            sysRizhi.setJldate(currentDate);
            rizhiService.save(sysRizhi);



        }



        //databaseLogger.logBeforeOperation(methodName, args, startTime);
    }


    @After("execution(* com.lf.service.*.*(..))")
    public void logAfter(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        long endTime = System.currentTimeMillis(); // 获取当前时间作为方法结束时间
        Object[] args = joinPoint.getArgs(); // 获取方法参数
        //databaseLogger.logAfterOperation(methodName, args, endTime);
    }
}
