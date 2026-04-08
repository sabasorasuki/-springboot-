import request from '@/utils/request'

export default {
  getList(searchModel) {
    return request({
      url: "/userArticleOperation/list",
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        title: searchModel.title,
        username:searchModel.username,
        userids:searchModel.userids
      }
    });
  },

  getList1() {
    return request({
      url: "/userArticleOperation/list",
      method: 'get',
      params: {
        pageNo: 1,
        pageSize: 99,
      }
    });
  },

  add(content) {
    return request({
      url: "/userArticleOperation/add",
      method: 'post',
      data: content
    });
  },
  update(content) {
    return request({
      url: "/userArticleOperation/update",
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
      url: `/userArticleOperation/getById/${id}`,
      method: 'get'
    });
  },

  recommendations(userid) {
    return request({
      url: `/userArticleOperation/recommendations/${userid}`,
      method: 'get'
    });
  },

  getByhuodongId(id) {
    return request({
      url: `/userArticleOperation/getByhuodongId/${id}`,
      method: 'get'
    });
  },
  
  deleteById(id) {
    return request({
      url: `/userArticleOperation/deleteById/${id}`,
      method: 'delete'
    });
  },


}
