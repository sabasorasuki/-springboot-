# 会话交接摘要

## 当前所处阶段

阶段 1 ✅ → 阶段 2 ✅ → 阶段 3 ✅ → 阶段 4 ✅ → **阶段 5A ✅ 已完成**，准备进入阶段 5B。

---

## 阶段 5A 已完成内容

### 后端

- `UserController.java` 新增 `GET /user/artist/{id}`：单画师详情，返回 `ArtistVO` 安全投影，校验画师角色 + 启用状态

### 前端路由

- 新增 5 条 MainLayout 路由：`/work/:id`、`/artist/:id`、`/project/:id`、`/center/profile`、`/center/orders`

### 新页面

| 页面 | 数据来源 | 状态 |
|---|---|---|
| `work/detail.vue` | `huagao.getById`（真实） | 完整 |
| `artists/detail.vue` | `artist.getById` + `huagao.getList` by shangjiaids（真实） | 完整 |
| `projects/detail.vue` | 前端 mockProjects（待后端建表替换） | Mock |
| `center/profile.vue` | `/user/info` + `updateMyUser`（真实） | 完整 |
| `center/orders.vue` | 骨架占位 | 骨架 |

### 接线

- 首页/画师/企划列表卡片点击 → 跳转对应详情页
- MainLayout 头像菜单 → `/center/profile`、`/center/orders`
- Store 新增 `userId` 状态（从 `getInfo` 的 `data.userList.id` 提取）

### 已知技术债

1. **`ARTIST_ROLE_ID = 7` 硬编码** — `/user/artists` 和 `/user/artist/{id}` 均写死画师角色 ID，应改为查库
2. **画师无 bio/style 字段** — User 表缺失，画师详情页暂无简介区
3. **作品详情缺画师昵称** — 仅有 `shangjiaids`，未关联查出画师名称

---

## 阶段 4 已完成内容

### 后端

- `MyWebConfig.java` 白名单补充 `/sysHuagao/tuijianlist`、`/user/artists`
- `UserController.java` 新增 `/user/artists` 端点：
  - 按画师角色(roleId=7)从 `x_user_role` 筛选用户
  - 分页查询，只返回安全字段（`ArtistVO`：id/username/name/avatar/status/workCount/recentCovers）
  - 批量聚合每个画师的上架+审核成功画稿数量和最近 3 张封面
- 新建 `vo/ArtistVO.java`

### 前端

- `/home`：轮播（`/sysLunbo/list`）+ 推荐/最新（推荐链路或 `getzuixin` 降级）+ 分类标签（`/sysFenlei/list`）+ 全部作品分页
- `/artists`：画师卡片（`/user/artists`）+ 分类筛选 + 缩略图画廊 + 分页
- `/projects`：6 条 mock 数据 + 分类筛选 + 按目标 `sys_project` schema 结构化
- 新建 `api/artist.js`

---

## 已知过渡态（需后续阶段处理）

| 项目 | 说明 | 预计阶段 | 5A 进展 |
|---|---|---|---|
| 角色切换弹框 | `$confirm` 仅适配双角色，≥3 角色需改为可选列表 | 5B/6 | — |
| ~~个人中心/订单中心~~ | ~~仍跳旧页面~~ | ~~5~~ | ✅ 已改为 `/center/profile`、`/center/orders` |
| 画师简介/风格标签 | User 表无 bio/style 字段 | 5B | 5A 暂未处理 |
| ~~作品/画师详情页~~ | ~~点击卡片仅弹 toast~~ | ~~5~~ | ✅ 跳转详情页已接通 |
| 企划后端 | 无 `sys_project` 表，纯前端 mock | 5B | 5A 企划详情用 mock |
| `ARTIST_ROLE_ID = 7` 硬编码 | `/user/artists` 和 `/user/artist/{id}` 均写死 | 5B/6 | 5A 新增端点继续沿用 |
| 订单前台查询 | `/center/orders` 目前为骨架页 | 5B | 5A 仅放占位 |
| 作品详情缺画师昵称 | `SysHuagao.shangjiaids` 未关联查画师名 | 5B | 5A 以"查看画师主页"链接代替 |

---

## 下一步：阶段 5B — 后端数据扩展

### 候选任务

1. **企划后端** — 建 `sys_project` 表 + Entity/Service/Controller，替换前端 mock
2. **用户资料扩展** — User 表补 bio/style 字段，画师详情页/卡片展示真实数据
3. **订单前台查询** — 新前台订单列表接口，接入 `/center/orders`
4. **旧页面替换** — 逐步将旧后台个人中心/发布/分享页迁移到新前台路由下
5. **`ARTIST_ROLE_ID` 去硬编码** — 统一改为按角色名查库

### 需要注意

- 企划表建表时参考 `projects/index.vue` 注释中的目标 schema
- 个人中心后续字段扩展需同步 `center/profile.vue` 表单
- 订单前台接口需考虑按当前用户过滤（`userId` 已在 store 中可用）

---

## 参考文档

- `CLAUDE.md` — 仓库总览
- `artistsion-web/CLAUDE.md` — 前端指引
- `artistsion-admin/CLAUDE.md` — 后端指引
- `docs/PROJECT_MAP.md` — 业务映射
- `docs/REFACTOR_PROGRESS.md` — 长期进度
- `docs/FRONTEND_STYLE_SPEC.md` — 前端样式规范
