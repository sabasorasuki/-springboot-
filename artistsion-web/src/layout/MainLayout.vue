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
                <i class="el-icon-arrow-down" />
              </div>
              <el-dropdown-menu slot="dropdown">
                <el-dropdown-item command="center">个人中心</el-dropdown-item>
                <el-dropdown-item command="orders">订单中心</el-dropdown-item>
                <el-dropdown-item command="messages">消息中心</el-dropdown-item>
                <el-dropdown-item divided command="switchRole">身份切换</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </el-dropdown>
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

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'MainLayout',
  data() {
    return {
      defaultAvatar,
      searchQuery: '',
      navItems: [
        { path: '/home', label: '首页' },
        { path: '/artists', label: '画师' },
        { path: '/projects', label: '企划' }
      ]
    }
  },
  computed: {
    ...mapGetters(['avatar', 'name'])
  },
  methods: {
    isNavActive(path) {
      return this.$route.path === path || this.$route.path.startsWith(path + '/')
    },
    handleSearch() {
      if (this.searchQuery.trim()) {
        // 后续接搜索页
        this.$message.info('搜索功能即将上线')
      }
    },
    handleAvatarCommand(command) {
      switch (command) {
        case 'center':
          this.$message.info('个人中心即将上线')
          break
        case 'orders':
          this.$message.info('订单中心即将上线')
          break
        case 'messages':
          this.$message.info('消息中心即将上线')
          break
        case 'switchRole':
          this.$message.info('身份切换即将上线')
          break
        case 'logout':
          this.$store.dispatch('user/logout').then(() => {
            this.$router.push('/auth')
          })
          break
      }
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
