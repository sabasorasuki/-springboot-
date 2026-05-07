import request from '@/utils/request'

export default {
  recommendations(searchModel = {}) {
    return request({
      url: '/rec/recommendations',
      method: 'get',
      params: {
        domain: searchModel.domain || 'huagao',
        pageNo: searchModel.pageNo || 1,
        pageSize: searchModel.pageSize || 12,
        scene: searchModel.scene
      }
    })
  },

  trackAction(payload) {
    return request({
      url: '/recTrack/action',
      method: 'post',
      data: payload
    })
  }
}
