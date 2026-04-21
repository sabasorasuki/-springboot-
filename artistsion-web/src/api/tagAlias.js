import request from '@/utils/request'

export default {
  listByTagId(tagId) {
    return request({
      url: `/sysTagAlias/listByTagId/${tagId}`,
      method: 'get'
    })
  },

  add(content) {
    return request({
      url: '/sysTagAlias/add',
      method: 'post',
      data: content
    })
  },

  deleteById(id) {
    return request({
      url: `/sysTagAlias/deleteById/${id}`,
      method: 'delete'
    })
  }
}
