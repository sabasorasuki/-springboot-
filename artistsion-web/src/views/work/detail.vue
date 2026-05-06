<template>
  <div class="work-detail-page">
    <div v-if="loading" class="loading-box">
      <i class="el-icon-loading" /> 加载中…
    </div>
    <template v-else-if="work">
      <div class="detail-layout">
        <!-- ========== 左栏：图片 + 标签行 + 标签页 ========== -->
        <div class="detail-left">
          <!-- 大图 -->
          <div class="detail-cover">
            <img
              v-if="workPhotoUrl && !photoBroken"
              :src="workPhotoUrl"
              alt=""
              class="cover-img"
              @error="handlePhotoError"
            >
            <div v-else class="cover-placeholder">
              <span class="cover-placeholder__label">暂无封面</span>
            </div>
          </div>
          <!-- 图片下方：分类 + 举报图标 -->
          <div class="cover-bar">
            <div class="cover-bar__left">
              <span v-if="work.fenlei" class="bar-tag">{{ work.fenlei }}</span>
              <span v-if="work.type" class="bar-status">{{ work.type }}</span>
            </div>
            <el-tooltip content="举报" placement="top">
              <i class="el-icon-warning-outline bar-report-icon" @click="openReportDialog" />
            </el-tooltip>
          </div>
          <!-- 标签页 -->
          <div class="detail-tabs">
            <div class="tabs-nav">
              <span
                class="tab-item"
                :class="{ 'is-active': activeTab === 'info' }"
                @click="activeTab = 'info'"
              >橱窗详情</span>
              <span
                class="tab-item"
                :class="{ 'is-active': activeTab === 'comments' }"
                @click="activeTab = 'comments'"
              >评价<template v-if="commentTotal">（{{ commentTotal }}）</template></span>
            </div>
            <!-- 橱窗详情 -->
            <div v-show="activeTab === 'info'" class="tab-panel">
              <div v-if="work.content" class="rich-content" v-html="work.content" />
              <el-empty v-else description="暂无详情" :image-size="80" />
              <div v-if="work.fujin" class="attachment-section">
                <a :href="work.fujin" target="_blank" class="attachment-link">
                  <i class="el-icon-paperclip" /> 下载附件
                </a>
              </div>
            </div>
            <!-- 评价 -->
            <div v-show="activeTab === 'comments'" class="tab-panel">
              <div v-if="comments.length" class="comment-list">
                <div v-for="c in comments" :key="c.id" class="comment-item">
                  <img
                    v-if="c.avatar"
                    :src="normalizeImageUrl(c.avatar)"
                    class="comment-avatar"
                    @error="e => e.target.style.display='none'"
                  >
                  <div v-else class="comment-avatar comment-avatar--placeholder">
                    <i class="el-icon-user" />
                  </div>
                  <div class="comment-body">
                    <div class="comment-header">
                      <span class="comment-name">{{ c.plname || '匿名用户' }}</span>
                      <span class="comment-date">{{ c.pldate }}</span>
                    </div>
                    <div class="comment-text">{{ c.content }}</div>
                  </div>
                </div>
              </div>
              <el-empty v-else description="暂无评价" :image-size="80" />
              <!-- 发表评价 -->
              <div v-if="userId" class="comment-form">
                <el-input
                  v-model="newComment"
                  type="textarea"
                  :rows="3"
                  placeholder="写下你的评价…"
                  maxlength="500"
                  show-word-limit
                />
                <el-button
                  type="primary"
                  size="small"
                  :loading="commentSubmitting"
                  :disabled="!newComment.trim()"
                  style="margin-top:8px"
                  @click="submitComment"
                >发表评价</el-button>
              </div>
            </div>
          </div>
        </div>

        <!-- ========== 右栏：作者卡片 + 价格 + 操作 ========== -->
        <div class="detail-right">
          <div class="work-heading">
            <h1 class="work-heading__title">{{ work.name || '未命名橱窗' }}</h1>
          </div>
          <div v-if="work.fenlei || systemTagList.length || freeTagList.length" class="work-taxonomy">
            <div v-if="work.fenlei" class="taxonomy-row">
              <span class="taxonomy-label">分类</span>
              <div class="taxonomy-values">
                <span class="taxonomy-chip taxonomy-chip--category">{{ work.fenlei }}</span>
              </div>
            </div>
            <div v-if="systemTagList.length" class="taxonomy-row">
              <span class="taxonomy-label">系统标签</span>
              <div class="taxonomy-values">
                <span
                  v-for="tag in systemTagList"
                  :key="tag.id"
                  class="taxonomy-chip"
                >{{ tag.name }}</span>
              </div>
            </div>
            <div v-if="freeTagList.length" class="taxonomy-row">
              <span class="taxonomy-label">自由标签</span>
              <div class="taxonomy-values">
                <span
                  v-for="tag in freeTagList"
                  :key="tag"
                  class="taxonomy-chip taxonomy-chip--free"
                >{{ tag }}</span>
              </div>
            </div>
          </div>
          <!-- 作者信息卡 -->
          <div class="artist-card" @click="goArtist(work.shangjiaids)">
            <img
              v-if="artistInfo && artistInfo.avatar"
              :src="normalizeImageUrl(artistInfo.avatar)"
              class="artist-avatar"
              @error="e => e.target.style.display='none'"
            >
            <div v-else class="artist-avatar artist-avatar--placeholder">
              <i class="el-icon-user" />
            </div>
            <div class="artist-meta">
              <span class="artist-name">{{ artistDisplayName }}</span>
              <span v-if="artistInfo && artistInfo.bio" class="artist-bio">{{ artistInfo.bio }}</span>
              <span v-if="artistInfo && artistInfo.workCount != null" class="artist-stat">
                {{ artistInfo.workCount }} 件作品在售
              </span>
            </div>
          </div>
          <!-- 价格 -->
          <div class="price-block">
            <span class="price-label">橱窗价格</span>
            <div class="price-row">
              <span class="price-value">¥{{ work.price }}</span>
              <span v-if="work.zhekou && work.zhekou > 0" class="price-discount">优惠 ¥{{ work.zhekou }}</span>
            </div>
          </div>
          <!-- 操作按钮列 -->
          <div class="action-stack">
            <el-button type="primary" class="action-btn" :loading="buyLoading" @click="buyNow">
              <i class="el-icon-shopping-bag-1" /> 立即购买
            </el-button>
            <el-button class="action-btn action-btn--cart" :loading="cartLoading" @click="addToCart">
              <i class="el-icon-shopping-cart-2" /> 加入购物车
            </el-button>
            <el-button
              class="action-btn action-btn--fav"
              :class="{ 'is-faved': isFav }"
              :loading="favLoading"
              @click="toggleFav"
            >
              <i :class="isFav ? 'el-icon-star-on' : 'el-icon-star-off'" /> {{ isFav ? '已收藏' : '收藏橱窗' }}
            </el-button>
          </div>
          <!-- 删除（仅自己） -->
          <el-button
            v-if="isOwner"
            type="text"
            class="delete-link"
            :loading="deleteLoading"
            @click="handleDelete"
          >
            <i class="el-icon-delete" /> 删除投稿
          </el-button>
        </div>
      </div>
    </template>
    <el-empty v-else description="作品不存在或已下架" />

    <ReportDialog
      v-model="reportVisible"
      target-type="作品"
      :target-id="work ? work.id : ''"
      :target-title="work ? work.name : ''"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import huagaoApi from '@/api/huagao'
import shoucangApi from '@/api/shoucang'
import orderApi from '@/api/order'
import pinglunApi from '@/api/pinglun'
import recHuagaoApi from '@/api/recHuagao'
import artistApi from '@/api/artist'
import ReportDialog from '@/components/ReportDialog'
import { normalizeImageUrl } from '@/utils/oss'
import { buildCenterProfileRoute, buildOtherArtistProfileRoute } from '@/utils/centerProfile'
import { createClientEventId } from '@/utils/visitor'

export default {
  name: 'WorkDetail',
  components: { ReportDialog },
  data() {
    return {
      loading: true,
      work: null,
      photoBroken: false,
      activeTab: 'info',
      // artist
      artistInfo: null,
      // fav
      isFav: false,
      favId: null,
      favLoading: false,
      // cart / buy
      cartLoading: false,
      buyLoading: false,
      // comments
      comments: [],
      commentTotal: 0,
      newComment: '',
      commentSubmitting: false,
      // misc
      reportVisible: false,
      deleteLoading: false,
      detailViewTracked: false,
      detailDwellTimer: null,
      detailDwellActiveAt: null,
      visibilityHandler: null
    }
  },
  computed: {
    ...mapGetters(['userId', 'name', 'avatar']),
    workPhotoUrl() {
      return normalizeImageUrl(this.work && this.work.photo)
    },
    isOwner() {
      if (!this.work || !this.userId) return false
      return String(this.work.shangjiaids) === String(this.userId)
    },
    systemTagList() {
      if (!this.work || !Array.isArray(this.work.systemTags)) return []
      return this.work.systemTags.filter(tag => tag && tag.id)
    },
    freeTagList() {
      if (!this.work || !Array.isArray(this.work.freeTagNames)) return []
      return this.work.freeTagNames.filter(Boolean)
    },
    artistDisplayName() {
      if (this.artistInfo) return this.artistInfo.name || this.artistInfo.username || '画师'
      return this.work && this.work.artistName ? this.work.artistName : '画师'
    }
  },
  created() {
    this.fetchWork()
  },
  mounted() {
    if (typeof document !== 'undefined') {
      this.visibilityHandler = this.handleVisibilityChange
      document.addEventListener('visibilitychange', this.visibilityHandler)
    }
  },
  beforeDestroy() {
    this.flushDetailDwell(true)
    this.stopDetailDwellTimer()
    if (typeof document !== 'undefined' && this.visibilityHandler) {
      document.removeEventListener('visibilitychange', this.visibilityHandler)
      this.visibilityHandler = null
    }
  },
  beforeRouteLeave(to, from, next) {
    this.flushDetailDwell(true)
    next()
  },
  methods: {
    normalizeImageUrl,
    async fetchWork() {
      const id = this.$route.params.id
      if (!id) { this.loading = false; return }
      try {
        const res = await huagaoApi.getById(id)
        if (res.data && res.code === 20000) {
          this.work = res.data
          this.photoBroken = false
          this.checkFav()
          this.fetchArtist()
          this.fetchComments()
          this.trackDetailView()
        }
      } catch (e) {
        console.error('获取作品详情失败', e)
      } finally {
        this.loading = false
      }
    },
    async fetchArtist() {
      if (!this.work || !this.work.shangjiaids) return
      try {
        const res = await artistApi.getById(this.work.shangjiaids)
        if (res.code === 20000 && res.data) {
          this.artistInfo = res.data
        }
      } catch (_) { /* ignore */ }
    },
    async fetchComments() {
      if (!this.work) return
      try {
        const res = await pinglunApi.getList1({ wzids: String(this.work.id) })
        const rows = res.data && res.data.rows ? res.data.rows : []
        this.comments = rows
        this.commentTotal = rows.length
      } catch (_) { /* ignore */ }
    },
    async submitComment() {
      if (!this.userId) { this.$message.warning('请先登录'); return }
      if (!this.newComment.trim()) return
      this.commentSubmitting = true
      try {
        await pinglunApi.add({
          wzids: String(this.work.id),
          plname: this.name || '用户',
          content: this.newComment.trim(),
          avatar: this.avatar || ''
        })
        this.$message.success('评价成功')
        this.newComment = ''
        this.fetchComments()
      } catch (e) {
        this.$message.error('评价失败')
      } finally {
        this.commentSubmitting = false
      }
    },
    async checkFav() {
      this.isFav = false
      this.favId = null
      if (!this.userId || !this.work) return
      try {
        const res = await shoucangApi.getList1({ wzids: String(this.work.id), userids: String(this.userId) })
        const rows = res.data && res.data.rows ? res.data.rows : (Array.isArray(res.data) ? res.data : [])
        if (rows.length > 0) {
          this.isFav = true
          this.favId = rows[0].id
        }
      } catch (_) { /* ignore */ }
    },
    async toggleFav() {
      if (!this.userId) { this.$message.warning('请先登录'); return }
      this.favLoading = true
      try {
        if (this.isFav && this.favId) {
          await shoucangApi.deleteById(this.favId)
          this.isFav = false
          this.favId = null
          this.$message.success('已取消收藏')
        } else {
          const res = await shoucangApi.add({
            title: this.work.name,
            wzids: String(this.work.id),
            photo: this.workPhotoUrl || this.work.photo || '',
            fenlei: this.work.fenlei,
            price: String(this.work.price),
            userids: String(this.userId)
          })
          if (res && res.message === '已收藏') {
            this.$message.success('已收藏')
            await this.checkFav()
            return
          }
          this.$message.success('收藏成功')
          await this.checkFav()
          this.trackFavoriteAction()
        }
      } catch (e) {
        this.$message.error('操作失败')
      } finally {
        this.favLoading = false
      }
    },
    async addToCart() {
      if (!this.userId) { this.$message.warning('请先登录'); return }
      this.cartLoading = true
      try {
        const res = await orderApi.add({
          name: this.work.name,
          photo: this.workPhotoUrl || this.work.photo || '',
          price: this.work.price,
          spids: String(this.work.id),
          shangjiaids: this.work.shangjiaids,
          userids: String(this.userId),
          status: '购物车'
        })
        this.$message.success((res && res.message) || '已加入购物车')
        if (!res || res.message !== '该橱窗已在购物车中') {
          this.trackAddToCartAction()
        }
      } catch (e) {
        this.$message.error(e.message || '加入购物车失败')
      } finally {
        this.cartLoading = false
      }
    },
    async buyNow() {
      if (!this.userId) { this.$message.warning('请先登录'); return }
      this.buyLoading = true
      try {
        const res = await orderApi.add({
          name: this.work.name,
          photo: this.workPhotoUrl || this.work.photo || '',
          price: this.work.price,
          spids: String(this.work.id),
          shangjiaids: this.work.shangjiaids,
          userids: String(this.userId),
          status: '待付款'
        })
        this.$message.success('订单已创建')
        this.trackCreateOrderAction()
        // 跳转到订单页
        this.$router.push('/center/profile?tab=orders')
      } catch (e) {
        this.$message.error(e.message || '购买失败')
      } finally {
        this.buyLoading = false
      }
    },
    goArtist(artistId) {
      if (!artistId) return
      if (this.userId && String(this.userId) === String(artistId)) {
        this.$router.push(buildCenterProfileRoute({
          isSelf: true,
          viewMode: 'artist',
          tab: 'submissions',
          sub: 'showcase'
        }))
        return
      }
      this.$router.push(buildOtherArtistProfileRoute(artistId, 'showcase'))
    },
    buildTrackPayload(eventType, extra = {}) {
      if (!this.work || !this.work.id) return null
      return {
        eventId: createClientEventId(eventType),
        eventType,
        requestId: this.$route.query.requestId || '',
        huagaoId: this.work.id,
        shangjiaId: this.work.shangjiaids ? Number(this.work.shangjiaids) : null,
        position: this.$route.query.position ? Number(this.$route.query.position) : null,
        eventValue: extra.eventValue != null ? Number(extra.eventValue) : null,
        scene: this.$route.query.scene || 'work_detail',
        source: extra.source || this.$route.query.source || 'detail_direct'
      }
    },
    trackDetailView() {
      if (this.detailViewTracked || !this.work || !this.work.id) return
      this.detailViewTracked = true
      recHuagaoApi.trackAction(this.buildTrackPayload('detail_view', {
        source: this.$route.query.source || 'detail_direct'
      })).catch(() => {})
      this.startDetailDwellTimer()
    },
    startDetailDwellTimer() {
      this.stopDetailDwellTimer()
      this.detailDwellActiveAt = Date.now()
      this.detailDwellTimer = setInterval(() => {
        if (typeof document !== 'undefined' && document.hidden) return
        this.flushDetailDwell(false)
      }, 5000)
    },
    stopDetailDwellTimer() {
      if (this.detailDwellTimer) {
        clearInterval(this.detailDwellTimer)
        this.detailDwellTimer = null
      }
      this.detailDwellActiveAt = null
    },
    handleVisibilityChange() {
      if (typeof document === 'undefined') return
      if (document.hidden) {
        this.flushDetailDwell(true)
        this.detailDwellActiveAt = null
        return
      }
      if (this.detailViewTracked && this.work && this.work.id) {
        this.detailDwellActiveAt = Date.now()
      }
    },
    flushDetailDwell(force) {
      if (!this.detailViewTracked || !this.work || !this.work.id || !this.detailDwellActiveAt) return
      const now = Date.now()
      const delta = now - this.detailDwellActiveAt
      const threshold = force ? 1000 : 5000
      if (delta < threshold) return
      this.detailDwellActiveAt = now
      recHuagaoApi.trackAction(this.buildTrackPayload('detail_dwell', {
        eventValue: delta,
        source: 'detail_dwell_timer'
      })).catch(() => {})
    },
    trackFavoriteAction() {
      if (!this.work || !this.work.id) return
      recHuagaoApi.trackAction(this.buildTrackPayload('favorite', {
        source: 'detail_favorite_button'
      })).catch(() => {})
    },
    trackAddToCartAction() {
      if (!this.work || !this.work.id) return
      recHuagaoApi.trackAction(this.buildTrackPayload('add_to_cart', {
        source: 'detail_add_to_cart_button'
      })).catch(() => {})
    },
    trackCreateOrderAction() {
      if (!this.work || !this.work.id) return
      recHuagaoApi.trackAction(this.buildTrackPayload('create_order', {
        source: 'detail_buy_now_button'
      })).catch(() => {})
    },
    handlePhotoError() {
      this.photoBroken = true
    },
    handleDelete() {
      if (!this.work || !this.work.id) return
      this.$confirm(`确认删除投稿《${this.work.name || '未命名投稿'}》吗？删除后无法恢复。`, '删除确认', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
        this.deleteLoading = true
        try {
          const res = await huagaoApi.deleteById(this.work.id)
          this.$message.success(res.message || '投稿已删除')
          this.$router.replace(buildCenterProfileRoute({
            isSelf: true,
            viewMode: 'artist',
            tab: 'submissions',
            sub: 'showcase'
          }))
        } finally {
          this.deleteLoading = false
        }
      }).catch(() => {})
    },
    openReportDialog() {
      this.reportVisible = true
    }
  }
}
</script>

<style lang="scss" scoped>
$brand: #6c5ce7;
$brand-light: rgba(108, 92, 231, 0.08);
$text-primary: #1f2937;
$text-secondary: #6b7280;
$text-muted: #9ca3af;
$border: #e5e7eb;
$bg-page: #f7f8fa;
$radius-lg: 16px;
$radius-md: 12px;

.work-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 32px 20px 60px;
}

.loading-box {
  text-align: center;
  padding: 80px 0;
  color: $text-muted;
  font-size: 16px;
}

/* ========== 两栏布局 ========== */
.detail-layout {
  display: flex;
  gap: 32px;
  align-items: flex-start;
}

.detail-left {
  flex: 1;
  min-width: 0;
}

.detail-right {
  flex: 0 0 320px;
  position: sticky;
  top: 80px;
}

.work-heading {
  padding: 0 2px 14px;
}

.work-heading__title {
  margin: 0;
  font-size: 28px;
  line-height: 1.25;
  font-weight: 700;
  color: $text-primary;
  word-break: break-word;
}

/* ========== 封面图 ========== */
.detail-cover {
  border-radius: $radius-lg;
  overflow: hidden;
  background: #f0f0f0;
  aspect-ratio: 4 / 3;
}

.cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.cover-placeholder__label {
  font-size: 13px;
  color: #7b8796;
}

/* ========== 图片下方工具条 ========== */
.cover-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
}

.cover-bar__left {
  display: flex;
  gap: 8px;
  align-items: center;
}

.bar-tag {
  font-size: 13px;
  color: $brand;
  background: $brand-light;
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 500;
}

.bar-status {
  font-size: 13px;
  color: #00b894;
  background: rgba(0, 184, 148, 0.08);
  padding: 4px 12px;
  border-radius: 20px;
}

.bar-report-icon {
  font-size: 18px;
  color: $text-muted;
  cursor: pointer;
  padding: 4px;
  border-radius: 50%;
  transition: all 0.2s;

  &:hover {
    color: #e74c3c;
    background: rgba(231, 76, 60, 0.08);
  }
}

/* ========== 标签页 ========== */
.detail-tabs {
  margin-top: 4px;
}

.tabs-nav {
  display: flex;
  gap: 0;
  border-bottom: 2px solid $border;
}

.tab-item {
  padding: 12px 24px;
  font-size: 15px;
  font-weight: 500;
  color: $text-secondary;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  transition: all 0.2s;

  &:hover {
    color: $brand;
  }

  &.is-active {
    color: $brand;
    border-bottom-color: $brand;
  }
}

.tab-panel {
  padding: 20px 0;
}

/* ========== 详情内容 ========== */
.rich-content {
  line-height: 1.8;
  color: $text-primary;
  font-size: 14px;

  ::v-deep img {
    max-width: 100%;
    border-radius: 8px;
    margin: 8px 0;
  }
}

.attachment-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid $border;
}

.attachment-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: $brand;
  text-decoration: none;
  font-size: 14px;

  &:hover {
    text-decoration: underline;
  }
}

/* ========== 评价列表 ========== */
.comment-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-item {
  display: flex;
  gap: 12px;
  padding-bottom: 16px;
  border-bottom: 1px solid $border;

  &:last-child {
    border-bottom: none;
  }
}

.comment-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  flex-shrink: 0;
  object-fit: cover;

  &--placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    background: $brand-light;
    color: $brand;
    font-size: 18px;
  }
}

.comment-body {
  flex: 1;
  min-width: 0;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 4px;
}

.comment-name {
  font-size: 14px;
  font-weight: 600;
  color: $text-primary;
}

.comment-date {
  font-size: 12px;
  color: $text-muted;
}

.comment-text {
  font-size: 14px;
  color: $text-secondary;
  line-height: 1.6;
  word-break: break-word;
}

.comment-form {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid $border;
}

/* ========== 右栏：作者卡片 ========== */
.artist-card {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 16px;
  background: #fff;
  border-radius: $radius-md;
  border: 1px solid $border;
  cursor: pointer;
  transition: box-shadow 0.2s;

  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
  }
}

.artist-avatar {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  flex-shrink: 0;
  object-fit: cover;

  &--placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    background: $brand-light;
    color: $brand;
    font-size: 22px;
  }
}

.artist-meta {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.artist-name {
  font-size: 16px;
  font-weight: 600;
  color: $text-primary;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.artist-bio {
  font-size: 13px;
  color: $text-secondary;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.artist-stat {
  font-size: 12px;
  color: $text-muted;
}

.work-taxonomy {
  margin-top: 16px;
  padding: 16px;
  background: #fff;
  border-radius: $radius-md;
  border: 1px solid $border;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.taxonomy-row {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.taxonomy-label {
  font-size: 13px;
  font-weight: 600;
  color: $text-secondary;
}

.taxonomy-values {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.taxonomy-chip {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  padding: 4px 10px;
  border-radius: 999px;
  background: $brand-light;
  color: $brand;
  font-size: 13px;
  line-height: 1.2;

  &--category {
    background: rgba(225, 112, 85, 0.12);
    color: #d35400;
  }

  &--free {
    background: rgba(123, 135, 150, 0.12);
    color: $text-secondary;
  }
}

/* ========== 价格块 ========== */
.price-block {
  margin-top: 16px;
  padding: 16px;
  background: #fff;
  border-radius: $radius-md;
  border: 1px solid $border;
}

.price-label {
  font-size: 13px;
  color: $text-muted;
}

.price-row {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin-top: 4px;
}

.price-value {
  font-size: 28px;
  font-weight: 700;
  color: #e17055;
}

.price-discount {
  font-size: 13px;
  color: #fff;
  background: #e17055;
  padding: 2px 8px;
  border-radius: 4px;
}

/* ========== 操作按钮列 ========== */
.action-stack {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 16px;
}

.action-stack .action-btn + .action-btn {
  margin-left: 0;
}

.action-btn {
  width: 100%;
  height: 42px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 500;
  border-radius: 8px;
  letter-spacing: 0.5px;

  &--cart {
    color: $brand;
    border-color: $brand;
    background: #fff;

    &:hover {
      background: $brand-light;
    }
  }

  &--fav {
    color: $text-secondary;
    border-color: $border;
    background: #fff;

    &:hover {
      color: $brand;
      border-color: $brand;
    }

    &.is-faved {
      color: #f59e0b;
      border-color: #f59e0b;
    }
  }
}

.delete-link {
  margin-top: 12px;
  color: $text-muted;
  font-size: 13px;

  &:hover {
    color: #e74c3c;
  }
}

/* ========== 响应式 ========== */
@media (max-width: 900px) {
  .detail-layout {
    flex-direction: column;
  }

  .detail-right {
    flex: none;
    width: 100%;
    position: static;
  }
}
</style>
