<template>
  <div class="admin-layout">
    <header class="admin-layout__header">
      <div class="admin-topbar">
        <div class="admin-topbar__inner">
          <router-link to="/dashboard" class="admin-logo">
            <span class="admin-logo__text">Artistsion</span>
            <span class="admin-logo__badge">管理</span>
          </router-link>

          <nav class="admin-nav">
            <router-link
              v-for="item in navGroups"
              :key="item.key"
              :to="item.path"
              class="admin-nav__item"
              :class="{ 'is-active': isGroupActive(item) }"
            >
              <i :class="item.icon" />
              <span>{{ item.label }}</span>
            </router-link>
          </nav>

          <div class="admin-topbar__right">
            <router-link to="/home" class="admin-back-btn" title="返回前台">
              <i class="el-icon-monitor" />
              <span>前台</span>
            </router-link>

            <el-dropdown trigger="click" @command="handleCommand">
              <div class="admin-avatar">
                <img :src="headerAvatar" class="admin-avatar__img" alt="">
                <span class="admin-avatar__name">{{ name || '管理员' }}</span>
                <i class="el-icon-arrow-down" />
              </div>
              <el-dropdown-menu slot="dropdown">
                <router-link to="/userinfo">
                  <el-dropdown-item>
                    <i class="el-icon-setting" /> 账号设置
                  </el-dropdown-item>
                </router-link>
                <el-dropdown-item divided command="logout">
                  <i class="el-icon-switch-button" /> 退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </el-dropdown>
          </div>
        </div>
      </div>

      <div v-if="activeSubItems.length > 1" class="admin-subnav">
        <div class="admin-subnav__inner">
          <router-link
            v-for="sub in activeSubItems"
            :key="sub.path"
            :to="sub.path"
            class="admin-subnav__item"
            :class="{ 'is-active': isSubActive(sub.path) }"
          >
            {{ sub.label }}
          </router-link>
        </div>
      </div>
    </header>

    <main class="admin-layout__content">
      <transition name="fade-transform" mode="out-in">
        <router-view :key="$route.path" />
      </transition>
    </main>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { normalizeImageUrl } from '@/utils/oss'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const NAV_GROUPS = [
  {
    key: 'overview',
    label: '总览',
    icon: 'el-icon-data-analysis',
    path: '/dashboard',
    matchPaths: ['/dashboard'],
    children: []
  },
  {
    key: 'content',
    label: '内容审核',
    icon: 'el-icon-document-checked',
    path: '/shangp/shangpsh',
    matchPaths: ['/shangp', '/fenxiang', '/report'],
    children: [
      { path: '/shangp/shangpsh', label: '作品审核' },
      { path: '/fenxiang/fenxiangad', label: '社区内容' },
      { path: '/report/center', label: '举报审核' }
    ]
  },
  {
    key: 'trade',
    label: '交易管理',
    icon: 'el-icon-shopping-bag-1',
    path: '/order/orderadglqb',
    matchPaths: ['/order', '/tongji'],
    children: [
      { path: '/order/orderadglqb', label: '交易订单' },
      { path: '/tongji/tongji', label: '交易统计' }
    ]
  },
  {
    key: 'user',
    label: '用户管理',
    icon: 'el-icon-user',
    path: '/sys/user',
    matchPaths: ['/sys'],
    children: [
      { path: '/sys/user', label: '用户' },
      { path: '/sys/role', label: '角色' },
      { path: '/sys/route', label: '菜单权限' }
    ]
  },
  {
    key: 'operation',
    label: '运营配置',
    icon: 'el-icon-s-operation',
    path: '/fenlei/fenlei',
    matchPaths: ['/fenlei', '/lunbo'],
    children: [
      { path: '/fenlei/fenlei', label: '分类管理' },
      { path: '/lunbo/lunbo', label: '轮播管理' }
    ]
  },
  {
    key: 'support',
    label: '工单日志',
    icon: 'el-icon-tickets',
    path: '/liuyan/liuyan',
    matchPaths: ['/liuyan', '/rizhi'],
    children: [
      { path: '/liuyan/liuyan', label: '反馈工单' },
      { path: '/rizhi/rizhi', label: '操作日志' }
    ]
  }
]

export default {
  name: 'AdminLayout',
  data() {
    return {
      defaultAvatar,
      navGroups: NAV_GROUPS
    }
  },
  computed: {
    ...mapGetters(['name', 'avatar', 'token']),
    headerAvatar() {
      return normalizeImageUrl(this.avatar) || this.defaultAvatar
    },
    activeSubItems() {
      const group = this.navGroups.find(g => this.isGroupActive(g))
      return group ? group.children : []
    }
  },
  methods: {
    isGroupActive(group) {
      const current = this.$route.path
      return group.matchPaths.some(p => current === p || current.startsWith(p + '/'))
    },
    isSubActive(path) {
      return this.$route.path === path || this.$route.path.startsWith(path + '/')
    },
    async handleCommand(cmd) {
      if (cmd === 'logout') {
        await this.$store.dispatch('user/logout')
        this.$router.push('/auth?redirect=/admin')
      }
    }
  }
}
</script>

<style lang="scss">
@import '~@/styles/admin-page.scss';
</style>

<style lang="scss" scoped>
.admin-layout {
  min-height: 100vh;
  background: #f7f8fa;
}

/* ── Header ── */
.admin-layout__header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

/* ── Top bar ── */
.admin-topbar {
  border-bottom: 1px solid #f0f0f0;
}

.admin-topbar__inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  height: 56px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.admin-logo {
  display: flex;
  align-items: center;
  gap: 6px;
  text-decoration: none;
  flex-shrink: 0;
  margin-right: 16px;
}

.admin-logo__text {
  font-size: 22px;
  font-weight: 700;
  color: #6c5ce7;
  letter-spacing: -0.5px;
}

.admin-logo__badge {
  font-size: 11px;
  font-weight: 600;
  color: #fff;
  background: #6c5ce7;
  padding: 2px 7px;
  border-radius: 4px;
  line-height: 1.3;
}

/* ── Nav items ── */
.admin-nav {
  display: flex;
  align-items: center;
  gap: 4px;
  flex: 1;
  min-width: 0;
}

.admin-nav__item {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 8px 14px;
  border-radius: 8px;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  white-space: nowrap;
  transition: background 0.2s, color 0.2s;

  i {
    font-size: 16px;
  }

  &:hover {
    background: #f5f3ff;
    color: #6c5ce7;
  }

  &.is-active {
    background: #f0edff;
    color: #6c5ce7;
    font-weight: 600;
  }
}

/* ── Right side ── */
.admin-topbar__right {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-shrink: 0;
  margin-left: auto;
}

.admin-back-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
  color: #606266;
  text-decoration: none;
  border: 1px solid #e4e7ed;
  transition: all 0.2s;

  &:hover {
    color: #6c5ce7;
    border-color: #6c5ce7;
    background: #f5f3ff;
  }
}

.admin-avatar {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
}

.admin-avatar__img {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}

.admin-avatar__name {
  font-size: 14px;
  color: #333;
  max-width: 80px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ── Sub nav ── */
.admin-subnav {
  background: #fff;
}

.admin-subnav__inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  height: 44px;
  display: flex;
  align-items: center;
  gap: 32px;
}

.admin-subnav__item {
  text-decoration: none;
  font-size: 15px;
  font-weight: 500;
  color: #909399;
  line-height: 44px;
  border-bottom: 2px solid transparent;
  transition: color 0.2s, border-color 0.2s;

  &:hover {
    color: #333;
  }

  &.is-active {
    color: #6c5ce7;
    border-bottom-color: #6c5ce7;
  }
}

/* ── Content ── */
.admin-layout__content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
  min-height: calc(100vh - 100px);
}

/* ── Transition ── */
.fade-transform-leave-active,
.fade-transform-enter-active {
  transition: all 0.2s;
}

.fade-transform-enter {
  opacity: 0;
  transform: translateY(8px);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
