package com.lf.common.utils;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public final class TagSensitiveWordUtil {

    private static final List<String> SENSITIVE_WORDS = Collections.unmodifiableList(Arrays.asList(
            "法轮功",
            "台独",
            "藏独",
            "港独",
            "约炮",
            "嫖娼",
            "赌博",
            "六合彩",
            "毒品",
            "冰毒",
            "海洛因",
            "成人视频",
            "色情网",
            "裸聊"
    ));

    private TagSensitiveWordUtil() {
    }

    public static boolean containsSensitiveWord(String normalizedValue) {
        if (normalizedValue == null || normalizedValue.isEmpty()) {
            return false;
        }
        for (String word : SENSITIVE_WORDS) {
            if (normalizedValue.contains(word)) {
                return true;
            }
        }
        return false;
    }
}
