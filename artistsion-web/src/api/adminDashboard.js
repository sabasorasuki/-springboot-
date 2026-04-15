import request from '@/utils/request'

export default {
  getSummary() {
    return request({
      url: '/adminDashboard/summary',
      method: 'get'
    })
  }
}
