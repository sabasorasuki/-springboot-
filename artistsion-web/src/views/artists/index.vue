<template>
  <div class="artists-page">
    <section class="page-header">
      <h1 class="page-title">发现画师</h1>
      <p class="page-desc">探索风格各异的画师，找到最适合你的创作者</p>
    </section>

    <!-- 分类筛选栏 -->
    <section class="section">
      <div class="filter-bar">
        <span
          v-for="tag in filterTags"
          :key="tag.value"
          class="filter-tag"
          :class="{ 'is-active': activeFilter === tag.value }"
          @click="onFilterChange(tag.value)"
        >{{ tag.label }}</span>
      </div>
    </section>

    <!-- 画师卡片列表 -->
    <section class="section artist-list-section" v-loading="loading">
      <div v-if="artists.length" class="artist-grid">
        <div
          v-for="artist in artists"
          :key="artist.id"
          class="artist-card"
          @click="goArtistDetail(artist.id)"
        >
          <div class="artist-card__header">
            <img
              :src="artist.avatarUrl || defaultAvatar"
              class="artist-avatar"
              alt=""
            >
            <div class="artist-info">
              <div class="artist-name">{{ artist.name || artist.username }}</div>
              <div class="artist-stat">
                <span>{{ artist.workCount || 0 }} 件作品</span>
              </div>
            </div>
          </div>
          <div v-if="artist.recentCoverUrls && artist.recentCoverUrls.length" class="artist-card__gallery">
            <div
              v-for="(cover, idx) in artist.recentCoverUrls"
              :key="idx"
              class="gallery-thumb"
            >
              <img :src="cover" alt="" class="thumb-img" loading="lazy" decoding="async">
            </div>
            <div
              v-for="n in Math.max(0, 9 - artist.recentCoverUrls.length)"
              :key="'empty-' + n"
              class="gallery-thumb gallery-thumb--empty"
            />
          </div>
          <div v-else class="artist-card__gallery">
            <div v-for="n in 9" :key="n" class="gallery-thumb gallery-thumb--empty" />
          </div>
          <div class="artist-card__footer">
            <span class="footer-label">{{ artist.bio || '暂无简介' }}</span>
          </div>
        </div>
      </div>
      <el-empty v-else-if="!loading" description="暂无画师" :image-size="120" />

      <!-- 分页 -->
      <div v-if="total > pageSize" class="pagination-wrap">
        <el-pagination
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="pageSize"
          :current-page.sync="pageNo"
          :disabled="loading"
          @current-change="onPageChange"
        />
      </div>
    </section>
  </div>
</template>

<script>
import artistApi from '@/api/artist'
import fenleiApi from '@/api/fenlei'
import recApi from '@/api/rec'
import { buildOtherArtistProfileRoute } from '@/utils/centerProfile'
import { normalizeImageUrl } from '@/utils/oss'
import { createClientEventId } from '@/utils/visitor'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'ArtistsPage',
  data() {
    return {
      defaultAvatar,
      artists: [],
      total: 0,
      pageNo: 1,
      pageSize: 9,
      loading: false,
      keyword: '',
      activeFilter: '',
      filterTags: [{ label: '全部', value: '' }],
      categories: []
    }
  },
  watch: {
    '$route.query': {
      handler(query) {
        if (this.applyRouteQuery(query)) {
          this.fetchArtists()
        }
      }
    }
  },
  created() {
    this.applyRouteQuery()
    this.fetchCategories()
    this.fetchArtists()
  },
  methods: {
    fetchCategories() {
      fenleiApi.getList1().then(res => {
        this.categories = res.data.rows || []
        this.filterTags = [
          { label: '全部', value: '' },
          ...this.categories.map(c => ({ label: c.fenlei, value: c.fenlei }))
        ]
      }).catch(() => {})
    },

    normalizeArtist(artist) {
      const rawCovers = artist.recentCovers
      const recentCovers = Array.isArray(rawCovers)
        ? rawCovers
        : (typeof rawCovers === 'string' ? rawCovers.split('|||') : [])
      return {
        ...artist,
        avatarUrl: normalizeImageUrl(artist.avatar),
        recentCoverUrls: recentCovers.map(cover => normalizeImageUrl(cover)).filter(Boolean).slice(0, 9)
      }
    },

    fetchArtists() {
      this.loading = true
      const useList = this.activeFilter || this.keyword
      const request = useList
        ? artistApi.getList({
          pageNo: this.pageNo,
          pageSize: this.pageSize,
          keyword: this.keyword || undefined,
          fenlei: this.activeFilter || undefined
        })
        : recApi.recommendations({
          domain: 'artist',
          pageNo: this.pageNo,
          pageSize: this.pageSize,
          scene: 'artists'
        })
      request.then(res => {
        const requestId = res.data.requestId || ''
        const modelVersion = res.data.modelVersion || ''
        this.artists = (res.data.rows || []).map((artist, index) => Object.assign(this.normalizeArtist(artist), {
          trackingRequestId: requestId,
          trackingPosition: ((this.pageNo - 1) * this.pageSize) + index + 1,
          trackingScene: 'artists',
          trackingSource: 'artists_recommend',
          trackingModelVersion: modelVersion
        }))
        this.total = res.data.total || 0
      }).catch(() => {
        this.artists = []
        this.total = 0
      }).finally(() => {
        this.loading = false
      })
    },

    onFilterChange(value) {
      this.activeFilter = value
      this.pageNo = 1
      if (!this.syncRouteQuery()) {
        this.fetchArtists()
      }
    },
    applyRouteQuery(query = this.$route.query) {
      const nextKeyword = query.keyword ? String(query.keyword).trim() : ''
      const nextFilter = query.fenlei ? String(query.fenlei).trim() : ''
      const changed = this.keyword !== nextKeyword || this.activeFilter !== nextFilter
      this.keyword = nextKeyword
      this.activeFilter = nextFilter || ''
      if (changed) {
        this.pageNo = 1
      }
      return changed
    },
    syncRouteQuery() {
      const query = {}
      if (this.keyword) query.keyword = this.keyword
      if (this.activeFilter) query.fenlei = this.activeFilter
      const current = this.$route.query || {}
      if ((current.keyword || '') === (query.keyword || '') && (current.fenlei || '') === (query.fenlei || '')) {
        return false
      }
      this.$router.replace({ path: '/artists', query }).catch(() => {})
      return true
    },
    onPageChange(page) {
      if (this.loading) {
        return
      }
      this.pageNo = page
      this.fetchArtists()
    },

    goArtistDetail(id) {
      const artist = this.artists.find(item => item.id === id) || { id }
      const query = {}
      if (artist.trackingRequestId) {
        recApi.trackAction({
          eventId: createClientEventId('click'),
          eventType: 'click_detail',
          domain: 'artist',
          requestId: artist.trackingRequestId,
          itemId: artist.id,
          authorId: artist.id,
          position: artist.trackingPosition,
          scene: artist.trackingScene || 'artists',
          source: artist.trackingSource || 'artists_recommend',
          modelVersion: artist.trackingModelVersion || ''
        }).catch(() => {})
        query.requestId = artist.trackingRequestId
        query.position = artist.trackingPosition
        query.scene = artist.trackingScene || 'artists'
        query.source = artist.trackingSource || 'artists_recommend'
        query.domain = 'artist'
        query.modelVersion = artist.trackingModelVersion || ''
      }
      const route = buildOtherArtistProfileRoute(id, 'featuredWorks')
      this.$router.push({
        path: route.path,
        query: Object.assign({}, route.query, query)
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.artists-page {
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

.section {
  margin-top: 32px;
}

.artist-list-section {
  min-height: 420px;
}

/* ── 画师网格 ── */
.artist-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.artist-card {
  background: #fff;
  border-radius: 14px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
}

.artist-card__header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;
}

.artist-avatar {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
  background: #f0e8f5;
}

.artist-info {
  min-width: 0;
}

.artist-name {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.artist-stat {
  font-size: 13px;
  color: #999;
  margin-top: 4px;
}

/* ── 缩略图画廊 ── */
.artist-card__gallery {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  margin-bottom: 14px;
}

.gallery-thumb {
  position: relative;
  padding-top: 100%;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f5f5;
}

.gallery-thumb--empty {
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.thumb-img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.artist-card__footer {
  font-size: 13px;
  color: #aaa;
}

.footer-label {
  display: inline-block;
}

/* ── 分页 ── */
.pagination-wrap {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

.loading-placeholder {
  text-align: center;
  padding: 40px 0;
  color: #999;
  font-size: 14px;
}

/* ── 响应式 ── */
@media (max-width: 900px) {
  .artist-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .artist-grid {
    grid-template-columns: 1fr;
  }
}
</style>
