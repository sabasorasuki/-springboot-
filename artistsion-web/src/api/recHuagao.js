import recApi from '@/api/rec'

export default {
  recommendations(searchModel) {
    return recApi.recommendations({
      ...searchModel,
      domain: 'huagao'
    })
  },

  trackAction(payload) {
    return recApi.trackAction({
      ...payload,
      domain: 'huagao',
      itemId: payload.itemId || payload.huagaoId,
      authorId: payload.authorId || payload.shangjiaId
    })
  }
}
