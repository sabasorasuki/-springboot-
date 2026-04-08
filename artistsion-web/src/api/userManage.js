import request from '@/utils/request'

export default {
  getUserList(searchModel) {
    return request({
      url: "/user/list",
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        username: searchModel.username,
        phone: searchModel.phone,
      }
    });
  },

  register(data) {
    return request({
      url: '/user/register',
      method: 'post',
      data
    })
  },
 getInfo(token) {
    return request({
      url: '/user/info',
      method: 'get',
      params: { token }
    })
  },
  addUser(user) {
    return request({
      url: "/user/addUser",
      method: 'post',
      data: user
    });
  },
  updateUser(user) {
    return request({
      url: "/user/updateUser",
      method: 'put',
      data: user
    });
  },
  uploadAvatar(avatar){
    return request({
      url: `/user/uploadAvatar/${avatar}`,
      method: 'get'
    });
  },
  updateMyUser(user) {
    return request({
      url: "/user/updateMyUser",
      method: 'put',
      data: user
    });
  },

  saveUser(user){
    if(user.id == null && user.id == undefined){
      return this.addUser(user);
    }
    return this.updateUser(user);
  },

  getUserById(id) {
    return request({
      url: `/user/getUserById/${id}`,
      method: 'get'
    });
  },
  deleteUserById(id) {
    return request({
      url: `/user/deleteUserById/${id}`,
      method: 'delete'
    });
  },


}
