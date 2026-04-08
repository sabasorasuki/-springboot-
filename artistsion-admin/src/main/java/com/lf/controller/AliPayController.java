package com.lf.controller;

import com.alipay.api.AlipayApiException;
import com.lf.common.Result;
import com.lf.entity.*;
import com.lf.service.IPayService;
import com.lf.service.UserService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@RestController
public class AliPayController {
    @Resource
    private IPayService model;



    @Resource
    private UserService userService;


    @PostMapping(value = "/order/alipay")
    public Result<?> alipay(@RequestBody Alipays alipays) throws AlipayApiException {
        AlipayBean alipayBean = new AlipayBean();



            // 生成一个4位随机数，用于拼接订单号
        String randomStr = String.format("%04d", new Random().nextInt(10000));
            // 获取当前时间戳，用于拼接订单号
        long timestamp = System.currentTimeMillis();
            // 拼接订单号
        String orderNo = timestamp + randomStr;
        alipayBean.setOut_trade_no(orderNo);
        alipayBean.setSubject(alipays.getOrder_detail());
        alipayBean.setTotal_amount(alipays.getOrder_price());
        alipayBean.setBody(alipays.getGoods_info());
        String s = model.aliPay(alipayBean);
        System.out.println(s);
        Map<String,Object> data = new HashMap<>();
        data.put("rows",s);
        return Result.success(data);
    }
}
