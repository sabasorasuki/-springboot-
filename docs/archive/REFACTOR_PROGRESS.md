# 重构里程碑摘要

## 已完成阶段结论

- 阶段 1 到 5：新主站路由、首页 / 画师 / 企划、详情页、个人中心与订单基础能力已落地。
- 阶段 6：统一认证入口为 `/auth`，删除旧前台与旧登录页主路径；`/admin` 成为控制台统一入口；OSS URL 集中化；若干关键链路补洞完成。
- 阶段 7 到 8：admin 菜单收敛完成，`dashboard` 改造成管理看板，`GET /adminDashboard/summary` 落地，非 admin 访问边界已加固。
- 阶段 9 到 10：`sys_report`、`/sysReport/*`、`src/views/report/index.vue`、`src/components/ReportDialog` 落地，前台举报到 admin 处理形成闭环。

## 仍然成立的结论

- admin 当前是“在旧菜单链路上做前端收敛”的过渡控制台，还不是完全独立的新后台。
- `/user/info` + `menuList` + 动态 `require()` 仍是最敏感的高耦合链路。
- 隐藏兼容页 `/userinfo`、`/fabusp`、`/myfenxiang`、`/liaotian` 仍在，后续应继续收口。
- 生产部署前必须替换 JWT、支付、AI、邮件等默认或测试密钥。

## 现在应看哪里

- 当前动态状态：`docs/SESSION_HANDOFF.md`
- 当前静态结构：`docs/PROJECT_MAP.md`
