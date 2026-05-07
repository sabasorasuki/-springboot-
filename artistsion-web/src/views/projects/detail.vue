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
          <el-button
            v-if="!isOwner"
            type="primary"
            round
            icon="el-icon-edit"
            :disabled="!canApply"
            @click="openApplyDialog"
          >
            {{ canApply ? '我要应征' : '暂不可应征' }}
          </el-button>
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

      <div v-if="isOwner" class="applications-card">
        <div class="applications-header">
          <h2>应征记录</h2>
          <span>{{ applicationTotal }} 条</span>
        </div>
        <div v-if="applicationLoading" class="applications-loading">
          <i class="el-icon-loading" /> 加载中…
        </div>
        <div v-else-if="applications.length" class="application-list">
          <div
            v-for="application in applications"
            :key="application.id"
            class="application-item"
          >
            <el-avatar :size="34" :src="application.applicantAvatar" icon="el-icon-user" />
            <div class="application-main">
              <div class="application-top">
                <span class="application-name">{{ application.applicantName || '应征者' }}</span>
                <span class="application-status">{{ application.status }}</span>
              </div>
              <p v-if="application.message" class="application-message">{{ application.message }}</p>
              <a
                v-if="application.portfolioUrl"
                class="application-link"
                :href="application.portfolioUrl"
                target="_blank"
                rel="noopener noreferrer"
              >
                查看作品集
              </a>
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无应征" :image-size="96" />
      </div>
    </template>
    <el-empty v-else description="企划不存在" />

    <el-dialog
      title="应征企划"
      :visible.sync="applyVisible"
      width="520px"
      append-to-body
    >
      <el-form ref="applyForm" :model="applyForm" :rules="applyRules" label-width="90px">
        <el-form-item label="应征说明" prop="message">
          <el-input
            v-model="applyForm.message"
            type="textarea"
            :rows="5"
            maxlength="1000"
            show-word-limit
            placeholder="介绍你的创作经验、档期和对该企划的理解"
          />
        </el-form-item>
        <el-form-item label="作品集链接">
          <el-input
            v-model.trim="applyForm.portfolioUrl"
            placeholder="可填写个人主页、作品集或代表作品链接"
          />
        </el-form-item>
      </el-form>
      <span slot="footer">
        <el-button @click="applyVisible = false">取消</el-button>
        <el-button type="primary" :loading="applyLoading" @click="submitApplication">提交应征</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import projectApi from '@/api/project'
import recApi from '@/api/rec'
import { buildCenterProfileRoute, buildOtherClientProfileRoute } from '@/utils/centerProfile'
import { createClientEventId } from '@/utils/visitor'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'ProjectDetail',
  data() {
    return {
      loading: true,
      project: null,
      deleteLoading: false,
      applyVisible: false,
      applyLoading: false,
      applyForm: {
        message: '',
        portfolioUrl: ''
      },
      applyRules: {
        message: [{ required: true, message: '请填写应征说明', trigger: 'blur' }]
      },
      applications: [],
      applicationTotal: 0,
      applicationLoading: false,
      detailViewTracked: false
    }
  },
  computed: {
    ...mapGetters(['userId', 'token']),
    statusClass() {
      if (!this.project) return ''
      const map = { '招募中': 'recruiting', '进行中': 'ongoing', '已完成': 'done', '已关闭': 'closed' }
      return map[this.project.status] || ''
    },
    isOwner() {
      if (!this.project || !this.userId) return false
      return Number(this.project.userId) === Number(this.userId)
    },
    canApply() {
      return this.project && this.project.status === '招募中'
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
          this.trackProjectAction('detail_view', 'project_detail_view')
          if (this.isOwner) {
            this.fetchApplications()
          }
          if (this.$route.query.apply === '1') {
            this.$nextTick(this.openApplyDialog)
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
    openApplyDialog() {
      if (!this.token) {
        this.$router.push('/auth')
        return
      }
      if (this.isOwner || !this.canApply) {
        return
      }
      this.applyVisible = true
    },
    submitApplication() {
      this.$refs.applyForm.validate(async valid => {
        if (!valid || !this.project) return
        this.applyLoading = true
        try {
          const res = await projectApi.apply({
            projectId: this.project.id,
            message: this.applyForm.message,
            portfolioUrl: this.applyForm.portfolioUrl
          })
          this.$message.success(res.message || '应征已提交')
          this.trackProjectAction('apply_project', 'project_apply_submit')
          this.applyVisible = false
          this.applyForm.message = ''
          this.applyForm.portfolioUrl = ''
          if (this.$route.query.apply) {
            const query = { ...this.$route.query }
            delete query.apply
            this.$router.replace({ path: this.$route.path, query }).catch(() => {})
          }
        } finally {
          this.applyLoading = false
        }
      })
    },
    async fetchApplications() {
      if (!this.project || !this.project.id) return
      this.applicationLoading = true
      try {
        const res = await projectApi.getApplications({
          projectId: this.project.id,
          pageNo: 1,
          pageSize: 50
        })
        this.applications = (res.data && res.data.rows) || []
        this.applicationTotal = (res.data && res.data.total) || 0
      } finally {
        this.applicationLoading = false
      }
    },
    goPublisherProfile() {
      if (!this.project || !this.project.userId) return
      this.$router.push(buildOtherClientProfileRoute(this.project.userId, 'projects'))
    },
    trackProjectAction(eventType, source) {
      if (!this.project || !this.project.id) return
      if (eventType === 'detail_view') {
        if (this.detailViewTracked) return
        this.detailViewTracked = true
      }
      recApi.trackAction({
        eventId: createClientEventId(eventType),
        eventType,
        domain: 'project',
        requestId: this.$route.query.requestId || '',
        itemId: this.project.id,
        authorId: this.project.userId,
        position: this.$route.query.position ? Number(this.$route.query.position) : null,
        scene: this.$route.query.scene || 'project_detail',
        source: source || this.$route.query.source || 'project_detail',
        modelVersion: this.$route.query.modelVersion || ''
      }).catch(() => {})
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

.applications-card {
  margin-top: 20px;
  background: #fff;
  border-radius: 12px;
  padding: 22px 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.applications-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;

  h2 {
    margin: 0;
    font-size: 18px;
    color: #333;
  }

  span {
    font-size: 13px;
    color: #999;
  }
}

.applications-loading {
  padding: 24px 0;
  text-align: center;
  color: #999;
}

.application-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.application-item {
  display: flex;
  gap: 12px;
  padding: 14px 0;
  border-top: 1px solid #f3f3f3;
}

.application-main {
  flex: 1;
  min-width: 0;
}

.application-top {
  display: flex;
  align-items: center;
  gap: 10px;
}

.application-name {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.application-status {
  font-size: 12px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 2px 8px;
  border-radius: 4px;
}

.application-message {
  margin: 8px 0 0;
  font-size: 13px;
  line-height: 1.6;
  color: #666;
  white-space: pre-wrap;
}

.application-link {
  display: inline-block;
  margin-top: 8px;
  font-size: 13px;
  color: #6c5ce7;
}
</style>
