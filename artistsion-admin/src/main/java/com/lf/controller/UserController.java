package com.lf.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lf.common.Result;
import com.lf.dao.RoleMapper;
import com.lf.dao.SysHuagaoMapper;
import com.lf.entity.Role;
import com.lf.entity.SysHuagao;
import com.lf.entity.User;
import com.lf.entity.UserRole;
import com.lf.service.SysHuagaoService;
import com.lf.service.UserRoleService;
import com.lf.service.UserService;
import com.lf.vo.ArtistVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.util.*;
import java.util.stream.Collectors;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author
 * @since 2023-07-10
 */
@Api(tags = {"用户接口列表"})
@RestController
@RequestMapping("/user")
public class UserController {

    @Resource
    private UserService userService;

    @Resource
    private UserRoleService userRoleService;

    @Resource
    private SysHuagaoService sysHuagaoService;

    @Resource
    private SysHuagaoMapper sysHuagaoMapper;

    @Resource
    private PasswordEncoder passwordEncoder;

    @Resource
    private RoleMapper roleMapper;

    private static final int ARTIST_RECENT_COVER_LIMIT = 9;

    private int artistRoleId;

    @PostConstruct
    public void init() {
        LambdaQueryWrapper<Role> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Role::getRoleName, "画师角色");
        Role role = roleMapper.selectOne(wrapper);
        this.artistRoleId = role != null ? role.getRoleId() : 7; // fallback
    }

    @ApiOperation("公开画师列表（安全投影，匿名可访问）")
    @GetMapping("/artists")
    public Result<Map<String, Object>> getArtistList(
            @RequestParam(value = "pageNo", defaultValue = "1") Long pageNo,
            @RequestParam(value = "pageSize", defaultValue = "12") Long pageSize,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "fenlei", required = false) String fenlei) {
        long safePageNo = Math.max(1L, pageNo == null ? 1L : pageNo);
        long safePageSize = Math.max(1L, Math.min(pageSize == null ? 12L : pageSize, 24L));

        // 1. 查出所有拥有画师角色的 userId
        LambdaQueryWrapper<UserRole> urWrapper = new LambdaQueryWrapper<>();
        urWrapper.eq(UserRole::getRoleId, artistRoleId);
        List<Integer> artistUserIds = userRoleService.list(urWrapper)
                .stream()
                .map(UserRole::getUserId)
                .collect(Collectors.toList());

        if (artistUserIds.isEmpty()) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("total", 0);
            empty.put("rows", Collections.emptyList());
            return Result.success(empty);
        }

        // 2. 分页查用户（只查启用的、未删除的）
        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.in(User::getId, artistUserIds);
        userWrapper.eq(User::getStatus, 1);
        userWrapper.eq(User::getDeleted, 0);
        if (org.springframework.util.StringUtils.hasText(keyword)) {
            String safeKeyword = keyword.trim();
            userWrapper.and(w -> w.like(User::getUsername, safeKeyword)
                    .or().like(User::getName, safeKeyword)
                    .or().like(User::getBio, safeKeyword)
                    .or().like(User::getStyleTags, safeKeyword));
        }
        if (org.springframework.util.StringUtils.hasText(fenlei)) {
            userWrapper.like(User::getStyleTags, fenlei.trim());
        }
        userWrapper.orderByDesc(User::getId);
        Page<User> page = new Page<>(safePageNo, safePageSize);
        userService.page(page, userWrapper);

        // 3. 批量查这些画师的作品统计和最近封面。封面只取列表展示需要的9张，避免翻页时拼接/传输过多图片。
        List<Integer> pageUserIds = page.getRecords().stream()
                .map(User::getId).collect(Collectors.toList());

        Map<Integer, Long> workCountMap = new HashMap<>();
        Map<Integer, List<String>> recentCoverMap = new HashMap<>();
        if (!pageUserIds.isEmpty()) {
            List<Map<String, Object>> statRows = sysHuagaoMapper.selectArtistWorkStats(pageUserIds, ARTIST_RECENT_COVER_LIMIT);
            for (Map<String, Object> row : statRows) {
                Integer artistId = toInteger(getMapValue(row, "artistId"));
                if (artistId == null) {
                    continue;
                }
                workCountMap.put(artistId, toLong(getMapValue(row, "workCount")));
                recentCoverMap.put(artistId, splitCovers(getMapValue(row, "recentCovers")));
            }
        }

        // 4. 组装 VO
        List<ArtistVO> voList = new ArrayList<>();
        for (User u : page.getRecords()) {
            ArtistVO vo = new ArtistVO();
            vo.setId(u.getId());
            vo.setUsername(u.getUsername());
            vo.setName(u.getName());
            vo.setAvatar(u.getAvatar());
            vo.setStatus(u.getStatus());
            vo.setBio(u.getBio());
            vo.setStyleTags(u.getStyleTags());

            vo.setWorkCount(workCountMap.getOrDefault(u.getId(), 0L));
            vo.setRecentCovers(recentCoverMap.getOrDefault(u.getId(), Collections.emptyList()));
            voList.add(vo);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", voList);
        return Result.success(data);
    }

    @ApiOperation("单个画师详情（安全投影）")
    @GetMapping("/artist/{id}")
    public Result<ArtistVO> getArtistById(@PathVariable Integer id) {
        User u = userService.getById(id);
        if (u == null || u.getStatus() != 1) {
            return Result.fail(20001, "画师不存在");
        }
        // 校验是否拥有画师角色
        LambdaQueryWrapper<UserRole> urWrapper = new LambdaQueryWrapper<>();
        urWrapper.eq(UserRole::getUserId, id).eq(UserRole::getRoleId, artistRoleId);
        if (userRoleService.count(urWrapper) == 0) {
            return Result.fail(20001, "画师不存在");
        }
        // 查画稿统计
        LambdaQueryWrapper<SysHuagao> hgWrapper = new LambdaQueryWrapper<>();
        hgWrapper.eq(SysHuagao::getShangjiaids, String.valueOf(id));
        hgWrapper.eq(SysHuagao::getType, "上架");
        hgWrapper.eq(SysHuagao::getStatus, "审核成功");
        hgWrapper.orderByDesc(SysHuagao::getId);
        List<SysHuagao> works = sysHuagaoService.list(hgWrapper);

        ArtistVO vo = new ArtistVO();
        vo.setId(u.getId());
        vo.setUsername(u.getUsername());
        vo.setName(u.getName());
        vo.setAvatar(u.getAvatar());
        vo.setStatus(u.getStatus());
        vo.setBio(u.getBio());
        vo.setStyleTags(u.getStyleTags());
        vo.setWorkCount((long) works.size());
        vo.setRecentCovers(works.stream()
                .limit(ARTIST_RECENT_COVER_LIMIT)
                .map(SysHuagao::getPhoto)
                .collect(Collectors.toList()));
        return Result.success(vo);
    }

    @ApiOperation("公开用户主页资料（安全投影）")
    @GetMapping("/public/{id}")
    public Result<ArtistVO> getPublicUserById(@PathVariable Integer id) {
        User u = userService.getById(id);
        if (u == null || u.getStatus() != 1) {
            return Result.fail(20001, "用户不存在");
        }

        LambdaQueryWrapper<SysHuagao> hgWrapper = new LambdaQueryWrapper<>();
        hgWrapper.eq(SysHuagao::getShangjiaids, String.valueOf(id));
        hgWrapper.eq(SysHuagao::getType, "上架");
        hgWrapper.eq(SysHuagao::getStatus, "审核成功");
        hgWrapper.orderByDesc(SysHuagao::getId);
        List<SysHuagao> works = sysHuagaoService.list(hgWrapper);

        ArtistVO vo = new ArtistVO();
        vo.setId(u.getId());
        vo.setUsername(u.getUsername());
        vo.setName(u.getName());
        vo.setAvatar(u.getAvatar());
        vo.setStatus(u.getStatus());
        vo.setBio(u.getBio());
        vo.setStyleTags(u.getStyleTags());
        vo.setWorkCount((long) works.size());
        vo.setRecentCovers(works.stream()
                .limit(ARTIST_RECENT_COVER_LIMIT)
                .map(SysHuagao::getPhoto)
                .collect(Collectors.toList()));
        return Result.success(vo);
    }

    private Object getMapValue(Map<String, Object> row, String key) {
        if (row == null) {
            return null;
        }
        if (row.containsKey(key)) {
            return row.get(key);
        }
        for (Map.Entry<String, Object> entry : row.entrySet()) {
            if (entry.getKey() != null && entry.getKey().equalsIgnoreCase(key)) {
                return entry.getValue();
            }
        }
        return null;
    }

    private Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Long toLong(Object value) {
        if (value == null) {
            return 0L;
        }
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0L;
        }
    }

    private List<String> splitCovers(Object value) {
        if (value == null) {
            return Collections.emptyList();
        }
        String raw = String.valueOf(value);
        if (!org.springframework.util.StringUtils.hasText(raw)) {
            return Collections.emptyList();
        }
        return Arrays.stream(raw.split("\\|\\|\\|"))
                .filter(org.springframework.util.StringUtils::hasText)
                .limit(ARTIST_RECENT_COVER_LIMIT)
                .collect(Collectors.toList());
    }

    @GetMapping("/all")
    public Result<List<User>> getAllUser() {
        List<User> list = userService.list();
        return Result.success(list, "查询成功");
    }

    @ApiOperation("用户登录")
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody User user) {
        Map<String, Object> data = userService.login(user);
        return Result.success(data);
    }

    @GetMapping("/info")
    public Result<Map<String, Object>> getUserInfo(@RequestParam("token") String token) {
        Map<String, Object> data = userService.getUserInfo(token);
        if (data != null) {
            return Result.success(data);
        }
        return Result.fail(20003, "用户登录信息无效,请重新登录");
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setStatus(1);
        userService.addUser(user);
        userRoleService.save(new UserRole(null, user.getId(), user.getRole()));
        return Result.success("用户注册成功");
    }

    @PostMapping("/logout")
    public Result<?> logout(@RequestHeader("X-token") String token) {
        userService.logout(token);
        return Result.success();
    }

    @GetMapping("/list")
    public Result<?> getUserListPage(@RequestParam(value = "username", required = false) String username,
                                     @RequestParam(value = "phone", required = false) String phone,
                                     @RequestParam("pageNo") Long pageNo,
                                     @RequestParam("pageSize") Long pageSize) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(User::getId);
        if (username != "") {
            wrapper.eq(username != null, User::getUsername, username);
        }
        if (phone != "") {
            wrapper.eq(phone != null, User::getPhone, phone);
        }
        Page<User> page = new Page<>(pageNo, pageSize);
        userService.page(page, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", page.getTotal());
        data.put("rows", page.getRecords());

        return Result.success(data);
    }

    @PostMapping("/addUser")
    public Result<?> addUser(@RequestBody User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userService.addUser(user);
        return Result.success("新增用户成功");
    }

    @PutMapping("/updateMyUser")
    public Result<?> updateMyUser(@RequestBody User user) {
        if (user.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        userService.updateMyUser(user);
        return Result.success("用户信息修改完毕!");
    }

    @PutMapping("/updateUser")
    public Result<?> updateUser(@RequestBody User user) {
        user.setPassword(null);
        userService.updateUser(user);
        return Result.success("修改用户成功");
    }

    @GetMapping("/getUserById/{id}")
    public Result<User> getUserById(@PathVariable("id") Integer id) {
        User user = userService.getUserById(id);
        return Result.success(user);
    }

    @DeleteMapping("/deleteUserById/{id}")
    public Result<User> deleteUserById(@PathVariable("id") Integer id) {
        userService.deleteUserById(id);
        return Result.success("删除用户成功");
    }

}
