# Artistsion Project Map

## 1. Product Summary

Artistsion is a painter commission / art trading platform. One repository contains both the user-facing site and admin-style management functions.

The system combines:

- Public browsing pages
- User registration and login
- Personal center
- Artist/painter listing publication
- Order management and payment
- Favorites, comments, and message-like interactions
- Recommendation logic based on user behavior
- Simple AI chat/helper capability

## 2. Repository Map

### Root

- `artistsion-web`: Vue frontend
- `artistsion-admin`: Spring Boot backend
- `artistsion.sql`: main database dump
- repo-root Alipay integration notes folder: payment integration reference material

### Frontend key paths

- `artistsion-web/src/api`: API wrappers
- `artistsion-web/src/views`: business pages
- `artistsion-web/src/store`: Vuex state
- `artistsion-web/src/router/index.js`: static routes
- `artistsion-web/src/permission.js`: auth + dynamic route injection

### Backend key paths

- `artistsion-admin/src/main/java/com/lf/controller`
- `artistsion-admin/src/main/java/com/lf/service`
- `artistsion-admin/src/main/java/com/lf/service/impl`
- `artistsion-admin/src/main/java/com/lf/entity`
- `artistsion-admin/src/main/resources/mapper`

## 3. Business Model To Code Mapping

### Users and roles

- Table: `x_user`
- Role tables: `x_role`, `x_user_role`, `x_role_menu`
- Menu table: `x_menu`
- Backend:
  - `controller/UserController.java`
  - `service/impl/UserServiceImpl.java`
  - `service/impl/MenuServiceImpl.java`
- Frontend:
  - `src/api/user.js`
  - `src/store/modules/user.js`
  - `src/views/login/*`
  - `src/views/sys/user.vue`
  - `src/views/sys/role.vue`
  - `src/views/sys/route.vue`

### Commission listings / tradable art items

- Main table: `sys_huagao`
- Meaning: artwork/commission slots/products that can be listed, reviewed, recommended, ordered
- Backend:
  - `controller/SysHuagaoController.java`
  - `entity/SysHuagao.java`
- Frontend:
  - `src/api/huagao.js`
  - `src/views/shangp/*`
  - homepage sections in `src/views/about/the-index.vue`

Likely important fields:

- `name`
- `photo`
- `price`
- `fenlei`
- `content`
- `zhekou`
- `type`
- `shangjiaids`
- `status`

### Showcase posts / artist sharing posts

- Main table: `sys_zuopin`
- Meaning: artist posts or showcase content displayed in community/share sections
- Backend:
  - `controller/SysZuopinController.java`
  - `entity/SysZuopin.java`
- Frontend:
  - `src/api/fenxiang.js`
  - `src/views/fenxiang/*`
  - `src/views/userinfo/myfenxiang.vue`

Likely important fields:

- `title`
- `photo`
- `fbdate`
- `userids`
- `username`
- `content`
- `dznum`
- `fenlei`

### Orders and payment

- Main table: `sys_order`
- Backend:
  - `controller/SysOrderController.java`
  - `controller/AliPayController.java`
  - `entity/SysOrder.java`
- Frontend:
  - `src/api/order.js`
  - `src/views/order/*`
  - `src/views/userinfo/liaotian.vue` also touches order/chat-related flows

Likely important fields:

- `name`
- `photo`
- `price`
- `userids`
- `username`
- `phone`
- `address`
- `xddate`
- `rydate`
- `status`
- `ryfs`
- `spids`
- `shangjiaids`

### Recommendations

- Table: `user_article_operation`
- Meaning: stores user-item interaction data for recommendation
- Backend:
  - `controller/UserArticleOperationController.java`
  - `service/impl/UserArticleOperationServiceImpl.java`
- Frontend:
  - `src/api/tuijian.js`
  - homepage recommendation logic in `src/views/about/the-index.vue`

### AI helper

- Backend:
  - `controller/AliAiController.java`
- Frontend:
  - `src/views/ai/ai.vue`
  - `src/api/huagao.js` currently contains `aliTyqw(...)`

### Uploads

- Backend:
  - `controller/OSSController.java`
- Frontend:
  - several views hardcode upload/download URLs to `http://localhost:9999/oss/file/...`

### Supporting content

- `sys_fenlei`: categories
- `sys_lunbo`: carousel data
- `sys_pinglun`: comments
- `sys_shoucang`: favorites
- `sys_liuyan` / `sys_liuyans`: message-related content
- `sys_rizhi`: logs/statistics-related data

## 4. Frontend Route Model

There are two route sources:

### Public/static routes

Defined in `artistsion-web/src/router/index.js`, including:

- `/login`
- `/register`
- `/mas`
- `/theList`
- `/community`
- `/detail`
- `/details`
- `/dashboard`
- hidden personal routes like `/userinfo`, `/fabusp`, `/myfenxiang`, `/liaotian`

### Dynamic authenticated routes

After login:

1. frontend calls `/user/info`
2. backend returns `menuList`
3. frontend converts each menu item to a view component path
4. routes are injected with `router.addRoutes(...)`

This means route bugs may come from:

- bad menu data in DB
- bad backend menu filtering
- wrong `component` path in `x_menu`
- missing `.vue` file in `src/views`

## 5. Backend Request Model

### Response shape

Most endpoints return:

```json
{
  "code": 20000,
  "message": "success",
  "data": {}
}
```

### Pagination shape

Many list endpoints return:

```json
{
  "code": 20000,
  "data": {
    "total": 0,
    "rows": []
  }
}
```

### Auth

- login returns JWT token
- frontend stores token locally
- requests send `X-Token`
- interceptor validates most routes
- whitelist is defined in `MyWebConfig`

## 6. Local Environment Assumptions

### Frontend

- Dev port: `8888`
- Dev base API: `http://localhost:9999`

### Backend

- Port: `9999`
- MySQL db: `artistsion`
- Redis: local default host/port

## 7. Risks And Maintenance Notes

- Current tracked config contains sensitive credentials and keys. Avoid copying them around.
- Existing subproject READMEs are mostly template leftovers and should not be treated as the source of truth.
- Some legacy Chinese text/comments display incorrectly in terminal output; do not do broad encoding cleanup unless asked.
- The repo already has active uncommitted changes, so edits should stay narrowly scoped.

## 8. Recommended Claude Workflow For Future Tasks

### If the task is frontend

1. Read `artistsion-web/CLAUDE.md`
2. Open the target page in `src/views`
3. Open the paired API module in `src/api`
4. Check whether the page depends on token, menu injection, or hardcoded upload URLs

### If the task is backend

1. Read `artistsion-admin/CLAUDE.md`
2. Open the controller first
3. Trace to service impl, entity, and mapper XML
4. Verify response shape matches existing frontend expectations

### If the task touches auth or permissions

1. Check frontend `src/permission.js`
2. Check backend `MyWebConfig`, `JwtValidateInterceptor`, `UserServiceImpl`, `MenuServiceImpl`
3. Check related menu/role data assumptions in SQL tables
