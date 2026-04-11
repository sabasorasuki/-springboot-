# Copilot Instructions

## Purpose

This file gives Copilot and similar coding assistants enough repository context to work effectively in this project without over-constraining future changes.

The project may undergo significant refactors. Favor understanding the current architecture first, then choose the level of change that best matches the task. Large restructures, module extraction, cleanup, and contract adjustments are allowed when they are intentional and carried through consistently.

## Project Snapshot

- Repository type: full-stack graduation project
- Domain: painter commission / art marketplace / showcase platform
- Frontend app: `artistsion-web`
- Backend app: `artistsion-admin`
- Database bootstrap: `artistsion.sql`

### Frontend

- Stack: Vue 2, Vue Router, Vuex, Element UI, Axios, WangEditor, ECharts
- Dev port: `8888`
- App shape: one large SPA containing public pages, user-center pages, and admin/management pages

### Backend

- Stack: Spring Boot 2.7.13, MyBatis-Plus, MySQL, Redis, JWT, Swagger/Springfox
- Extra integrations: Alipay SDK, DashScope SDK, Mahout-based recommendation logic
- Dev port: `9999`

## Read First

When starting a task, read the smallest set of files that gives you real context:

- Root overview: `CLAUDE.md`
- Business/domain map: `docs/PROJECT_MAP.md`
- Frontend-specific guide: `artistsion-web/CLAUDE.md`
- Backend-specific guide: `artistsion-admin/CLAUDE.md`

Then trace from the feature entrypoint:

- Frontend changes: target page in `artistsion-web/src/views` and its paired API file in `artistsion-web/src/api`
- Backend changes: controller -> service impl -> entity -> mapper XML

## Run / Build / Test Commands

### Backend (`artistsion-admin`)

- Run dev:
  - `cd artistsion-admin`
  - `.\mvnw.cmd spring-boot:run`
- Build:
  - `cd artistsion-admin`
  - `.\mvnw.cmd clean package`
- Run all tests:
  - `cd artistsion-admin`
  - `.\mvnw.cmd test`
- Run one test:
  - `.\mvnw.cmd -Dtest=FullyQualifiedTestClassName#methodName test`

### Frontend (`artistsion-web`)

- Install:
  - `cd artistsion-web`
  - `npm install`
- Run dev:
  - `cd artistsion-web`
  - `npm run dev`
- Build production:
  - `cd artistsion-web`
  - `npm run build:prod`
- Lint:
  - `cd artistsion-web`
  - `npm run lint`
- Run unit tests:
  - `cd artistsion-web`
  - `npm run test:unit`
- Run one unit test:
  - `npm run test:unit -- -t "pattern"`
  - `npx jest tests/unit/utils/parseTime.spec.js -t "pattern"`

## Architecture Notes

### High-level layout

There are two main applications in one repository:

- `artistsion-web`: Vue 2 SPA
- `artistsion-admin`: Spring Boot backend

The frontend started from a template, but the repository is no longer a template project. Actual business behavior lives in local views, APIs, backend controllers, SQL schema, and menu data.

### Core business modules

- `sys_huagao`: commission listings / art products / available slots
- `sys_zuopin`: showcase posts / community sharing posts
- `sys_order`: orders, cart-like records, payment-related data
- `sys_fenlei`: categories
- `sys_lunbo`: homepage carousel
- `sys_pinglun`: comments
- `sys_shoucang`: favorites / collections
- `sys_liuyan` and `sys_liuyans`: message-like modules
- `user_article_operation`: user behavior for recommendations
- `x_user`, `x_role`, `x_menu`, `x_user_role`, `x_role_menu`: auth and menu permissions

### Frontend routing model

Frontend routing is split into:

- Static/public routes in `artistsion-web/src/router/index.js`
- Logged-in dynamic routes injected in `artistsion-web/src/permission.js`

After login:

1. frontend requests `/user/info`
2. backend returns `menuList`
3. frontend maps each `menu.component` to `@/views/${menu.component}.vue`
4. routes are injected dynamically

This means many route/menu failures come from menu data in `x_menu`, not only from frontend code.

### Auth model

- Login endpoint: `/user/login`
- User info endpoint: `/user/info`
- Frontend sends token with header `X-Token`
- Backend JWT validation lives in `JwtValidateInterceptor`
- Interceptor whitelist lives in `MyWebConfig`

Important detail:

- `/user/info` is currently excluded from interceptor validation, but still expects a `token` query param and parses user info from it

### Response shape

Most backend endpoints use a shared `Result` wrapper.

Common success response:

```json
{
  "code": 20000,
  "message": "success",
  "data": {}
}
```

Common paginated response:

```json
{
  "code": 20000,
  "data": {
    "total": 0,
    "rows": []
  }
}
```

## Working Style Guidance

Use these as defaults, not hard walls:

- Match the scope of the solution to the task.
- Small bugfixes can stay local.
- Medium changes can cross frontend/backend layers when needed.
- Large refactors are acceptable if they clearly improve maintainability or unblock future work.
- If changing architecture or contracts, make the change end-to-end instead of leaving half-migrated behavior behind.

Prefer practical improvements over strict preservation of legacy structure. For example, it is fine to:

- extract duplicated logic
- rename misleading modules
- centralize hardcoded URLs or config
- split oversized components
- introduce clearer service boundaries
- improve request/response contracts when all consumers are updated
- replace brittle template leftovers with repository-specific code

## Repository-Specific Realities

- The frontend mixes public site pages, personal-center pages, and admin pages in one app.
- Many upload/download URLs are hardcoded to `http://localhost:9999/oss/file/...` in views, not just in shared config.
- Frontend and backend are tightly coupled on field names and response shapes.
- `src/api` contains some template leftovers or semi-unused methods; do not assume every frontend method has a valid backend counterpart.
- Menu-driven routing depends on database data being correct.
- Some Chinese text/comments may display as mojibake in certain terminals; do not do broad encoding rewrites unless the task is specifically about encoding cleanup.

## Minimal Guardrails

Keep these in mind even during large changes:

- Do not expose or copy secrets from `artistsion-admin/src/main/resources/application.properties`.
- When changing API contracts, update both backend producers and frontend consumers.
- When changing routes or menu pages, account for the `x_menu.component` to Vue file-path mapping.
- When changing upload behavior, search for hardcoded upload/download URLs across views.
- When changing auth behavior, inspect both frontend token handling and backend interceptor/whitelist logic.
- When changing order, payment, AI, or recommendation flows, trace both UI and backend controller/service behavior before refactoring.

## Good Starting Points By Task Type

### Frontend page or UI work

- Open the target file in `artistsion-web/src/views`
- Open the paired API module in `artistsion-web/src/api`
- Check whether the page depends on:
  - login state
  - dynamic menus
  - hardcoded file URLs
  - backend-specific response fields

### Backend business logic work

- Open the controller first
- Trace into service impl
- Check entity fields
- Check mapper XML or mapper interface behavior
- Verify that the response shape still matches frontend expectations

### Auth / permission / menu work

- `artistsion-web/src/permission.js`
- `artistsion-web/src/router/index.js`
- `artistsion-web/src/store/modules/user.js`
- `artistsion-admin/src/main/java/com/lf/config/MyWebConfig.java`
- `artistsion-admin/src/main/java/com/lf/interceptor/JwtValidateInterceptor.java`
- `artistsion-admin/src/main/java/com/lf/service/impl/UserServiceImpl.java`
- `artistsion-admin/src/main/java/com/lf/service/impl/MenuServiceImpl.java`

### Homepage / listing / recommendation work

- `artistsion-web/src/views/about/the-index.vue`
- `artistsion-web/src/api/huagao.js`
- `artistsion-web/src/api/tuijian.js`
- `artistsion-admin/src/main/java/com/lf/controller/SysHuagaoController.java`
- `artistsion-admin/src/main/java/com/lf/controller/UserArticleOperationController.java`
- `artistsion-admin/src/main/java/com/lf/service/impl/UserArticleOperationServiceImpl.java`

### Order / payment work

- `artistsion-web/src/views/order/*`
- `artistsion-web/src/api/order.js`
- `artistsion-admin/src/main/java/com/lf/controller/SysOrderController.java`
- `artistsion-admin/src/main/java/com/lf/controller/AliPayController.java`

## Refactor-Friendly Defaults

If the task appears to be part of a bigger modernization effort, prefer changes that move the codebase toward:

- clearer module boundaries
- less hardcoded environment knowledge
- fewer duplicated API wrappers
- more centralized configuration
- smaller and more focused Vue components
- cleaner backend service responsibilities
- better separation between public pages and admin behavior

When making large changes, leave the repository in a coherent state:

- remove or update obsolete references
- keep imports and file paths aligned
- update both route definitions and menu assumptions where needed
- avoid preserving dead compatibility layers unless they are explicitly needed

## Quick Bug Checklist

- Route/menu issue:
  - check `x_menu.component`
  - check `src/permission.js`
  - check that the target `.vue` file actually exists
- Auth issue:
  - check `X-Token`
  - check `/user/info`
  - check interceptor whitelist
- Data rendering issue:
  - check controller response shape
  - check frontend API wrapper
  - check expected field names
- Upload issue:
  - check `OSSController`
  - check hardcoded frontend URLs

## Final Note

These instructions are meant to accelerate understanding, not to block change. Preserve what is useful, but do not hesitate to redesign parts of the system when the task calls for it and the change is completed consistently.
