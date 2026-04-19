<template>
  <div class="center-follows-page">
    <h1 class="page-title">关注</h1>

    <div v-if="userId" class="follow-stats">
      <span class="stat-item">关注 <strong>{{ stats.following }}</strong></span>
      <span class="stat-sep">|</span>
      <span class="stat-item">粉丝 <strong>{{ stats.followers }}</strong></span>
    </div>

    <el-tabs v-model="activeTab" type="card" @tab-click="onTabChange">
      <!-- 已关注 -->
      <el-tab-pane label="已关注" name="following">
        <div v-if="following.loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
        <template v-else>
          <div v-if="following.list.length" class="user-list">
            <div v-for="user in following.list" :key="user.id" class="user-card">
              <img :src="user.avatar || defaultAvatar" class="user-avatar" alt="" @click="goArtist(user.id)">
              <div class="user-info" @click="goArtist(user.id)">
                <div class="user-name">{{ user.name || user.username }}</div>
                <div v-if="user.bio" class="user-bio">{{ user.bio }}</div>
                <div v-if="user.styleTags" class="user-tags">
                  <span v-for="tag in user.styleTags.split(',')" :key="tag" class="style-tag">{{ tag }}</span>
                </div>
              </div>
              <el-button size="small" type="info" plain @click="handleUnfollow(user)">取消关注</el-button>
            </div>
          </div>
          <el-empty v-else description="暂无关注" :image-size="120">
            <el-button type="primary" size="small" @click="$router.push('/artists')">发现画师</el-button>
          </el-empty>
          <div v-if="following.total > following.pageSize" class="pager">
            <el-pagination background layout="prev, pager, next" :total="following.total" :page-size="following.pageSize" :current-page.sync="following.pageNo" @current-change="fetchFollowing" />
          </div>
        </template>
      </el-tab-pane>

      <!-- 粉丝 -->
      <el-tab-pane label="粉丝" name="followers">
        <div v-if="followers.loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
        <template v-else>
          <div v-if="followers.list.length" class="user-list">
            <div v-for="user in followers.list" :key="user.id" class="user-card">
              <img :src="user.avatar || defaultAvatar" class="user-avatar" alt="" @click="goArtist(user.id)">
              <div class="user-info" @click="goArtist(user.id)">
                <div class="user-name">{{ user.name || user.username }}</div>
                <div v-if="user.bio" class="user-bio">{{ user.bio }}</div>
              </div>
              <el-button
                v-if="!isFollowingUser(user.id)"
                size="small"
                type="primary"
                @click="handleFollow(user)"
              >关注</el-button>
              <el-tag v-else size="small" type="success">互关</el-tag>
            </div>
          </div>
          <el-empty v-else description="暂无粉丝" :image-size="120" />
          <div v-if="followers.total > followers.pageSize" class="pager">
            <el-pagination background layout="prev, pager, next" :total="followers.total" :page-size="followers.pageSize" :current-page.sync="followers.pageNo" @current-change="fetchFollowers" />
          </div>
        </template>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import followApi from '@/api/follow'
import userApi from '@/api/userManage'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'CenterFollows',
  data() {
    return {
      defaultAvatar,
      activeTab: 'following',
      userId: null,
      stats: { following: 0, followers: 0 },
      followingIds: new Set(),
      following: { list: [], total: 0, pageNo: 1, pageSize: 20, loading: false },
      followers: { list: [], total: 0, pageNo: 1, pageSize: 20, loading: false }
    }
  },
  computed: {
    ...mapGetters(['token'])
  },
  async created() {
    const res = await userApi.getInfo(this.token)
    this.userId = res.data.userList.id
    this.fetchStats()
    this.fetchFollowing()
  },
  methods: {
    async fetchStats() {
      try {
        const res = await followApi.count(this.userId)
        this.stats = res.data || { following: 0, followers: 0 }
      } catch { /* ignore */ }
    },
    onTabChange(tab) {
      if (tab.name === 'following' && !this.following.list.length && !this.following.loading) this.fetchFollowing()
      if (tab.name === 'followers' && !this.followers.list.length && !this.followers.loading) this.fetchFollowers()
    },
    async fetchFollowing() {
      this.following.loading = true
      try {
        const res = await followApi.getFollowing({ userId: this.userId, pageNo: this.following.pageNo, pageSize: this.following.pageSize })
        this.following.list = res.data.rows || []
        this.following.total = res.data.total || 0
        // 缓存已关注的 ID 集合
        this.followingIds = new Set(this.following.list.map(u => u.id))
      } finally { this.following.loading = false }
    },
    async fetchFollowers() {
      this.followers.loading = true
      try {
        const res = await followApi.getFollowers({ userId: this.userId, pageNo: this.followers.pageNo, pageSize: this.followers.pageSize })
        this.followers.list = res.data.rows || []
        this.followers.total = res.data.total || 0
      } finally { this.followers.loading = false }
    },
    isFollowingUser(id) {
      return this.followingIds.has(id)
    },
    goArtist(id) {
      this.$router.push('/artist/' + id)
    },
    async handleUnfollow(user) {
      try {
        await followApi.unfollow({ followerId: this.userId, followingId: user.id })
        this.$message.success('已取消关注')
        this.followingIds.delete(user.id)
        this.fetchFollowing()
        this.fetchStats()
      } catch {
        this.$message.error('操作失败')
      }
    },
    async handleFollow(user) {
      try {
        await followApi.follow({ followerId: this.userId, followingId: user.id })
        this.$message.success('关注成功')
        this.followingIds.add(user.id)
        this.fetchStats()
        this.$forceUpdate()
      } catch {
        this.$message.error('操作失败')
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.center-follows-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 32px 20px;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 12px;
}
.follow-stats {
  margin-bottom: 20px;
  font-size: 14px;
  color: #666;
  strong { color: #333; font-size: 16px; }
}
.stat-sep {
  margin: 0 12px;
  color: #ddd;
}
.loading-box {
  text-align: center;
  padding: 60px 0;
  color: #999;
}
.user-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.user-card {
  display: flex;
  align-items: center;
  gap: 14px;
  background: #fff;
  border-radius: 10px;
  padding: 14px 18px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.05);
}
.user-avatar {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  object-fit: cover;
  cursor: pointer;
  flex-shrink: 0;
}
.user-info {
  flex: 1;
  min-width: 0;
  cursor: pointer;
}
.user-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
}
.user-bio {
  font-size: 12px;
  color: #999;
  margin-top: 2px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.user-tags {
  margin-top: 4px;
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}
.style-tag {
  font-size: 11px;
  background: #f0f0f0;
  color: #666;
  padding: 1px 6px;
  border-radius: 3px;
}
.pager {
  margin-top: 20px;
  text-align: center;
}
</style>
