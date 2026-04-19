<template>
  <div class="main-layout">
    <header class="main-layout__header">
      <!-- 第一排：功能导航 -->
      <div class="main-layout__topbar">
        <div class="topbar-inner">
          <router-link to="/home" class="topbar-logo">
            <span class="logo-text">Artistsion</span>
          </router-link>

          <div class="topbar-search">
            <el-input
              v-model="searchQuery"
              placeholder="搜索作品、画师..."
              prefix-icon="el-icon-search"
              clearable
              size="medium"
              @keyup.enter.native="handleSearch"
            />
          </div>

          <div class="topbar-actions">
            <template v-if="token">
              <el-badge :value="0" :hidden="true" class="action-item">
                <i class="el-icon-chat-dot-round" title="消息" />
              </el-badge>
              <el-badge :value="0" :hidden="true" class="action-item">
                <i class="el-icon-bell" title="通知" />
              </el-badge>

              <el-dropdown trigger="click" @command="handleAvatarCommand">
                <div class="avatar-wrapper">
                  <img
                    :src="avatar || defaultAvatar"
                    class="avatar-img"
                    alt="avatar"
                  >
                  <span class="avatar-name">{{ name || '用户' }}</span>
                  <i class="el-icon-arrow-down" />
                </div>
                <el-dropdown-menu slot="dropdown">
                  <el-dropdown-item command="center">
                    <i class="el-icon-user" /> 个人中心
                  </el-dropdown-item>
                  <el-dropdown-item command="submissions">
                    <i class="el-icon-edit" /> 投稿
                  </el-dropdown-item>
                  <el-dropdown-item command="favorites">
                    <i class="el-icon-star-off" /> 收藏
                  </el-dropdown-item>
                  <el-dropdown-item command="cart">
                    <i class="el-icon-shopping-cart-2" /> 购物车
                  </el-dropdown-item>
                  <el-dropdown-item command="orders">
                    <i class="el-icon-document" /> 订单
                  </el-dropdown-item>
                  <el-dropdown-item v-if="roles.length > 1" divided command="switchRole">
                    <i class="el-icon-sort" /> 切换身份
                    <span class="role-badge">{{ activeRoleLabel }}</span>
                  </el-dropdown-item>
                  <el-dropdown-item divided command="logout">
                    <i class="el-icon-switch-button" /> 退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </el-dropdown>
            </template>
            <template v-else>
              <router-link to="/auth" class="topbar-login-btn">
                登录 / 注册
              </router-link>
            </template>
          </div>
        </div>
      </div>

      <!-- 第二排：站点一级导航 -->
      <nav class="main-layout__sitenav">
        <div class="sitenav-inner">
          <router-link
            v-for="item in navItems"
            :key="item.path"
            :to="item.path"
            class="sitenav-link"
            :class="{ 'is-active': isNavActive(item.path) }"
          >
            {{ item.label }}
          </router-link>
        </div>
      </nav>
    </header>

    <!-- 页面内容区 -->
    <main class="main-layout__content">
      <router-view />
    </main>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { switchRole } from '@/api/auth'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const ROLE_LABELS = {
  '用户角色': '客户',
  '画师角色': '画师',
  'admin': '管理员'
}

export default {
  name: 'MainLayout',
  data() {
    return {
      defaultAvatar,
      searchQuery: '',
      navItems: [
        { path: '/home', label: '首页' },
        { path: '/artists', label: '画师' },
        { path: '/projects', label: '企划' },
        { path: '/works', label: '作品' },
        { path: '/showcase', label: '橱窗' }
      ]
    }
  },
  computed: {
    ...mapGetters(['avatar', 'name', 'token', 'roles', 'activeRole']),
    activeRoleLabel() {
      return ROLE_LABELS[this.activeRole] || this.activeRole || ''
    }
  },
  methods: {
    isNavActive(path) {
      return this.$route.path === path || this.$route.path.startsWith(path + '/')
    },
    handleSearch() {
      if (this.searchQuery.trim()) {
        this.$message.info('搜索功能即将上线')
      }
    },
    async handleAvatarCommand(command) {
      switch (command) {
        case 'center':
          this.$router.push('/center/profile')
          break
        case 'submissions':
          this.$router.push('/center/submissions')
          break
        case 'favorites':
          this.$router.push('/center/favorites')
          break
        case 'cart':
          this.$router.push('/center/cart')
          break
        case 'orders':
          this.$router.push('/center/orders')
          break
        case 'switchRole':
          await this.doSwitchRole()
          break
        case 'logout':
          await this.$store.dispatch('user/logout')
          this.$router.push('/auth')
          break
      }
    },
    async doSwitchRole() {
      const otherRoles = this.roles.filter(r => r !== this.activeRole)
      if (otherRoles.length === 0) {
        this.$message.warning('您当前只有一个身份')
        return
      }
      // 如果只有一个可切换身份，直接切换；否则弹选择
      const targetRole = otherRoles.length === 1
        ? otherRoles[0]
        : await this.promptRoleSelection(otherRoles)
      if (!targetRole) return

      try {
        await switchRole({ role: targetRole })
        this.$store.commit('user/SET_ACTIVE_ROLE', targetRole)
        const label = ROLE_LABELS[targetRole] || targetRole
        this.$message.success(`已切换为${label}`)
      } catch (err) {
        this.$message.error(err.message || '切换失败')
      }
    },
    promptRoleSelection(availableRoles) {
      const labels = availableRoles.map(r => ROLE_LABELS[r] || r)
      const h = this.$createElement
      let selectedIdx = 0
      const radioGroup = h('el-radio-group', {
        props: { value: 0 },
        on: { input: val => { selectedIdx = val } },
        style: 'display:flex;flex-direction:column;gap:10px;margin-top:10px;'
      }, availableRoles.map((r, i) =>
        h('el-radio', { props: { label: i } }, [labels[i]])
      ))
      return this.$msgbox({
        title: '切换身份',
        message: radioGroup,
        showCancelButton: true,
        confirmButtonText: '确定',
        cancelButtonText: '取消'
      }).then(() => availableRoles[selectedIdx]).catch(() => null)
    }
  }
}
</script>

<style lang="scss" scoped>
.main-layout {
  min-height: 100vh;
  background: #f7f8fa;
}

.main-layout__header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

/* ── 第一排 ── */
.main-layout__topbar {
  border-bottom: 1px solid #f0f0f0;
}

.topbar-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  height: 56px;
  display: flex;
  align-items: center;
  gap: 24px;
}

.topbar-logo {
  text-decoration: none;
  flex-shrink: 0;
}

.logo-text {
  font-size: 22px;
  font-weight: 700;
  color: #6c5ce7;
  letter-spacing: -0.5px;
}

.topbar-search {
  flex: 1;
  max-width: 480px;

  ::v-deep .el-input__inner {
    border-radius: 20px;
    background: #f7f8fa;
    border-color: #eee;

    &:focus {
      border-color: #6c5ce7;
      background: #fff;
    }
  }
}

.topbar-actions {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-shrink: 0;

  .action-item {
    cursor: pointer;
    font-size: 20px;
    color: #666;
    transition: color 0.2s;

    &:hover {
      color: #6c5ce7;
    }
  }
}

.avatar-wrapper {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
}

.avatar-img {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}

.avatar-name {
  font-size: 14px;
  color: #333;
  max-width: 80px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.topbar-login-btn {
  display: inline-block;
  padding: 6px 20px;
  font-size: 14px;
  font-weight: 500;
  color: #fff;
  background: #6c5ce7;
  border-radius: 20px;
  text-decoration: none;
  transition: background 0.2s;

  &:hover {
    background: #5a4bd1;
  }
}

.role-badge {
  display: inline-block;
  margin-left: 6px;
  padding: 1px 6px;
  font-size: 11px;
  color: #6c5ce7;
  background: #f0ecff;
  border-radius: 8px;
}

/* ── 第二排 ── */
.main-layout__sitenav {
  background: #fff;
}

.sitenav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  height: 44px;
  display: flex;
  align-items: center;
  gap: 32px;
}

.sitenav-link {
  text-decoration: none;
  font-size: 15px;
  font-weight: 500;
  color: #666;
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

/* ── 内容区 ── */
.main-layout__content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
  min-height: calc(100vh - 100px);
}
</style>
