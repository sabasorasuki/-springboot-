package com.lf.service;

import com.lf.common.request.RecHuagaoActionTrackRequest;
import com.lf.entity.SysHuagao;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface RecHuagaoTrackService {

    String trackListIfNeeded(String scene,
                             String keyword,
                             String fenlei,
                             Long tagId,
                             Long pageNo,
                             Long pageSize,
                             Long total,
                             List<SysHuagao> records,
                             Long userId,
                             String visitorId,
                             String sessionId);

    void trackAction(RecHuagaoActionTrackRequest request,
                     Long userId,
                     String visitorId,
                     String sessionId);

    Map<String, Object> getRequestDebug(String requestId);

    Map<String, Object> getDailyRebuildCheck(LocalDate dt);

    Map<String, Object> getTrainingSamplePreview(LocalDate dateFrom,
                                                 LocalDate dateTo,
                                                 Integer limit);
}
