import request from '@/utils/request'

export default {
  getAdminList(searchModel) {
    return request({
      url: '/sysFenlei/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        fenlei: searchModel.fenlei,
        status: searchModel.status
      }
    })
  },

  getList1() {
    return request({
      url: '/sysFenlei/list',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99,
        status: 1
      }
    })
  },

  update(content) {
    return request({
      url: '/sysFenlei/update',
      method: 'put',
      data: content
    })
  },

  getById(id) {
    return request({
      url: `/sysFenlei/getById/${id}`,
      method: 'get'
    })
  },

  getByhuodongId(id) {
    return request({
      url: `/sysHuodong/getByhuodongId/${id}`,
      method: 'get'
    })
  }

}
