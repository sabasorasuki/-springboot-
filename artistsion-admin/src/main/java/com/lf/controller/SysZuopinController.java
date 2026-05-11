package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.common.utils.JwtUtil;
import com.lf.entity.SysZuopin;
import com.lf.entity.User;
import com.lf.service.SysZuopinService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
@RestController
@RequestMapping("/sysZuopin")
public class SysZuopinController {



    @Resource
    private SysZuopinService service;

    @Resource
    private JwtUtil jwtUtil;


    @GetMapping("/list")
    public Result<Map<String,Object>> getList(
            @RequestParam(value = "title",required = false) String title,
            @RequestParam(value = "keyword",required = false) String keyword,
            @RequestParam(value = "fenlei",required = false) String fenlei,
            @RequestParam(value = "userids",required = false) String userids,
            @RequestParam(value = "id",required = false) String id,
            @RequestParam(value = "pageNo") Long pageNo,
            @RequestParam(value = "pageSize") Long pageSize){
        LambdaQueryWrapper<SysZuopin> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasLength(title),SysZuopin::getTitle,title);
        if (StringUtils.hasText(keyword)) {
            String likeKeyword = "%" + keyword.trim() + "%";
            wrapper.and(w -> w.like(SysZuopin::getTitle, keyword.trim())
                    .or().like(SysZuopin::getContent, keyword.trim())
                    .or().like(SysZuopin::getFenlei, keyword.trim())
                    .or().apply("EXISTS (SELECT 1 FROM sys_zuopin_tag zt INNER JOIN sys_tag st ON st.id = zt.tag_id WHERE zt.zuopin_id = sys_zuopin.id AND st.deleted = 0 AND (st.name LIKE {0} OR st.normalized_name LIKE {0}))", likeKeyword));
        }
        wrapper.like(StringUtils.hasLength(fenlei),SysZuopin::getFenlei,fenlei);
        wrapper.eq(StringUtils.hasLength(userids),SysZuopin::getUserids,userids);
        wrapper.eq(StringUtils.hasLength(id),SysZuopin::getId,id);
        wrapper.orderByDesc(SysZuopin::getId);

        Page<SysZuopin> page = new Page<>(pageNo,pageSize);
        service.page(page, wrapper);
        service.fillTagInfo(page.getRecords());

        Map<String,Object> data = new HashMap<>();
        data.put("total",page.getTotal());
        data.put("rows",page.getRecords());

        return Result.success(data);

    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody SysZuopin shetuan){
        Date date = new Date();
        shetuan.setFbdate(date);
        service.saveWithTags(shetuan);
        return Result.success("添加成功");
    }


    @PutMapping("/update")
    public Result<?> update(@RequestBody SysZuopin shetuan){

        if("点赞".equals(shetuan.getDianzan())){
            SysZuopin zuopin = service.getById(shetuan.getId());
            shetuan.setDznum( zuopin.getDznum()+1);
            service.updateById(shetuan);
            return Result.success("修改成功");
        }

        service.updateWithTags(shetuan);
        return Result.success("修改成功");
    }



    @GetMapping("/getById/{id}")
    public Result<SysZuopin> getById(@PathVariable("id") Integer id){
        SysZuopin shetuan = service.getDetailById(id.longValue());
        return Result.success(shetuan);
    }

    @DeleteMapping("/deleteById/{id}")
    public Result<SysZuopin> deleteById(HttpServletRequest request, @PathVariable("id") Integer id){
        SysZuopin zuopin = service.getById(id);
        if (zuopin == null) {
            return Result.fail(20001, "投稿不存在");
        }

        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(request.getHeader("X-Token"), User.class);
        } catch (Exception e) {
            return Result.fail(20003, "令牌无效");
        }

        if (loginUser == null || loginUser.getId() == null) {
            return Result.fail(20003, "未登录");
        }
        if (!String.valueOf(loginUser.getId()).equals(zuopin.getUserids())) {
            return Result.fail(20001, "只能删除自己的投稿");
        }

        service.removeById(id);
        return Result.success("删除成功");
    }




}

