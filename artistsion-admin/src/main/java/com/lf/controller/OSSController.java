package com.lf.controller;

import com.lf.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/oss/file")
public class OSSController {

    @Value("${images.path}")
    private String basePath;

    @Value("${file.public-base-url:http://localhost:9999}")
    private String publicBaseUrl;

    private String normalizeBasePath(String value) {
        if (value == null) {
            return "";
        }
        String p = value.trim();
        if (p.isEmpty()) {
            return "";
        }
        if (!p.endsWith("/") && !p.endsWith("\\")) {
            p = p + File.separator;
        }
        return p;
    }

    private List<String> candidateBasePaths() {
        Set<String> candidates = new LinkedHashSet<>();
        String configuredPath = normalizeBasePath(basePath);
        if (StringUtils.hasLength(configuredPath)) {
            candidates.add(configuredPath);
        }
        String fallbackPath = normalizeBasePath(System.getProperty("user.dir") + File.separator + "uploads" + File.separator + "images");
        candidates.add(fallbackPath);
        return new ArrayList<>(candidates);
    }

    private File resolveWritableDirectory() throws IOException {
        IOException lastException = null;
        for (String candidate : candidateBasePaths()) {
            try {
                Path path = Paths.get(candidate);
                Files.createDirectories(path);
                if (Files.isDirectory(path) && Files.isWritable(path)) {
                    return path.toFile();
                }
            } catch (Exception ex) {
                lastException = ex instanceof IOException ? (IOException) ex : new IOException(ex);
            }
        }
        throw lastException != null ? lastException : new IOException("No writable storage directory available");
    }

    private File resolveExistingFile(String name) throws IOException {
        for (String candidate : candidateBasePaths()) {
            File baseDir = new File(candidate).getCanonicalFile();
            File target = new File(baseDir, name).getCanonicalFile();
            if (!target.getPath().startsWith(baseDir.getPath())) {
                continue;
            }
            if (target.exists() && target.isFile()) {
                return target;
            }
        }
        return null;
    }

    private String normalizeModule(String module) {
        if (!StringUtils.hasText(module)) {
            return "common";
        }
        String sanitized = module.trim().toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9_-]", "");
        return StringUtils.hasLength(sanitized) ? sanitized : "common";
    }

    private static String extOf(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf('.')).toLowerCase(Locale.ROOT);
    }

    private static String contentTypeOf(String ext) {
        switch (ext) {
            case ".jpg":
            case ".jpeg":
                return "image/jpeg";
            case ".png":
                return "image/png";
            case ".gif":
                return "image/gif";
            case ".webp":
                return "image/webp";
            case ".bmp":
                return "image/bmp";
            case ".svg":
                return "image/svg+xml";
            case ".zip":
                return "application/zip";
            case ".rar":
                return "application/x-rar-compressed";
            case ".7z":
                return "application/x-7z-compressed";
            case ".pdf":
                return "application/pdf";
            case ".txt":
                return "text/plain; charset=UTF-8";
            default:
                return "application/octet-stream";
        }
    }

    private static boolean isDangerousName(String name) {
        if (name == null || name.isEmpty()) {
            return true;
        }
        return name.contains("..") || name.contains("/") || name.contains("\\");
    }

    @PostMapping("/upload")
    public Result<String> upload(MultipartFile file,
                                 @RequestParam(value = "module", required = false) String module) {
        if (file == null || file.isEmpty()) {
            return Result.fail(50000, "文件为空");
        }
        String originalFilename = file.getOriginalFilename();
        String suffix = extOf(originalFilename);
        if (!StringUtils.hasLength(suffix)) {
            suffix = ".bin";
        }
        String fileName = normalizeModule(module) + "_" + UUID.randomUUID().toString().replace("-", "") + suffix;
        final File dir;
        try {
            dir = resolveWritableDirectory();
        } catch (IOException e) {
            return Result.fail(50000, "无法创建存储目录");
        }
        try {
            file.transferTo(new File(dir, fileName));
        } catch (IOException e) {
            e.printStackTrace();
            return Result.fail(50000, "保存失败");
        }
        return Result.success(fileName, "上传成功");
    }

    @GetMapping("/download")
    public void download(@RequestParam("name") String name,
                         @RequestParam(value = "attachment", required = false, defaultValue = "false") boolean attachment,
                         @RequestParam(value = "originalName", required = false) String originalName,
                         HttpServletResponse response) {
        if (isDangerousName(name)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        File target;
        try {
            target = resolveExistingFile(name);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        if (target == null || !target.exists() || !target.isFile()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String ext = extOf(name);
        String mime = contentTypeOf(ext);
        response.setContentType(mime);
        boolean forceAttachment = attachment;
        if (!forceAttachment && !(mime.startsWith("image/") || mime.startsWith("text/"))) {
            forceAttachment = true;
        }
        String downloadName = StringUtils.hasLength(originalName) ? originalName : name;
        try {
            String asciiFallback = downloadName.replaceAll("[^\\x20-\\x7E]", "_");
            if (!StringUtils.hasLength(asciiFallback)) {
                asciiFallback = "download" + ext;
            }
            String encoded = URLEncoder.encode(downloadName, StandardCharsets.UTF_8.name()).replace("+", "%20");
            if (forceAttachment) {
                response.setHeader("Content-Disposition",
                        "attachment; filename=\"" + asciiFallback + "\"; filename*=UTF-8''" + encoded);
            } else {
                response.setHeader("Content-Disposition", "inline; filename=\"" + asciiFallback + "\"");
            }
            response.setContentLengthLong(target.length());
            try (InputStream in = new FileInputStream(target);
                 ServletOutputStream out = response.getOutputStream()) {
                byte[] buf = new byte[8192];
                int len;
                while ((len = in.read(buf)) != -1) {
                    out.write(buf, 0, len);
                }
                out.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping(value = "/uploadImg")
    @ResponseBody
    public Map<String, Object> uploadImg(@RequestParam(value = "myFileName") MultipartFile file, HttpServletRequest request) {
        Map<String, Object> map = new HashMap<>();
        try {
            Result<String> upload = this.upload(file, "editor");
            if (upload.getCode() == null || upload.getCode() != 20000) {
                map.put("errno", 1);
                map.put("message", upload.getMessage());
                return map;
            }
            String stored = upload.getData();
            String base = publicBaseUrl.endsWith("/") ? publicBaseUrl.substring(0, publicBaseUrl.length() - 1) : publicBaseUrl;
            String url = base + request.getContextPath() + "/oss/file/download?name=" + URLEncoder.encode(stored, StandardCharsets.UTF_8.name());
            Map<String, String> data = new HashMap<>();
            data.put("url", url);
            data.put("alt", null);
            data.put("href", null);
            map.put("errno", 0);
            map.put("data", data);
            return map;
        } catch (Exception e) {
            e.printStackTrace();
            map.put("errno", 1);
            return map;
        }
    }
}
