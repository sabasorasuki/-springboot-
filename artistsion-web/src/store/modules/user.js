import { login, logout } from '@/api/user'
import { authLogin as authLoginApi, getAuthMe } from '@/api/auth'
import { getToken, setToken, removeToken } from '@/utils/auth'
import { resetRouter } from '@/router'

const DISPLAY_MODE_KEY = 'artistsion_display_mode'

const getDefaultState = () => {
  return {
    token: getToken(),
    userId: null,
    name: '',
    avatar: '',
    menuList: [],
    roles: [],
    activeRole: '',
    displayMode: localStorage.getItem(DISPLAY_MODE_KEY) || 'client'
  }
}

const state = getDefaultState()

const mutations = {
  RESET_STATE: (state) => {
    Object.assign(state, getDefaultState())
  },
  SET_TOKEN: (state, token) => {
    state.token = token
  },
  SET_NAME: (state, name) => {
    state.name = name
  },
  SET_AVATAR: (state, avatar) => {
    state.avatar = avatar
  },
  SET_MENU_LIST: (state, menuList) => {
    state.menuList = menuList
  },
  SET_ROLES: (state, roles) => {
    state.roles = roles
  },
  SET_USER_ID: (state, userId) => {
    state.userId = userId
  },
  SET_ACTIVE_ROLE: (state, activeRole) => {
    state.activeRole = activeRole
  },
  SET_DISPLAY_MODE: (state, mode) => {
    state.displayMode = mode
    localStorage.setItem(DISPLAY_MODE_KEY, mode)
  }
}

const actions = {
  // user login (旧登录，保留兼容)
  login({ commit }, userInfo) {
    const { username, password } = userInfo
    return new Promise((resolve, reject) => {
      login({ username: username.trim(), password: password }).then(response => {
        const { data } = response
        commit('SET_TOKEN', data.token)
        setToken(data.token)
        resolve()
      }).catch(error => {
        reject(error)
      })
    })
  },

  // 新认证登录
  authLogin({ commit }, loginInfo) {
    const { account, password } = loginInfo
    return new Promise((resolve, reject) => {
      authLoginApi({ account: account.trim(), password }).then(response => {
        const { data } = response
        commit('SET_TOKEN', data.token)
        setToken(data.token)
        if (data.roles) {
          commit('SET_ROLES', data.roles)
        }
        if (data.activeRole) {
          commit('SET_ACTIVE_ROLE', data.activeRole)
        }
        resolve(data)
      }).catch(error => {
        reject(error)
      })
    })
  },

  // get user info
  getInfo({ commit, state }) {
    return new Promise((resolve, reject) => {
      getAuthMe().then(response => {
        const { data } = response

        if (!data) {
          reject('Verification failed, please Login again.')
        }

        const profile = data.user || data.userList || {}
        const name = data.name || profile.username || profile.name || ''
        const avatar = data.avatar || profile.avatar || ''
        const menuList = data.menuList || []
        const roles = data.roles || []
        const activeRole = data.activeRole || ''

        if (profile.id) {
          commit('SET_USER_ID', profile.id)
        }
        commit('SET_NAME', name)
        commit('SET_AVATAR', avatar)
        commit('SET_MENU_LIST', menuList)
        if (roles) {
          commit('SET_ROLES', roles)
        }
        if (activeRole) {
          commit('SET_ACTIVE_ROLE', activeRole)
        }

        resolve(data)
      }).catch(error => {
        reject(error)
      })
    })
  },

  // user logout
  logout({ commit, state }) {
    return new Promise((resolve, reject) => {
      logout(state.token).then(() => {
        removeToken() // must remove  token  first
        resetRouter()
        commit('RESET_STATE')
        resolve()
      }).catch(error => {
        reject(error)
      })
    })
  },

  // remove token
  resetToken({ commit }) {
    return new Promise(resolve => {
      removeToken() // must remove  token  first
      commit('RESET_STATE')
      resolve()
    })
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
