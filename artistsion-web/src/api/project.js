import request from '@/utils/request'

export default {
  getList(searchModel = {}) {
    return request({
      url: '/sysProject/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo || 1,
        pageSize: searchModel.pageSize || 12,
        category: searchModel.category || undefined,
        status: searchModel.status || undefined,
        userId: searchModel.userId || undefined
      }
    })
  },
  getById(id) {
    return request({
      url: `/sysProject/getById/${id}`,
      method: 'get'
    })
  },
  add(data) {
    return request({
      url: '/sysProject/add',
      method: 'post',
      data
    })
  }
}
