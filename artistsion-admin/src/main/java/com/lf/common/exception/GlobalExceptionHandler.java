package com.lf.common.exception;

import com.lf.common.Result;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException ex) {
        return Result.fail(ex.getCode(), ex.getMessage());
    }

    @ExceptionHandler(DuplicateKeyException.class)
    public Result<?> handleDuplicateKeyException(DuplicateKeyException ex) {
        return Result.fail(20006, "\u7528\u6237\u540d\u5df2\u5b58\u5728");
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public Result<?> handleDataIntegrityViolationException(DataIntegrityViolationException ex) {
        return Result.fail(20006, "\u6570\u636e\u7ea6\u675f\u51b2\u7a81\uff0c\u8bf7\u68c0\u67e5\u7528\u6237\u540d\u662f\u5426\u5df2\u5b58\u5728");
    }
}
