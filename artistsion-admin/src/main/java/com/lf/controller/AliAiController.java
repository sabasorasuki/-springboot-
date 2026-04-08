package com.lf.controller;

import com.alibaba.dashscope.aigc.generation.Generation;
import com.alibaba.dashscope.aigc.generation.GenerationParam;
import com.alibaba.dashscope.aigc.generation.GenerationResult;
import com.alibaba.dashscope.common.Message;
import com.alibaba.dashscope.common.Role;
import com.alibaba.dashscope.exception.InputRequiredException;
import com.alibaba.dashscope.exception.NoApiKeyException;
import com.lf.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.HttpHeaders;

import javax.annotation.Resource;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

@RestController
@RequestMapping("/ai/")
public class AliAiController {

    @Value("${ai.api.key}")
    private String apiKey;

    @Resource
    private Generation generation;

    @PostMapping(value = "aliTyqw")
    public Result<ResponseEntity<String>> send(@RequestBody String content) throws NoApiKeyException, InputRequiredException {
        try {
            // URL解码 content，确保编码后的内容变成正常的字符串
            String decodedContent = URLDecoder.decode(content, StandardCharsets.UTF_8.name());
            System.out.println(decodedContent);

            // 用户与模型的对话历史
            Message userMessage = Message.builder()
                    .role(Role.USER.getValue())
                    .content(decodedContent)
                    .build();

            GenerationParam param = GenerationParam.builder()
                    .model("qwen-turbo")
                    .messages(Arrays.asList(userMessage))
                    .resultFormat(GenerationParam.ResultFormat.MESSAGE)
                    .topP(0.8)
                    .apiKey(apiKey)
                    .enableSearch(true)
                    .build();

            GenerationResult generationResult = generation.call(param);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.TEXT_PLAIN);
            headers.set("Content-Type", "text/plain;charset=UTF-8");

            String output = generationResult.getOutput().getChoices().get(0).getMessage().getContent();
            System.out.println("Output content: " + output);

            return Result.success(output);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.fail("解码失败");
        }
    }
}