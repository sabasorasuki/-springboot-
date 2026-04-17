# Artistsion Web 指引

## 前端技术栈

- Vue 2 + Vue Router + Vuex
- Element UI + Axios
- WangEditor + ECharts
- 双壳结构：`MainLayout`（主站）与 `Layout`（admin）

## 启动和构建命令

- 安装依赖：`npm install`
- 开发：`npm run dev`
- 生产构建：`npm run build:prod`
- 单测：`npm run test:unit`
- 关键配置：`.env.development`、`.env.production`、`vue.config.js`

## 路由与权限链路

- 静态路由入口：`src/router/index.js`
- 登录守卫：`src/permission.js`
- 当前唯一认证入口：`/auth`
- 主站关键路径：`/home`、`/artists`、`/projects`、`/work/:id`、`/artist/:id`、`/project/:id`、`/post/:id`、`/center/profile`、`/center/orders`
- admin 统一入口：`/admin`，默认落到 `/dashboard`
- admin 深链接兼容：`/admin/<legacy-path>` 会在守卫里映射回旧后台路由
- 动态菜单链路仍是 `/user/info` -> `menuList` -> `require(@/views/${menu.component}.vue)`
- admin 菜单白名单、标题覆写和 admin-only 路径集中在 `src/utils/adminConsole.js`

## 当前前台 / admin 的边界

- 主站、个人中心、举报入口走 `MainLayout`
- 控制台走旧 `Layout` + 动态菜单
- admin 当前定位是平台控制台，不再把用户自助页作为主菜单
- 非 admin 身份访问 `/admin`、`/dashboard`、`/sys/*`、`/report/*` 等会被守卫拦回 `/home`
- 仍保留的隐藏兼容页：`/userinfo`、`/fabusp`、`/myfenxiang`、`/liaotian`

## 最容易改错的前端模块

- `src/permission.js`：同时处理白名单、动态路由注入、`/admin` 兼容映射和 admin 拦截
- `src/router/index.js`：两套路由壳共存，主站页和 admin 页不要挂错壳
- `src/store/modules/user.js`：新旧认证接口并存，但运行时仍默认消费 `/user/info`
- `src/utils/adminConsole.js`：admin 菜单收敛和权限边界的单一事实源
- `src/components/ReportDialog` 与 `src/views/report/index.vue`：举报前后台闭环共用链路
- `src/views/center/profile.vue`：仍会跳隐藏兼容页，改个人中心时要一起检查 `/fabusp`、`/myfenxiang`、`/liaotian`
