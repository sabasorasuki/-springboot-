package com.lf.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

import com.lf.common.exception.BusinessException;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);
    private static final String CODE_PREFIX = "email:code:";
    private static final long CODE_TTL_MINUTES = 5;
    private static final long RESEND_COOLDOWN_SECONDS = 60;

    private final Map<String, CodeCacheEntry> localCodeCache = new ConcurrentHashMap<>();

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    @Resource
    private JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    /**
     * 发送验证码到指定邮箱，存入 Redis，TTL 5 分钟。
     */
    public void sendVerificationCode(String email) {
        if (!StringUtils.hasText(fromEmail)) {
            throw new BusinessException(20011, "邮件服务未配置，请联系管理员");
        }

        String code = generateCode();
        String redisKey = CODE_PREFIX + email;

        // 限流：同一邮箱 60 秒内不能重复发送
        Long ttl = getRemainingCooldownSeconds(redisKey);
        if (ttl != null && ttl > 0) {
            throw new BusinessException(20010, "验证码已发送，请60秒后重试");
        }

        cacheCode(redisKey, code);

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(email);
            message.setSubject("Artistsion 注册验证码");
            message.setText("您的验证码是：" + code + "，有效期5分钟。请勿泄露给他人。");
            mailSender.send(message);
            log.info("验证码已发送至 {}", email);
        } catch (Exception e) {
            clearCode(redisKey);
            log.error("邮件发送失败，邮箱: {}", email, e);
            throw new BusinessException(20011, "验证码发送失败，请稍后重试");
        }
    }

    /**
     * 验证码校验
     */
    public boolean verifyCode(String email, String code) {
        String redisKey = CODE_PREFIX + email;
        String storedCode = getCachedCode(redisKey);
        if (storedCode != null && storedCode.equals(code)) {
            clearCode(redisKey);
            return true;
        }
        return false;
    }

    private Long getRemainingCooldownSeconds(String redisKey) {
        try {
            Long ttl = redisTemplate.getExpire(redisKey, TimeUnit.SECONDS);
            if (ttl == null || ttl <= 0) {
                return 0L;
            }
            long cooldownBoundary = CODE_TTL_MINUTES * 60 - RESEND_COOLDOWN_SECONDS;
            return ttl > cooldownBoundary ? ttl - cooldownBoundary : 0L;
        } catch (RedisConnectionFailureException ex) {
            CodeCacheEntry entry = localCodeCache.get(redisKey);
            if (entry == null) {
                return 0L;
            }
            long remaining = entry.cooldownUntilMillis - System.currentTimeMillis();
            if (remaining <= 0) {
                return 0L;
            }
            log.warn("Redis 不可用，邮箱验证码限流降级为本地缓存");
            return (long) Math.ceil(remaining / 1000.0);
        }
    }

    private void cacheCode(String redisKey, String code) {
        try {
            redisTemplate.opsForValue().set(redisKey, code, CODE_TTL_MINUTES, TimeUnit.MINUTES);
        } catch (RedisConnectionFailureException ex) {
            long now = System.currentTimeMillis();
            localCodeCache.put(redisKey, new CodeCacheEntry(
                    code,
                    now + TimeUnit.MINUTES.toMillis(CODE_TTL_MINUTES),
                    now + TimeUnit.SECONDS.toMillis(RESEND_COOLDOWN_SECONDS)
            ));
            log.warn("Redis 不可用，邮箱验证码存储降级为本地缓存");
        }
    }

    private String getCachedCode(String redisKey) {
        try {
            Object stored = redisTemplate.opsForValue().get(redisKey);
            return stored == null ? null : stored.toString();
        } catch (RedisConnectionFailureException ex) {
            CodeCacheEntry entry = localCodeCache.get(redisKey);
            if (entry == null) {
                return null;
            }
            if (entry.expireAtMillis <= System.currentTimeMillis()) {
                localCodeCache.remove(redisKey);
                return null;
            }
            log.warn("Redis 不可用，邮箱验证码校验降级为本地缓存");
            return entry.code;
        }
    }

    private void clearCode(String redisKey) {
        try {
            redisTemplate.delete(redisKey);
        } catch (RedisConnectionFailureException ex) {
            log.warn("Redis 不可用，邮箱验证码删除降级为本地缓存");
        } finally {
            localCodeCache.remove(redisKey);
        }
    }

    private String generateCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }

    private static class CodeCacheEntry {
        private final String code;
        private final long expireAtMillis;
        private final long cooldownUntilMillis;

        private CodeCacheEntry(String code, long expireAtMillis, long cooldownUntilMillis) {
            this.code = code;
            this.expireAtMillis = expireAtMillis;
            this.cooldownUntilMillis = cooldownUntilMillis;
        }
    }
}
