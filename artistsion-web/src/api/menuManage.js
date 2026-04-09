import request from '@/utils/request'

export default {
  getAllMenu() {
    return request({
      url: '/menu/getAllMenu',
      method: 'get'
    })
  },

  // 条件查询菜单列表
  getMenuList(searchModel) {
    return request({
      url: '/menu/list',
      method: 'get',
      params: {
        title: searchModel.title,
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize
      }
    })
  },

  // 根据id查询
  getMenuById(id) {
    return request({
      url: `/menu/getMenuById/${id}`,
      method: 'get'
    })
  },

  saveRoute(route) {
    if (route.menuId === null || route.menuId === undefined) {
      return this.addRoute(route)
    }
    return this.updateRoute(route)
  },

  addRoute(route) {
    return request({
      url: '/menu/addRole',
      method: 'post',
      data: route
    })
  },
  updateRoute(route) {
    return request({
      url: '/menu/updateRole',
      method: 'put',
      data: route
    })
  },

  // 根据id删除
  deleteMenuById(id) {
    return request({
      url: `/menu/deleteMenuById/${id}`,
      method: 'delete'
    })
  }

}
