<template>
  <div class="artist-detail-page">
    <div v-if="loading" class="loading-box">
      <i class="el-icon-loading" /> 加载中…
    </div>
    <template v-else-if="artist">
      <!-- 画师头部 -->
      <div class="artist-header">
        <el-avatar :size="96" :src="artist.avatar" icon="el-icon-user" class="artist-avatar" />
        <div class="artist-meta">
          <h1 class="artist-name">{{ artist.name || artist.username }}</h1>
          <div class="artist-tags">
            <span class="tag-item works-count">{{ artist.workCount || 0 }} 件作品</span>
            <span v-if="artist.status === 1" class="tag-item status-active">接稿中</span>
          </div>
          <div v-if="styleTagList.length" class="style-tags">
            <span v-for="tag in styleTagList" :key="tag" class="style-tag">{{ tag }}</span>
          </div>
          <p v-if="artist.bio" class="artist-bio">{{ artist.bio }}</p>
        </div>
      </div>

      <!-- 作品集 -->
      <section class="section">
        <div class="section-header">
          <h2 class="section-title">TA 的作品</h2>
        </div>
        <div v-if="worksLoading" class="loading-box">
          <i class="el-icon-loading" /> 加载中…
        </div>
        <div v-else-if="works.length" class="card-grid">
          <div
            v-for="w in works"
            :key="w.id"
            class="work-card"
            @click="goWork(w.id)"
          >
            <div class="card-cover">
              <img v-if="w.photo" :src="w.photo" alt="" class="cover-img">
              <div v-else class="cover-placeholder" />
            </div>
            <div class="card-body">
              <div class="card-title">{{ w.name }}</div>
              <div class="card-meta">
                <span v-if="w.fenlei" class="card-tag">{{ w.fenlei }}</span>
                <span v-if="w.price" class="card-price">¥{{ w.price }}</span>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无作品" :image-size="120" />

        <div v-if="works.length && worksTotal > works.length" class="load-more">
          <el-button :loading="worksLoading" type="text" @click="loadMoreWorks">加载更多</el-button>
        </div>
      </section>
    </template>
    <el-empty v-else description="画师不存在" />
  </div>
</template>

<script>
import artistApi from '@/api/artist'
import huagaoApi from '@/api/huagao'

export default {
  name: 'ArtistDetail',
  data() {
    return {
      loading: true,
      artist: null,
      works: [],
      worksTotal: 0,
      worksLoading: false,
      worksPage: 1
    }
  },
  created() {
    this.fetchArtist()
  },
  computed: {
    styleTagList() {
      if (!this.artist || !this.artist.styleTags) return []
      return this.artist.styleTags.split(',').map(s => s.trim()).filter(Boolean)
    }
  },
  methods: {
    async fetchArtist() {
      const id = this.$route.params.id
      if (!id) { this.loading = false; return }
      try {
        const res = await artistApi.getById(id)
        if (res.data && res.code === 20000) {
          this.artist = res.data
          this.fetchWorks()
        }
      } catch (e) {
        console.error('获取画师信息失败', e)
      } finally {
        this.loading = false
      }
    },
    async fetchWorks() {
      this.worksLoading = true
      try {
        const res = await huagaoApi.getList({
          shangjiaids: String(this.$route.params.id),
          type: '上架',
          status: '审核成功',
          pageNo: this.worksPage,
          pageSize: 12
        })
        if (res.data && res.code === 20000) {
          this.works = this.works.concat(res.data.rows || [])
          this.worksTotal = res.data.total || 0
        }
      } catch (e) {
        console.error('获取画师作品失败', e)
      } finally {
        this.worksLoading = false
      }
    },
    loadMoreWorks() {
      this.worksPage++
      this.fetchWorks()
    },
    goWork(id) {
      this.$router.push('/work/' + id)
    }
  }
}
</script>

<style lang="scss" scoped>
.artist-detail-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px;
}

.loading-box {
  text-align: center;
  padding: 60px 0;
  color: #999;
  font-size: 16px;
}

/* ── 画师头部 ── */
.artist-header {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 40px;
  padding: 28px 32px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.artist-avatar {
  flex-shrink: 0;
}

.artist-name {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px 0;
}

.artist-tags {
  display: flex;
  gap: 10px;
}

.tag-item {
  font-size: 13px;
  padding: 3px 10px;
  border-radius: 4px;
}

.works-count {
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
}

.status-active {
  color: #00b894;
  background: rgba(0, 184, 148, 0.08);
}

.style-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 8px;
}

.style-tag {
  font-size: 12px;
  padding: 2px 10px;
  border-radius: 4px;
  color: #e17055;
  background: rgba(225, 112, 85, 0.08);
}

.artist-bio {
  margin: 10px 0 0;
  font-size: 14px;
  color: #666;
  line-height: 1.6;
}

/* ── 区块 ── */
.section {
  margin-top: 32px;
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

/* ── 作品网格（同首页） ── */
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

.load-more {
  text-align: center;
  margin-top: 24px;
}
</style>
