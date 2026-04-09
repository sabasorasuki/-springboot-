# Artistsion Repository Guide

## Project Identity

This repository is a painter commission marketplace / art trading site.

- Frontend app: `artistsion-web`
- Backend app: `artistsion-admin`
- Database dump: `artistsion.sql`
- Payment integration notes: repo-root markdown notes under the Alipay integration folder

This is not a clean scaffold anymore. The frontend started from `vue-admin-template`, but the real business logic now lives in the local `src/views`, `src/api`, backend controllers, and SQL schema.

## What Claude Should Read First

- For frontend work, read `artistsion-web/CLAUDE.md`
- For backend work, read `artistsion-admin/CLAUDE.md`
- For business/domain mapping, read `docs/PROJECT_MAP.md`

## Local Run Setup

### Backend

- App: Spring Boot
- Port: `9999`
- Main class: `artistsion-admin/src/main/java/com/lf/XAdminApplication.java`
- Typical command on Windows:

```powershell
cd artistsion-admin
.\mvnw.cmd spring-boot:run
```

### Frontend

- App: Vue 2 + Element UI
- Dev port: `8888`
- Dev API base: `http://localhost:9999`
- Typical command:

```powershell
cd artistsion-web
npm install
npm run dev
```

### Data dependencies

- MySQL database name: `artistsion`
- Redis is expected locally
- SQL bootstrap file: `artistsion.sql`

## Core Business Modules

- `sys_huagao`: commission listings / art product listings
- `sys_zuopin`: showcase posts / artist sharing posts
- `sys_order`: orders and payment-related records
- `sys_fenlei`: categories
- `sys_lunbo`: homepage carousel
- `sys_pinglun`: comments
- `sys_shoucang`: favorites / collections
- `sys_liuyan` and `sys_liuyans`: message-like modules
- `user_article_operation`: recommendation behavior data
- `x_user`, `x_role`, `x_menu`, `x_user_role`, `x_role_menu`: auth and menu permissions

## Important Architecture Notes

- Frontend routing is partly dynamic. Initial public routes are in `artistsion-web/src/router/index.js`, but logged-in menu routes come from backend `x_menu` data and are injected in `artistsion-web/src/permission.js`.
- Backend responses use a shared wrapper `Result`, with success code `20000`.
- Login uses JWT. Frontend sends token via `X-Token`.
- Some public pages are accessible without login, but most management/user-center pages depend on token + backend menus.

## Things That Are Easy To Get Wrong

- The subproject `README.md` files are mostly upstream template docs, not reliable project documentation.
- `artistsion-admin/src/main/resources/application.properties` contains real local secrets and keys. Do not copy them into docs, logs, issues, or commits unless the user explicitly asks.
- Some Chinese text/comments appear garbled in terminal output because of encoding display issues. Do not mass-rewrite strings/comments just to "fix" mojibake unless the task is explicitly about encoding.
- The git worktree may already be dirty. Be careful not to overwrite unrelated user changes.

## Preferred Working Style In This Repo

- When changing frontend business pages, trace the matching API file in `artistsion-web/src/api` first.
- When changing backend behavior, check the controller, service impl, entity, and corresponding mapper XML together.
- When changing menus or permissions, inspect both frontend dynamic routing and the `x_menu` / role tables.
- When changing order, payment, upload, or AI features, review existing hardcoded URLs and config usage before refactoring.
