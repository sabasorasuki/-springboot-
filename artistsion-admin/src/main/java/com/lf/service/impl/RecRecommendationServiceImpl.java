package com.lf.service.impl;

import com.lf.dao.RecRecommendationMapper;
import com.lf.service.RecRecommendationService;
import com.lf.service.RecTrackService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class RecRecommendationServiceImpl implements RecRecommendationService {

    private static final Logger log = LoggerFactory.getLogger(RecRecommendationServiceImpl.class);

    private static final String GLOBAL_ACTOR_KEY = "global";

    @Resource
    private RecRecommendationMapper recRecommendationMapper;

    @Resource
    private RecTrackService recTrackService;

    @Override
    public Map<String, Object> getRecommendations(String domain,
                                                  Integer userId,
                                                  String visitorId,
                                                  String sessionId,
                                                  String scene,
                                                  Long pageNo,
                                                  Long pageSize) {
        String safeDomain = normalizeDomain(domain);
        Long safePageNo = normalizePageNo(pageNo);
        Long safePageSize = normalizePageSize(pageSize);
        Long offset = (safePageNo - 1) * safePageSize;

        String modelVersion = null;
        Long total = 0L;
        List<Map<String, Object>> rows = new ArrayList<>();
        boolean fallback = true;

        try {
            modelVersion = recRecommendationMapper.selectActiveModelVersion(safeDomain);
            if (StringUtils.hasText(modelVersion)) {
                for (String actorKey : buildActorCandidates(userId, visitorId)) {
                    Long matched = recRecommendationMapper.countAvailableRecommendations(safeDomain, modelVersion, actorKey);
                    if (matched != null && matched > 0) {
                        List<Map<String, Object>> matchedRows = recRecommendationMapper.selectAvailableRecommendations(
                                safeDomain, modelVersion, actorKey, offset, safePageSize
                        );
                        if (!matchedRows.isEmpty() || safePageNo > 1) {
                            total = matched;
                            rows = matchedRows;
                            fallback = false;
                            break;
                        }
                    }
                }
            }
        } catch (Exception ex) {
            log.warn("Failed to load site recommendations for domain {}, fallback to latest/hot", safeDomain, ex);
            rows = new ArrayList<>();
            total = 0L;
            fallback = true;
        }

        if (fallback) {
            total = recRecommendationMapper.countFallbackItems(safeDomain);
            rows = recRecommendationMapper.selectFallbackItems(safeDomain, offset, safePageSize);
            modelVersion = null;
        }

        normalizeRows(rows, safeDomain, modelVersion);
        String requestId = recTrackService.trackList(
                safeDomain,
                scene,
                null,
                null,
                null,
                safePageNo,
                safePageSize,
                total,
                rows,
                userId == null ? null : Long.valueOf(userId),
                sanitize(visitorId),
                sanitize(sessionId),
                modelVersion,
                fallback
        );

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("total", total == null ? 0L : total);
        data.put("rows", rows);
        data.put("requestId", requestId);
        data.put("modelVersion", modelVersion);
        data.put("domain", safeDomain);
        data.put("fallback", fallback);
        return data;
    }

    @Override
    public Map<String, Object> getHealth() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("models", recRecommendationMapper.selectModelHealth());
        data.put("logs", recRecommendationMapper.selectLogHealth());
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

    private void normalizeRows(List<Map<String, Object>> rows, String domain, String modelVersion) {
        if (rows == null) {
            return;
        }
        for (Map<String, Object> row : rows) {
            row.put("domain", domain);
            row.put("trackingModelVersion", modelVersion);
            if (!row.containsKey("itemId") && row.containsKey("id")) {
                row.put("itemId", row.get("id"));
            }
        }
    }

    private String normalizeDomain(String domain) {
        String safeDomain = sanitize(domain);
        if (!Arrays.asList("huagao", "zuopin", "project", "artist").contains(safeDomain)) {
            return "huagao";
        }
        return safeDomain;
    }

    private Long normalizePageNo(Long pageNo) {
        return pageNo == null || pageNo < 1 ? 1L : pageNo;
    }

    private Long normalizePageSize(Long pageSize) {
        if (pageSize == null || pageSize < 1) {
            return 12L;
        }
        return Math.min(pageSize, 50L);
    }

    private String sanitize(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }
}
