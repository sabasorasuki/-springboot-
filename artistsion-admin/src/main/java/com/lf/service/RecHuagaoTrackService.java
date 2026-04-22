package com.lf.service;

import com.lf.common.request.RecHuagaoActionTrackRequest;
import com.lf.entity.SysHuagao;

import java.util.List;

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
}
