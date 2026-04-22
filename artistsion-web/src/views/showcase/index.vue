<template>
  <div class="showcase-page">
    <section class="page-header">
      <h1 class="page-title">橱窗</h1>
      <p class="page-desc">浏览画师们的可购画稿</p>
    </section>

    <!-- 筛选区 -->
    <section class="section filter-section">
      <div class="filter-panel">
        <div class="search-row">
          <el-input
            v-model.trim="keyword"
            clearable
            placeholder="搜索标题、角色名、自由标签或标签别名"
            @clear="onSearch"
            @keyup.enter.native="onSearch"
          >
            <el-button slot="append" icon="el-icon-search" @click="onSearch">搜索</el-button>
          </el-input>
        </div>
        <div class="filter-group">
          <span class="filter-label">分类</span>
          <div class="filter-bar">
            <span
              v-for="tag in filterTags"
              :key="tag"
              class="filter-tag"
              :class="{ 'is-active': activeFilter === tag }"
              @click="onFilterChange(tag)"
            >{{ tag }}</span>
          </div>
        </div>
        <div class="filter-group">
          <span class="filter-label">系统标签</span>
          <el-select
            v-model="activeTagId"
            class="tag-select"
            clearable
            filterable
            placeholder="全部标签"
            @change="onTagChange"
          >
            <el-option-group
              v-for="group in groupedSystemTags"
              :key="group.group"
              :label="group.group"
            >
              <el-option
                v-for="item in group.items"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-option-group>
          </el-select>
        </div>
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
          @click="goDetail(item)"
        >
          <div class="card-cover">
            <img
              v-if="item.photoUrl && !item.photoBroken"
              :src="item.photoUrl"
              alt=""
              class="cover-img"
              @error="handleImageError(item)"
            >
            <div v-else class="cover-placeholder">
              <span class="cover-placeholder__label">暂无封面</span>
            </div>
            <div v-if="item.price" class="price-badge">¥{{ item.price }}</div>
          </div>
          <div class="card-body">
            <div class="card-title">{{ item.name }}</div>
            <div class="card-meta">
              <span v-if="item.fenlei" class="card-tag">{{ item.fenlei }}</span>
              <span class="card-author" @click.stop="goAuthor(item)">
                {{ getAuthorName(item) }}
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
import { mapGetters } from 'vuex'
import huagaoApi from '@/api/huagao'
import recHuagaoApi from '@/api/recHuagao'
import fenleiApi from '@/api/fenlei'
import tagApi from '@/api/tag'
import { normalizeImageUrl } from '@/utils/oss'
import { buildCenterProfileRoute, buildOtherArtistProfileRoute } from '@/utils/centerProfile'
import { createClientEventId } from '@/utils/visitor'

export default {
  name: 'ShowcasePage',
  data() {
    return {
      items: [],
      total: 0,
      pageNo: 1,
      loading: false,
      keyword: '',
      activeTagId: null,
      filterTags: ['全部'],
      activeFilter: '全部',
      systemTagOptions: []
    }
  },
  computed: {
    ...mapGetters(['userId']),
    groupedSystemTags() {
      const groups = []
      const groupMap = {}
      this.systemTagOptions.forEach(item => {
        const groupName = item.tagGroup || '未分组'
        if (!groupMap[groupName]) {
          groupMap[groupName] = {
            group: groupName,
            items: []
          }
          groups.push(groupMap[groupName])
        }
        groupMap[groupName].items.push(item)
      })
      return groups
    }
  },
  created() {
    this.fetchCategories()
    this.fetchSystemTags()
    this.fetchItems()
  },
  methods: {
    normalizeItem(item) {
      return {
        ...item,
        photoUrl: normalizeImageUrl(item && item.photo),
        photoBroken: false
      }
    },
    fetchCategories() {
      fenleiApi.getFixedList().then(res => {
        const cats = [...new Set((res.data.rows || []).map(c => c.fenlei).filter(Boolean))]
        this.filterTags = ['全部', ...cats]
      }).catch(() => {})
    },
    fetchSystemTags() {
      tagApi.getSystemOptions().then(res => {
        this.systemTagOptions = res.data || []
      }).catch(() => {})
    },
    buildListParams() {
      const params = {
        pageNo: this.pageNo,
        pageSize: 16,
        scene: 'showcase',
        type: '上架',
        status: '审核成功'
      }
      if (this.activeFilter !== '全部') {
        params.fenlei = this.activeFilter
      }
      if (this.activeTagId) {
        params.tagId = this.activeTagId
      }
      if (this.keyword) {
        params.keyword = this.keyword
      }
      return params
    },
    fetchItems() {
      this.loading = true
      const params = this.buildListParams()
      huagaoApi.getList(params).then(res => {
        const rows = res.data.rows || []
        const requestId = res.data.requestId || ''
        const pageSize = params.pageSize || 16
        const normalizedRows = rows.map((item, index) => {
          const normalizedItem = this.normalizeItem(item)
          normalizedItem.trackingRequestId = requestId || ''
          normalizedItem.trackingPosition = ((this.pageNo - 1) * pageSize) + index + 1
          return normalizedItem
        })
        this.items = this.pageNo === 1 ? normalizedRows : this.items.concat(normalizedRows)
        this.total = res.data.total || 0
      }).catch(() => {}).finally(() => {
        this.loading = false
      })
    },
    resetAndFetch() {
      this.pageNo = 1
      this.items = []
      this.fetchItems()
    },
    onSearch() {
      this.resetAndFetch()
    },
    onFilterChange(tag) {
      this.activeFilter = tag
      this.resetAndFetch()
    },
    onTagChange() {
      this.resetAndFetch()
    },
    loadMore() {
      this.pageNo++
      this.fetchItems()
    },
    goDetail(item) {
      if (!item || !item.id) return
      const query = {}
      if (item.trackingRequestId) {
        recHuagaoApi.trackAction({
          eventId: createClientEventId('click'),
          eventType: 'click_detail',
          requestId: item.trackingRequestId,
          huagaoId: item.id,
          shangjiaId: item.shangjiaids ? Number(item.shangjiaids) : null,
          position: item.trackingPosition,
          scene: 'showcase',
          source: 'showcase_card'
        }).catch(() => {})
        query.requestId = item.trackingRequestId
        query.position = item.trackingPosition
        query.scene = 'showcase'
        query.source = 'showcase_card'
      }
      this.$router.push({ path: '/work/' + item.id, query })
    },
    handleImageError(item) {
      this.$set(item, 'photoBroken', true)
    },
    getAuthorName(item) {
      return (item && item.artistName) || '画师'
    },
    goAuthor(item) {
      const authorId = item && item.shangjiaids ? String(item.shangjiaids) : ''
      if (!authorId) return
      if (this.userId && String(this.userId) === authorId) {
        this.$router.push(buildCenterProfileRoute({
          isSelf: true,
          viewMode: 'artist',
          tab: 'submissions',
          sub: 'showcase'
        }))
        return
      }
      this.$router.push(buildOtherArtistProfileRoute(authorId, 'showcase'))
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

.filter-panel {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.search-row {
  max-width: 560px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.filter-label {
  font-size: 13px;
  font-weight: 600;
  color: #666;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.tag-select {
  width: 100%;
  max-width: 340px;
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
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.cover-placeholder__label {
  font-size: 12px;
  letter-spacing: 1px;
  color: #7b8796;
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

@media (max-width: 768px) {
  .search-row,
  .tag-select {
    max-width: none;
  }

  .card-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 520px) {
  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>
