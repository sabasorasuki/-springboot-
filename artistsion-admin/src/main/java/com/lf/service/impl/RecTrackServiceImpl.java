package com.lf.service.impl;

import com.lf.common.exception.BusinessException;
import com.lf.common.request.RecActionTrackRequest;
import com.lf.dao.RecTrackMapper;
import com.lf.service.RecTrackService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class RecTrackServiceImpl implements RecTrackService {

    private static final Logger log = LoggerFactory.getLogger(RecTrackServiceImpl.class);

    private static final Set<String> ALLOWED_DOMAINS = new HashSet<>(Arrays.asList(
            "huagao", "zuopin", "project", "artist"
    ));

    private static final Set<String> ALLOWED_ACTION_TYPES = new HashSet<>(Arrays.asList(
            "impression",
            "click_detail",
            "detail_view",
            "detail_dwell",
            "favorite",
            "like",
            "comment",
            "follow",
            "add_to_cart",
            "apply_project",
            "create_order"
    ));

    @Resource
    private RecTrackMapper recTrackMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String trackList(String domain,
                            String scene,
                            String keyword,
                            String category,
                            Long tagId,
                            Long pageNo,
                            Long pageSize,
                            Long total,
                            List<Map<String, Object>> records,
                            Long userId,
                            String visitorId,
                            String sessionId,
                            String modelVersion,
                            boolean fallback) {
        String safeDomain = normalizeDomain(domain);
        String safeScene = defaultText(scene, safeDomain);
        Long safePageNo = normalizePageNo(pageNo);
        Long safePageSize = normalizePageSize(pageSize);
        String requestId = UUID.randomUUID().toString().replace("-", "");
        LocalDateTime now = LocalDateTime.now();

        Map<String, Object> requestRow = new HashMap<>();
        requestRow.put("requestId", requestId);
        requestRow.put("domain", safeDomain);
        requestRow.put("queryKey", queryKey(safeDomain, safeScene, keyword, category, tagId));
        requestRow.put("scene", safeScene);
        requestRow.put("userId", userId);
        requestRow.put("visitorId", sanitize(visitorId));
        requestRow.put("sessionId", sanitize(sessionId));
        requestRow.put("keyword", sanitize(keyword));
        requestRow.put("category", sanitize(category));
        requestRow.put("tagId", tagId);
        requestRow.put("pageNo", safePageNo);
        requestRow.put("pageSize", safePageSize);
        requestRow.put("sortMode", fallback ? "fallback" : "personalized");
        requestRow.put("resultTotal", total == null ? 0L : total);
        requestRow.put("returnedCount", records == null ? 0L : Long.valueOf(records.size()));
        requestRow.put("fallback", fallback ? 1 : 0);
        requestRow.put("modelVersion", sanitize(modelVersion));
        requestRow.put("createdAt", now);
        recTrackMapper.insertRequestLog(requestRow);

        if (records != null) {
            long basePosition = (safePageNo - 1) * safePageSize;
            for (int i = 0; i < records.size(); i++) {
                Map<String, Object> record = records.get(i);
                Long itemId = valueAsLong(firstPresent(record, "itemId", "id"));
                if (itemId == null) {
                    continue;
                }
                Long authorId = valueAsLong(firstPresent(record, "authorId", "shangjiaids", "userids", "userId"));
                Map<String, Object> impressionRow = new HashMap<>();
                impressionRow.put("requestId", requestId);
                impressionRow.put("domain", safeDomain);
                impressionRow.put("itemId", itemId);
                impressionRow.put("authorId", authorId);
                impressionRow.put("position", basePosition + i + 1);
                impressionRow.put("pageNo", safePageNo);
                impressionRow.put("pageSize", safePageSize);
                impressionRow.put("scene", safeScene);
                impressionRow.put("modelVersion", sanitize(modelVersion));
                impressionRow.put("createdAt", now);
                recTrackMapper.insertImpressionLog(impressionRow);
            }
        }
        return requestId;
    }

    @Override
    public void trackAction(RecActionTrackRequest request,
                            Long userId,
                            String visitorId,
                            String sessionId) {
        validateActionRequest(request);

        Map<String, Object> row = new HashMap<>();
        row.put("eventId", request.getEventId().trim());
        row.put("eventType", request.getEventType().trim());
        row.put("domain", normalizeDomain(request.getDomain()));
        row.put("requestId", sanitize(request.getRequestId()));
        row.put("itemId", request.getItemId());
        row.put("authorId", request.getAuthorId());
        row.put("userId", userId);
        row.put("visitorId", sanitize(visitorId));
        row.put("sessionId", sanitize(sessionId));
        row.put("position", request.getPosition());
        row.put("eventValue", request.getEventValue());
        row.put("scene", sanitize(request.getScene()));
        row.put("source", sanitize(request.getSource()));
        row.put("modelVersion", sanitize(request.getModelVersion()));
        row.put("createdAt", LocalDateTime.now());
        int inserted = recTrackMapper.insertActionLog(row);
        if (inserted == 0) {
            log.info("Ignore duplicate rec action event: {}", request.getEventId());
        }
    }

    private void validateActionRequest(RecActionTrackRequest request) {
        if (request == null) {
            throw new BusinessException(20001, "行为参数不能为空");
        }
        if (!StringUtils.hasText(request.getEventId())) {
            throw new BusinessException(20001, "eventId不能为空");
        }
        if (!StringUtils.hasText(request.getEventType()) ||
                !ALLOWED_ACTION_TYPES.contains(request.getEventType().trim())) {
            throw new BusinessException(20001, "eventType不支持");
        }
        normalizeDomain(request.getDomain());
        if (request.getItemId() == null || request.getItemId() < 1) {
            throw new BusinessException(20001, "itemId不能为空");
        }
    }

    private String normalizeDomain(String domain) {
        String safeDomain = sanitize(domain);
        if (!StringUtils.hasText(safeDomain) || !ALLOWED_DOMAINS.contains(safeDomain)) {
            throw new BusinessException(20001, "推荐内容域不支持");
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

    private String defaultText(String value, String fallback) {
        String sanitized = sanitize(value);
        return StringUtils.hasText(sanitized) ? sanitized : fallback;
    }

    private String sanitize(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }

    private String queryKey(String domain, String scene, String keyword, String category, Long tagId) {
        String raw = String.valueOf(domain) + "|" + scene + "|" +
                String.valueOf(sanitize(keyword)) + "|" +
                String.valueOf(sanitize(category)) + "|" +
                String.valueOf(tagId);
        return DigestUtils.md5DigestAsHex(raw.getBytes(StandardCharsets.UTF_8));
    }

    private Object firstPresent(Map<String, Object> row, String... keys) {
        for (String key : keys) {
            if (row.containsKey(key) && row.get(key) != null) {
                return row.get(key);
            }
        }
        return null;
    }

    private Long valueAsLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        try {
            String text = String.valueOf(value).trim();
            if (!StringUtils.hasText(text)) {
                return null;
            }
            return Long.valueOf(text);
        } catch (NumberFormatException ignored) {
            return null;
        }
    }
}
