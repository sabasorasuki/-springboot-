import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysPinglun/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        type: searchModel.type,
        name: searchModel.name,
        id: searchModel.id
      }
    })
  },

  getList1(searchModel) {
    return request({
      url: '/sysPinglun/list',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99,
        wzids: searchModel.wzids
      }
    })
  },

  add(content) {
    return request({
      url: '/sysPinglun/add',
      method: 'post',
      data: content
    })
  },
  update(content) {
    return request({
      url: '/sysPinglun/update',
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
      url: `/sysPinglun/getById/${id}`,
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
      url: `/sysPinglun/deleteById/${id}`,
      method: 'delete'
    })
  }

}
