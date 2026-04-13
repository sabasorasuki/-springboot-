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
        <div class="publisher-row">
          <el-avatar :size="36" :src="project.userAvatar" icon="el-icon-user" />
          <span class="publisher-name">{{ project.username }}</span>
        </div>

        <!-- 操作 -->
        <div class="action-row">
          <el-button type="primary" round icon="el-icon-edit">我要应征</el-button>
          <el-button round icon="el-icon-star-off">收藏企划</el-button>
        </div>
      </div>
    </template>
    <el-empty v-else description="企划不存在" />
  </div>
</template>

<script>
const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const mockProjects = [
  { id: 1, title: '原创小说封面插画', description: '需要一张竖版小说封面，古风仙侠题材，主角为一男一女，画面需有仙鹤和云海元素。', category: '插画', style: '国风', budgetMin: 800, budgetMax: 1500, deadline: '2026-05-15', status: '招募中', userId: 10, username: '云中书客', userAvatar: defaultAvatar },
  { id: 2, title: 'VTuber 形象立绘', description: '需要 Live2D 可用的全身立绘，日系风格，角色为猫耳少女，需要三套表情差分。', category: '立绘', style: '日系', budgetMin: 2000, budgetMax: 4000, deadline: '2026-05-01', status: '招募中', userId: 11, username: 'NekoChannel', userAvatar: defaultAvatar },
  { id: 3, title: '情侣头像定制一对', description: 'Q版情侣头像，背景可爱简洁，希望能体现两人的性格差异。', category: '头像', style: 'Q版', budgetMin: 200, budgetMax: 500, deadline: '2026-04-28', status: '招募中', userId: 12, username: '甜筒酱', userAvatar: defaultAvatar },
  { id: 4, title: '桌游卡牌原画 (10 张)', description: '独立桌游项目需要10张角色卡牌原画，欧美奇幻风格，含简单场景背景。', category: '插画', style: '欧美', budgetMin: 5000, budgetMax: 10000, deadline: '2026-06-30', status: '招募中', userId: 13, username: 'BoardCraft', userAvatar: defaultAvatar },
  { id: 5, title: '个人 IP 吉祥物设计', description: '品牌吉祥物设计，需要一个可爱的柴犬形象，包含三视图和配色方案。', category: '立绘', style: 'Q版', budgetMin: 1000, budgetMax: 2000, deadline: '2026-05-20', status: '进行中', userId: 14, username: 'ShibaLab', userAvatar: defaultAvatar },
  { id: 6, title: '水彩风游记插图 (5 张)', description: '旅行公众号需要5张水彩风景插图，主题包括海边、古镇、雪山等。', category: '插画', style: '写实', budgetMin: 1500, budgetMax: 3000, deadline: '2026-05-10', status: '招募中', userId: 15, username: '走走停停', userAvatar: defaultAvatar }
]

export default {
  name: 'ProjectDetail',
  data() {
    return {
      loading: true,
      project: null
    }
  },
  computed: {
    statusClass() {
      if (!this.project) return ''
      const map = { '招募中': 'recruiting', '进行中': 'ongoing', '已完成': 'done', '已关闭': 'closed' }
      return map[this.project.status] || ''
    }
  },
  created() {
    this.fetchProject()
  },
  methods: {
    fetchProject() {
      const id = Number(this.$route.params.id)
      this.project = mockProjects.find(p => p.id === id) || null
      this.loading = false
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
