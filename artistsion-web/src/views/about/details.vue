<template>
  <div class="page-container">
    <the-header />
    <div class="post-wrap">
      <div class="post-breadcrumb-bar">
        <span class="crumb-label">交流区</span>
        <span class="crumb-sep">/</span>
        <span class="crumb-current">帖子正文</span>
      </div>
      <el-row :gutter="28">
        <el-col :xs="24" :md="16">
          <div class="article-container">
            <div class="article-header">
              <h1 class="article-title">{{ email.title }}</h1>
              <div class="article-meta">
                <div class="meta-item">
                  <i class="fa fa-user" /> {{ email.username }}
                </div>
                <div class="meta-item">
                  <i class="fa fa-calendar" /> {{ email.fbdate }}
                </div>
                <div class="meta-item">
                  <i class="fa fa-thumbs-up" /> {{ email.dznum }} 赞
                </div>
              </div>
            </div>
            <div class="article-content" v-html="email.content" />
          </div>
        </el-col>

        <el-col :xs="24" :md="8">
          <div class="interaction-container">
            <p class="side-hint">觉得有用就点个赞，有疑问欢迎留言。</p>
            <div class="action-buttons">
              <el-button
                :class="['like-button', { 'is-liked': isLiked }]"
                @click="toggleLike"
              >
                <i class="fa fa-thumbs-up" />
                {{ isLiked ? '已赞' : '点赞' }}
              </el-button>

              <el-button
                class="comment-button"
                @click="showCommentInput = !showCommentInput"
              >
                <i class="fa fa-comment" />
                写留言
              </el-button>
            </div>

            <el-collapse-transition>
              <div v-if="showCommentInput" class="comment-form">
                <el-input
                  v-model="newComment"
                  type="textarea"
                  placeholder="文明交流，禁止人身攻击与广告。"
                  rows="4"
                  resize="none"
                />
                <el-button
                  type="primary"
                  class="submit-comment-btn"
                  @click="postComment"
                >
                  <i class="fa fa-paper-plane" /> 发布
                </el-button>
              </div>
            </el-collapse-transition>

            <div class="comments-section">
              <h3 class="comments-title">
                <i class="fa fa-comments" /> 全部留言
              </h3>
              <el-collapse-transition>
                <div v-if="comments.length > 0" class="comments-list">
                  <div
                    v-for="comment in comments"
                    :key="comment.id"
                    class="comment-item"
                  >
                    <div class="comment-user">
                      <el-avatar :src="comment.avatar" :size="40" />
                      <div class="user-info">
                        <div class="username">{{ comment.plname }}</div>
                        <div class="comment-time">{{ comment.pldate }}</div>
                      </div>
                    </div>
                    <div class="comment-text">{{ comment.content }}</div>
                  </div>
                </div>
                <div v-else class="no-comments">
                  <i class="fa fa-comment-o" />
                  <p>还没有留言，来抢沙发吧</p>
                </div>
              </el-collapse-transition>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
import TheHeader from '@/views/about/the-header'
import api from '@/api/fenxiang.js'
import PlingLunapi from '@/api/pinglun.js'
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
import DianZangapi from '@/api/dianzan.js'

export default {
  name: 'EmailContent',
  components: { TheHeader },
  data() {
    return {
      email: {
        title: '示例帖子标题',
        type: '作者',
        fbdate: '2023-04-07 12:30:00',
        content: '正文加载中，若长时间无内容请检查网络或联系管理员。'
      },
      query: {},
      searchModel: {
        id: '',
        wzids: '',
        pageNo: 1,
        pageSize: 5
      },
      isFavorite: false,
      isLiked: false,
      showCommentInput: false,
      newComment: '',
      Form: {},
      Form1: {},
      comments: [
        {
          id: 1,
          avatar: 'https://example.com/avatar1.png',
          plname: '用户1',
          pldate: '2024-02-01 12:00:00',
          content: '占位评论，接口返回后会覆盖。'
        },
        {
          id: 2,
          avatar: 'https://example.com/avatar2.png',
          plname: '用户2',
          pldate: '2024-02-01 13:00:00',
          content: '同上。'
        }
      ]
    }
  },

  mounted() {
    this.query.id = this.$route.query.id
    this.Form.wzids = this.$route.query.id
    this.listNew()
    this.getInfo(this.token)
    this.fetchComments()
  },
  methods: {
    toggleLike() {
      this.Form1.id = this.$route.query.id
      this.Form1.dianzan = '点赞'
      this.searchModel.zpids = this.$route.query.id
      this.searchModel.userids = this.Form.userids
      DianZangapi.getList(this.searchModel).then(response => {
        this.dianzan = response.data.rows
        console.log('dianzan', this.dianzan)
        if (this.dianzan.length === 0) {
          api.saveOrUpdate(this.Form1).then(response => {
            this.$message({
              message: '点赞成功',
              type: 'success'
            })

            this.listNew()
          })

          this.Form.zpids = this.$route.query.id

          DianZangapi.saveOrUpdate(this.Form).then(response => {
          })
        } else {
          this.$message({
            message: '您已点过赞了',
            type: 'info'
          })
        }
      })
    },

    postComment() {
      if (!this.newComment.trim()) {
        this.$message({
          message: '留言不能为空',
          type: 'warning'
        })
        return
      }

      this.Form.content = this.newComment
      PlingLunapi.saveOrUpdate(this.Form).then(response => {
        this.$message({
          message: response.message,
          type: 'success'
        })
        this.listNew()
      })

      const newComment = {
        id: this.comments.length + 1,
        avatar: this.Form.avatar,
        plname: this.Form.plname,
        pldate: new Date().toLocaleString(),
        content: this.newComment
      }

      this.comments.push(newComment)
      this.newComment = ''
    },

    listNew() {
      this.searchModel.id = this.query.id
      this.searchModel.pageNo = '1'
      this.searchModel.pageSize = '6'
      api.getList(this.searchModel).then(response => {
        this.email = response.data.rows[0]
      })
    },

    getInfo(token) {
      userApi.getInfo(token).then(response => {
        this.forms = response.data.userList
        this.Form.userids = this.forms.id
        this.Form.plname = this.forms.name
        this.Form.avatar = this.forms.avatar
      })
    },

    fetchComments() {
      this.searchModel.wzids = this.query.id
      PlingLunapi.getList1(this.searchModel).then(response => {
        this.comments = response.data.rows
      })
    }
  },

  computed: {
    ...mapGetters(['token'])
  }
}
</script>

<style scoped>
.page-container {
  min-height: 100vh;
  background: #f6f3ee;
}

.post-wrap {
  max-width: 1180px;
  margin: 0 auto;
  padding: 1.5rem 1rem 3rem;
}

.post-breadcrumb-bar {
  margin-bottom: 1.25rem;
  font-size: 0.85rem;
  color: rgba(42, 38, 53, 0.55);
}

.crumb-label {
  color: #c084fc;
  font-weight: 600;
}

.crumb-sep {
  margin: 0 0.35rem;
  opacity: 0.5;
}

.crumb-current {
  color: #2a2635;
}

.article-container {
  background: #fffef9;
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(42, 38, 53, 0.06);
  padding: 1.75rem;
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.article-header {
  margin-bottom: 1.75rem;
  padding-bottom: 1.25rem;
  border-bottom: 1px solid rgba(42, 38, 53, 0.08);
}

.article-title {
  font-size: clamp(1.35rem, 3vw, 2rem);
  color: #2a2635;
  margin-bottom: 0.85rem;
  line-height: 1.35;
  font-weight: 800;
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  color: rgba(42, 38, 53, 0.55);
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
}

.article-content {
  font-size: 1rem;
  line-height: 1.85;
  color: #374151;
}

.interaction-container {
  background: #fffef9;
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(42, 38, 53, 0.06);
  padding: 1.35rem;
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.side-hint {
  font-size: 0.82rem;
  color: rgba(42, 38, 53, 0.5);
  margin: 0 0 1rem;
  line-height: 1.5;
}

.action-buttons {
  display: flex;
  gap: 0.65rem;
  margin-bottom: 1.25rem;
}

.like-button, .comment-button {
  flex: 1;
  padding: 0.65rem;
  border-radius: 999px;
  transition: all 0.2s ease;
}

.like-button {
  background: #f0ebe3;
  border: 1px solid rgba(42, 38, 53, 0.08);
  color: #2a2635;
}

.like-button.is-liked {
  background: linear-gradient(135deg, #ff8fab, #c084fc);
  color: #1e1b2e;
  border-color: transparent;
  font-weight: 600;
}

.comment-button {
  background: linear-gradient(135deg, #2d2640, #4a3266);
  color: #faf7f2;
  border: none;
}

.comment-form {
  margin-bottom: 1.5rem;
}

.submit-comment-btn {
  margin-top: 0.75rem;
  width: 100%;
  border-radius: 999px;
  padding: 0.65rem;
  background: linear-gradient(135deg, #a78bfa, #c084fc) !important;
  border: none !important;
}

.comments-section {
  margin-top: 1.5rem;
}

.comments-title {
  font-size: 1.05rem;
  color: #2a2635;
  margin-bottom: 1.1rem;
  padding-bottom: 0.65rem;
  border-bottom: 2px solid rgba(192, 132, 252, 0.35);
  font-weight: 700;
}

.comment-item {
  padding: 1rem;
  border-radius: 14px;
  background: #f6f3ee;
  margin-bottom: 0.75rem;
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.comment-user {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.65rem;
}

.user-info {
  flex: 1;
}

.username {
  font-weight: 600;
  color: #2a2635;
}

.comment-time {
  font-size: 0.78rem;
  color: rgba(42, 38, 53, 0.45);
  margin-top: 0.15rem;
}

.comment-text {
  color: #4b5563;
  line-height: 1.65;
  font-size: 0.92rem;
}

.no-comments {
  text-align: center;
  padding: 2rem 1rem;
  color: rgba(42, 38, 53, 0.45);
}

.no-comments i {
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
  color: rgba(192, 132, 252, 0.35);
}

@media (max-width: 768px) {
  .post-wrap {
    padding: 1rem 0.75rem 2rem;
  }
  .article-meta {
    flex-direction: column;
    gap: 0.35rem;
  }
  .interaction-container {
    margin-top: 1.25rem;
  }
}
</style>
