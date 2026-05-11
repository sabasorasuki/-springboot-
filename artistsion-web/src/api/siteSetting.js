import request from '@/utils/request'

export default {
  getAuthConfig() {
    return request({
      url: '/sysSiteSetting/auth-config',
      method: 'get'
    })
  },

  updateAuthConfig(data) {
    return request({
      url: '/sysSiteSetting/auth-config',
      method: 'put',
      data
    })
  }
}
