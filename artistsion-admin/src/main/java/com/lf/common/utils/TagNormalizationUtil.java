package com.lf.common.utils;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

public final class TagNormalizationUtil {

    private static final Pattern INVISIBLE_SPACE_PATTERN = Pattern.compile("[\\u200B\\u200C\\u200D\\u2060\\uFEFF\\u00A0\\u3000\\r\\n\\t]");

    private TagNormalizationUtil() {
    }

    public static String sanitizeDisplayName(String rawValue) {
        if (rawValue == null) {
            return "";
        }
        String value = rawValue.trim();
        value = INVISIBLE_SPACE_PATTERN.matcher(value).replaceAll("");
        return Normalizer.normalize(value, Normalizer.Form.NFKC);
    }

    public static String normalize(String rawValue) {
        if (rawValue == null) {
            return "";
        }
        String value = rawValue.trim();
        value = INVISIBLE_SPACE_PATTERN.matcher(value).replaceAll("");
        value = value.toLowerCase(Locale.ROOT);
        return Normalizer.normalize(value, Normalizer.Form.NFKC);
    }
}
