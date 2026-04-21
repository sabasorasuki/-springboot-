import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysTag/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        name: searchModel.name,
        tagType: searchModel.tagType,
        tagGroup: searchModel.tagGroup,
        status: searchModel.status
      }
    })
  },

  getById(id) {
    return request({
      url: `/sysTag/getById/${id}`,
      method: 'get'
    })
  },

  getSystemOptions() {
    return request({
      url: '/sysTag/systemOptions',
      method: 'get'
    })
  },

  add(content) {
    return request({
      url: '/sysTag/add',
      method: 'post',
      data: content
    })
  },

  update(content) {
    return request({
      url: '/sysTag/update',
      method: 'put',
      data: content
    })
  }
}
