<template>
  <div class="showcase-page">
    <section class="page-header">
      <h1 class="page-title">橱窗</h1>
      <p class="page-desc">浏览画师们的可购画稿</p>
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

    <!-- 橱窗列表 -->
    <section class="section">
      <div v-if="loading && items.length === 0" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="items.length" class="card-grid">
        <div
          v-for="item in items"
          :key="item.id"
          class="showcase-card"
          @click="goDetail(item.id)"
        >
          <div class="card-cover">
            <img v-if="item.photo" :src="item.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
            <div v-if="item.price" class="price-badge">¥{{ item.price }}</div>
          </div>
          <div class="card-body">
            <div class="card-title">{{ item.name }}</div>
            <div class="card-meta">
              <span v-if="item.fenlei" class="card-tag">{{ item.fenlei }}</span>
              <span class="card-author" @click.stop="goAuthor(item)">
                {{ item.shangjiaids_name || '画师' }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无橱窗作品" :image-size="120" />

      <div v-if="total > items.length" class="load-more">
        <el-button :loading="loading" type="text" @click="loadMore">加载更多</el-button>
      </div>
    </section>
  </div>
</template>

<script>
import huagaoApi from '@/api/huagao'
import fenleiApi from '@/api/fenlei'

export default {
  name: 'ShowcasePage',
  data() {
    return {
      items: [],
      total: 0,
      pageNo: 1,
      loading: false,
      filterTags: ['全部'],
      activeFilter: '全部'
    }
  },
  created() {
    this.fetchCategories()
    this.fetchItems()
  },
  methods: {
    fetchCategories() {
      fenleiApi.getList1().then(res => {
        const cats = (res.data.rows || []).map(c => c.fenlei)
        this.filterTags = ['全部', ...cats]
      }).catch(() => {})
    },
    fetchItems() {
      this.loading = true
      const params = {
        pageNo: this.pageNo,
        pageSize: 16,
        type: '上架',
        status: '审核成功'
      }
      if (this.activeFilter !== '全部') {
        params.fenlei = this.activeFilter
      }
      huagaoApi.getList(params).then(res => {
        const rows = res.data.rows || []
        this.items = this.pageNo === 1 ? rows : this.items.concat(rows)
        this.total = res.data.total || 0
      }).catch(() => {}).finally(() => {
        this.loading = false
      })
    },
    onFilterChange(tag) {
      this.activeFilter = tag
      this.pageNo = 1
      this.items = []
      this.fetchItems()
    },
    loadMore() {
      this.pageNo++
      this.fetchItems()
    },
    goDetail(id) {
      this.$router.push('/work/' + id)
    },
    goAuthor(item) {
      const authorId = item.shangjiaids
      if (authorId) {
        this.$router.push('/artist/' + authorId)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.showcase-page {
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

.showcase-card {
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

.price-badge {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0, 0, 0, 0.65);
  color: #ffd43b;
  font-size: 13px;
  font-weight: 600;
  padding: 3px 10px;
  border-radius: 12px;
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
</style>
