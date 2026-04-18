package com.lf.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lf.common.Result;
import com.lf.common.exception.BusinessException;
import com.lf.common.utils.JwtUtil;
import com.lf.dao.RoleMapper;
import com.lf.dao.UserMapper;
import com.lf.dao.UserRoleMapper;
import com.lf.entity.Menu;
import com.lf.entity.Role;
import com.lf.entity.User;
import com.lf.entity.UserRole;
import com.lf.service.EmailService;
import com.lf.service.MenuService;
import com.lf.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Api(tags = {"新认证接口"})
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Resource
    private UserService userService;

    @Resource
    private UserMapper userMapper;

    @Resource
    private UserRoleMapper userRoleMapper;

    @Resource
    private RoleMapper roleMapper;

    @Resource
    private PasswordEncoder passwordEncoder;

    @Resource
    private JwtUtil jwtUtil;

    @Resource
    private MenuService menuService;

    @Resource
    private EmailService emailService;

    /**
     * 登录：支持用户名或邮箱
     */
    @ApiOperation("登录")
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String account = body.get("account");
        String password = body.get("password");

        if (!StringUtils.hasText(account) || !StringUtils.hasText(password)) {
            throw new BusinessException(20002, "账号和密码不能为空");
        }

        account = account.trim();

        // 判断是邮箱还是用户名
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (account.contains("@")) {
            wrapper.eq(User::getEmail, account);
        } else {
            wrapper.eq(User::getUsername, account);
        }
        wrapper.last("limit 2");
        List<User> users = userMapper.selectList(wrapper);

        if (users.isEmpty()) {
            throw new BusinessException(20002, "用户不存在");
        }
        if (users.size() > 1) {
            throw new BusinessException(20012, "账号数据异常，请联系管理员");
        }

        User loginUser = users.get(0);
        if (!passwordEncoder.matches(password, loginUser.getPassword())) {
            throw new BusinessException(20002, "账号或密码错误");
        }

        // 生成 token
        loginUser.setPassword(null);
        String token = jwtUtil.createToken(loginUser);

        // 查询角色
        List<String> roles = userMapper.getRoleNamesByUserId(loginUser.getId());

        // 构建返回
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);

        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", loginUser.getId());
        userInfo.put("username", loginUser.getUsername());
        userInfo.put("email", loginUser.getEmail());
        userInfo.put("name", loginUser.getName());
        userInfo.put("avatar", loginUser.getAvatar());
        data.put("user", userInfo);

        data.put("roles", roles);
        data.put("activeRole", resolveActiveRole(roles));

        return Result.success(data);
    }

    /**
     * 注册：邮箱验证码
     */
    @ApiOperation("注册")
    @PostMapping("/register")
    public Result<?> register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String email = body.get("email");
        String emailCode = body.get("emailCode");
        String password = body.get("password");
        String nickname = body.get("nickname");
        String initialRole = body.get("initialRole");

        // 基本校验
        if (!StringUtils.hasText(username)) {
            throw new BusinessException(20006, "用户名不能为空");
        }
        if (!StringUtils.hasText(email)) {
            throw new BusinessException(20006, "邮箱不能为空");
        }
        if (!StringUtils.hasText(emailCode)) {
            throw new BusinessException(20006, "验证码不能为空");
        }
        if (!StringUtils.hasText(password)) {
            throw new BusinessException(20006, "密码不能为空");
        }

        // 验证码校验
        if (!emailService.verifyCode(email, emailCode)) {
            throw new BusinessException(20007, "验证码错误或已过期");
        }

        // 用户名去重
        username = username.trim();
        LambdaQueryWrapper<User> nameCheck = new LambdaQueryWrapper<>();
        nameCheck.eq(User::getUsername, username);
        if (userMapper.selectCount(nameCheck) > 0) {
            throw new BusinessException(20006, "用户名已存在");
        }

        // 邮箱去重
        LambdaQueryWrapper<User> emailCheck = new LambdaQueryWrapper<>();
        emailCheck.eq(User::getEmail, email);
        if (userMapper.selectCount(emailCheck) > 0) {
            throw new BusinessException(20006, "该邮箱已注册");
        }

        // 创建用户
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setName(StringUtils.hasText(nickname) ? nickname : username);
        user.setStatus(1);
        userMapper.insert(user);

        // 分配角色：默认 client -> roleId 需要从 x_role 查
        // 当前数据库里 role 存的是 roleId 整数，使用旧注册同样的方式
        Integer roleId = resolveRoleId(initialRole);
        if (roleId != null) {
            userRoleMapper.insert(new UserRole(null, user.getId(), roleId));
        }

        return Result.success("注册成功");
    }

    /**
     * 发送邮箱验证码
     */
    @ApiOperation("发送邮箱验证码")
    @PostMapping("/send-email-code")
    public Result<?> sendEmailCode(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (!StringUtils.hasText(email) || !email.contains("@")) {
            throw new BusinessException(20006, "请输入有效邮箱");
        }
        emailService.sendVerificationCode(email);
        return Result.success("验证码已发送");
    }

    /**
     * 获取当前用户信息（从 X-Token 头解析）
     */
    @ApiOperation("获取当前用户信息")
    @GetMapping("/me")
    public Result<Map<String, Object>> me(@RequestHeader("X-Token") String token) {
        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(token, User.class);
        } catch (Exception e) {
            throw new BusinessException(20003, "登录信息无效，请重新登录");
        }

        if (loginUser == null) {
            throw new BusinessException(20003, "登录信息无效，请重新登录");
        }

        // 重新查数据库拿最新信息
        User dbUser = userMapper.selectById(loginUser.getId());
        if (dbUser == null) {
            throw new BusinessException(20003, "用户不存在");
        }

        List<String> roles = userMapper.getRoleNamesByUserId(dbUser.getId());
        List<Menu> menuList = menuService.getMenuListByUserId(dbUser.getId());

        Map<String, Object> data = new HashMap<>();

        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", dbUser.getId());
        userInfo.put("username", dbUser.getUsername());
        userInfo.put("email", dbUser.getEmail());
        userInfo.put("name", dbUser.getName());
        userInfo.put("avatar", dbUser.getAvatar());
        data.put("user", userInfo);

        data.put("roles", roles);
        data.put("activeRole", resolveActiveRole(roles));
        data.put("menuList", menuList);

        // 兼容旧前端 getInfo 消费结构
        data.put("name", dbUser.getUsername());
        data.put("avatar", dbUser.getAvatar());

        return Result.success(data);
    }

    /**
     * 切换当前身份（简单实现：仅返回确认，不持久化到数据库）
     */
    @ApiOperation("切换身份")
    @PostMapping("/switch-role")
    public Result<Map<String, Object>> switchRole(
            @RequestHeader("X-Token") String token,
            @RequestBody Map<String, String> body) {
        String targetRole = body.get("role");
        if (!StringUtils.hasText(targetRole)) {
            throw new BusinessException(20006, "请指定目标身份");
        }

        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(token, User.class);
        } catch (Exception e) {
            throw new BusinessException(20003, "登录信息无效");
        }

        List<String> roles = userMapper.getRoleNamesByUserId(loginUser.getId());
        if (!roles.contains(targetRole)) {
            throw new BusinessException(20008, "您没有该身份权限");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("activeRole", targetRole);
        return Result.success(data);
    }

    /**
     * 根据前端传的 initialRole 字符串解析数据库 roleId。
     * 前端传 "artist" → 查 role_name = "画师角色"，
     * 前端传 "client" 或其他 → 查 role_name = "用户角色"。
     */
    private Integer resolveRoleId(String initialRole) {
        String roleName = "artist".equals(initialRole) ? "画师角色" : "用户角色";
        LambdaQueryWrapper<Role> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Role::getRoleName, roleName);
        Role role = roleMapper.selectOne(wrapper);
        return role != null ? role.getRoleId() : null;
    }

    private String resolveActiveRole(List<String> roles) {
        if (roles == null || roles.isEmpty()) {
            return "";
        }
        if (roles.contains("admin")) {
            return "admin";
        }
        return roles.get(0);
    }
}
