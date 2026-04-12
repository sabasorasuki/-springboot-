# Artistsion 新会话上下文

## 可直接粘贴给新会话

```text
这是一个前后端分离的毕业设计项目，项目名可以理解为 Artistsion，定位是“画师约稿 / 画稿交易 / 作品展示平台”。仓库里前端和后端都在同一个 repo。

仓库结构：
- `artistsion-web`：Vue 2 前端，基于 `vue-admin-template` 改出来的单体前端，里面混合了公开站点、个人中心和后台管理。
- `artistsion-admin`：Spring Boot 2.7 后端，MyBatis-Plus + MySQL + Redis + JWT。
- `artistsion.sql`：主数据库导出文件。
- `docs/PROJECT_MAP.md`：项目结构和业务映射说明。
- `docs/NEW_CHAT_CONTEXT_ZH.md`：这份新会话上下文。

技术栈：
- 前端：Vue 2、Vue Router、Vuex、Element UI、Axios、WangEditor、ECharts。
- 后端：Spring Boot 2.7.13、MyBatis-Plus、MySQL、Redis、JWT、Swagger/Springfox、支付宝 SDK、阿里 DashScope SDK。
- 开发端口：前端 `8888`，后端 `9999`。

项目核心业务：
1. 画稿/稿位展示与交易：
   - 核心表是 `sys_huagao`
   - 代表可上架的画稿、稿位、定制服务
   - 支持分类、价格、折扣、上下架、审核状态、详情富文本
2. 作品/帖子分享：
   - 核心表是 `sys_zuopin`
   - 用于社区展示、经验分享、作品发布
   - 支持点赞和评论
3. 订单与支付：
   - 核心表是 `sys_order`
   - 有购物车、下单、支付、订单管理等流程
   - 支付宝支付入口后端是 `/order/alipay`
4. 个性化推荐：
   - 交互行为表是 `user_article_operation`
   - 后端用 Mahout 做基于用户的协同过滤推荐
   - 首页登录后会优先走推荐，未登录则展示最新稿位
5. AI 助手：
   - 前端页在 `src/views/ai/ai.vue`
   - 后端接口是 `/ai/aliTyqw`
   - 当前接的是阿里通义千问
6. 内容辅助模块：
   - `sys_fenlei` 分类
   - `sys_lunbo` 轮播图
   - `sys_pinglun` 评论
   - `sys_shoucang` 收藏
   - `sys_liuyan` / `sys_liuyans` 留言类模块
   - `sys_rizhi` 日志/统计相关

前端结构重点：
- 静态公共路由在 `artistsion-web/src/router/index.js`
- 登录鉴权和动态菜单注入在 `artistsion-web/src/permission.js`
- 登录后会请求 `/user/info`，后端返回 `menuList`
- 前端通过 `require(@/views/${menu.component}.vue)` 动态加载页面
- 所以很多“页面进不去/菜单不显示”问题，根源可能是数据库 `x_menu` 的 component 配置，而不是前端代码本身

当前前端实际是一个“大单体”：
- `/mas` 是公开首页外壳
- 首页主内容在 `src/views/about/the-index.vue`
- 公共页面有列表页、详情页、社区页
- 登录后还有个人中心、我的发布、我的分享、购物车、聊天/联系页
- 同一个前端里还塞了系统管理页：用户、角色、菜单、订单统计、日志等

典型用户路径：
- 游客进入 `/mas` 浏览首页、轮播、攻略帖、热门稿位
- 注册/登录后可查看个性化推荐
- 在稿位详情页加入购物车、收藏
- 在购物车页发起支付宝支付
- 用户可在个人中心修改资料、头像、密码
- 画师/卖家可发布画稿，内容编辑器用的是 WangEditor
- 管理员可审核、管理用户/角色/菜单/分类/轮播/订单等

后端结构重点：
- Controller 在 `artistsion-admin/src/main/java/com/lf/controller`
- Service / ServiceImpl、Entity、Mapper XML 分层比较传统
- 通用返回结构是 `Result`
- 成功码一般是 `20000`
- 很多分页接口返回：
  `{ code: 20000, data: { total, rows } }`

认证与权限：
- 登录接口：`/user/login`
- 用户信息接口：`/user/info`
- 前端 token 放在请求头 `X-Token`
- JWT 校验拦截器：`JwtValidateInterceptor`
- 白名单配置：`MyWebConfig`
- 需要注意：`/user/info` 目前在白名单里，但它仍然依赖 query 参数里的 `token`
- 菜单权限来自 `x_menu`、`x_role`、`x_user_role`、`x_role_menu`

重要模块对应关系：
- 用户与权限：
  - 前端：`src/views/login/*`、`src/views/sys/*`、`src/store/modules/user.js`
  - 后端：`UserController`、`UserServiceImpl`、`MenuServiceImpl`
- 画稿：
  - 前端：`src/api/huagao.js`、`src/views/shangp/*`、`src/views/about/detail.vue`
  - 后端：`SysHuagaoController`
- 作品分享：
  - 前端：`src/api/fenxiang.js`、`src/views/fenxiang/*`、`src/views/about/details.vue`
  - 后端：`SysZuopinController`
- 订单：
  - 前端：`src/api/order.js`、`src/views/order/*`
  - 后端：`SysOrderController`、`AliPayController`
- 推荐：
  - 前端：`src/api/tuijian.js`、首页推荐逻辑在 `src/views/about/the-index.vue`
  - 后端：`UserArticleOperationController`、`UserArticleOperationServiceImpl`
- 上传：
  - 前端很多页面直接写死 `http://localhost:9999/oss/file/...`
  - 后端：`OSSController`
- AI：
  - 前端：`src/views/ai/ai.vue`
  - 后端：`AliAiController`

当前项目状态和维护注意点：
- 这个仓库不是模板项目了，业务代码已经很重，不能再按 `vue-admin-template` 原样理解
- 子项目自带的 `README.md` 大多还是上游模板文档，不要把它们当成真实项目文档
- `application.properties` 里有真实数据库、支付、AI 等敏感配置，不要在回复里展开泄露
- 有不少上传/下载 URL 是硬编码在页面里的，不只是在统一配置里
- 动态路由和菜单高度依赖数据库种子数据
- 前后端字段名耦合比较重，改接口时需要同步检查所有消费者；如果是明确的大改，允许连同前后端一起重构和更新契约
- `src/api` 里有一些模板遗留或半弃用方法，不能只看前端方法名就默认后端一定存在对应接口
- 终端里部分中文注释可能有编码显示问题，但不代表源码本身有问题

最近已知的重要改动/现状：
- 用户名唯一性最近做过修复，后端 `UserServiceImpl` 里对用户名做了 trim + 唯一校验，仓库里还有 `artistsion-admin/sql/2026-04-06-fix-user-username-unique.sql`
- 文件上传/下载接口目前已经是本地文件落盘方案，控制器是 `OSSController`
- 首页、详情页、AI 页面等最近明显做过一轮 UI 升级，不再是最初的模板风格

如果你要继续分析或修改这个项目，请优先这样读：
1. 先看 `docs/PROJECT_MAP.md` 和这份上下文
2. 前端问题先看目标页面 + 对应 `src/api/*.js`
3. 权限/菜单问题同时看 `src/permission.js`、`/user/info`、`x_menu`
4. 后端问题按 Controller -> ServiceImpl -> Entity/Mapper XML 顺序追
5. 订单/支付/上传/AI 相关改动要特别注意已有硬编码和前端契约，但如果任务本身是重构，这些部分也可以一起系统性调整
```

## 建议的新会话使用方式

相比每次重新描述整个项目，更稳妥的做法是：

1. 每次开新会话先贴上面那段文本。
2. 再补一句这次你想解决的具体问题，比如“我现在要改首页推荐逻辑”或“我要修复购物车支付后状态不同步”。
3. 如果问题很聚焦，再附上相关文件路径，能明显减少模型先做全仓探索的时间。

## 推荐优先阅读文件

- 根文档：`CLAUDE.md`
- 业务映射：`docs/PROJECT_MAP.md`
- 前端项目说明：`artistsion-web/CLAUDE.md`
- 后端项目说明：`artistsion-admin/CLAUDE.md`
- 前端路由：`artistsion-web/src/router/index.js`
- 前端鉴权：`artistsion-web/src/permission.js`
- 后端鉴权：`artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java`
- JWT 拦截器：`artistsion-admin/src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`
- 用户服务：`artistsion-admin/src/main/java/com/lf/service/impl/UserServiceImpl.java`

## 我这次分析得到的项目判断

- 这是一个“公开站点 + 用户中心 + 管理后台”三合一的 Vue 2 前端。
- 后端是相对直接的 CRUD 风格 Spring Boot 项目，但集成了 JWT、推荐、支付、AI、上传下载。
- 项目的真实复杂度不在脚手架，而在“数据库菜单驱动动态路由”和“前后端字段/接口紧耦合”。
- 以后如果要继续维护，最值得优先抽离和治理的是：
  - 环境配置与敏感信息
  - 上传/下载与静态资源 URL
  - 支付流程与订单状态一致性
  - 动态路由对 `x_menu` 数据的强依赖
  - 前端公共站点与后台管理混在同一应用里的边界问题
