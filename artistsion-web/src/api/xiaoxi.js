import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysLiuyans/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        userids: searchModel.userids,
        tsids: searchModel.tsids
      }
    })
  },

  add(content) {
    return request({
      url: '/sysLiuyans/add',
      method: 'post',
      data: content
    })
  },
  update(content) {
    return request({
      url: '/sysLiuyans/update',
      method: 'put',
      data: content
    })
  },

  saveOrUpdate(content) {
    if (content.id == null || content.id === undefined) {
      return this.add(content)
    }
    return this.update(content)
  },

  getById(id) {
    return request({
      url: `/sysLiuyans/getById/${id}`,
      method: 'get'
    })
  },

  getByhuodongId(id) {
    return request({
      url: `/sysHuodong/getByhuodongId/${id}`,
      method: 'get'
    })
  },

  deleteById(id) {
    return request({
      url: `/sysLiuyans/deleteById/${id}`,
      method: 'delete'
    })
  }

}
