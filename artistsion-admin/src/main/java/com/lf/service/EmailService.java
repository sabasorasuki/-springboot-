package com.lf.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);
    private static final String CODE_PREFIX = "email:code:";
    private static final long CODE_TTL_MINUTES = 5;

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    @Resource(name = "javaMailSender")
    private JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    /**
     * 发送验证码到指定邮箱，存入 Redis，TTL 5 分钟。
     * 如果邮件配置不可用，则 fallback 到控制台打印。
     */
    public void sendVerificationCode(String email) {
        String code = generateCode();
        String redisKey = CODE_PREFIX + email;

        // 限流：同一邮箱 60 秒内不能重复发送
        Long ttl = redisTemplate.getExpire(redisKey, TimeUnit.SECONDS);
        if (ttl != null && ttl > (CODE_TTL_MINUTES * 60 - 60)) {
            throw new com.lf.common.exception.BusinessException(20010, "验证码已发送，请60秒后重试");
        }

        redisTemplate.opsForValue().set(redisKey, code, CODE_TTL_MINUTES, TimeUnit.MINUTES);

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(email);
            message.setSubject("Artistsion 注册验证码");
            message.setText("您的验证码是：" + code + "，有效期5分钟。请勿泄露给他人。");
            mailSender.send(message);
            log.info("验证码已发送至 {}", email);
        } catch (Exception e) {
            // 邮件发送失败时 fallback 到控制台
            log.warn("邮件发送失败，fallback 到控制台输出。原因: {}", e.getMessage());
            log.info("【FALLBACK】邮箱 {} 的验证码: {}", email, code);
        }
    }

    /**
     * 验证码校验
     */
    public boolean verifyCode(String email, String code) {
        String redisKey = CODE_PREFIX + email;
        Object stored = redisTemplate.opsForValue().get(redisKey);
        if (stored != null && stored.toString().equals(code)) {
            redisTemplate.delete(redisKey);
            return true;
        }
        return false;
    }

    private String generateCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }
}
