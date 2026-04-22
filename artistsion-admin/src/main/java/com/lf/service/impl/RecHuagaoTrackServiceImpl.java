package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lf.dao.RecHuagaoActionLogMapper;
import com.lf.dao.RecHuagaoDebugMapper;
import com.lf.dao.RecHuagaoImpressionLogMapper;
import com.lf.dao.RecHuagaoItemStatDailyMapper;
import com.lf.dao.RecHuagaoQueryStatDailyMapper;
import com.lf.dao.RecHuagaoRequestLogMapper;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.RecHuagaoActionTrackRequest;
import com.lf.common.utils.TagNormalizationUtil;
import com.lf.entity.RecHuagaoActionLog;
import com.lf.entity.RecHuagaoImpressionLog;
import com.lf.entity.RecHuagaoItemStatDaily;
import com.lf.entity.RecHuagaoQueryStatDaily;
import com.lf.entity.RecHuagaoRequestLog;
import com.lf.entity.SysHuagao;
import com.lf.service.RecHuagaoTrackService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class RecHuagaoTrackServiceImpl implements RecHuagaoTrackService {

    private static final Logger log = LoggerFactory.getLogger(RecHuagaoTrackServiceImpl.class);

    private static final String SCENE_SHOWCASE = "showcase";
    private static final String EVENT_CLICK_DETAIL = "click_detail";
    private static final String EVENT_FAVORITE = "favorite";
    private static final Set<String> ALLOWED_ACTION_TYPES = Arrays.stream(new String[]{EVENT_CLICK_DETAIL, EVENT_FAVORITE})
            .collect(Collectors.toSet());

    @Resource
    private RecHuagaoRequestLogMapper requestLogMapper;

    @Resource
    private RecHuagaoImpressionLogMapper impressionLogMapper;

    @Resource
    private RecHuagaoActionLogMapper actionLogMapper;

    @Resource
    private RecHuagaoDebugMapper debugMapper;

    @Resource
    private RecHuagaoItemStatDailyMapper itemStatDailyMapper;

    @Resource
    private RecHuagaoQueryStatDailyMapper queryStatDailyMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String trackListIfNeeded(String scene,
                                    String keyword,
                                    String fenlei,
                                    Long tagId,
                                    Long pageNo,
                                    Long pageSize,
                                    Long total,
                                    List<SysHuagao> records,
                                    Long userId,
                                    String visitorId,
                                    String sessionId) {
        if (!isShowcaseScene(scene)) {
            return null;
        }

        String sanitizedKeyword = sanitizeKeyword(keyword);
        String normalizedKeyword = StringUtils.hasText(sanitizedKeyword)
                ? TagNormalizationUtil.normalize(sanitizedKeyword)
                : null;
        String normalizedFenlei = sanitizeValue(fenlei);
        int hasSearch = StringUtils.hasText(sanitizedKeyword) ? 1 : 0;
        int hasFenleiFilter = StringUtils.hasText(normalizedFenlei) && !"全部".equals(normalizedFenlei) ? 1 : 0;
        int hasTagFilter = tagId != null && tagId > 0 ? 1 : 0;
        String requestId = UUID.randomUUID().toString().replace("-", "");
        String queryKey = buildQueryKey(scene, normalizedKeyword, normalizedFenlei, hasTagFilter == 1 ? tagId : null);
        LocalDateTime now = LocalDateTime.now();
        LocalDate today = now.toLocalDate();

        RecHuagaoRequestLog requestLog = new RecHuagaoRequestLog();
        requestLog.setRequestId(requestId);
        requestLog.setQueryKey(queryKey);
        requestLog.setScene(SCENE_SHOWCASE);
        requestLog.setUserId(userId);
        requestLog.setVisitorId(sanitizeValue(visitorId));
        requestLog.setSessionId(sanitizeValue(sessionId));
        requestLog.setKeyword(sanitizedKeyword);
        requestLog.setNormalizedKeyword(normalizedKeyword);
        requestLog.setFenlei(hasFenleiFilter == 1 ? normalizedFenlei : null);
        requestLog.setTagId(hasTagFilter == 1 ? tagId : null);
        requestLog.setPageNo(pageNo);
        requestLog.setPageSize(pageSize);
        requestLog.setSortMode(hasSearch == 1 ? "search_score" : "default");
        requestLog.setHasSearch(hasSearch);
        requestLog.setHasFenleiFilter(hasFenleiFilter);
        requestLog.setHasTagFilter(hasTagFilter);
        requestLog.setResultTotal(total == null ? 0L : total);
        requestLog.setReturnedCount(records == null ? 0L : (long) records.size());
        requestLog.setCreatedAt(now);
        requestLogMapper.insert(requestLog);

        List<RecHuagaoImpressionLog> impressions = buildImpressions(requestLog, records, now);
        for (RecHuagaoImpressionLog impression : impressions) {
            impressionLogMapper.insert(impression);
        }

        safeUpsertListAggregates(requestLog, impressions, today);
        return requestId;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void trackAction(RecHuagaoActionTrackRequest request,
                            Long userId,
                            String visitorId,
                            String sessionId) {
        validateActionRequest(request);

        String eventType = request.getEventType().trim();
        LocalDateTime now = LocalDateTime.now();
        LocalDate today = now.toLocalDate();

        RecHuagaoActionLog actionLog = new RecHuagaoActionLog();
        actionLog.setEventId(request.getEventId().trim());
        actionLog.setEventType(eventType);
        actionLog.setRequestId(sanitizeValue(request.getRequestId()));
        actionLog.setHuagaoId(request.getHuagaoId());
        actionLog.setShangjiaId(request.getShangjiaId());
        actionLog.setUserId(userId);
        actionLog.setVisitorId(sanitizeValue(visitorId));
        actionLog.setSessionId(sanitizeValue(sessionId));
        actionLog.setPosition(request.getPosition());
        actionLog.setScene(sanitizeScene(request.getScene()));
        actionLog.setSource(sanitizeValue(request.getSource()));
        actionLog.setCreatedAt(now);

        try {
            actionLogMapper.insert(actionLog);
        } catch (DuplicateKeyException duplicateKeyException) {
            log.info("Ignore duplicate huagao action event: {}", actionLog.getEventId());
            return;
        }

        RecHuagaoRequestLog requestLog = null;
        if (StringUtils.hasText(actionLog.getRequestId())) {
            requestLog = requestLogMapper.selectById(actionLog.getRequestId());
        }
        safeUpsertActionAggregates(actionLog, requestLog, today);
    }

    @Override
    public Map<String, Object> getRequestDebug(String requestId) {
        String sanitizedRequestId = sanitizeValue(requestId);
        if (!StringUtils.hasText(sanitizedRequestId)) {
            throw new BusinessException(20001, "requestId不能为空");
        }

        RecHuagaoRequestLog requestLog = requestLogMapper.selectById(sanitizedRequestId);
        if (requestLog == null) {
            throw new BusinessException(20001, "请求日志不存在");
        }

        List<RecHuagaoImpressionLog> impressions = impressionLogMapper.selectList(
                new LambdaQueryWrapper<RecHuagaoImpressionLog>()
                        .eq(RecHuagaoImpressionLog::getRequestId, sanitizedRequestId)
                        .orderByAsc(RecHuagaoImpressionLog::getPosition)
                        .orderByAsc(RecHuagaoImpressionLog::getId)
        );
        List<RecHuagaoActionLog> actions = actionLogMapper.selectList(
                new LambdaQueryWrapper<RecHuagaoActionLog>()
                        .eq(RecHuagaoActionLog::getRequestId, sanitizedRequestId)
                        .orderByAsc(RecHuagaoActionLog::getCreatedAt)
                        .orderByAsc(RecHuagaoActionLog::getId)
        );

        long clickDetailCount = actions.stream()
                .filter(this::isClickDetail)
                .count();
        long favoriteCount = actions.stream()
                .filter(this::isFavorite)
                .count();
        Set<Long> exposedHuagaoIds = impressions.stream()
                .map(RecHuagaoImpressionLog::getHuagaoId)
                .filter(Objects::nonNull)
                .collect(Collectors.toCollection(LinkedHashSet::new));
        Set<Long> actedHuagaoIds = actions.stream()
                .map(RecHuagaoActionLog::getHuagaoId)
                .filter(Objects::nonNull)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("requestId", sanitizedRequestId);
        summary.put("scene", requestLog.getScene());
        summary.put("hasSearch", intValue(requestLog.getHasSearch()));
        summary.put("hasFenleiFilter", intValue(requestLog.getHasFenleiFilter()));
        summary.put("hasTagFilter", intValue(requestLog.getHasTagFilter()));
        summary.put("impressionCount", impressions.size());
        summary.put("clickDetailCount", clickDetailCount);
        summary.put("favoriteCount", favoriteCount);
        summary.put("exposedHuagaoIds", exposedHuagaoIds);
        summary.put("actedHuagaoIds", actedHuagaoIds);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("summary", summary);
        data.put("request", requestLog);
        data.put("impressions", impressions);
        data.put("actions", actions);
        return data;
    }

    @Override
    public Map<String, Object> getDailyRebuildCheck(LocalDate dt) {
        LocalDate targetDt = dt == null ? LocalDate.now() : dt;
        List<Map<String, Object>> itemRows = debugMapper.selectItemDailyRebuildCheck(targetDt);
        List<Map<String, Object>> queryRows = debugMapper.selectQueryDailyRebuildCheck(targetDt);

        long itemMismatchCount = countMismatchRows(itemRows);
        long queryMismatchCount = countMismatchRows(queryRows);

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("dt", targetDt);
        summary.put("itemRowCount", itemRows.size());
        summary.put("itemMismatchCount", itemMismatchCount);
        summary.put("queryRowCount", queryRows.size());
        summary.put("queryMismatchCount", queryMismatchCount);
        summary.put("allMatched", itemMismatchCount == 0 && queryMismatchCount == 0);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("summary", summary);
        data.put("itemRows", itemRows);
        data.put("queryRows", queryRows);
        return data;
    }

    @Override
    public Map<String, Object> getTrainingSamplePreview(LocalDate dateFrom,
                                                        LocalDate dateTo,
                                                        Integer limit) {
        LocalDate safeDateTo = dateTo == null ? LocalDate.now() : dateTo;
        LocalDate safeDateFrom = dateFrom == null ? safeDateTo : dateFrom;
        if (safeDateFrom.isAfter(safeDateTo)) {
            throw new BusinessException(20001, "dateFrom不能晚于dateTo");
        }
        int safeLimit = normalizePreviewLimit(limit);
        List<Map<String, Object>> rows = debugMapper.selectTrainingSamplePreview(safeDateFrom, safeDateTo, safeLimit);

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("dateFrom", safeDateFrom);
        summary.put("dateTo", safeDateTo);
        summary.put("limit", safeLimit);
        summary.put("rowCount", rows.size());

        Map<String, Object> labelSummary = new LinkedHashMap<>();
        labelSummary.put("impressionOnly", rows.stream().filter(row -> intValue(row.get("relevance")) == 0).count());
        labelSummary.put("clickDetail", rows.stream().filter(row -> intValue(row.get("relevance")) == 1).count());
        labelSummary.put("favorite", rows.stream().filter(row -> intValue(row.get("relevance")) == 2).count());

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("summary", summary);
        data.put("labelSummary", labelSummary);
        data.put("rows", rows);
        return data;
    }

    private void validateActionRequest(RecHuagaoActionTrackRequest request) {
        if (request == null) {
            throw new BusinessException(20001, "行为参数不能为空");
        }
        if (!StringUtils.hasText(request.getEventId())) {
            throw new BusinessException(20001, "事件ID不能为空");
        }
        if (request.getEventId().trim().length() > 64) {
            throw new BusinessException(20001, "事件ID长度不能超过64个字符");
        }
        if (!StringUtils.hasText(request.getEventType())) {
            throw new BusinessException(20001, "事件类型不能为空");
        }
        if (!ALLOWED_ACTION_TYPES.contains(request.getEventType().trim())) {
            throw new BusinessException(20001, "暂不支持的行为类型");
        }
        if (request.getHuagaoId() == null || request.getHuagaoId() <= 0) {
            throw new BusinessException(20001, "画稿ID不能为空");
        }
        if (request.getPosition() != null && request.getPosition() <= 0) {
            throw new BusinessException(20001, "位置参数不合法");
        }
    }

    private List<RecHuagaoImpressionLog> buildImpressions(RecHuagaoRequestLog requestLog,
                                                          List<SysHuagao> records,
                                                          LocalDateTime createdAt) {
        if (records == null || records.isEmpty()) {
            return java.util.Collections.emptyList();
        }

        Map<Long, RecHuagaoImpressionLog> uniqueImpressions = new LinkedHashMap<>();
        long safePageNo = requestLog.getPageNo() == null || requestLog.getPageNo() < 1 ? 1 : requestLog.getPageNo();
        long safePageSize = requestLog.getPageSize() == null || requestLog.getPageSize() < 1 ? records.size() : requestLog.getPageSize();
        int basePosition = (int) ((safePageNo - 1) * safePageSize);

        for (int i = 0; i < records.size(); i++) {
            SysHuagao item = records.get(i);
            if (item == null || item.getId() == null || uniqueImpressions.containsKey(item.getId())) {
                continue;
            }
            RecHuagaoImpressionLog impression = new RecHuagaoImpressionLog();
            impression.setRequestId(requestLog.getRequestId());
            impression.setHuagaoId(item.getId());
            impression.setShangjiaId(parseLong(item.getShangjiaids()));
            impression.setPosition(basePosition + i + 1);
            impression.setPageNo(requestLog.getPageNo());
            impression.setPageSize(requestLog.getPageSize());
            impression.setScene(requestLog.getScene());
            impression.setKeyword(requestLog.getKeyword());
            impression.setNormalizedKeyword(requestLog.getNormalizedKeyword());
            impression.setFenlei(requestLog.getFenlei());
            impression.setTagId(requestLog.getTagId());
            impression.setSearchScore(item.getSearchScore());
            impression.setCreatedAt(createdAt);
            uniqueImpressions.put(item.getId(), impression);
        }
        return uniqueImpressions.values().stream().collect(Collectors.toList());
    }

    private void safeUpsertListAggregates(RecHuagaoRequestLog requestLog,
                                          List<RecHuagaoImpressionLog> impressions,
                                          LocalDate today) {
        int hasSearch = intValue(requestLog.getHasSearch());
        int hasFenleiFilter = intValue(requestLog.getHasFenleiFilter());
        int hasTagFilter = intValue(requestLog.getHasTagFilter());
        for (RecHuagaoImpressionLog impression : impressions) {
            try {
                RecHuagaoItemStatDaily itemStat = new RecHuagaoItemStatDaily();
                itemStat.setDt(today);
                itemStat.setHuagaoId(impression.getHuagaoId());
                itemStat.setShangjiaId(impression.getShangjiaId());
                itemStat.setImpressionCnt(1L);
                itemStat.setClickDetailCnt(0L);
                itemStat.setFavoriteCnt(0L);
                itemStat.setSearchImpressionCnt(hasSearch == 1 ? 1L : 0L);
                itemStat.setFilterFenleiImpressionCnt(hasFenleiFilter == 1 ? 1L : 0L);
                itemStat.setFilterTagImpressionCnt(hasTagFilter == 1 ? 1L : 0L);
                itemStat.setSearchClickDetailCnt(0L);
                itemStat.setSearchFavoriteCnt(0L);
                itemStatDailyMapper.upsert(itemStat);
            } catch (Exception ex) {
                log.warn("Failed to upsert huagao item daily stat, requestId={}, huagaoId={}",
                        requestLog.getRequestId(), impression.getHuagaoId(), ex);
            }
        }

        try {
            RecHuagaoQueryStatDaily queryStat = new RecHuagaoQueryStatDaily();
            queryStat.setDt(today);
            queryStat.setQueryKey(requestLog.getQueryKey());
            queryStat.setScene(requestLog.getScene());
            queryStat.setKeyword(requestLog.getKeyword());
            queryStat.setNormalizedKeyword(requestLog.getNormalizedKeyword());
            queryStat.setFenlei(requestLog.getFenlei());
            queryStat.setTagId(requestLog.getTagId());
            queryStat.setHasSearch(hasSearch);
            queryStat.setHasFenleiFilter(hasFenleiFilter);
            queryStat.setHasTagFilter(hasTagFilter);
            queryStat.setRequestCnt(1L);
            queryStat.setImpressionCnt((long) impressions.size());
            queryStat.setClickDetailCnt(0L);
            queryStat.setFavoriteCnt(0L);
            queryStatDailyMapper.upsert(queryStat);
        } catch (Exception ex) {
            log.warn("Failed to upsert huagao query daily stat, requestId={}", requestLog.getRequestId(), ex);
        }
    }

    private void safeUpsertActionAggregates(RecHuagaoActionLog actionLog,
                                            RecHuagaoRequestLog requestLog,
                                            LocalDate today) {
        boolean isSearchRequest = requestLog != null && intValue(requestLog.getHasSearch()) == 1;
        try {
            RecHuagaoItemStatDaily itemStat = new RecHuagaoItemStatDaily();
            itemStat.setDt(today);
            itemStat.setHuagaoId(actionLog.getHuagaoId());
            itemStat.setShangjiaId(actionLog.getShangjiaId());
            itemStat.setImpressionCnt(0L);
            itemStat.setClickDetailCnt(isClickDetail(actionLog) ? 1L : 0L);
            itemStat.setFavoriteCnt(isFavorite(actionLog) ? 1L : 0L);
            itemStat.setSearchImpressionCnt(0L);
            itemStat.setFilterFenleiImpressionCnt(0L);
            itemStat.setFilterTagImpressionCnt(0L);
            itemStat.setSearchClickDetailCnt(isSearchRequest && isClickDetail(actionLog) ? 1L : 0L);
            itemStat.setSearchFavoriteCnt(isSearchRequest && isFavorite(actionLog) ? 1L : 0L);
            itemStatDailyMapper.upsert(itemStat);
        } catch (Exception ex) {
            log.warn("Failed to upsert huagao item daily action stat, eventId={}", actionLog.getEventId(), ex);
        }

        if (requestLog == null) {
            return;
        }

        try {
            RecHuagaoQueryStatDaily queryStat = new RecHuagaoQueryStatDaily();
            queryStat.setDt(today);
            queryStat.setQueryKey(requestLog.getQueryKey());
            queryStat.setScene(requestLog.getScene());
            queryStat.setKeyword(requestLog.getKeyword());
            queryStat.setNormalizedKeyword(requestLog.getNormalizedKeyword());
            queryStat.setFenlei(requestLog.getFenlei());
            queryStat.setTagId(requestLog.getTagId());
            queryStat.setHasSearch(intValue(requestLog.getHasSearch()));
            queryStat.setHasFenleiFilter(intValue(requestLog.getHasFenleiFilter()));
            queryStat.setHasTagFilter(intValue(requestLog.getHasTagFilter()));
            queryStat.setRequestCnt(0L);
            queryStat.setImpressionCnt(0L);
            queryStat.setClickDetailCnt(isClickDetail(actionLog) ? 1L : 0L);
            queryStat.setFavoriteCnt(isFavorite(actionLog) ? 1L : 0L);
            queryStatDailyMapper.upsert(queryStat);
        } catch (Exception ex) {
            log.warn("Failed to upsert huagao query daily action stat, eventId={}", actionLog.getEventId(), ex);
        }
    }

    private boolean isShowcaseScene(String scene) {
        return SCENE_SHOWCASE.equalsIgnoreCase(sanitizeScene(scene));
    }

    private boolean isClickDetail(RecHuagaoActionLog actionLog) {
        return Objects.equals(EVENT_CLICK_DETAIL, actionLog.getEventType());
    }

    private boolean isFavorite(RecHuagaoActionLog actionLog) {
        return Objects.equals(EVENT_FAVORITE, actionLog.getEventType());
    }

    private String sanitizeKeyword(String keyword) {
        String sanitizedKeyword = TagNormalizationUtil.sanitizeDisplayName(keyword);
        return StringUtils.hasText(sanitizedKeyword) ? sanitizedKeyword : null;
    }

    private String sanitizeScene(String scene) {
        if (!StringUtils.hasText(scene)) {
            return null;
        }
        String sanitized = scene.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }

    private String sanitizeValue(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }

    private String buildQueryKey(String scene, String normalizedKeyword, String fenlei, Long tagId) {
        String raw = String.join("|",
                sanitizeScene(scene) == null ? "" : sanitizeScene(scene),
                normalizedKeyword == null ? "" : normalizedKeyword,
                fenlei == null ? "" : fenlei,
                tagId == null ? "" : String.valueOf(tagId));
        return DigestUtils.md5DigestAsHex(raw.getBytes(StandardCharsets.UTF_8));
    }

    private Long parseLong(String rawValue) {
        if (!StringUtils.hasText(rawValue)) {
            return null;
        }
        try {
            return Long.parseLong(rawValue.trim());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private int intValue(Integer value) {
        return value == null ? 0 : value;
    }

    private int intValue(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ignored) {
            return 0;
        }
    }

    private long countMismatchRows(List<Map<String, Object>> rows) {
        return rows.stream()
                .filter(row -> intValue(row.get("is_match")) != 1)
                .count();
    }

    private int normalizePreviewLimit(Integer limit) {
        if (limit == null || limit < 1) {
            return 100;
        }
        return Math.min(limit, 500);
    }
}
