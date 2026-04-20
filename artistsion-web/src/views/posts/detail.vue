<template>
  <div class="post-detail-page">
    <div v-if="loading" class="loading-box">
      <i class="el-icon-loading" /> 加载中…
    </div>
    <template v-else-if="post">
      <section class="post-hero">
        <div class="hero-copy">
          <p class="hero-kicker">Community Post</p>
          <h1>{{ post.title }}</h1>
          <div class="hero-meta">
            <span v-if="post.fenlei" class="meta-tag">{{ post.fenlei }}</span>
            <span class="meta-item">{{ post.username || '匿名用户' }}</span>
            <span class="meta-item">{{ post.fbdate || '未记录发布时间' }}</span>
          </div>
        </div>
        <div class="hero-actions">
          <el-button
            v-if="isOwner"
            type="danger"
            plain
            round
            :loading="deleteLoading"
            @click="handleDelete"
          >
            删除投稿
          </el-button>
          <el-button type="danger" plain round @click="openReportDialog">举报内容</el-button>
        </div>
      </section>

      <section v-if="post.photo" class="post-cover-card">
        <img :src="post.photo" alt="" class="post-cover">
      </section>

      <section class="post-content-card">
        <div class="section-header">
          <h2>内容详情</h2>
          <el-tag size="mini" effect="plain" type="warning">互动热度 {{ post.dznum || 0 }}</el-tag>
        </div>
        <div class="post-content" v-html="post.content || '<p>暂无内容</p>'" />
      </section>
    </template>
    <el-empty v-else description="帖子不存在或已被删除" />

    <ReportDialog
      v-model="reportVisible"
      target-type="社区内容"
      :target-id="post ? post.id : ''"
      :target-title="post ? post.title : ''"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import fenxiangApi from '@/api/fenxiang'
import ReportDialog from '@/components/ReportDialog'
import { buildCenterProfileRoute } from '@/utils/centerProfile'

export default {
  name: 'PostDetail',
  components: {
    ReportDialog
  },
  data() {
    return {
      loading: true,
      post: null,
      reportVisible: false,
      deleteLoading: false
    }
  },
  computed: {
    ...mapGetters(['userId']),
    isOwner() {
      if (!this.post || !this.userId) return false
      return String(this.post.userids) === String(this.userId)
    }
  },
  created() {
    this.fetchPost()
  },
  methods: {
    async fetchPost() {
      const id = this.$route.params.id
      if (!id) {
        this.loading = false
        return
      }
      try {
        const response = await fenxiangApi.getById(id)
        if (response.code === 20000) {
          this.post = response.data
        }
      } catch (error) {
        console.error('获取帖子详情失败', error)
      } finally {
        this.loading = false
      }
    },
    handleDelete() {
      if (!this.post || !this.post.id) return
      this.$confirm(`确认删除投稿《${this.post.title || '未命名投稿'}》吗？删除后无法恢复。`, '删除确认', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
        this.deleteLoading = true
        try {
          const response = await fenxiangApi.deleteById(this.post.id)
          this.$message.success(response.message || '投稿已删除')
          this.$router.replace(buildCenterProfileRoute({
            isSelf: true,
            viewMode: 'artist',
            tab: 'submissions',
            sub: 'works'
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
.post-detail-page {
  max-width: 1020px;
  margin: 0 auto;
  padding: 32px 20px 56px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.loading-box {
  text-align: center;
  padding: 80px 0;
  color: #8391a3;
}

.post-hero {
  display: flex;
  justify-content: space-between;
  gap: 24px;
  padding: 28px 32px;
  border-radius: 24px;
  background:
    radial-gradient(circle at top right, rgba(255, 209, 143, 0.28), transparent 34%),
    linear-gradient(135deg, #102542 0%, #1d436d 42%, #2f5a86 100%);
  color: #fff;
}

.hero-kicker {
  margin: 0 0 8px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.72);
}

.post-hero h1 {
  margin: 0;
  font-size: 30px;
  line-height: 1.2;
}

.hero-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 16px;
}

.meta-tag,
.meta-item {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  padding: 0 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.12);
  color: rgba(255, 255, 255, 0.88);
  font-size: 13px;
}

.hero-actions {
  display: flex;
  align-items: flex-start;
}

.post-cover-card,
.post-content-card {
  padding: 24px;
  border-radius: 22px;
  background: #fff;
  border: 1px solid #e8edf5;
  box-shadow: 0 8px 24px rgba(16, 37, 66, 0.05);
}

.post-cover {
  display: block;
  width: 100%;
  max-height: 520px;
  object-fit: cover;
  border-radius: 18px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: center;
  margin-bottom: 18px;
}

.section-header h2 {
  margin: 0;
  font-size: 22px;
  color: #102542;
}

.post-content {
  color: #314156;
  line-height: 1.9;

  ::v-deep img {
    max-width: 100%;
    border-radius: 14px;
  }
}

@media (max-width: 768px) {
  .post-hero {
    flex-direction: column;
    padding: 24px;
  }

  .post-hero h1 {
    font-size: 26px;
  }
}
</style>
