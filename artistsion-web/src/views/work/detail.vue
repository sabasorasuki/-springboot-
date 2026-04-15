<template>
  <div class="work-detail-page">
    <div v-if="loading" class="loading-box">
      <i class="el-icon-loading" /> 加载中…
    </div>
    <template v-else-if="work">
      <!-- 主体区域 -->
      <div class="detail-main">
        <!-- 左：大图 -->
        <div class="detail-cover">
          <img v-if="work.photo" :src="work.photo" alt="" class="cover-img">
          <div v-else class="cover-placeholder" />
        </div>
        <!-- 右：信息 -->
        <div class="detail-info">
          <h1 class="detail-title">{{ work.name }}</h1>
          <div class="detail-meta">
            <span v-if="work.fenlei" class="meta-tag">{{ work.fenlei }}</span>
            <span v-if="work.type" class="meta-status">{{ work.type }}</span>
          </div>
          <div class="detail-price-row">
            <span class="price">¥{{ work.price }}</span>
            <span v-if="work.zhekou && work.zhekou < 10" class="discount">{{ work.zhekou }}折</span>
          </div>
          <div v-if="work.shangjiaids" class="detail-artist">
            <span class="label">画师：</span>
            <span v-if="work.artistName" class="artist-name-text">{{ work.artistName }}</span>
            <el-button type="text" @click="goArtist(work.shangjiaids)">查看画师主页</el-button>
          </div>
          <div class="detail-actions">
            <el-button type="primary" icon="el-icon-shopping-cart-2" round :loading="cartLoading" @click="addToCart">加入购物车</el-button>
            <el-button :icon="isFav ? 'el-icon-star-on' : 'el-icon-star-off'" :type="isFav ? 'warning' : 'default'" round :loading="favLoading" @click="toggleFav">{{ isFav ? '已收藏' : '收藏' }}</el-button>
            <el-button type="danger" plain round @click="openReportDialog">举报作品</el-button>
          </div>
        </div>
      </div>

      <!-- 详细介绍 -->
      <div v-if="work.content" class="detail-content-section">
        <h2 class="section-title">作品介绍</h2>
        <div class="rich-content" v-html="work.content" />
      </div>

      <!-- 附件 -->
      <div v-if="work.fujin" class="detail-content-section">
        <h2 class="section-title">附件</h2>
        <a :href="work.fujin" target="_blank" class="attachment-link">
          <i class="el-icon-paperclip" /> 下载附件
        </a>
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
import ReportDialog from '@/components/ReportDialog'

export default {
  name: 'WorkDetail',
  components: {
    ReportDialog
  },
  data() {
    return {
      loading: true,
      work: null,
      isFav: false,
      favId: null,
      favLoading: false,
      cartLoading: false,
      reportVisible: false
    }
  },
  computed: {
    ...mapGetters(['userId'])
  },
  created() {
    this.fetchWork()
  },
  methods: {
    async fetchWork() {
      const id = this.$route.params.id
      if (!id) { this.loading = false; return }
      try {
        const res = await huagaoApi.getById(id)
        if (res.data && res.code === 20000) {
          this.work = res.data
          this.checkFav()
        }
      } catch (e) {
        console.error('获取作品详情失败', e)
      } finally {
        this.loading = false
      }
    },
    async checkFav() {
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
          await shoucangApi.add({
            title: this.work.name,
            wzids: String(this.work.id),
            photo: this.work.photo,
            fenlei: this.work.fenlei,
            price: String(this.work.price),
            userids: String(this.userId)
          })
          this.$message.success('收藏成功')
          this.checkFav()
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
        await orderApi.add({
          name: this.work.name,
          photo: this.work.photo,
          price: this.work.price,
          spids: String(this.work.id),
          shangjiaids: this.work.shangjiaids,
          userids: String(this.userId),
          status: '购物车'
        })
        this.$message.success('已加入购物车')
      } catch (e) {
        this.$message.error('加入购物车失败')
      } finally {
        this.cartLoading = false
      }
    },
    goArtist(artistId) {
      this.$router.push('/artist/' + artistId)
    },
    openReportDialog() {
      this.reportVisible = true
    }
  }
}
</script>

<style lang="scss" scoped>
.work-detail-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px;
}

.loading-box {
  text-align: center;
  padding: 80px 0;
  color: #999;
  font-size: 16px;
}

/* 主体：左图右信息 */
.detail-main {
  display: flex;
  gap: 32px;
  margin-bottom: 40px;
}

.detail-cover {
  flex: 0 0 480px;
  border-radius: 14px;
  overflow: hidden;
  background: #f5f5f5;
  aspect-ratio: 1;
}

.cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cover-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.detail-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.detail-title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  margin: 0;
}

.detail-meta {
  display: flex;
  gap: 10px;
  align-items: center;
}

.meta-tag {
  font-size: 13px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 3px 10px;
  border-radius: 4px;
}

.meta-status {
  font-size: 13px;
  color: #00b894;
  background: rgba(0, 184, 148, 0.08);
  padding: 3px 10px;
  border-radius: 4px;
}

.detail-price-row {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.price {
  font-size: 28px;
  font-weight: 700;
  color: #e17055;
}

.discount {
  font-size: 14px;
  color: #fff;
  background: #e17055;
  padding: 2px 8px;
  border-radius: 4px;
}

.detail-artist {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #666;
  font-size: 14px;

  .label {
    color: #999;
  }
}

.detail-actions {
  margin-top: auto;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

/* 内容区 */
.detail-content-section {
  margin-bottom: 32px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 16px 0;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.rich-content {
  line-height: 1.8;
  color: #555;
  font-size: 14px;

  img {
    max-width: 100%;
    border-radius: 8px;
  }
}

.attachment-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #6c5ce7;
  text-decoration: none;
  font-size: 14px;

  &:hover {
    text-decoration: underline;
  }
}
</style>
