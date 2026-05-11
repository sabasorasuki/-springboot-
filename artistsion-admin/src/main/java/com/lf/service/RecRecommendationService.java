package com.lf.service;

import java.util.Map;

public interface RecRecommendationService {

    Map<String, Object> getRecommendations(String domain,
                                           Integer userId,
                                           String visitorId,
                                           String sessionId,
                                           String scene,
                                           Long pageNo,
                                           Long pageSize);

    Map<String, Object> getHealth();
}
