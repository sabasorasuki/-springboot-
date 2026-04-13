import request from '@/utils/request'

/**
 * 新认证接口签名（阶段 1 仅定义，不实际调用）
 * 后端实现后再启用
 */

export function authLogin(data) {
  return request({
    url: '/auth/login',
    method: 'post',
    data
  })
}

export function authRegister(data) {
  return request({
    url: '/auth/register',
    method: 'post',
    data
  })
}

export function sendEmailCode(data) {
  return request({
    url: '/auth/send-email-code',
    method: 'post',
    data
  })
}

export function getAuthMe() {
  return request({
    url: '/auth/me',
    method: 'get'
  })
}

export function switchRole(data) {
  return request({
    url: '/auth/switch-role',
    method: 'post',
    data
  })
}
