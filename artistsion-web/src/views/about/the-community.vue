<template>
  <main role="main">
    <div class="search-nav">
      <div class="container">
        <div class="community-head">
          <h1 class="page-heading">交流区</h1>
          <p class="page-sub">接稿经验、排期提醒、画风讨论——搜标题快速定位。</p>
        </div>
        <div class="search-wrapper">
          <div class="search-controls">
            <el-input
              v-model="searchModel.title"
              placeholder="搜索帖子标题…"
              class="search-input"
              prefix-icon="el-icon-search"
            />
            <el-button
              type="primary"
              class="search-btn"
              @click="listPosts"
            >
              <i class="fa fa-search" /> 搜索
            </el-button>
            <el-button
              type="info"
              class="back-btn"
              @click="qiantai()"
            >
              <i class="fa fa-arrow-left" /> 回首页
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <div class="main-content">
      <div class="container">
        <div class="pagination-wrapper">
          <el-pagination
            :current-page="searchModel.pageNo"
            :page-sizes="[6, 12, 24, 36]"
            :page-size="searchModel.pageSize"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
            background
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>

        <div class="spots-grid">
          <div v-for="o in posts" :key="o.id" class="spot-item">
            <the-coursetiezi :course="o" />
          </div>
          <div v-show="posts.length === 0" class="no-data">
            <i class="fa fa-comments fa-3x" />
            <h3>暂无相关帖子</h3>
            <p>换个关键词，或稍后再来刷新</p>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script>
import TheCoursetiezi from '@/views/about/the-coursetiezi'
import tiezipi from '@/api/fenxiang.js'

export default {
  name: 'TheCommunity',
  components: { TheCoursetiezi },
  data() {
    return {
      posts: [],
      total: 0,
      searchModel: {
        pageNo: 1,
        pageSize: 6,
        title: ''
      }
    }
  },
  mounted() {
    this.listPosts()
  },
  methods: {
    listPosts() {
      tiezipi.getList(this.searchModel).then(response => {
        this.posts = response.data.rows || []
        this.total = response.data.total || 0
      })
    },
    qiantai() {
      this.$router.push('/mas')
    },
    handleSizeChange(val) {
      this.searchModel.pageSize = val
      this.listPosts()
    },
    handleCurrentChange(val) {
      this.searchModel.pageNo = val
      this.listPosts()
    }
  }
}
</script>

<style scoped>
.search-nav {
  background: linear-gradient(135deg, #1e1b2e 0%, #352848 100%);
  padding: 1.75rem 0 2rem;
  box-shadow: 0 12px 40px rgba(30, 27, 46, 0.25);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(255, 143, 171, 0.12);
}

.community-head {
  margin-bottom: 1.25rem;
}

.page-heading {
  color: #faf7f2;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 0.35rem;
}

.page-sub {
  margin: 0;
  font-size: 0.875rem;
  color: rgba(250, 247, 242, 0.6);
}

.search-wrapper {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.search-controls {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  flex-wrap: wrap;
}

.search-input {
  max-width: 280px;
}

.search-input :deep(.el-input__inner) {
  border-radius: 999px;
  border: 1px solid rgba(42, 38, 53, 0.08);
  background: #fffef9;
}

.search-btn {
  border-radius: 999px;
  padding: 11px 22px;
  background: linear-gradient(135deg, #a78bfa, #c084fc) !important;
  border: none !important;
}

.back-btn {
  border-radius: 999px;
  padding: 11px 22px;
  background: rgba(255, 255, 255, 0.12) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: #faf7f2 !important;
}

.main-content {
  background: #f6f3ee;
  padding: 2.5rem 0;
  min-height: calc(100vh - 200px);
}

.pagination-wrapper {
  margin-bottom: 1.75rem;
  display: flex;
  justify-content: center;
}

.spots-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  padding: 0.25rem;
}

.spot-item {
  transition: transform 0.2s;
}

.spot-item:hover {
  transform: translateY(-4px);
}

.no-data {
  grid-column: 1 / -1;
  text-align: center;
  padding: 3.5rem 1rem;
  color: rgba(42, 38, 53, 0.5);
  background: #fffef9;
  border-radius: 20px;
  border: 1px dashed rgba(42, 38, 53, 0.12);
}

.no-data i {
  margin-bottom: 1rem;
  color: rgba(192, 132, 252, 0.45);
}

.no-data h3 {
  font-weight: 600;
  color: #2a2635;
  margin-bottom: 0.35rem;
}

.no-data p {
  margin: 0;
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .search-controls {
    width: 100%;
  }
  .search-input {
    width: 100%;
    max-width: none;
  }
  .spots-grid {
    grid-template-columns: 1fr;
  }
}
</style>
