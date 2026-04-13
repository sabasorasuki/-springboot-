<template>
  <div class="projects-page">
    <section class="page-header">
      <h1 class="page-title">企划大厅</h1>
      <p class="page-desc">浏览委托需求，找到适合的项目机会</p>
    </section>

    <!-- 筛选区 -->
    <section class="section">
      <div class="filter-bar">
        <span
          v-for="tag in filterTags"
          :key="tag"
          class="filter-tag"
          :class="{ 'is-active': activeFilter === tag }"
          @click="activeFilter = tag"
        >{{ tag }}</span>
      </div>
    </section>

    <!-- 企划列表 -->
    <section class="section">
      <div class="project-list">
        <div
          v-for="project in filteredProjects"
          :key="project.id"
          class="project-card"
        >
          <div class="project-card__body">
            <h3 class="project-title">{{ project.title }}</h3>
            <p class="project-desc">{{ project.description }}</p>
          </div>
          <div class="project-card__meta">
            <span class="meta-tag">{{ project.category }}</span>
            <span v-if="project.style" class="meta-tag meta-tag--style">{{ project.style }}</span>
            <span class="meta-text">
              预算 ¥{{ project.budgetMin }}–{{ project.budgetMax }}
            </span>
            <span class="meta-text">
              截止 {{ project.deadline }}
            </span>
            <span
              class="status-badge"
              :class="'status-badge--' + statusClass(project.status)"
            >{{ project.status }}</span>
          </div>
          <div class="project-card__footer">
            <div class="publisher">
              <img :src="project.userAvatar" class="publisher-avatar" alt="">
              <span class="publisher-name">{{ project.username }}</span>
            </div>
            <div class="project-actions">
              <el-button size="small" type="primary" plain @click="goDetail(project.id)">
                查看详情
              </el-button>
              <el-button size="small" plain @click="onApply(project.id)">
                立即应征
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <el-empty
        v-if="!filteredProjects.length"
        description="暂无匹配企划"
        :image-size="120"
      />
    </section>

    <!-- 数据说明 -->
    <section class="section data-note">
      <p>当前为示例数据，企划发布功能即将上线。</p>
    </section>
  </div>
</template>

<script>
/**
 * 企划页 — 本阶段使用静态 mock 数据。
 *
 * 目标后端表结构 (sys_project)：
 *   id          BIGINT AUTO_INCREMENT PRIMARY KEY
 *   title       VARCHAR(200)  NOT NULL  -- 企划标题
 *   description TEXT                    -- 需求描述
 *   category    VARCHAR(50)             -- 分类（插画/立绘/头像等）
 *   style       VARCHAR(50)             -- 风格偏好
 *   budget_min  DECIMAL(10,2)           -- 预算下限
 *   budget_max  DECIMAL(10,2)           -- 预算上限
 *   deadline    DATE                    -- 截稿日期
 *   status      VARCHAR(20) DEFAULT '招募中' -- 招募中/进行中/已完成/已关闭
 *   user_id     BIGINT NOT NULL         -- 发布者ID
 *   username    VARCHAR(50)             -- 发布者名称（冗余）
 *   user_avatar VARCHAR(500)            -- 发布者头像（冗余）
 *   created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
 *   updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
 *
 * TODO: 后端建表后，替换 mockProjects 为 /sysProject/list 接口调用
 */

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const mockProjects = [
  {
    id: 1,
    title: '原创小说封面插画',
    description: '需要一张竖版小说封面，古风仙侠题材，主角为一男一女，画面需有仙鹤和云海元素。',
    category: '插画',
    style: '国风',
    budgetMin: 800,
    budgetMax: 1500,
    deadline: '2026-05-15',
    status: '招募中',
    userId: 10,
    username: '云中书客',
    userAvatar: defaultAvatar
  },
  {
    id: 2,
    title: 'VTuber 形象立绘',
    description: '需要 Live2D 可用的全身立绘，日系风格，角色为猫耳少女，需要三套表情差分。',
    category: '立绘',
    style: '日系',
    budgetMin: 2000,
    budgetMax: 4000,
    deadline: '2026-05-01',
    status: '招募中',
    userId: 11,
    username: 'NekoChannel',
    userAvatar: defaultAvatar
  },
  {
    id: 3,
    title: '情侣头像定制一对',
    description: 'Q版情侣头像，背景可爱简洁，希望能体现两人的性格差异。',
    category: '头像',
    style: 'Q版',
    budgetMin: 200,
    budgetMax: 500,
    deadline: '2026-04-28',
    status: '招募中',
    userId: 12,
    username: '甜筒酱',
    userAvatar: defaultAvatar
  },
  {
    id: 4,
    title: '桌游卡牌原画 (10 张)',
    description: '独立桌游项目需要10张角色卡牌原画，欧美奇幻风格，含简单场景背景。',
    category: '插画',
    style: '欧美',
    budgetMin: 5000,
    budgetMax: 10000,
    deadline: '2026-06-30',
    status: '招募中',
    userId: 13,
    username: 'BoardCraft',
    userAvatar: defaultAvatar
  },
  {
    id: 5,
    title: '个人 IP 吉祥物设计',
    description: '品牌吉祥物设计，需要一个可爱的柴犬形象，包含三视图和配色方案。',
    category: '立绘',
    style: 'Q版',
    budgetMin: 1000,
    budgetMax: 2000,
    deadline: '2026-05-20',
    status: '进行中',
    userId: 14,
    username: 'ShibaLab',
    userAvatar: defaultAvatar
  },
  {
    id: 6,
    title: '水彩风游记插图 (5 张)',
    description: '旅行公众号需要5张水彩风景插图，主题包括海边、古镇、雪山等。',
    category: '插画',
    style: '写实',
    budgetMin: 1500,
    budgetMax: 3000,
    deadline: '2026-05-10',
    status: '招募中',
    userId: 15,
    username: '走走停停',
    userAvatar: defaultAvatar
  }
]

export default {
  name: 'ProjectsPage',
  data() {
    return {
      projects: mockProjects,
      activeFilter: '全部',
      filterTags: ['全部', '插画', '立绘', '头像']
    }
  },
  computed: {
    filteredProjects() {
      if (this.activeFilter === '全部') return this.projects
      return this.projects.filter(p => p.category === this.activeFilter)
    }
  },
  methods: {
    statusClass(status) {
      const map = { '招募中': 'open', '进行中': 'active', '已完成': 'done', '已关闭': 'closed' }
      return map[status] || 'open'
    },
    goDetail(id) {
      this.$router.push('/project/' + id)
    },
    onApply(id) {
      // TODO: Phase 5 — 应征流程
      this.$message.info('应征功能即将上线')
    }
  }
}
</script>

<style lang="scss" scoped>
.projects-page {
  padding-bottom: 60px;
}

.page-header {
  text-align: center;
  padding: 40px 0 24px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px;
}

.page-desc {
  font-size: 15px;
  color: #888;
  margin: 0;
}

/* ── 筛选栏 ── */
.section {
  margin-top: 32px;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
}

.filter-tag {
  display: inline-block;
  padding: 6px 18px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 20px;
  font-size: 14px;
  color: #555;
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    color: #6c5ce7;
    border-color: #6c5ce7;
  }

  &.is-active {
    color: #fff;
    background: #6c5ce7;
    border-color: #6c5ce7;
  }
}

/* ── 企划列表 ── */
.project-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.project-card {
  background: #fff;
  border-radius: 14px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  }
}

.project-card__body {
  margin-bottom: 14px;
}

.project-title {
  font-size: 17px;
  font-weight: 600;
  color: #333;
  margin: 0 0 8px;
}

.project-desc {
  font-size: 14px;
  color: #666;
  line-height: 1.6;
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ── 元信息区 ── */
.project-card__meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 16px;
}

.meta-tag {
  font-size: 12px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 3px 10px;
  border-radius: 4px;
}

.meta-tag--style {
  color: #e17055;
  background: rgba(225, 112, 85, 0.08);
}

.meta-text {
  font-size: 13px;
  color: #999;
}

.status-badge {
  font-size: 12px;
  padding: 3px 10px;
  border-radius: 4px;
  font-weight: 500;

  &--open {
    color: #00b894;
    background: rgba(0, 184, 148, 0.1);
  }

  &--active {
    color: #0984e3;
    background: rgba(9, 132, 227, 0.1);
  }

  &--done {
    color: #636e72;
    background: rgba(99, 110, 114, 0.1);
  }

  &--closed {
    color: #d63031;
    background: rgba(214, 48, 49, 0.1);
  }
}

/* ── 底部：发布者 + 按钮 ── */
.project-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.publisher {
  display: flex;
  align-items: center;
  gap: 8px;
}

.publisher-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  background: #f0e8f5;
}

.publisher-name {
  font-size: 13px;
  color: #666;
}

.project-actions {
  display: flex;
  gap: 10px;
}

/* ── 数据说明 ── */
.data-note {
  text-align: center;
  p {
    font-size: 13px;
    color: #bbb;
    margin: 0;
  }
}

/* ── 响应式 ── */
@media (max-width: 600px) {
  .project-card__footer {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}
</style>
