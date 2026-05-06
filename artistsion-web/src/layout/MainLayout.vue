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
              placeholder="搜索橱窗画稿、分类、标签..."
              prefix-icon="el-icon-search"
              clearable
              size="medium"
              @clear="clearSearch"
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

              <!-- 主操作按钮：画师模式=投稿，用户模式=发布需求 -->
              <el-button type="primary" size="small" class="main-action-btn" @click="handleMainAction">
                {{ displayMode === 'artist' ? '投稿' : '发布需求' }}
              </el-button>

              <el-dropdown trigger="click" @command="handleAvatarCommand">
                <div class="avatar-wrapper">
                  <img
                    :src="headerAvatar"
                    class="avatar-img"
                    alt="avatar"
                  >
                  <span class="avatar-name">{{ name || '用户' }}</span>
                  <i class="el-icon-arrow-down" />
                </div>
                <el-dropdown-menu slot="dropdown">
                  <el-dropdown-item
                    v-for="item in avatarDropdownItems"
                    :key="item.command"
                    :command="item.command"
                  >
                    <i :class="item.icon" /> {{ item.label }}
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
import { normalizeImageUrl } from '@/utils/oss'
import { getCenterDropdownItems, getCenterDropdownRoute } from '@/utils/centerProfile'

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
        { path: '/projects', label: '企划' },
        { path: '/works', label: '作品' },
        { path: '/showcase', label: '橱窗' }
      ]
    }
  },
  computed: {
    ...mapGetters(['avatar', 'name', 'token', 'roles', 'displayMode']),
    headerAvatar() {
      return normalizeImageUrl(this.avatar) || this.defaultAvatar
    },
    avatarDropdownItems() {
      return getCenterDropdownItems(this.displayMode)
    }
  },
  watch: {
    '$route.query.keyword': {
      immediate: true,
      handler(keyword) {
        this.searchQuery = keyword ? String(keyword) : ''
      }
    }
  },
  methods: {
    isNavActive(path) {
      return this.$route.path === path || this.$route.path.startsWith(path + '/')
    },
    handleSearch() {
      const keyword = this.searchQuery.trim()
      if (!keyword) {
        this.clearSearch()
        return
      }
      const query = {
        keyword
      }
      this.$router.push({
        path: '/showcase',
        query
      }).catch(() => {})
    },
    clearSearch() {
      if (this.$route.path !== '/showcase' || !this.$route.query.keyword) {
        return
      }
      const query = { ...this.$route.query }
      delete query.keyword
      this.$router.replace({
        path: '/showcase',
        query
      }).catch(() => {})
    },
    handleMainAction() {
      if (this.displayMode === 'artist') {
        this.$router.push('/publish/work')
      } else {
        this.$router.push('/publish/project')
      }
    },
    async handleAvatarCommand(command) {
      if (command === 'logout') {
        await this.$store.dispatch('user/logout')
        this.$router.push('/auth')
        return
      }

      const target = getCenterDropdownRoute(command, this.displayMode)
      this.$router.push(target).catch(() => {})
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

.main-action-btn {
  margin-right: 4px;
  min-width: 88px;
  background: #6c5ce7;
  border-color: #6c5ce7;
  border-radius: 20px;
  font-size: 13px;

  &:hover,
  &:focus {
    background: #5a4bd1;
    border-color: #5a4bd1;
  }
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
