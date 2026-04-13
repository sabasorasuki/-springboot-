# 会话交接摘要

## 当前所处阶段

阶段 1 ✅ 已完成，阶段 2 ✅ 已完成，准备进入阶段 3。

## 本阶段结论（阶段 1）

- 新前台路由骨架已建立：`/auth`、`/home`、`/artists`、`/projects`
- 新前台使用独立 `MainLayout`（双层顶部导航），与旧 `Layout`（sidebar）完全隔离
- 未登录非白名单页已重定向到 `/auth`
- 已登录访问 `/auth` 重定向到 `/home`
- 旧后台管理端（Layout、dashboard、动态菜单、管理页）完全保留未动
- 后端和数据库本阶段无改动
- 项目构建通过，零错误

## 关键改动文件

### 阶段 1 新建

- `artistsion-web/src/layout/MainLayout.vue`
- `artistsion-web/src/views/auth/index.vue`
- `artistsion-web/src/views/home/index.vue`
- `artistsion-web/src/views/artists/index.vue`
- `artistsion-web/src/views/projects/index.vue`
- `artistsion-web/src/api/auth.js`

### 阶段 1 修改

- `artistsion-web/src/router/index.js` — import MainLayout，新增 4 条静态路由
- `artistsion-web/src/permission.js` — 白名单加 `/auth`，重定向目标改为 `/auth` 和 `/home`

## 下一阶段必须先做的事

### 1. 修正根路径 `/` 的默认行为（最高优先级）

当前 `/` 仍然 redirect 到 `/dashboard`（旧后台），必须修正为：

- 未登录访问 `/` → 跳 `/auth`
- 已登录访问 `/` → 进入 `/home`
- **不应继续默认落到旧 `/dashboard`**

### 2. 实现 `/auth` 页面真实登录/注册

当前 `/auth` 页面的登录和注册按钮是占位 stub，需要接入真实后端接口。

### 3. 后端新增 `/auth/*` 接口

- `POST /auth/login` — 支持用户名或邮箱 + 密码
- `POST /auth/register` — 支持邮箱验证码
- `POST /auth/send-email-code` — 发送邮箱验证码
- `GET /auth/me` — 获取当前用户 + roles + activeRole
- `POST /auth/switch-role` — 切换当前身份

### 4. 旧接口保留兼容

旧 `/user/login`、`/user/info`、`/user/register` 保留不删除。

### 5. 邮件验证码

后端当前无 `spring-boot-starter-mail` 依赖。需要决定是真实实现还是先 mock。

## 当前风险

1. **根路径 `/` 未收口** — 仍落到旧 dashboard，阶段 2 第一步必须处理
2. **邮件发送是新能力** — 后端无邮件依赖，需补充或 mock
3. **旧管理端依赖链** — 旧 `/user/login` + `/user/info` → menuList → 动态路由注入，不能断
4. **User 实体需扩展** — `nickname`、`active_role` 是拟新增字段，不是已有字段
5. **双 Layout 共存** — 新路由用 `MainLayout`，旧路由用 `Layout`，不要搞混

## 已知注意点

- `/user/info` 的两层逻辑独立：拦截器白名单放行是 `MyWebConfig` 配置的（拦截器只读 `X-Token` 请求头），接口本身要求 `token` 查询参数并从中解析用户——不要把这两层混在一起
- `nickname`、`active_role` 不是已有字段，不要当成现成表结构来假设
- `spring-boot-starter-mail` 不存在，邮件发送不是现成能力

## 下一位助手的工作原则

1. **不要把项目当普通模板项目** — 业务代码已经很重
2. **不要只改前端不改后端** — 认证改造是前后端联动
3. **不要做半迁移** — 要么新接口完整落地，要么暂时不动旧接口
4. **新前台先独立、旧后台先保留** — 不要在阶段 2 清理旧代码
5. **先阅读文档再动手** — 优先阅读 `docs/REFACTOR_PROGRESS.md`、`docs/CODEX_REFACTOR_BRIEF.md`、`docs/FRONTEND_STYLE_SPEC.md`
6. **保持项目可运行** — 每步改完后验证构建和基本流程

## 参考文档

- `CLAUDE.md` — 仓库总览
- `artistsion-web/CLAUDE.md` — 前端指引
- `artistsion-admin/CLAUDE.md` — 后端指引
- `docs/PROJECT_MAP.md` — 业务映射
- `docs/CODEX_REFACTOR_BRIEF.md` — 重构目标和验收标准
- `docs/FRONTEND_STYLE_SPEC.md` — 前端样式规范
- `docs/REFACTOR_PROGRESS.md` — 长期进度
# 当前会话交接摘要

## 当前所处阶段
已完成阶段 1，准备进入阶段 2（认证系统重构）。

## 当前结论
- 新前台骨架已建立
- 新前台使用独立 `MainLayout`
- 新增了 `/auth`、`/home`、`/artists`、`/projects`
- 未登录非白名单页已跳转 `/auth`
- 旧后台管理端、旧 Layout、旧动态菜单仍保留
- 后端和数据库尚未改动

## 本阶段关键文件
- `src/layout/MainLayout.vue`
- `src/views/auth/index.vue`
- `src/views/home/index.vue`
- `src/views/artists/index.vue`
- `src/views/projects/index.vue`
- `src/api/auth.js`
- `src/router/index.js`
- `src/permission.js`

## 下一阶段必须先做的事
1. 核对根路径 `/` 的默认行为
   - 未登录访问 `/` 应跳 `/auth`
   - 已登录访问 `/` 应进 `/home`
2. 实现 `/auth` 真实登录 / 注册 UI
3. 设计并实现 `/auth/*` 新接口
4. 登录支持用户名或邮箱
5. 注册支持邮箱验证码
6. 先不要删旧 `/user/login`、`/user/info`

## 当前风险
- 邮箱验证码可能需要新增邮件依赖和 SMTP 配置
- 旧后台链路依赖 `/user/info -> menuList`
- 不能在阶段 2 提前删除旧后台代码

## 下一位助手的工作原则
- 不要把项目当普通模板项目
- 不要只改前端，不改后端
- 不要做半迁移
- 先保证新前台认证链路成立，再考虑旧代码清理