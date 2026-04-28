import request from '@/utils/request'

export default {
  recommendations(searchModel) {
    return request({
      url: '/recHuagao/recommendations',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo,
        pageSize: searchModel.pageSize,
        scene: searchModel.scene
      }
    })
  },

  trackAction(payload) {
    return request({
      url: '/recHuagaoTrack/action',
      method: 'post',
      data: payload
    })
  }
}
