package com.lf.controller;

import com.lf.common.Result;
import com.lf.common.request.RecHuagaoActionTrackRequest;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.User;
import com.lf.service.RecHuagaoTrackService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/recHuagaoTrack")
public class RecHuagaoTrackController {

    @Resource
    private RecHuagaoTrackService recHuagaoTrackService;

    @Resource
    private JwtUtil jwtUtil;

    @PostMapping("/action")
    public Result<?> trackAction(HttpServletRequest request,
                                 @RequestBody RecHuagaoActionTrackRequest trackRequest) {
        User loginUser = resolveOptionalLoginUser(request);
        Long userId = loginUser == null || loginUser.getId() == null ? null : Long.valueOf(loginUser.getId());
        recHuagaoTrackService.trackAction(
                trackRequest,
                userId,
                sanitizeHeader(request.getHeader("X-Visitor-Id")),
                sanitizeHeader(request.getHeader("X-Session-Id"))
        );
        return Result.success("记录成功");
    }

    @GetMapping("/debug/request/{requestId}")
    public Result<Map<String, Object>> getRequestDebug(@PathVariable("requestId") String requestId) {
        return Result.success(recHuagaoTrackService.getRequestDebug(requestId));
    }

    @GetMapping("/debug/rebuildCheck")
    public Result<Map<String, Object>> getDailyRebuildCheck(
            @RequestParam(value = "dt", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dt) {
        return Result.success(recHuagaoTrackService.getDailyRebuildCheck(dt));
    }

    @GetMapping("/debug/samplePreview")
    public Result<Map<String, Object>> getTrainingSamplePreview(
            @RequestParam(value = "dateFrom", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(value = "dateTo", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo,
            @RequestParam(value = "limit", required = false) Integer limit) {
        return Result.success(recHuagaoTrackService.getTrainingSamplePreview(dateFrom, dateTo, limit));
    }

    @GetMapping("/debug/trainingReadiness")
    public Result<Map<String, Object>> getTrainingReadiness(
            @RequestParam(value = "dateFrom", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(value = "dateTo", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo) {
        return Result.success(recHuagaoTrackService.getTrainingReadiness(dateFrom, dateTo));
    }

    @GetMapping("/debug/sampleExport")
    public void exportTrainingSamples(
            @RequestParam(value = "dateFrom", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(value = "dateTo", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo,
            @RequestParam(value = "limit", required = false) Integer limit,
            HttpServletResponse response) throws IOException {
        List<Map<String, Object>> rows = recHuagaoTrackService.getTrainingSampleExportRows(dateFrom, dateTo, limit);
        List<String> headers = trainingSampleExportHeaders();
        LocalDate safeDateTo = dateTo == null ? LocalDate.now() : dateTo;
        LocalDate safeDateFrom = dateFrom == null ? safeDateTo : dateFrom;
        String filename = "huagao_training_samples_" + safeDateFrom + "_" + safeDateTo + ".csv";

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter writer = response.getWriter();
        writer.write('\ufeff');
        writer.println(headers.stream().map(this::csvCell).collect(Collectors.joining(",")));
        for (Map<String, Object> row : rows) {
            writer.println(headers.stream()
                    .map(header -> csvCell(row.get(header)))
                    .collect(Collectors.joining(",")));
        }
        writer.flush();
    }

    private User resolveOptionalLoginUser(HttpServletRequest request) {
        String token = request.getHeader("X-Token");
        if (!StringUtils.hasText(token)) {
            return null;
        }
        try {
            return jwtUtil.parseToken(token, User.class);
        } catch (Exception ignored) {
            return null;
        }
    }

    private String sanitizeHeader(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String sanitized = value.trim();
        return StringUtils.hasText(sanitized) ? sanitized : null;
    }

    private List<String> trainingSampleExportHeaders() {
        return Arrays.asList(
                "request_id",
                "scene",
                "user_id",
                "visitor_id",
                "session_id",
                "keyword",
                "normalized_keyword",
                "fenlei",
                "tag_id",
                "page_no",
                "page_size",
                "sort_mode",
                "has_search",
                "has_fenlei_filter",
                "has_tag_filter",
                "huagao_id",
                "shangjia_id",
                "position",
                "search_score",
                "impression_at",
                "click_detail_cnt",
                "detail_view_cnt",
                "detail_dwell_cnt",
                "detail_dwell_total_ms",
                "favorite_cnt",
                "add_cart_cnt",
                "create_order_cnt",
                "first_click_detail_at",
                "first_detail_view_at",
                "first_favorite_at",
                "first_add_to_cart_at",
                "first_create_order_at",
                "relevance",
                "label_source"
        );
    }

    private String csvCell(Object value) {
        if (value == null) {
            return "";
        }
        String raw = String.valueOf(value);
        if (raw.contains("\"") || raw.contains(",") || raw.contains("\n") || raw.contains("\r")) {
            return "\"" + raw.replace("\"", "\"\"") + "\"";
        }
        return raw;
    }
}
