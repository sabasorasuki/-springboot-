import Vue from 'vue'
import Router from 'vue-router'
import { buildCenterProfileRoute, getPersistedDisplayMode } from '@/utils/centerProfile'

Vue.use(Router)

function buildSelfCenterRedirect(tab, sub, mode = getPersistedDisplayMode()) {
  return buildCenterProfileRoute({
    isSelf: true,
    viewMode: mode,
    tab,
    sub
  })
}

/* Layout */
import Layout from '@/layout'
import MainLayout from '@/layout/MainLayout'

/**
 * Note: sub-menu only appear when route children.length >= 1
 * Detail see: https://panjiachen.github.io/vue-element-admin-site/guide/essentials/router-and-nav.html
 *
 * hidden: true                   if set true, item will not show in the sidebar(default is false)
 * alwaysShow: true               if set true, will always show the root menu
 *                                if not set alwaysShow, when item has more than one children route,
 *                                it will becomes nested mode, otherwise not show the root menu
 * redirect: noRedirect           if set noRedirect will no redirect in the breadcrumb
 * name:'router-name'             the name is used by <keep-alive> (must set!!!)
 * meta : {
    roles: ['admin','editor']    control the page roles (you can set multiple roles)
    title: 'title'               the name show in sidebar and breadcrumb (recommend set)
    icon: 'svg-name'/'el-icon-x' the icon show in the sidebar
    breadcrumb: false            if set false, the item will hidden in breadcrumb(default is true)
    activeMenu: '/example/list'  if set path, the sidebar will highlight the path you set
  }
 */

/**
 * constantRoutes
 * a base page that does not have permission requirements
 * all roles can be accessed
 */
export const constantRoutes = [
  {
    path: '/auth',
    component: () => import('@/views/auth/index'),
    hidden: true
  },
  {
    path: '/admin',
    redirect: '/dashboard',
    hidden: true
  },
  {
    path: '/admin/*',
    component: Layout,
    hidden: true
  },
  {
    path: '/404',
    component: () => import('@/views/404'),
    hidden: true
  },
  // ── 新前台站路由（使用 MainLayout） ──
  {
    path: '/home',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/home/index'),
        meta: { title: '首页' }
      }
    ]
  },
  {
    path: '/artists',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'Artists',
        component: () => import('@/views/artists/index'),
        meta: { title: '画师' }
      }
    ]
  },
  {
    path: '/projects',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'Projects',
        component: () => import('@/views/projects/index'),
        meta: { title: '企划' }
      }
    ]
  },
  {
    path: '/works',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'Works',
        component: () => import('@/views/works/index'),
        meta: { title: '作品' }
      }
    ]
  },
  {
    path: '/showcase',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'Showcase',
        component: () => import('@/views/showcase/index'),
        meta: { title: '橱窗' }
      }
    ]
  },
  // ── 发布页（MainLayout） ──
  {
    path: '/publish',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: 'work',
        name: 'PublishWork',
        component: () => import('@/views/publish/work'),
        meta: { title: '投稿发布' }
      },
      {
        path: 'project',
        name: 'PublishProject',
        component: () => import('@/views/publish/project'),
        meta: { title: '发布企划' }
      }
    ]
  },
  // ── 详情页 & 个人中心（MainLayout） ──
  {
    path: '/work/:id',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'WorkDetail',
        component: () => import('@/views/work/detail'),
        meta: { title: '作品详情' }
      }
    ]
  },
  {
    path: '/artist/:id',
    redirect: to => buildCenterProfileRoute({
      isSelf: false,
      userId: Number(to.params.id),
      viewMode: to.query.view,
      tab: to.query.tab,
      sub: to.query.sub
    }),
    hidden: true
  },
  {
    path: '/project/:id',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'ProjectDetail',
        component: () => import('@/views/projects/detail'),
        meta: { title: '企划详情' }
      }
    ]
  },
  {
    path: '/post/:id',
    component: MainLayout,
    hidden: true,
    children: [
      {
        path: '',
        name: 'PostDetail',
        component: () => import('@/views/posts/detail'),
        meta: { title: '帖子详情' }
      }
    ]
  },
  {
    path: '/center',
    component: MainLayout,
    redirect: () => buildSelfCenterRedirect(),
    hidden: true,
    children: [
      {
        path: 'profile/:id?',
        name: 'CenterProfile',
        component: () => import('@/views/center/profile'),
        meta: { title: '个人中心' }
      },
      {
        path: 'orders',
        redirect: () => buildSelfCenterRedirect('orders'),
        meta: { title: '我的订单' }
      },
      {
        path: 'submissions',
        redirect: () => buildSelfCenterRedirect('submissions', 'works', 'artist'),
        meta: { title: '投稿管理' }
      },
      {
        path: 'favorites',
        redirect: () => buildSelfCenterRedirect('favorites', getPersistedDisplayMode() === 'artist' ? 'projects' : 'works'),
        meta: { title: '我的收藏' }
      },
      {
        path: 'cart',
        redirect: () => buildSelfCenterRedirect('cart', '', 'client'),
        meta: { title: '购物车' }
      },
      {
        path: 'projects',
        redirect: () => buildSelfCenterRedirect('projects', '', 'client'),
        meta: { title: '我的企划' }
      },
      {
        path: 'follows',
        name: 'CenterFollows',
        component: () => import('@/views/center/follows'),
        meta: { title: '关注' }
      }
    ]
  },
  // ── 旧后台管理路由（保留原 Layout） ──
  {
    path: '/',
    component: Layout,
    redirect: '/home',
    children: [{
      // admin 过渡版首页：当前已改造成管理看板，继续作为 /admin 的默认落点。
      path: 'dashboard',
      name: 'Dashboard',
      component: () => import('@/views/dashboard/index'),
      meta: { title: '控制台', icon: 'dashboard', affix: true, noCache: false }
    },
    // 兼容保留：以下隐藏路由本质上是旧用户自助页，后续会迁出 admin 侧信息架构。
    {
      path: '/userinfo',
      name: 'AdminProfile',
      component: () => import('@/views/userinfo/index'),
      meta: { title: '管理员账号设置' },
      hidden: true
    },
    {
      path: '/fabusp',
      name: 'fabusp',
      component: () => import('@/views/userinfo/fabusp'),
      hidden: true
    }, {
      path: '/myfenxiang',
      name: 'myfenxiang',
      component: () => import('@/views/userinfo/myfenxiang'),
      hidden: true
    },
    {
      path: '/liaotian',
      name: 'liaotian',
      component: () => import('@/views/userinfo/liaotian'),
      hidden: true
    }

    ]
  }
]

const createRouter = () => new Router({
  // mode: 'history', // require service support
  scrollBehavior: () => ({ y: 0 }),
  routes: constantRoutes
})

const router = createRouter()

// Detail see: https://github.com/vuejs/vue-router/issues/1234#issuecomment-357941465
export function resetRouter() {
  const newRouter = createRouter()
  router.matcher = newRouter.matcher // reset router
}

export default router
