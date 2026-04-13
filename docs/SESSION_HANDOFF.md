# 会话交接摘要

## 当前所处阶段

阶段 1 ✅ 已完成，阶段 2 ✅ 已完成，准备进入阶段 3。

---

## 阶段 2 收尾事项（本轮已完成）

| 事项 | 状态 |
|---|---|
| `resolveRoleId()` 硬编码 → 查库 | ✅ 改为 `LambdaQueryWrapper<Role>` 按 `role_name` 查 |
| 配置脱敏 | ✅ 密钥替换为 `${ENV_VAR:}` 占位，真实值移至 `application-local.properties` |
| `.gitignore` 加 `application-local.properties` | ✅ |
| `/auth/me` 返回 `menuList` 定性 | ✅ 过渡方案，新前台不依赖，详见 REFACTOR_PROGRESS.md |
| 文档清理 | ✅ 去掉重复和"本地未推送"标记 |

---

## 阶段 3 目标：新前台导航完善

### 核心任务

1. **TopBar 头像菜单接入真实用户信息**
   - 登录后显示 `name`/`avatar`
   - 下拉菜单：个人中心、切换身份、退出
   - 未登录显示「登录/注册」按钮

2. **SiteNav 当前路由高亮**
   - 首页/画师/企划三个导航项，根据 `$route.path` 高亮

3. **搜索框初步**（可选）
   - TopBar 搜索输入框 UI，暂不接入后端

4. **新前台路由完全由前端静态驱动**
   - 不依赖 `menuList`，`/home`、`/artists`、`/projects` 已在 `constantRoutes` 中
   - `menuList` 仍由 `getInfo` 拿取，仅供旧管理端动态路由使用

### 需要注意

- `MainLayout.vue` 中 TopBar 已有骨架，需要从 Vuex store 读取 `name`/`avatar`/`roles`/`activeRole`
- 退出登录需调 `store.dispatch('user/logout')`，跳转 `/auth`
- 切换身份可调 `switchRole` API + `SET_ACTIVE_ROLE` mutation

---

## 已泄露密钥处理建议（需手动操作）

详见 `docs/REFACTOR_PROGRESS.md` 的「配置脱敏说明」章节：
- 支付宝沙箱密钥：重新生成
- DashScope API Key：吊销旧 key + 创建新 key
- MySQL 密码：ALTER USER 修改
- 更新 `application-local.properties` 中的新值

---

## 参考文档

- `CLAUDE.md` — 仓库总览
- `artistsion-web/CLAUDE.md` — 前端指引
- `artistsion-admin/CLAUDE.md` — 后端指引
- `docs/PROJECT_MAP.md` — 业务映射
- `docs/REFACTOR_PROGRESS.md` — 长期进度
- `docs/FRONTEND_STYLE_SPEC.md` — 前端样式规范
