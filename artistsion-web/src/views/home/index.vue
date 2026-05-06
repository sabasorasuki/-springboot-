<template>
  <div class="home-page">
    <!-- 顶部轮播推荐区 -->
    <section v-if="carouselItems.length" class="hero-carousel">
      <el-carousel height="320px" :interval="5000" arrow="hover" indicator-position="outside">
        <el-carousel-item v-for="item in carouselItems" :key="item.id">
          <div class="carousel-slide">
            <img :src="item.lunbo" class="carousel-img" alt="">
            <div class="carousel-overlay">
              <span class="carousel-label">{{ item.name }}</span>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </section>

    <!-- 个性化推荐 -->
    <section class="section">
      <div class="section-header">
        <h2 class="section-title">为你推荐</h2>
      </div>
      <div v-if="recommendLoading" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="recommendWorks.length" class="card-grid">
        <div
          v-for="work in recommendWorks"
          :key="work.id"
          class="work-card"
          @click="goWorkDetail(work)"
        >
          <div class="card-cover">
            <img v-if="work.photo" :src="work.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="card-body">
            <div class="card-title">{{ work.name }}</div>
            <div class="card-meta">
              <span v-if="work.fenlei" class="card-tag">{{ work.fenlei }}</span>
              <span v-if="work.price" class="card-price">¥{{ work.price }}</span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无作品" :image-size="120" />
    </section>

    <!-- 热门分类 -->
    <section v-if="categories.length" class="section">
      <div class="section-header">
        <h2 class="section-title">热门分类</h2>
      </div>
      <div class="tag-group">
        <span
          v-for="cat in categories"
          :key="cat.id"
          class="category-tag"
          @click="goCategory(cat.fenlei)"
        >{{ cat.fenlei }}</span>
      </div>
    </section>

    <section v-if="communityPosts.length" class="section">
      <div class="section-header">
        <h2 class="section-title">社区精选</h2>
      </div>
      <div class="community-grid">
        <div
          v-for="post in communityPosts"
          :key="post.id"
          class="community-card"
          @click="goPostDetail(post.id)"
        >
          <div class="community-cover">
            <img v-if="post.photo" :src="post.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="community-body">
            <div class="community-title">{{ post.title }}</div>
            <div class="community-meta">
              <span v-if="post.fenlei" class="card-tag">{{ post.fenlei }}</span>
              <span class="community-author">{{ post.username || '匿名用户' }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 全部作品浏览 -->
    <section class="section">
      <div class="section-header">
        <h2 class="section-title">浏览全部</h2>
      </div>
      <div v-if="allWorks.length" class="card-grid">
        <div
          v-for="work in allWorks"
          :key="work.id"
          class="work-card"
          @click="goWorkDetail(work)"
        >
          <div class="card-cover">
            <img v-if="work.photo" :src="work.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="card-body">
            <div class="card-title">{{ work.name }}</div>
            <div class="card-meta">
              <span v-if="work.fenlei" class="card-tag">{{ work.fenlei }}</span>
              <span v-if="work.price" class="card-price">¥{{ work.price }}</span>
            </div>
          </div>
        </div>
      </div>
      <div v-if="allWorks.length && allWorksTotal > allWorks.length" class="load-more">
        <el-button :loading="allWorksLoading" type="text" @click="loadMoreWorks">
          加载更多
        </el-button>
      </div>
    </section>
  </div>
</template>

<script>
import huagaoApi from '@/api/huagao'
import recHuagaoApi from '@/api/recHuagao'
import fenleiApi from '@/api/fenlei'
import lunboApi from '@/api/lunbo'
import fenxiangApi from '@/api/fenxiang'
import { createClientEventId } from '@/utils/visitor'

export default {
  name: 'HomePage',
  data() {
    return {
      carouselItems: [],
      recommendWorks: [],
      recommendLoading: false,
      categories: [],
      communityPosts: [],
      allWorks: [],
      allWorksTotal: 0,
      allWorksPage: 1,
      allWorksLoading: false
    }
  },
  created() {
    this.fetchCarousel()
    this.fetchCategories()
    this.fetchCommunityPosts()
    this.fetchAllWorks()
    this.fetchRecommend()
  },
  methods: {
    /** 轮播图 */
    fetchCarousel() {
      lunboApi.getList1().then(res => {
        this.carouselItems = res.data.rows || []
      }).catch(() => {})
    },

    /** 分类标签 */
    fetchCategories() {
      fenleiApi.getFixedList().then(res => {
        this.categories = res.data.rows || []
      }).catch(() => {})
    },

    fetchCommunityPosts() {
      fenxiangApi.getList({
        pageNo: 1,
        pageSize: 4
      }).then(res => {
        this.communityPosts = res.data.rows || []
      }).catch(() => {})
    },

    /** LTR 推荐，后端无结果时会降级为最新上架橱窗 */
    fetchRecommend() {
      this.recommendLoading = true
      recHuagaoApi.recommendations({
        pageNo: 1,
        pageSize: 12,
        scene: 'home'
      }).then(res => {
        const requestId = res.data.requestId || ''
        const rows = res.data.rows || []
        this.recommendWorks = rows.map((item, index) => {
          return Object.assign({}, item, {
            trackingRequestId: requestId,
            trackingPosition: index + 1,
            trackingScene: 'home',
            trackingSource: 'home_recommend'
          })
        })
      }).catch(() => {
        return this.fetchLatest()
      }).finally(() => {
        this.recommendLoading = false
      })
    },

    fetchLatest() {
      return huagaoApi.getzuixin({ pageNo: 1, pageSize: 12 }).then(res => {
        this.recommendWorks = res.data.rows || []
      })
    },

    /** 全部作品 */
    fetchAllWorks() {
      this.allWorksLoading = true
      huagaoApi.getList({
        pageNo: this.allWorksPage,
        pageSize: 12,
        type: '上架',
        status: '审核成功'
      }).then(res => {
        const rows = res.data.rows || []
        this.allWorks = this.allWorksPage === 1 ? rows : this.allWorks.concat(rows)
        this.allWorksTotal = res.data.total || 0
      }).catch(() => {}).finally(() => {
        this.allWorksLoading = false
      })
    },

    loadMoreWorks() {
      this.allWorksPage++
      this.fetchAllWorks()
    },

    goWorkDetail(work) {
      const item = typeof work === 'object' ? work : { id: work }
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
          scene: item.trackingScene || 'home',
          source: item.trackingSource || 'home_recommend'
        }).catch(() => {})
        query.requestId = item.trackingRequestId
        query.position = item.trackingPosition
        query.scene = item.trackingScene || 'home'
        query.source = item.trackingSource || 'home_recommend'
      }
      this.$router.push({ path: '/work/' + item.id, query })
    },

    goPostDetail(id) {
      this.$router.push('/post/' + id)
    },

    goCategory(fenlei) {
      this.$router.push({
        path: '/showcase',
        query: fenlei ? { fenlei } : {}
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.home-page {
  padding-bottom: 60px;
}

/* ── 轮播区 ── */
.hero-carousel {
  margin-bottom: 8px;

  ::v-deep .el-carousel__indicators--outside {
    text-align: center;
  }
}

.carousel-slide {
  position: relative;
  width: 100%;
  height: 320px;
  border-radius: 16px;
  overflow: hidden;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.carousel-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.carousel-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 20px;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.45));
}

.carousel-label {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
}

/* ── 通用区块 ── */
.section {
  margin-top: 40px;
}

.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

/* ── 作品网格 ── */
.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.community-grid {
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

.community-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
}

.community-cover {
  position: relative;
  width: 100%;
  padding-top: 68%;
  background: #f5f5f5;
  overflow: hidden;
}

.community-body {
  padding: 14px 16px 16px;
}

.community-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  line-height: 1.5;
  min-height: 44px;
}

.community-meta {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  align-items: center;
  margin-top: 10px;
}

.community-author {
  font-size: 12px;
  color: #7b8796;
}

.card-cover {
  width: 100%;
  padding-top: 100%; /* 1:1 */
  position: relative;
  overflow: hidden;
  background: #f5f5f5;
}

.cover-img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cover-placeholder {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
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
  gap: 8px;
}

.card-tag {
  font-size: 12px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 2px 8px;
  border-radius: 4px;
}

.card-price {
  font-size: 13px;
  color: #e17055;
  font-weight: 500;
}

/* ── 分类标签 ── */
.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.category-tag {
  display: inline-block;
  padding: 8px 18px;
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
    background: rgba(108, 92, 231, 0.04);
  }
}

/* ── 加载更多 ── */
.load-more {
  text-align: center;
  margin-top: 24px;
}

.loading-placeholder {
  text-align: center;
  padding: 40px 0;
  color: #999;
  font-size: 14px;
}

/* ── 响应式 ── */
@media (max-width: 900px) {
  .card-grid,
  .community-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 600px) {
  .card-grid,
  .community-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .carousel-slide {
    height: 200px;
    border-radius: 8px;
  }

  .hero-carousel {
    ::v-deep .el-carousel {
      height: 200px !important;
    }
  }
}
</style>
