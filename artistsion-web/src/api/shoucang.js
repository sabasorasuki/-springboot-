import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysShoucang/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        userids: searchModel.userids,
        wzids: searchModel.wzids
      }
    })
  },

  getListtuijian(searchModel) {
    return request({
      url: '/sysShoucang/getListtuijian',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99,
        wzids: searchModel.wzids,
        userids: searchModel.userids
      }
    })
  },

  getorder() {
    return request({
      url: '/sysShoucang/getorder',
      method: 'get'
    })
  },

  getList1(searchModel) {
    return request({
      url: '/sysShoucang/list',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99,
        wzids: searchModel.wzids,
        userids: searchModel.userids
      }
    })
  },

  add(content) {
    return request({
      url: '/sysShoucang/add',
      method: 'post',
      data: content
    })
  },
  update(content) {
    return request({
      url: '/sysShoucang/update',
      method: 'put',
      data: content
    })
  },

  saveOrUpdate(content) {
    if (content.id === null || content.id === undefined) {
      return this.add(content)
    }
    return this.update(content)
  },

  getById(id) {
    return request({
      url: `/sysShoucang/getById/${id}`,
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
      url: `/sysShoucang/deleteById/${id}`,
      method: 'delete'
    })
  }

}
