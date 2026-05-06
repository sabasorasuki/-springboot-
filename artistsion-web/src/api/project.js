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
  },
  apply(data) {
    return request({
      url: '/sysProject/apply',
      method: 'post',
      data
    })
  },
  getApplications(searchModel = {}) {
    return request({
      url: '/sysProject/applications',
      method: 'get',
      params: {
        projectId: searchModel.projectId,
        pageNo: searchModel.pageNo || 1,
        pageSize: searchModel.pageSize || 20
      }
    })
  },
  deleteById(id) {
    return request({
      url: `/sysProject/deleteById/${id}`,
      method: 'delete'
    })
  }
}
