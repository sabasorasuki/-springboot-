import router from './router'
import store from './store'
import { Message } from 'element-ui'
import NProgress from 'nprogress' // progress bar
import 'nprogress/nprogress.css' // progress bar style
import { getToken } from '@/utils/auth' // get token from cookie
import getPageTitle from '@/utils/get-page-title'
import AdminLayout from '@/layout/AdminLayout'
import {
  ADMIN_ENTRY_PATH,
  ADMIN_MENU_OVERRIDES,
  canAccessAdminConsole,
  isAdminEntryPath,
  isAdminOnlyPath,
  shouldKeepAdminMenu,
  shouldUseAdminConsoleMenus
} from '@/utils/adminConsole'

NProgress.configure({ showSpinner: false }) // NProgress Configuration

const whiteList = ['/auth'] // no redirect whitelist
const publicPathPatterns = [
  /^\/$/,
  /^\/home$/,
  /^\/artists$/,
  /^\/artist\/\d+$/,
  /^\/projects$/,
  /^\/project\/\d+$/,
  /^\/works$/,
  /^\/work\/\d+$/,
  /^\/showcase$/,
  /^\/post\/\d+$/,
  /^\/center\/profile\/\d+$/,
  /^\/404$/
]

function isPublicPath(path) {
  return publicPathPatterns.some(pattern => pattern.test(path))
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
    if (to.path === '/auth') {
      // if is logged in, redirect to the home page
      next({ path: '/home' })
      NProgress.done()
    } else {
      const hasGetUserInfo = store.getters.name
      if (hasGetUserInfo) {
        if (handleAdminAccess(to, next)) {
          return
        }
        next()
      } else {
        try {
          // get user info
          await store.dispatch('user/getInfo')

          if (handleAdminAccess(to, next)) {
            return
          }

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

    if (whiteList.indexOf(to.path) !== -1 || isPublicPath(to.path)) {
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

function myFilterAsyncRoutes(menuList, usedRouteNames = new Set()) {
  menuList.filter(menu => {
    const isLayoutRoute = menu.component === 'Layout'
    menu.name = createUniqueRouteName(menu, usedRouteNames, isLayoutRoute)

    if (isLayoutRoute) {
      menu.component = AdminLayout
    } else {
      menu.component = require(`@/views/${menu.component}.vue`).default
    }
    // 递归处理子菜单
    if (menu.children && menu.children.length) {
      menu.children = myFilterAsyncRoutes(menu.children, usedRouteNames)
    }
    return true
  })
  return menuList
}

function createUniqueRouteName(menu, usedRouteNames, isLayoutRoute) {
  const rawName = (menu.name || menu.path || menu.component || 'route').replace(/[^\w-]/g, '_')
  const baseName = isLayoutRoute ? `${rawName}_layout_${menu.menuId || 'root'}` : rawName
  let candidate = baseName
  let index = 1

  while (usedRouteNames.has(candidate)) {
    candidate = `${baseName}_${index}`
    index++
  }

  usedRouteNames.add(candidate)
  return candidate
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
    if (!shouldKeepAdminMenu(menu)) {
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

function routeRequiresAdmin(to) {
  return to.matched.some(route => route.meta && route.meta.requiresAdmin)
}

function handleAdminAccess(to, next) {
  const canAccess = canAccessAdminConsole(store.getters.roles, store.getters.activeRole)
  if (routeRequiresAdmin(to) && !canAccess) {
    Message.warning('当前身份不可访问管理员页面')
    next({ path: '/home', replace: true })
    NProgress.done()
    return true
  }
  if (isAdminEntryPath(to.path)) {
    if (!canAccess) {
      Message.warning('当前身份不可进入管理员控制台')
      next({ path: '/home', replace: true })
      NProgress.done()
      return true
    }
    const legacyAdminPath = resolveLegacyAdminPath(to.path)
    if (legacyAdminPath) {
      next({ path: legacyAdminPath, query: to.query, hash: to.hash, replace: true })
      return true
    }
  }
  if (!canAccess && isAdminOnlyPath(to.path)) {
    Message.warning('当前身份不可访问管理员页面')
    next({ path: '/home', replace: true })
    NProgress.done()
    return true
  }
  return false
}
