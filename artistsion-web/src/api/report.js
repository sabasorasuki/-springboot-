import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysReport/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        status: searchModel.status,
        targetType: searchModel.targetType,
        reason: searchModel.reason,
        keyword: searchModel.keyword
      }
    })
  },

  getById(id) {
    return request({
      url: `/sysReport/getById/${id}`,
      method: 'get'
    })
  },

  handle(data) {
    return request({
      url: '/sysReport/handle',
      method: 'put',
      data
    })
  },

  add(data) {
    return request({
      url: '/sysReport/add',
      method: 'post',
      data
    })
  }
}
