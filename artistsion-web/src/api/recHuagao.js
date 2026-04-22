import request from '@/utils/request'

export default {
  trackAction(payload) {
    return request({
      url: '/recHuagaoTrack/action',
      method: 'post',
      data: payload
    })
  }
}
