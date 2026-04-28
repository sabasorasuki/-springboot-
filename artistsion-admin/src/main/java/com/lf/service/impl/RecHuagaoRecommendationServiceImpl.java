package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.dao.RecHuagaoRecommendationMapper;
import com.lf.dao.SysHuagaoMapper;
import com.lf.dao.UserMapper;
import com.lf.entity.SysHuagao;
import com.lf.entity.User;
import com.lf.service.RecHuagaoRecommendationService;
import com.lf.service.RecHuagaoTrackService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class RecHuagaoRecommendationServiceImpl implements RecHuagaoRecommendationService {

    private static final Logger log = LoggerFactory.getLogger(RecHuagaoRecommendationServiceImpl.class);

    private static final String DEFAULT_SCENE = "home";
    private static final String GLOBAL_ACTOR_KEY = "global";

    @Resource
    private RecHuagaoRecommendationMapper recommendationMapper;

    @Resource
    private SysHuagaoMapper sysHuagaoMapper;

    @Resource
    private UserMapper userMapper;

    @Resource
    private RecHuagaoTrackService recHuagaoTrackService;

    @Override
    public Map<String, Object> getRecommendations(Integer userId,
                                                   String visitorId,
                                                   String sessionId,
                                                   String scene,
                                                   Long pageNo,
                                                   Long pageSize) {
        long safePageNo = normalizePageNo(pageNo);
        long safePageSize = normalizePageSize(pageSize);
        String safeScene = sanitizeScene(scene);
        long offset = (safePageNo - 1) * safePageSize;

        String modelVersion = null;
        Long total = 0L;
        List<SysHuagao> records = new ArrayList<>();
        boolean fallback = true;

        try {
            modelVersion = recommendationMapper.selectActiveModelVersion();
            if (StringUtils.hasText(modelVersion)) {
                for (String actorKey : buildActorCandidates(userId, visitorId)) {
                    total = recommendationMapper.countAvailableRecommendations(modelVersion, actorKey);
                    if (total != null && total > 0) {
                        records = recommendationMapper.selectAvailableRecommendations(modelVersion, actorKey, offset, safePageSize);
                        if (!records.isEmpty() || safePageNo > 1) {
                            fallback = false;
                            break;
                        }
                    }
                }
            }
        } catch (Exception ex) {
            log.warn("Failed to load huagao LTR recommendations, fallback to latest", ex);
            records = new ArrayList<>();
            total = 0L;
            fallback = true;
        }

        if (fallback) {
            Page<SysHuagao> page = new Page<>(safePageNo, safePageSize);
            LambdaQueryWrapper<SysHuagao> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(SysHuagao::getStatus, "审核成功");
            wrapper.eq(SysHuagao::getType, "上架");
            wrapper.orderByDesc(SysHuagao::getId);
            sysHuagaoMapper.selectPage(page, wrapper);
            records = page.getRecords();
            total = page.getTotal();
        }

        populateArtistNames(records);
        String requestId = trackRecommendationList(
                safeScene,
                safePageNo,
                safePageSize,
                total,
                records,
                userId,
                visitorId,
                sessionId
        );

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("total", total == null ? 0L : total);
        data.put("rows", records);
        data.put("requestId", requestId);
        data.put("modelVersion", fallback ? null : modelVersion);
        data.put("fallback", fallback);
        return data;
    }

    private List<String> buildActorCandidates(Integer userId, String visitorId) {
        List<String> actorKeys = new ArrayList<>();
        if (userId != null && userId > 0) {
            actorKeys.add("u:" + userId);
        } else if (StringUtils.hasText(visitorId)) {
            actorKeys.add("v:" + visitorId.trim());
        }
        actorKeys.add(GLOBAL_ACTOR_KEY);
        return actorKeys;
    }

    private String trackRecommendationList(String scene,
                                           long pageNo,
                                           long pageSize,
                                           Long total,
                                           List<SysHuagao> records,
                                           Integer userId,
                                           String visitorId,
                                           String sessionId) {
        try {
            return recHuagaoTrackService.trackListIfNeeded(
                    scene,
                    null,
                    null,
                    null,
                    pageNo,
                    pageSize,
                    total,
                    records,
                    userId == null ? null : Long.valueOf(userId),
                    sanitizeValue(visitorId),
                    sanitizeValue(sessionId)
            );
        } catch (Exception ex) {
            log.warn("Failed to track huagao recommendation list", ex);
            return null;
        }
    }

    private void populateArtistNames(List<SysHuagao> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        Set<Integer> artistIds = new LinkedHashSet<>();
        for (SysHuagao record : records) {
            Integer artistId = parseArtistId(record);
            if (artistId != null) {
                artistIds.add(artistId);
            }
        }

        if (artistIds.isEmpty()) {
            return;
        }

        List<User> artists = userMapper.selectBatchIds(artistIds);
        Map<Integer, String> artistNames = new HashMap<>();
        for (User artist : artists) {
            if (artist == null || artist.getId() == null) {
                continue;
            }
            artistNames.put(artist.getId(), resolveArtistName(artist));
        }

        for (SysHuagao record : records) {
            Integer artistId = parseArtistId(record);
            if (artistId != null) {
                record.setArtistName(artistNames.get(artistId));
            }
        }
    }

    private Integer parseArtistId(SysHuagao record) {
        if (record == null || !StringUtils.hasText(record.getShangjiaids())) {
            return null;
        }
        try {
            return Integer.parseInt(record.getShangjiaids().trim());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private String resolveArtistName(User artist) {
        if (artist == null) {
            return null;
        }
        return StringUtils.hasText(artist.getName()) ? artist.getName() : artist.getUsername();
    }

    private long normalizePageNo(Long pageNo) {
        if (pageNo == null || pageNo < 1) {
            return 1L;
        }
        return pageNo;
    }

    private long normalizePageSize(Long pageSize) {
        if (pageSize == null || pageSize < 1) {
            return 12L;
        }
        return Math.min(pageSize, 50L);
    }

    private String sanitizeScene(String scene) {
        String sanitized = sanitizeValue(scene);
        return StringUtils.hasText(sanitized) ? sanitized : DEFAULT_SCENE;
    }

    private String sanitizeValue(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }
}
