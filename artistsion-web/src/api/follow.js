import request from '@/utils/request'

export default {
  follow(data) {
    return request({
      url: '/sysFollow/follow',
      method: 'post',
      data
    })
  },
  unfollow(params) {
    return request({
      url: '/sysFollow/unfollow',
      method: 'delete',
      params: {
        followerId: params.followerId,
        followingId: params.followingId
      }
    })
  },
  getFollowing(params) {
    return request({
      url: '/sysFollow/following',
      method: 'get',
      params: {
        userId: params.userId,
        pageNo: params.pageNo || 1,
        pageSize: params.pageSize || 20
      }
    })
  },
  getFollowers(params) {
    return request({
      url: '/sysFollow/followers',
      method: 'get',
      params: {
        userId: params.userId,
        pageNo: params.pageNo || 1,
        pageSize: params.pageSize || 20
      }
    })
  },
  getFriends(params) {
    return request({
      url: '/sysFollow/friends',
      method: 'get',
      params: {
        userId: params.userId,
        pageNo: params.pageNo || 1,
        pageSize: params.pageSize || 20
      }
    })
  },
  check(params) {
    return request({
      url: '/sysFollow/check',
      method: 'get',
      params: {
        followerId: params.followerId,
        followingId: params.followingId
      }
    })
  },
  count(userId) {
    return request({
      url: '/sysFollow/count',
      method: 'get',
      params: { userId }
    })
  }
}
