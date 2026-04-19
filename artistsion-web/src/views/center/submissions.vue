<template>
  <div class="center-submissions-page">
    <h1 class="page-title">我的投稿</h1>
    <el-tabs v-model="activeTab" type="card" @tab-click="onTabChange">
      <!-- 作品 -->
      <el-tab-pane label="作品" name="works">
        <div v-if="works.loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
        <template v-else>
          <div v-if="works.list.length" class="card-grid">
            <div v-for="item in works.list" :key="item.id" class="sub-card">
              <img v-if="item.photo" :src="item.photo" class="sub-thumb" alt="">
              <div class="sub-info">
                <div class="sub-title">{{ item.title || '无标题' }}</div>
                <div class="sub-meta">
                  <span v-if="item.fenlei" class="sub-tag">{{ item.fenlei }}</span>
                  <span class="sub-date">{{ item.fbdate }}</span>
                </div>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无作品投稿">
            <el-button type="primary" size="small" @click="$router.push('/publish/work')">去投稿</el-button>
          </el-empty>
          <div v-if="works.total > works.pageSize" class="pager">
            <el-pagination background layout="prev, pager, next" :total="works.total" :page-size="works.pageSize" :current-page.sync="works.pageNo" @current-change="fetchWorks" />
          </div>
        </template>
      </el-tab-pane>

      <!-- 橱窗 -->
      <el-tab-pane label="橱窗" name="showcase">
        <div v-if="showcase.loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
        <template v-else>
          <div v-if="showcase.list.length" class="card-grid">
            <div v-for="item in showcase.list" :key="item.id" class="sub-card">
              <div class="thumb-wrap">
                <img v-if="item.photo" :src="item.photo" class="sub-thumb" alt="">
                <span class="price-badge">¥{{ item.price }}</span>
              </div>
              <div class="sub-info">
                <div class="sub-title">{{ item.name }}</div>
                <div class="sub-meta">
                  <el-tag :type="item.status === '审核成功' ? 'success' : item.status === '未审核' ? 'warning' : 'info'" size="mini">
                    {{ item.status }}
                  </el-tag>
                  <el-tag :type="item.type === '上架' ? '' : 'info'" size="mini">{{ item.type }}</el-tag>
                </div>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无橱窗投稿">
            <el-button type="primary" size="small" @click="$router.push('/publish/work?type=huagao')">去发布</el-button>
          </el-empty>
          <div v-if="showcase.total > showcase.pageSize" class="pager">
            <el-pagination background layout="prev, pager, next" :total="showcase.total" :page-size="showcase.pageSize" :current-page.sync="showcase.pageNo" @current-change="fetchShowcase" />
          </div>
        </template>
      </el-tab-pane>

      <!-- 企划 -->
      <el-tab-pane label="企划" name="projects">
        <div v-if="projects.loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
        <template v-else>
          <div v-if="projects.list.length" class="card-grid">
            <div v-for="item in projects.list" :key="item.id" class="sub-card sub-card--project" @click="$router.push('/project/' + item.id)">
              <div class="sub-info">
                <div class="sub-title">{{ item.title }}</div>
                <div class="sub-desc">{{ item.description }}</div>
                <div class="sub-meta">
                  <el-tag v-if="item.status" size="mini" :type="item.status === '招募中' ? 'success' : 'info'">{{ item.status }}</el-tag>
                  <span v-if="item.budgetMin || item.budgetMax" class="budget-text">
                    预算 ¥{{ item.budgetMin || 0 }} - ¥{{ item.budgetMax || '不限' }}
                  </span>
                </div>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无企划发布">
            <el-button type="primary" size="small" @click="$router.push('/publish/project')">去发布</el-button>
          </el-empty>
          <div v-if="projects.total > projects.pageSize" class="pager">
            <el-pagination background layout="prev, pager, next" :total="projects.total" :page-size="projects.pageSize" :current-page.sync="projects.pageNo" @current-change="fetchProjects" />
          </div>
        </template>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import fenxiangApi from '@/api/fenxiang'
import huagaoApi from '@/api/huagao'
import projectApi from '@/api/project'
import userApi from '@/api/userManage'

export default {
  name: 'CenterSubmissions',
  data() {
    return {
      activeTab: 'works',
      userId: null,
      works: { list: [], total: 0, pageNo: 1, pageSize: 12, loading: false },
      showcase: { list: [], total: 0, pageNo: 1, pageSize: 12, loading: false },
      projects: { list: [], total: 0, pageNo: 1, pageSize: 12, loading: false }
    }
  },
  computed: {
    ...mapGetters(['token'])
  },
  async created() {
    await this.loadUser()
    this.fetchWorks()
  },
  methods: {
    async loadUser() {
      const res = await userApi.getInfo(this.token)
      this.userId = res.data.userList.id
    },
    onTabChange(tab) {
      const name = tab.name
      if (name === 'works' && !this.works.list.length && !this.works.loading) this.fetchWorks()
      if (name === 'showcase' && !this.showcase.list.length && !this.showcase.loading) this.fetchShowcase()
      if (name === 'projects' && !this.projects.list.length && !this.projects.loading) this.fetchProjects()
    },
    async fetchWorks() {
      this.works.loading = true
      try {
        const res = await fenxiangApi.getList({ userids: this.userId, pageNo: this.works.pageNo, pageSize: this.works.pageSize })
        this.works.list = res.data.rows || []
        this.works.total = res.data.total || 0
      } finally { this.works.loading = false }
    },
    async fetchShowcase() {
      this.showcase.loading = true
      try {
        const res = await huagaoApi.getList({ shangjiaids: this.userId, pageNo: this.showcase.pageNo, pageSize: this.showcase.pageSize })
        this.showcase.list = res.data.rows || []
        this.showcase.total = res.data.total || 0
      } finally { this.showcase.loading = false }
    },
    async fetchProjects() {
      this.projects.loading = true
      try {
        const res = await projectApi.getList({ userId: this.userId, pageNo: this.projects.pageNo, pageSize: this.projects.pageSize })
        this.projects.list = res.data.rows || []
        this.projects.total = res.data.total || 0
      } finally { this.projects.loading = false }
    }
  }
}
</script>

<style lang="scss" scoped>
.center-submissions-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 32px 20px;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px;
}
.loading-box {
  text-align: center;
  padding: 60px 0;
  color: #999;
}
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 16px;
}
.sub-card {
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(0,0,0,0.06);
  transition: box-shadow 0.2s;
  &:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.10); }
}
.sub-card--project {
  cursor: pointer;
}
.thumb-wrap {
  position: relative;
}
.sub-thumb {
  width: 100%;
  height: 160px;
  object-fit: cover;
  display: block;
}
.price-badge {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0,0,0,0.6);
  color: #fff;
  font-size: 13px;
  padding: 2px 8px;
  border-radius: 4px;
}
.sub-info {
  padding: 10px 12px 14px;
}
.sub-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.sub-desc {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.sub-meta {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #999;
}
.sub-tag {
  background: #f0f0f0;
  padding: 1px 6px;
  border-radius: 3px;
}
.budget-text {
  color: #e17055;
}
.pager {
  margin-top: 20px;
  text-align: center;
}
</style>
