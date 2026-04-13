1. 
docs/CODEX_REFACTOR_BRIEF.md
artistsion-web/CLAUDE.md
artistsion-admin/CLAUDE.md
docs/PROJECT_MAP.md
docs/NEW_CHAT_CONTEXT_ZH.md

如果本文件与旧模板 README 或旧页面结构存在冲突，以本文件和上述说明文件为准。

2. 项目定位

这是一个画师委托平台 / 艺术交易平台。

核心业务目标：

用户可以作为“客户”发布企划、委托需求
用户可以作为“画师”展示作品、接单、应征企划
同一个账号可以同时拥有“客户”和“画师”两种身份
登录后用户可以在个人中心切换当前身份
网站主站应以作品浏览、画师发现、企划撮合为核心，而不是后台管理页面
3. 当前项目的真实现状

在开始改造前，必须理解以下事实：

3.1 当前前端不是纯前台站

当前前端是“公开页 + 用户中心 + 后台式动态菜单”混合结构，而不是一个清晰的前台内容站。

3.2 当前默认首页不是内容首页

当前 / 默认重定向到 /dashboard，而当前 dashboard 实际承载的是个人资料、修改密码、更新头像等内容，不是作品推荐首页。

3.3 当前鉴权和菜单是强耦合的

当前登录后的页面结构依赖如下链路：

前端登录成功
前端请求 /user/info
后端返回 menuList
前端根据 menuList 动态注入路由

因此，任何涉及登录、首页、菜单、权限的改造，都不能只改一个页面文件，必须同时检查：

artistsion-web/src/router/index.js
artistsion-web/src/permission.js
artistsion-web/src/store/modules/user.js
artistsion-admin/src/main/java/com/lf/controller/UserController.java
artistsion-admin/src/main/java/com/lf/service/impl/UserServiceImpl.java
artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java
3.4 当前未登录用户仍可访问部分页面

当前未登录不是只能看到登录页，系统仍然放行了一部分公开页面。
本次改造后，目标是：除了 /auth 之外，主站页面默认都要求登录。

3.5 当前登录仍以用户名 + 密码为中心

当前前端登录 action 仍然只提交用户名和密码。
当前登录页还包含一个前端本地验证码输入。
本次改造后，需要改为：

登录支持“用户名或邮箱 + 密码”
注册支持“邮箱 + 邮箱验证码”
不再依赖当前这种前端本地验证码逻辑作为核心认证体验
3.6 当前注册仍是单角色注册

当前注册页只能二选一：

用户（约稿方）
画师（接单方）

后端注册后只会直接保存一个用户角色关系。
本次改造后，需要升级为：

一个账号可以拥有两个身份
登录后返回用户拥有的身份列表
个人中心允许切换当前身份 activeRole
3.7 当前后端已经具备双身份扩展基础

当前 User 实体里已经有：

email
roleIdList

这说明当前数据模型并不是完全无法扩展。
但现有默认注册 / 登录流程还没有真正实现双身份逻辑，因此需要前后端一起改造。

4. 本次重构的最终目标
4.1 整体产品目标

将当前项目重构为一个更清晰的前台站，围绕三类核心场景组织：

首页：作品推荐与浏览
画师：画师发现与作品集预览
企划：客户需求大厅与画师应征
4.2 一级导航目标

登录后主站顶部仅保留三项一级导航：

首页
画师
企划
4.3 认证目标

将当前 /login 和 /register 重构为统一的 /auth 页面：

登录和注册在一个页面里切换
注册支持邮箱验证码
登录支持用户名或邮箱
登录成功后返回用户基本信息、拥有身份列表、当前身份
4.4 身份目标

同一个账号可拥有以下身份：

client
artist

要求：

同一账号可以同时拥有两个身份
登录后有当前身份 activeRole
在个人中心中可切换 activeRole
切换身份不需要重新登录
4.5 主站首页目标

登录后默认进入真正的前台首页，而不是旧 dashboard。

5. 建议的新页面结构
5.1 公开页
/auth
5.2 主站一级页
/home
/artists
/projects
5.3 详情页
/work/:id
/artist/:id
/project/:id
/search
5.4 通用个人中心页
/center/profile
/center/messages
/center/notifications
/center/orders
/center/favorites
5.5 客户身份页
/client/projects
/client/commissions
/client/drafts
5.6 画师身份页
/artist-center/works
/artist-center/services
/artist-center/applications
/artist-center/orders
/artist-center/schedule
/artist-center/stats
6. 新的交互与信息架构
6.1 主站顶部采用双层导航

第一排：

Logo
搜索框
消息入口
通知入口
用户头像

第二排：

首页
画师
企划
6.2 头像下拉菜单

所有身份都至少包含：

个人中心
订单中心
消息中心
身份切换
退出登录

当前身份为客户时，可额外显示：

发布企划
我的企划
我的委托

当前身份为画师时，可额外显示：

我的作品
我的稿位
接单管理
档期设置
6.3 搜索入口

第一阶段只要求支持：

按作品名称搜索

后续可扩展：

画师
标签
企划
7. 认证与接口重构建议
7.1 建议新增或重构的接口

建议逐步从 /user/* 收敛到更明确的 /auth/* 结构：

POST /auth/send-email-code
POST /auth/register
POST /auth/login
GET /auth/me
POST /auth/switch-role
POST /auth/logout

如果短期内需要兼容旧前端，可以暂时保留旧接口，但不要做长期半迁移状态。

7.2 登录请求目标

登录参数：

account
password

其中 account 可以是：

用户名
邮箱
7.3 注册请求目标

注册参数建议包含：

username
email
emailCode
password
confirmPassword
nickname
initialRole
7.4 登录返回目标

登录成功后建议返回：

token
user
roles
activeRole
8. 数据模型重构方向

不要求一开始就彻底重做数据库，但要求后续结构能支持以下业务模型：

8.1 账户层
一个账户唯一对应一个登录身份主体
一个账户可拥有多个业务角色
8.2 身份层

建议区分：

画师资料
客户资料
8.3 内容层

建议区分：

作品
作品图片 / 媒体
标签
8.4 企划层

建议区分：

企划主表
企划应征表
8.5 交易层

建议区分：

订单
委托来源（企划 / 稿位）
8.6 社交互动层

建议区分：

收藏
点赞
关注
评论
消息
通知
9. 实施顺序要求

请按以下顺序推进，而不是同时大面积混改：

阶段 1：现状梳理与入口调整
阅读文档和关键代码
梳理当前鉴权、登录、菜单、动态路由链路
让新前台站成为默认入口
不再让旧 dashboard 成为用户的默认首页
阶段 2：认证系统重构
合并登录 / 注册页为 /auth
登录支持用户名或邮箱
注册支持邮箱验证码
实现双身份模型与 activeRole
阶段 3：主站框架重建
新建主站公共布局
实现双层导航
实现搜索、消息、通知、头像菜单
实现身份切换入口
阶段 4：核心页面静态版
/home
/artists
/projects
/work/:id
/artist/:id
/project/:id

先把结构、布局、交互做好，再逐步接数据。

阶段 5：接真实数据
首页推荐作品
画师列表和详情
企划列表和详情
作品互动
企划发布与应征
个人中心与身份切换
阶段 6：补齐用户中心闭环
资料
消息
通知
订单
收藏 / 关注
客户身份页
画师身份页
10. 开发约束
不要把项目当成普通 vue-admin-template 模板。
不要只改页面样式而不改权限链路。
不要只改前端，不改后端。
不要做半迁移。
如果当前动态菜单机制阻碍新前台落地，可以保留旧管理端逻辑，同时为新前台建立独立、清晰、静态可控的路由树。
新前台不应继续强依赖“数据库菜单决定页面结构”的模式。
保留可复用业务能力，但允许重构。
不要泄露真实配置。
不要做无意义的大面积格式化。
改动必须保持项目可运行。
11. AI 助手开始编码前必须输出的内容

在真正修改代码前，请先输出：

你对当前项目结构的理解摘要
你计划修改的关键文件列表
分阶段实施方案
新增或调整的数据结构 / 接口摘要
你识别到的潜在风险点

只有在这些内容明确后，再开始编码。

12. AI 助手完成任务后必须输出的内容

完成后，请输出：

已修改文件列表
新增文件列表
认证系统改动说明
路由与页面结构改动说明
后端接口改动说明
数据模型改动说明
尚未完成的风险点
后续建议
13. 验收标准

以下结果必须成立：

未登录不能进入主站内容页
登录和注册合并为一个页面
登录支持用户名或邮箱
注册支持邮箱验证码
同一账号可以拥有客户和画师两个身份
登录后默认进入真正的前台首页，而不是旧 dashboard
顶部采用双层导航
首页是作品推荐流
画师页是画师发现与作品集预览页
企划页是客户需求大厅
个人中心可以切换身份
前后端逻辑一致，不存在明显半迁移状态
14. 推荐优先检查的关键文件
前端
artistsion-web/src/router/index.js
artistsion-web/src/permission.js
artistsion-web/src/store/modules/user.js
artistsion-web/src/views/login/index.vue
artistsion-web/src/views/login/register.vue
artistsion-web/src/api/*
artistsion-web/src/views/dashboard/index.vue
后端
artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java
artistsion-admin/src/main/java/com/lf/interceptor/JwtValidateInterceptor.java
artistsion-admin/src/main/java/com/lf/controller/UserController.java
artistsion-admin/src/main/java/com/lf/service/impl/UserServiceImpl.java
artistsion-admin/src/main/java/com/lf/entity/User.java
15. 结论

本次任务本质上不是旧页面小修小补，而是：

将当前混合式管理模板前端，重构为面向用户的画师交易平台前台站。

如果当前旧路由、旧菜单、旧鉴权模式阻碍目标达成，请优先保证新主站架构正确，再考虑旧系统兼容方式。