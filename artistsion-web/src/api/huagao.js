import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: '/sysHuagao/list',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        shangjiaids: searchModel.shangjiaids,
        title: searchModel.title,
        type: searchModel.type,
        status: searchModel.status,
        name: searchModel.name,
        fenlei: searchModel.fenlei,
        id: searchModel.id
      }
    })
  },

  aliTyqw(content) {
    return request({
      url: '/ai/aliTyqw',
      method: 'post',
      data: content.content
    })
  },

  getzuixin(searchModel) {
    return request({
      url: '/sysHuagao/getzuixin',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize

      }
    })
  },

  getListtuijian(searchModel) {
    return request({
      url: '/sysHuagao/tuijianlist',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        shangjiaids: searchModel.shangjiaids,
        title: searchModel.title,
        type: searchModel.type,
        status: searchModel.status,
        name: searchModel.name,
        fenlei: searchModel.fenlei,
        id: searchModel.id,
        tuijian: searchModel.tuijian.join(',') // 转为逗号分隔字符串,
      }
    })
  },

  getList1() {
    return request({
      url: '/sysHuagao/list',
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99
      }
    })
  },

  add(content) {
    return request({
      url: '/sysHuagao/add',
      method: 'post',
      data: content
    })
  },
  update(content) {
    return request({
      url: '/sysHuagao/update',
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
      url: `/sysHuagao/getById/${id}`,
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
      url: `/sysHuagao/deleteById/${id}`,
      method: 'delete'
    })
  }

}
