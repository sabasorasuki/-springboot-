export const ADMIN_ENTRY_PATH = '/admin'
export const ADMIN_ROLE_NAME = 'admin'

export const ADMIN_MENU_PATH_ALLOWLIST = new Set([
  '/sys',
  '/shangp',
  '/order',
  '/fenxiang',
  '/liuyan',
  '/fenlei',
  '/tongji',
  '/rizhi',
  '/lunbo'
])

export const ADMIN_MENU_COMPONENT_ALLOWLIST = new Set([
  'sys/user',
  'sys/role',
  'sys/route',
  'shangp/shangpsh',
  'order/orderadglqb',
  'fenxiang/fenxiangad',
  'liuyan/liuyan',
  'fenlei/fenlei',
  'tongji/tongji',
  'rizhi/rizhi',
  'lunbo/lunbo'
])

export const ADMIN_MENU_OVERRIDES = {
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

const ADMIN_ONLY_EXACT_PATHS = new Set([
  '/dashboard',
  '/userinfo',
  '/shangp/shangpsh',
  '/order/orderadglqb',
  '/fenxiang/fenxiangad',
  '/liuyan/liuyan'
])

const ADMIN_ONLY_PREFIXES = [
  '/sys',
  '/fenlei',
  '/tongji',
  '/rizhi',
  '/lunbo'
]

export function canAccessAdminConsole(roles = [], activeRole = '') {
  if (!Array.isArray(roles) || roles.indexOf(ADMIN_ROLE_NAME) === -1) {
    return false
  }
  return !activeRole || activeRole === ADMIN_ROLE_NAME
}

export function shouldUseAdminConsoleMenus(roles = [], activeRole = '') {
  return canAccessAdminConsole(roles, activeRole)
}

export function isAdminEntryPath(path = '') {
  return path === ADMIN_ENTRY_PATH || path.startsWith(`${ADMIN_ENTRY_PATH}/`)
}

export function isAdminOnlyPath(path = '') {
  if (ADMIN_ONLY_EXACT_PATHS.has(path)) {
    return true
  }
  return ADMIN_ONLY_PREFIXES.some(prefix => path === prefix || path.startsWith(`${prefix}/`))
}

export function shouldKeepAdminMenu(menu) {
  if (!menu) {
    return false
  }
  if (menu.component === 'Layout') {
    return ADMIN_MENU_PATH_ALLOWLIST.has(menu.path)
  }
  return ADMIN_MENU_COMPONENT_ALLOWLIST.has(menu.component)
}

