package com.lf.common.constants;

import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public final class TagConstants {

    public static final String TYPE_SYSTEM = "system";
    public static final String TYPE_FREE = "free";

    public static final List<String> SYSTEM_TAG_GROUPS = Collections.unmodifiableList(Arrays.asList(
            "风格",
            "人物",
            "构图",
            "情绪",
            "发型发色",
            "服装",
            "场景",
            "配色",
            "用途",
            "生产属性"
    ));

    public static final Set<Integer> ENABLE_STATUS = Collections.unmodifiableSet(new LinkedHashSet<>(Arrays.asList(0, 1)));

    private TagConstants() {
    }
}
