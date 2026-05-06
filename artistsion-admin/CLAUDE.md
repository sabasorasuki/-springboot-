# Artistsion Admin 指引

## 后端技术栈

- Spring Boot `2.7.13` / Java 8
- MyBatis-Plus + MySQL
- Redis + JWT
- Spring Mail + Swagger / Springfox
- Alipay SDK + DashScope SDK

## 启动方式

- 开发运行：`.\mvnw.cmd spring-boot:run`
- 编译自检：`.\mvnw.cmd -DskipTests compile`
- 入口类：`src/main/java/com/lf/XAdminApplication.java`
- 默认端口：`9999`
- 本地依赖：MySQL `artistsion`、Redis

## 认证与菜单链路

- 新认证接口：`/auth/login`、`/auth/register`、`/auth/me`、`/auth/switch-role`
- 旧 admin 运行时仍依赖：`/user/login`、`/user/info?token=...`
- JWT 校验：`src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`
- 白名单与跨域：`src/main/java/com/lf/config/MyWebConfig.java`
- 菜单来源：`MenuServiceImpl.getMenuListByUserId()` -> `x_menu` / `x_role_menu` / `x_user_role`
- 前端 token 走 `X-Token` 请求头，但 `/user/info` 仍是 query 参数 `token` 的兼容接口

## 关键控制器与表

- 认证 / 用户 / 菜单：`AuthController`、`UserController`、`MenuController`
- admin 能力：`AdminDashboardController`、`SysReportController`
- 内容与交易：`SysHuagaoController`、`SysZuopinController`、`SysOrderController`
- 配套能力：`OSSController`、`AliPayController`、`AliAiController`
- 权限表：`x_user`、`x_role`、`x_menu`、`x_user_role`、`x_role_menu`
- 业务表：`sys_huagao`、`sys_zuopin`、`sys_order`、`sys_report`、`sys_liuyan`、`sys_fenlei`、`sys_lunbo`
- 推荐表：`rec_huagao_model_version`、`rec_huagao_user_recommendation`、`rec_huagao_request_log`、`rec_huagao_impression_log`、`rec_huagao_action_log`

## 敏感配置提醒

- `src/main/resources/application.properties` 与本地覆写文件包含数据库、JWT、支付宝、DashScope、邮件、文件存储配置。
- 不要把真实密钥、支付参数、邮箱凭据、文件落盘路径写进文档、日志、截图或提交。
- 结构变更前先核对 `artistsion-admin/sql` 和根目录 `artistsion.sql` 是否需要同步。

## 改动后端时必须联查的层次

- 常规业务：`controller -> service/impl -> entity -> resources/mapper`
- 认证 / 权限：再加看 `MyWebConfig`、`JwtValidateInterceptor`、`UserServiceImpl`、`MenuServiceImpl`
- 菜单 / 角色：再加看 `x_menu`、`x_role_menu`、`x_user_role`，并联查前端 `permission.js`
- 列表筛选 / 返回结构：再加看对应前端 `src/api/*.js` 和页面是否依赖 `{ code: 20000, data: { total, rows } }`
