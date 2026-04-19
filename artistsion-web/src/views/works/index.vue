<template>
  <div class="works-page">
    <section class="page-header">
      <h1 class="page-title">作品</h1>
      <p class="page-desc">发现画师们的原创作品</p>
    </section>

    <!-- 筛选区 -->
    <section class="section filter-section">
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

    <!-- 作品网格 -->
    <section class="section">
      <div v-if="loading && works.length === 0" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="works.length" class="card-grid">
        <div
          v-for="item in works"
          :key="item.id"
          class="work-card"
          @click="openPreview(item)"
        >
          <div class="card-cover">
            <img v-if="item.photo" :src="item.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="card-body">
            <div v-if="item.title" class="card-title">{{ item.title }}</div>
            <div class="card-meta">
              <span v-if="item.fenlei" class="card-tag">{{ item.fenlei }}</span>
              <span class="card-author" @click.stop="goAuthor(item)">
                {{ item.username || '匿名' }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无作品" :image-size="120" />

      <div v-if="total > works.length" class="load-more">
        <el-button :loading="loading" type="text" @click="loadMore">加载更多</el-button>
      </div>
    </section>

    <!-- 作品弹窗预览 -->
    <el-dialog
      :visible.sync="previewVisible"
      :title="null"
      width="680px"
      custom-class="work-preview-dialog"
      :show-close="true"
      append-to-body
    >
      <div v-if="previewItem" class="preview-content">
        <div class="preview-image">
          <img :src="previewItem.photo" alt="" class="preview-img">
        </div>
        <div class="preview-info">
          <div class="preview-author" @click="goAuthor(previewItem)">
            <img :src="previewItem.userAvatar || defaultAvatar" class="author-avatar" alt="">
            <span class="author-name">{{ previewItem.username || '匿名' }}</span>
          </div>
          <h2 v-if="previewItem.title" class="preview-title">{{ previewItem.title }}</h2>
          <div v-if="previewItem.fenlei" class="preview-tags">
            <span class="card-tag">{{ previewItem.fenlei }}</span>
          </div>
          <p v-if="previewItem.content" class="preview-desc">{{ previewItem.content }}</p>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import fenxiangApi from '@/api/fenxiang'
import fenleiApi from '@/api/fenlei'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'WorksPage',
  data() {
    return {
      defaultAvatar,
      works: [],
      total: 0,
      pageNo: 1,
      loading: false,
      filterTags: ['全部'],
      activeFilter: '全部',
      previewVisible: false,
      previewItem: null
    }
  },
  created() {
    this.fetchCategories()
    this.fetchWorks()
  },
  methods: {
    fetchCategories() {
      fenleiApi.getList1().then(res => {
        const cats = (res.data.rows || []).map(c => c.fenlei)
        this.filterTags = ['全部', ...cats]
      }).catch(() => {})
    },
    fetchWorks() {
      this.loading = true
      const params = {
        pageNo: this.pageNo,
        pageSize: 16
      }
      if (this.activeFilter !== '全部') {
        params.fenlei = this.activeFilter
      }
      fenxiangApi.getList(params).then(res => {
        const rows = res.data.rows || []
        this.works = this.pageNo === 1 ? rows : this.works.concat(rows)
        this.total = res.data.total || 0
      }).catch(() => {}).finally(() => {
        this.loading = false
      })
    },
    onFilterChange(tag) {
      this.activeFilter = tag
      this.pageNo = 1
      this.works = []
      this.fetchWorks()
    },
    loadMore() {
      this.pageNo++
      this.fetchWorks()
    },
    openPreview(item) {
      this.previewItem = item
      this.previewVisible = true
    },
    goAuthor(item) {
      const authorId = item.userids || item.userId
      if (authorId) {
        this.previewVisible = false
        this.$router.push('/center/profile/' + authorId)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.works-page {
  padding: 20px 0 60px;
}

.page-header {
  margin-bottom: 8px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin: 0 0 8px;
}

.page-desc {
  font-size: 14px;
  color: #999;
  margin: 0;
}

.section {
  margin-top: 24px;
}

.filter-section {
  margin-top: 16px;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.filter-tag {
  display: inline-block;
  padding: 6px 16px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 20px;
  font-size: 13px;
  color: #666;
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

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.work-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
}

.card-cover {
  width: 100%;
  padding-top: 100%;
  position: relative;
  overflow: hidden;
  background: #f5f5f5;
}

.cover-img {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  object-fit: cover;
}

.cover-placeholder {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.card-body {
  padding: 12px 14px;
}

.card-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 6px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.card-tag {
  font-size: 12px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 2px 8px;
  border-radius: 4px;
}

.card-author {
  font-size: 12px;
  color: #7b8796;
  cursor: pointer;

  &:hover {
    color: #6c5ce7;
  }
}

.load-more {
  text-align: center;
  margin-top: 24px;
}

.loading-placeholder {
  text-align: center;
  padding: 40px 0;
  color: #999;
}

/* ── 预览弹窗 ── */
::v-deep .work-preview-dialog {
  border-radius: 16px;
  overflow: hidden;

  .el-dialog__header {
    padding: 12px 16px 0;
  }

  .el-dialog__body {
    padding: 0 24px 24px;
  }
}

.preview-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.preview-image {
  width: 100%;
  max-height: 420px;
  overflow: hidden;
  border-radius: 12px;
  background: #f5f5f5;
}

.preview-img {
  width: 100%;
  max-height: 420px;
  object-fit: contain;
}

.preview-info {
  padding: 0 4px;
}

.preview-author {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  margin-bottom: 12px;

  &:hover .author-name {
    color: #6c5ce7;
  }
}

.author-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
}

.author-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  transition: color 0.2s;
}

.preview-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 10px;
}

.preview-tags {
  margin-bottom: 10px;
}

.preview-desc {
  font-size: 14px;
  color: #666;
  line-height: 1.7;
  margin: 0;
}
</style>
