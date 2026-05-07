package com.lf.service;

import com.lf.common.request.RecActionTrackRequest;

import java.util.List;
import java.util.Map;

public interface RecTrackService {

    String trackList(String domain,
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
                     boolean fallback);

    void trackAction(RecActionTrackRequest request,
                     Long userId,
                     String visitorId,
                     String sessionId);
}
