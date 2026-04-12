# Artistsion Web Guide

## Stack

- Vue 2
- Vue Router
- Vuex
- Element UI
- Axios
- WangEditor

## Dev Basics

- Dev server port: `8888`
- Dev API base: `http://localhost:9999`
- Config files:
  - `.env.development`
  - `.env.production`
  - `vue.config.js`
  - `src/settings.js`

Typical commands:

```powershell
npm install
npm run dev
npm run build:prod
npm run test:unit
```

## Routing Model

- Static/public routes live in `src/router/index.js`
- Permission logic and dynamic route injection live in `src/permission.js`
- Logged-in menus are returned by backend `/user/info` and converted into route components with:

```js
require(`@/views/${menu.component}.vue`).default
```

This means:

- Backend menu `component` strings must match actual files under `src/views`
- Route/menu bugs are often data issues in `x_menu`, not only frontend code issues

## Main Frontend Areas

### Public-facing pages

- `src/views/AboutView.vue`: landing page shell
- `src/views/about/the-index.vue`: homepage data assembly
- `src/views/about/the-list.vue`: listing page
- `src/views/about/detail.vue`
- `src/views/about/details.vue`
- `src/views/about/the-community.vue`

### Auth

- `src/views/login/index.vue`
- `src/views/login/register.vue`
- API: `src/api/user.js`

### User center

- `src/views/userinfo/index.vue`: profile center
- `src/views/userinfo/fabusp.vue`: publish/edit own showcase or listing-related content
- `src/views/userinfo/myfenxiang.vue`
- `src/views/userinfo/liaotian.vue`

### Seller / artwork management

- `src/views/shangp/shangp.vue`
- `src/views/shangp/shangpsh.vue`
- `src/views/shangp/spsxj.vue`
- API: `src/api/huagao.js`

### Orders

- `src/views/order/gouwuche.vue`
- `src/views/order/ordergl.vue`
- `src/views/order/orderadgl.vue`
- `src/views/order/orderadglqb.vue`
- API: `src/api/order.js`

### System admin

- `src/views/sys/user.vue`
- `src/views/sys/role.vue`
- `src/views/sys/route.vue`
- APIs:
  - `src/api/userManage.js`
  - `src/api/roleManage.js`
  - `src/api/menuManage.js`

### Recommendation / AI / content extras

- `src/api/tuijian.js`: personalized recommendation requests
- `src/views/ai/ai.vue`: AI-related UI
- `src/api/fenxiang.js`: showcase/share posts (`sysZuopin`)
- `src/api/liuyan.js`, `src/api/pinglun.js`, `src/api/shoucang.js`

## Important Behavior Notes

- The homepage uses newest items for guests, but tries personalized recommendations for logged-in users.
- Many list pages expect backend responses shaped like:

```json
{ "code": 20000, "data": { "total": 0, "rows": [] } }
```

- A lot of upload and download URLs are hardcoded to `http://localhost:9999/oss/file/...` inside views, not only centralized in config.
- The project mixes public pages, personal-center pages, and admin pages inside one frontend app.

## Editing Guidance

- Before editing a view, check its paired API file under `src/api`.
- Before editing login/menu behavior, check:
  - `src/store/modules/user.js`
  - `src/permission.js`
  - `src/router/index.js`
- Broad refactors, component splits, route cleanup, and structural frontend changes are acceptable when the task calls for them. Avoid noise-only formatting churn, but do not feel constrained to keep changes artificially small.
- Do not replace project behavior with upstream `vue-admin-template` assumptions.
