
package com.lf.service.impl;

import com.alipay.api.AlipayApiException;
import com.lf.config.AlipayUtile;
import com.lf.entity.AlipayBean;
import com.lf.service.IPayService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;


@Service
public class PayModelImpl implements IPayService{
    @Resource
    private AlipayUtile alipayUtile;

    @Override
    public String aliPay(AlipayBean alipayBean) throws AlipayApiException {
        return alipayUtile.pay(alipayBean);
    }

}
