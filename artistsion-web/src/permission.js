import router from './router'
import store from './store'
import { Message } from 'element-ui'
import NProgress from 'nprogress' // progress bar
import 'nprogress/nprogress.css' // progress bar style
import { getToken } from '@/utils/auth' // get token from cookie
import getPageTitle from '@/utils/get-page-title'
import Layout from '@/layout'

NProgress.configure({ showSpinner: false }) // NProgress Configuration

const whiteList = ['/auth'] // no redirect whitelist
const ADMIN_ENTRY_PATH = '/admin'
const ADMIN_ROLE_NAME = 'admin'
const ADMIN_MENU_COMPONENT_BLACKLIST = new Set([
  'order/gouwuche',
  'order/ordergl',
  'order/orderadgl',
  'shangp/shangp',
  'shangp/spsxj',
  'fenxiang/fenxiang',
  'shoucang/shoucang',
  'liuyan/liuyanyh',
  'ai/ai'
])
const ADMIN_MENU_OVERRIDES = {
  '/sys': { title: '用户与权限', redirect: '/sys/user' },
  'sys/user': { title: '用户管理' },
  'sys/role': { title: '角色管理' },
  'sys/route': { title: '菜单权限' },
  '/shangp': { title: '作品与委托', redirect: '/shangp/shangpsh' },
  'shangp/shangpsh': { title: '作品审核' },
  '/order': { title: '订单与支付', redirect: '/order/orderadglqb' },
  'order/orderadglqb': { title: '交易订单总览' },
  '/fenxiang': { title: '内容与社区', redirect: '/fenxiang/fenxiangad' },
  'fenxiang/fenxiangad': { title: '社区内容管理' },
  '/liuyan': { title: '反馈与工单', redirect: '/liuyan/liuyan' },
  'liuyan/liuyan': { title: '反馈工单' },
  '/fenlei': { title: '分类与配置', redirect: '/fenlei/fenlei' },
  'fenlei/fenlei': { title: '分类管理' },
  '/tongji': { title: '统计与审计', redirect: '/tongji/tongji' },
  'tongji/tongji': { title: '交易统计' },
  '/rizhi': { title: '日志与审计', redirect: '/rizhi/rizhi' },
  'rizhi/rizhi': { title: '操作日志' },
  '/lunbo': { title: '轮播与运营', redirect: '/lunbo/lunbo' },
  'lunbo/lunbo': { title: '轮播运营' }
}

function resolveLegacyAdminPath(path) {
  if (path === `${ADMIN_ENTRY_PATH}/`) {
    return '/dashboard'
  }
  if (!path.startsWith(`${ADMIN_ENTRY_PATH}/`)) {
    return ''
  }
  const legacyPath = path.slice(ADMIN_ENTRY_PATH.length)
  return legacyPath || '/dashboard'
}

router.beforeEach(async(to, from, next) => {
  // start progress bar
  NProgress.start()

  // set page title
  document.title = getPageTitle(to.meta.title)

  // determine whether the user has logged in
  const hasToken = getToken()

  if (hasToken) {
    const legacyAdminPath = resolveLegacyAdminPath(to.path)
    if (legacyAdminPath) {
      next({ path: legacyAdminPath, query: to.query, hash: to.hash, replace: true })
      return
    }

    if (to.path === '/auth') {
      // if is logged in, redirect to the home page
      next({ path: '/home' })
      NProgress.done()
    } else {
      const hasGetUserInfo = store.getters.name
      if (hasGetUserInfo) {
        next()
      } else {
        try {
          // get user info
          await store.dispatch('user/getInfo')

          // 路由转换
          const runtimeMenuList = cloneMenuList(store.getters.menuList)
          const normalizedMenuList = shouldUseAdminConsoleMenus(store.getters.roles, store.getters.activeRole)
            ? normalizeAdminConsoleMenus(runtimeMenuList)
            : runtimeMenuList
          const myRoutes = myFilterAsyncRoutes(normalizedMenuList)
          // 404
          myRoutes.push({
            path: '*',
            redirect: '/404',
            hidden: true
          })
          // 动态添加路由
          router.addRoutes(myRoutes)
          // 存至全局变量
          global.myRoutes = myRoutes

          next({ ...to, replace: true }) // 防止刷新后页面空白

          // next()
        } catch (error) {
          // remove token and go to auth page to re-login
          await store.dispatch('user/resetToken')
          Message.error(error || 'Has Error')
          next(`/auth?redirect=${to.path}`)
          NProgress.done()
        }
      }
    }
  } else {
    /* has no token*/

    if (whiteList.indexOf(to.path) !== -1) {
      // in the free login whitelist, go directly
      next()
    } else {
      // other pages that do not have permission to access are redirected to the auth page.
      next(`/auth?redirect=${to.path}`)
      NProgress.done()
    }
  }
})

router.afterEach(() => {
  // finish progress bar
  NProgress.done()
})

function myFilterAsyncRoutes(menuList) {
  menuList.filter(menu => {
    if (menu.component === 'Layout') {
      menu.component = Layout
      console.log(menu.component)
    } else {
      menu.component = require(`@/views/${menu.component}.vue`).default
    }
    // 递归处理子菜单
    if (menu.children && menu.children.length) {
      menu.children = myFilterAsyncRoutes(menu.children)
    }
    return true
  })
  return menuList
}

function shouldUseAdminConsoleMenus(roles = [], activeRole = '') {
  if (!Array.isArray(roles) || roles.indexOf(ADMIN_ROLE_NAME) === -1) {
    return false
  }
  return !activeRole || activeRole === ADMIN_ROLE_NAME
}

function cloneMenuList(menuList) {
  return JSON.parse(JSON.stringify(menuList || []))
}

function applyAdminMenuOverride(menu) {
  const key = menu.component === 'Layout' ? menu.path : menu.component
  const override = ADMIN_MENU_OVERRIDES[key]
  if (!override) {
    return menu
  }
  if (override.title) {
    menu.title = override.title
    menu.meta = Object.assign({}, menu.meta, { title: override.title })
  }
  if (Object.prototype.hasOwnProperty.call(override, 'redirect')) {
    menu.redirect = override.redirect
  }
  return menu
}

function normalizeAdminConsoleMenus(menuList) {
  return menuList.reduce((result, rawMenu) => {
    const menu = Object.assign({}, rawMenu)
    if (menu.component !== 'Layout' && ADMIN_MENU_COMPONENT_BLACKLIST.has(menu.component)) {
      return result
    }
    if (menu.children && menu.children.length) {
      menu.children = normalizeAdminConsoleMenus(menu.children)
    }
    if (menu.component === 'Layout' && menu.children && menu.children.length === 0) {
      return result
    }
    result.push(applyAdminMenuOverride(menu))
    return result
  }, [])
}
