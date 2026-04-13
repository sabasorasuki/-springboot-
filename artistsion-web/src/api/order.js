import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysOrder/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        status: searchModel.status,
        userids: searchModel.userids,
        shangjiaids: searchModel.shangjiaids
      }
    })
  },

  alipay(content) {
    return request({
      url: '/order/alipay',
      method: 'post',
      data: content
    })
  },
  getorder() {
    return request({
      url: '/sysOrder/getorder',
      method: 'get'
    })
  },
  selectCountGroupByName() {
    return request({
      url: '/sysOrder/selectCountGroupByName',
      method: 'get'
    })
  },

  getList1() {
    return request({
      url: '/sysOrder/list',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99
      }
    })
  },

  add(content) {
    return request({
      url: '/sysOrder/add',
      method: 'post',
      data: content
    })
  },
  update(content) {
    return request({
      url: '/sysOrder/update',
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
      url: `/sysOrder/getById/${id}`,
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
      url: `/sysOrder/deleteById/${id}`,
      method: 'delete'
    })
  },

  getMine(params) {
    return request({
      url: '/sysOrder/mine',
      method: 'get',
      params: {
        role: params.role,
        pageNo: params.pageNo,
        pageSize: params.pageSize
      }
    })
  }

}
