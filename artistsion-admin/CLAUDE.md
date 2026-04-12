# Artistsion Admin Guide

## Stack

- Spring Boot `2.7.13`
- MyBatis-Plus
- MySQL
- Redis
- JWT
- Swagger / Springfox
- Alipay SDK
- DashScope SDK

## Run Basics

- Port: `9999`
- Main class: `src/main/java/com/lf/XAdminApplication.java`

Typical command on Windows:

```powershell
.\mvnw.cmd spring-boot:run
```

## Configuration

Primary config file:

- `src/main/resources/application.properties`

Important local dependencies:

- MySQL database: `artistsion`
- Redis: local default connection
- Local file storage path is configured in properties

Security note:

- `application.properties` currently contains database credentials, payment keys, and AI keys.
- Treat these as sensitive. Do not echo them into new docs, logs, screenshots, or commits unless the user explicitly asks.

## Project Structure

- `controller`: HTTP endpoints
- `service` / `service/impl`: business logic
- `dao`: MyBatis-Plus mapper interfaces
- `entity`: table mappings
- `resources/mapper`: mapper XML
- `config`: web, CORS, Redis, Swagger, Alipay, AI, MyBatis config
- `interceptor`: JWT validation

## Auth And Menu Flow

- Login endpoint: `/user/login`
- User info endpoint: `/user/info`
- Token validation: `src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`
- Interceptor registration / whitelist: `src/main/java/com/lf/config/MyWebConfig.java`
- Frontend menus come from `MenuService.getMenuListByUserId(...)`
- Menu data is stored in `x_menu` and filtered through user roles

Important detail:

- Frontend sends token in `X-Token`
- `/user/info` still expects a `token` query param and parses user data directly from JWT

## High-Value Controllers

- `UserController`: login, register, user CRUD, profile update
- `SysHuagaoController`: commission listing CRUD and homepage/recommendation listing
- `SysZuopinController`: showcase/share post CRUD
- `SysOrderController`: order CRUD
- `OSSController`: upload/download endpoints
- `AliPayController`: Alipay payment request
- `AliAiController`: DashScope / Tongyi Qianwen integration
- `UserArticleOperationController`: recommendation behavior and recommendation results

## Common Response And Query Patterns

- Success wrapper: `Result.success(...)`
- Success code: `20000`
- Many paginated list endpoints return:
  - `data.total`
  - `data.rows`
- Controllers often use `LambdaQueryWrapper` + `Page`
- A lot of CRUD endpoints are simple `save`, `updateById`, `removeById` flows

## Main Tables

- `sys_huagao`
- `sys_zuopin`
- `sys_order`
- `sys_fenlei`
- `sys_lunbo`
- `sys_pinglun`
- `sys_shoucang`
- `sys_liuyan`
- `sys_liuyans`
- `user_article_operation`
- `x_user`
- `x_role`
- `x_menu`
- `x_user_role`
- `x_role_menu`

Schema bootstrap:

- Root file `artistsion.sql`
- Additional SQL patch: `sql/2026-04-06-fix-user-username-unique.sql`

## Editing Guidance

- For backend behavior changes, inspect controller + service impl + entity + mapper XML together.
- Do not assume all validation lives in controllers. Some important checks are in service impls, for example username uniqueness in `UserServiceImpl`.
- Some strings/comments may render as mojibake in terminal output. Avoid mass re-encoding unless that is the task.
- Existing endpoint contracts are tightly coupled to the frontend, so check consumers carefully. Contract changes and backend restructures are allowed when intentional, but they should be completed end-to-end instead of half-migrated.
