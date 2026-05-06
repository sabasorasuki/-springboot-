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
          @click="onFilterChange(tag)"
        >{{ tag }}</span>
      </div>
    </section>

    <!-- 企划列表 -->
    <section class="section">
      <div class="project-list">
        <div
          v-for="project in projects"
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
            <div class="publisher publisher--clickable" @click.stop="goPublisher(project.userId)">
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
        v-if="!projects.length && !loading"
        description="暂无匹配企划"
        :image-size="120"
      />

      <div v-if="total > projects.length" class="load-more">
        <el-button :loading="loading" type="text" @click="loadMore">加载更多</el-button>
      </div>
    </section>
  </div>
</template>

<script>
import projectApi from '@/api/project'
import { buildOtherClientProfileRoute } from '@/utils/centerProfile'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'ProjectsPage',
  data() {
    return {
      projects: [],
      total: 0,
      pageNo: 1,
      loading: false,
      activeFilter: '全部',
      filterTags: ['全部', '插画', '立绘', '头像']
    }
  },
  created() {
    this.fetchProjects()
  },
  methods: {
    async fetchProjects() {
      this.loading = true
      try {
        const category = this.activeFilter === '全部' ? undefined : this.activeFilter
        const res = await projectApi.getList({
          pageNo: this.pageNo,
          pageSize: 12,
          category
        })
        if (res.data && res.code === 20000) {
          const rows = (res.data.rows || []).map(p => ({
            ...p,
            userAvatar: p.userAvatar || defaultAvatar
          }))
          if (this.pageNo === 1) {
            this.projects = rows
          } else {
            this.projects = this.projects.concat(rows)
          }
          this.total = res.data.total || 0
        }
      } catch (e) {
        console.error('获取企划列表失败', e)
      } finally {
        this.loading = false
      }
    },
    onFilterChange(tag) {
      this.activeFilter = tag
      this.pageNo = 1
      this.fetchProjects()
    },
    loadMore() {
      this.pageNo++
      this.fetchProjects()
    },
    statusClass(status) {
      const map = { '招募中': 'open', '进行中': 'active', '已完成': 'done', '已关闭': 'closed' }
      return map[status] || 'open'
    },
    goDetail(id) {
      this.$router.push('/project/' + id)
    },
    goPublisher(userId) {
      if (!userId) return
      this.$router.push(buildOtherClientProfileRoute(userId, 'projects'))
    },
    onApply(id) {
      this.$router.push({
        path: '/project/' + id,
        query: { apply: '1' }
      })
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

.publisher--clickable {
  cursor: pointer;
}

.publisher--clickable:hover .publisher-name {
  color: #6c5ce7;
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

.load-more {
  text-align: center;
  margin-top: 24px;
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
