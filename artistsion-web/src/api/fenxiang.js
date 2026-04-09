import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysZuopin/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        userids: searchModel.userids,
        fenlei: searchModel.fenlei,
        id: searchModel.id
      }
    })
  },

  getList1() {
    return request({
      url: '/sysZuopin/list',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99
      }
    })
  },
  getorder() {
    return request({
      url: '/sysZuopin/getorder',
      method: 'get'
    })
  },

  add(content) {
    return request({
      url: '/sysZuopin/add',
      method: 'post',
      data: content
    })
  },
  update(content) {
    return request({
      url: '/sysZuopin/update',
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
      url: `/sysZuopin/getById/${id}`,
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
      url: `/sysZuopin/deleteById/${id}`,
      method: 'delete'
    })
  }

}
