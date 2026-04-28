package com.lf.service;

import java.util.Map;

public interface RecHuagaoRecommendationService {

    Map<String, Object> getRecommendations(Integer userId,
                                            String visitorId,
                                            String sessionId,
                                            String scene,
                                            Long pageNo,
                                            Long pageSize);
}
