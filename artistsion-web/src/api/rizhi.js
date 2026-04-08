import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: "/sysRizhi/list",
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        fenlei:searchModel.fenlei,
        rizhi:searchModel.rizhi
      }
    });
  },

  getList1() {
    return request({
      url: "/sysRizhi/list",
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99,
      }
    });
  },

  add(content) {
    return request({
      url: "/sysRizhi/add",
      method: 'post',
      data: content
    });
  },
  update(content) {
    return request({
      url: "/sysRizhi/update",
      method: 'put',
      data: content
    });
  },

  saveOrUpdate(content){
    if(content.id == null && content.id == undefined){
      return this.add(content);
    }
    return this.update(content);
  },

  getById(id) {
    return request({
      url: `/sysRizhi/getById/${id}`,
      method: 'get'
    });
  },

  getByhuodongId(id) {
    return request({
      url: `/sysHuodong/getByhuodongId/${id}`,
      method: 'get'
    });
  },
  
  deleteById(id) {
    return request({
      url: `/sysRizhi/deleteById/${id}`,
      method: 'delete'
    });
  },


}
