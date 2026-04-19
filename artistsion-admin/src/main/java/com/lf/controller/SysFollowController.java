package com.lf.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.entity.SysFollow;
import com.lf.entity.User;
import com.lf.service.SysFollowService;
import com.lf.service.UserService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/sysFollow")
public class SysFollowController {

    @Resource
    private SysFollowService followService;

    @Resource
    private UserService userService;

    /**
     * 关注某用户
     */
    @PostMapping("/follow")
    public Result<?> follow(@RequestBody SysFollow follow) {
        if (follow.getFollowerId() == null || follow.getFollowingId() == null) {
            return Result.fail(20001, "参数缺失");
        }
        if (follow.getFollowerId().equals(follow.getFollowingId())) {
            return Result.fail(20001, "不能关注自己");
        }
        // 检查是否已关注
        LambdaQueryWrapper<SysFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFollow::getFollowerId, follow.getFollowerId());
        wrapper.eq(SysFollow::getFollowingId, follow.getFollowingId());
        if (followService.count(wrapper) > 0) {
            return Result.fail(20001, "已关注");
        }
        follow.setCreatedAt(new Date());
        followService.save(follow);
        return Result.success("关注成功");
    }

    /**
     * 取消关注
     */
    @DeleteMapping("/unfollow")
    public Result<?> unfollow(@RequestParam Long followerId, @RequestParam Long followingId) {
        LambdaQueryWrapper<SysFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFollow::getFollowerId, followerId);
        wrapper.eq(SysFollow::getFollowingId, followingId);
        followService.remove(wrapper);
        return Result.success("已取消关注");
    }

    /**
     * 我关注的人列表
     */
    @GetMapping("/following")
    public Result<Map<String, Object>> following(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") Long pageNo,
            @RequestParam(defaultValue = "20") Long pageSize) {
        LambdaQueryWrapper<SysFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFollow::getFollowerId, userId);
        wrapper.orderByDesc(SysFollow::getCreatedAt);
        Page<SysFollow> page = new Page<>(pageNo, pageSize);
        followService.page(page, wrapper);

        List<Long> ids = page.getRecords().stream()
                .map(SysFollow::getFollowingId).collect(Collectors.toList());
        List<User> users = ids.isEmpty() ? Collections.emptyList() : userService.listByIds(ids);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", users);
        return Result.success(data);
    }

    /**
     * 我的粉丝列表
     */
    @GetMapping("/followers")
    public Result<Map<String, Object>> followers(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") Long pageNo,
            @RequestParam(defaultValue = "20") Long pageSize) {
        LambdaQueryWrapper<SysFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFollow::getFollowingId, userId);
        wrapper.orderByDesc(SysFollow::getCreatedAt);
        Page<SysFollow> page = new Page<>(pageNo, pageSize);
        followService.page(page, wrapper);

        List<Long> ids = page.getRecords().stream()
                .map(SysFollow::getFollowerId).collect(Collectors.toList());
        List<User> users = ids.isEmpty() ? Collections.emptyList() : userService.listByIds(ids);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", users);
        return Result.success(data);
    }

    /**
     * 检查是否已关注某人
     */
    @GetMapping("/check")
    public Result<Boolean> check(@RequestParam Long followerId, @RequestParam Long followingId) {
        LambdaQueryWrapper<SysFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFollow::getFollowerId, followerId);
        wrapper.eq(SysFollow::getFollowingId, followingId);
        return Result.success(followService.count(wrapper) > 0);
    }

    /**
     * 互关好友列表（双向关注）
     */
    @GetMapping("/friends")
    public Result<Map<String, Object>> friends(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") Long pageNo,
            @RequestParam(defaultValue = "20") Long pageSize) {
        // 我关注的人
        List<Long> followingIds = followService.list(
                new LambdaQueryWrapper<SysFollow>().eq(SysFollow::getFollowerId, userId)
        ).stream().map(SysFollow::getFollowingId).collect(Collectors.toList());

        if (followingIds.isEmpty()) {
            Map<String, Object> data = new HashMap<>();
            data.put("total", 0);
            data.put("rows", Collections.emptyList());
            return Result.success(data);
        }

        // 在我关注的人中，找出也关注了我的（互关）
        List<Long> friendIds = followService.list(
                new LambdaQueryWrapper<SysFollow>()
                        .eq(SysFollow::getFollowingId, userId)
                        .in(SysFollow::getFollowerId, followingIds)
        ).stream().map(SysFollow::getFollowerId).collect(Collectors.toList());

        int total = friendIds.size();
        // 手动分页
        int start = (int) ((pageNo - 1) * pageSize);
        int end = Math.min(start + pageSize.intValue(), total);
        List<Long> pageIds = start >= total ? Collections.emptyList() : friendIds.subList(start, end);
        List<User> users = pageIds.isEmpty() ? Collections.emptyList() : userService.listByIds(pageIds);

        Map<String, Object> data = new HashMap<>();
        data.put("total", total);
        data.put("rows", users);
        return Result.success(data);
    }

    /**
     * 关注/粉丝计数
     */
    @GetMapping("/count")
    public Result<Map<String, Object>> count(@RequestParam Long userId) {
        long followingCount = followService.count(
                new LambdaQueryWrapper<SysFollow>().eq(SysFollow::getFollowerId, userId));
        long followerCount = followService.count(
                new LambdaQueryWrapper<SysFollow>().eq(SysFollow::getFollowingId, userId));
        Map<String, Object> data = new HashMap<>();
        data.put("following", followingCount);
        data.put("followers", followerCount);
        return Result.success(data);
    }
}
