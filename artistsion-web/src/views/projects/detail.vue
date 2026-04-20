<template>
  <div class="project-detail-page">
    <div v-if="loading" class="loading-box">
      <i class="el-icon-loading" /> 加载中…
    </div>
    <template v-else-if="project">
      <!-- 头部信息卡 -->
      <div class="project-card">
        <div class="card-header-row">
          <h1 class="project-title">{{ project.title }}</h1>
          <span :class="['status-badge', statusClass]">{{ project.status }}</span>
        </div>
        <p class="project-desc">{{ project.description }}</p>

        <!-- 标签行 -->
        <div class="tag-row">
          <span v-if="project.category" class="tag category">{{ project.category }}</span>
          <span v-if="project.style" class="tag style">{{ project.style }}</span>
        </div>

        <!-- 信息网格 -->
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">预算范围</span>
            <span class="info-value price">¥{{ project.budgetMin }} – ¥{{ project.budgetMax }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">截止日期</span>
            <span class="info-value">{{ project.deadline }}</span>
          </div>
        </div>

        <!-- 发布者 -->
        <div class="publisher-row publisher-row--clickable" @click="goPublisherProfile">
          <el-avatar :size="36" :src="project.userAvatar" icon="el-icon-user" />
          <span class="publisher-name">{{ project.username }}</span>
        </div>

        <!-- 操作 -->
        <div class="action-row">
          <el-button type="primary" round icon="el-icon-edit">我要应征</el-button>
          <el-button round icon="el-icon-star-off">收藏企划</el-button>
          <el-button
            v-if="isOwner"
            type="danger"
            plain
            round
            :loading="deleteLoading"
            @click="handleDelete"
          >
            删除企划
          </el-button>
        </div>
      </div>
    </template>
    <el-empty v-else description="企划不存在" />
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import projectApi from '@/api/project'
import { buildCenterProfileRoute, buildOtherClientProfileRoute } from '@/utils/centerProfile'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'ProjectDetail',
  data() {
    return {
      loading: true,
      project: null,
      deleteLoading: false
    }
  },
  computed: {
    ...mapGetters(['userId']),
    statusClass() {
      if (!this.project) return ''
      const map = { '招募中': 'recruiting', '进行中': 'ongoing', '已完成': 'done', '已关闭': 'closed' }
      return map[this.project.status] || ''
    },
    isOwner() {
      if (!this.project || !this.userId) return false
      return Number(this.project.userId) === Number(this.userId)
    }
  },
  created() {
    this.fetchProject()
  },
  methods: {
    async fetchProject() {
      const id = this.$route.params.id
      if (!id) { this.loading = false; return }
      try {
        const res = await projectApi.getById(id)
        if (res.data && res.code === 20000) {
          const p = res.data
          this.project = {
            ...p,
            userAvatar: p.userAvatar || defaultAvatar
          }
        }
      } catch (e) {
        console.error('获取企划详情失败', e)
      } finally {
        this.loading = false
      }
    },
    handleDelete() {
      if (!this.project || !this.project.id) return
      this.$confirm(`确认删除企划《${this.project.title || '未命名企划'}》吗？删除后无法恢复。`, '删除确认', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
        this.deleteLoading = true
        try {
          const res = await projectApi.deleteById(this.project.id)
          this.$message.success(res.message || '企划已删除')
          this.$router.replace(buildCenterProfileRoute({
            isSelf: true,
            viewMode: 'client',
            tab: 'projects'
          }))
        } finally {
          this.deleteLoading = false
        }
      }).catch(() => {})
    },
    goPublisherProfile() {
      if (!this.project || !this.project.userId) return
      this.$router.push(buildOtherClientProfileRoute(this.project.userId, 'projects'))
    }
  }
}
</script>

<style lang="scss" scoped>
.project-detail-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 32px 20px;
}

.loading-box {
  text-align: center;
  padding: 80px 0;
  color: #999;
  font-size: 16px;
}

.project-card {
  background: #fff;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.card-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.project-title {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin: 0;
}

.status-badge {
  font-size: 13px;
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 500;

  &.recruiting {
    color: #6c5ce7;
    background: rgba(108, 92, 231, 0.1);
  }
  &.ongoing {
    color: #00b894;
    background: rgba(0, 184, 148, 0.1);
  }
  &.done {
    color: #636e72;
    background: rgba(99, 110, 114, 0.1);
  }
  &.closed {
    color: #d63031;
    background: rgba(214, 48, 49, 0.1);
  }
}

.project-desc {
  font-size: 15px;
  line-height: 1.7;
  color: #555;
  margin: 0 0 20px 0;
}

.tag-row {
  display: flex;
  gap: 10px;
  margin-bottom: 24px;
}

.tag {
  font-size: 13px;
  padding: 3px 12px;
  border-radius: 4px;
}

.tag.category {
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
}

.tag.style {
  color: #e17055;
  background: rgba(225, 112, 85, 0.08);
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 24px;
  padding: 20px;
  background: #fafafa;
  border-radius: 10px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-label {
  font-size: 13px;
  color: #999;
}

.info-value {
  font-size: 15px;
  font-weight: 600;
  color: #333;

  &.price {
    color: #e17055;
  }
}

.publisher-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 24px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.publisher-row--clickable {
  cursor: pointer;
}

.publisher-row--clickable:hover .publisher-name {
  color: #6c5ce7;
}

.publisher-name {
  font-size: 14px;
  color: #555;
  font-weight: 500;
}

.action-row {
  display: flex;
  gap: 12px;
}
</style>
