package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.exception.BusinessException;
import com.lf.common.utils.JwtUtil;
import com.lf.dao.UserMapper;
import com.lf.dao.UserRoleMapper;
import com.lf.entity.Menu;
import com.lf.entity.User;
import com.lf.entity.UserRole;
import com.lf.service.MenuService;
import com.lf.service.UserService;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Resource
    private UserMapper userMapper;

    @Resource
    private RedisTemplate redisTemplate;

    @Resource
    private PasswordEncoder passwordEncoder;

    @Resource
    private JwtUtil jwtUtil;

    @Resource
    private UserRoleMapper userRoleMapper;

    @Resource
    private MenuService menuService;

    @Override
    public Map<String, Object> login(User user) {
        if (user == null || !StringUtils.hasText(user.getPassword())) {
            throw new BusinessException(20002, "\u7528\u6237\u540d\u6216\u5bc6\u7801\u4e0d\u80fd\u4e3a\u7a7a");
        }
        String normalizedUsername = normalizeAndValidateUsername(user.getUsername());

        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, normalizedUsername);
        wrapper.last("limit 2");
        List<User> loginUserList = userMapper.selectList(wrapper);

        if (loginUserList.isEmpty()) {
            throw new BusinessException(20002, "\u7528\u6237\u4e0d\u5b58\u5728");
        }
        if (loginUserList.size() > 1) {
            throw new BusinessException(20012, "\u7528\u6237\u540d\u6570\u636e\u5f02\u5e38\uff0c\u8bf7\u8054\u7cfb\u7ba1\u7406\u5458");
        }

        User loginUser = loginUserList.get(0);
        if (!passwordEncoder.matches(user.getPassword(), loginUser.getPassword())) {
            throw new BusinessException(20002, "\u7528\u6237\u540d\u6216\u5bc6\u7801\u9519\u8bef");
        }

        loginUser.setPassword(null);
        String token = jwtUtil.createToken(loginUser);

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        return data;
    }

    @Override
    public Map<String, Object> getUserInfo(String token) {
        User loginUser;
        try {
            loginUser = jwtUtil.parseToken(token, User.class);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        if (loginUser != null) {
            HashMap<String, Object> data = new HashMap<>();
            data.put("name", loginUser.getUsername());
            data.put("avatar", loginUser.getAvatar());
            data.put("userList", loginUser);

            List<String> roleList = userMapper.getRoleNamesByUserId(loginUser.getId());
            data.put("roles", roleList);

            List<Menu> menuList = menuService.getMenuListByUserId(loginUser.getId());
            data.put("menuList", menuList);
            return data;
        }
        return null;
    }

    @Override
    public void logout(String token) {
        // redisTemplate.delete(token);
    }

    @Override
    @Transactional
    public void addUser(User user) {
        String normalizedUsername = validateUsernameForCreate(user.getUsername());
        user.setUsername(normalizedUsername);

        this.baseMapper.insert(user);

        List<Integer> roleIdList = user.getRoleIdList();
        if (roleIdList != null) {
            for (Integer roleId : roleIdList) {
                userRoleMapper.insert(new UserRole(null, user.getId(), roleId));
            }
        }
    }

    @Override
    public User getUserById(Integer id) {
        User user = this.baseMapper.selectById(id);
        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, id);
        List<UserRole> userRoleList = userRoleMapper.selectList(wrapper);
        List<Integer> roleIdList = userRoleList.stream()
                .map(UserRole::getRoleId)
                .collect(Collectors.toList());
        user.setRoleIdList(roleIdList);
        return user;
    }

    @Override
    @Transactional
    public void updateMyUser(User user) {
        if (user == null || user.getId() == null) {
            throw new BusinessException(20001, "\u7528\u6237ID\u4e0d\u80fd\u4e3a\u7a7a");
        }
        String normalizedUsername = validateUsernameForUpdate(user.getUsername(), user.getId());
        user.setUsername(normalizedUsername);
        this.baseMapper.updateById(user);
    }

    @Override
    @Transactional
    public void updateUser(User user) {
        if (user == null || user.getId() == null) {
            throw new BusinessException(20001, "\u7528\u6237ID\u4e0d\u80fd\u4e3a\u7a7a");
        }

        String normalizedUsername = validateUsernameForUpdate(user.getUsername(), user.getId());
        user.setUsername(normalizedUsername);

        this.baseMapper.updateById(user);

        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, user.getId());
        userRoleMapper.delete(wrapper);

        List<Integer> roleIdList = user.getRoleIdList();
        if (roleIdList != null) {
            for (Integer roleId : roleIdList) {
                userRoleMapper.insert(new UserRole(null, user.getId(), roleId));
            }
        }
    }

    @Override
    public void deleteUserById(Integer id) {
        this.baseMapper.deleteById(id);

        LambdaQueryWrapper<UserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserRole::getUserId, id);
        userRoleMapper.delete(wrapper);
    }

    private String validateUsernameForCreate(String username) {
        String normalizedUsername = normalizeAndValidateUsername(username);
        // 创建场景：全局唯一（包含逻辑删除数据）
        ensureUsernameUnique(normalizedUsername, null);
        return normalizedUsername;
    }

    private String validateUsernameForUpdate(String username, Integer excludeUserId) {
        String normalizedUsername = normalizeAndValidateUsername(username);
        // 修改场景：排除当前用户自身 id 后校验唯一
        ensureUsernameUnique(normalizedUsername, excludeUserId);
        return normalizedUsername;
    }

    private String normalizeAndValidateUsername(String username) {
        if (username == null) {
            throw new BusinessException(20006, "\u7528\u6237\u540d\u4e0d\u80fd\u4e3a\u7a7a");
        }
        String normalizedUsername = username.trim();
        if (!StringUtils.hasText(normalizedUsername)) {
            throw new BusinessException(20006, "\u7528\u6237\u540d\u4e0d\u80fd\u4e3a\u7a7a");
        }
        return normalizedUsername;
    }

    private void ensureUsernameUnique(String username, Integer excludeUserId) {
        Integer count = userMapper.countByUsernameIncludeDeleted(username, excludeUserId);
        if (count != null && count > 0) {
            throw new BusinessException(20006, "\u7528\u6237\u540d\u5df2\u5b58\u5728");
        }
    }
}
