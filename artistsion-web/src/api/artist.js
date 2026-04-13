import request from '@/utils/request'

/**
 * 画师公开接口 — 对应后端 /user/artists
 * 返回安全投影数据（ArtistVO），不含 email/phone/password
 */
export default {
  getList(searchModel = {}) {
    return request({
      url: '/user/artists',
      method: 'get',
      params: {
        pageNo: searchModel.pageNo || 1,
        pageSize: searchModel.pageSize || 12,
        fenlei: searchModel.fenlei || undefined
      }
    })
  }
}
