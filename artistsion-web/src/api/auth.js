import request from '@/utils/request'

/**
 * 新认证接口
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

export function getRegisterOptions() {
  return request({
    url: '/auth/register-options',
    method: 'get'
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
