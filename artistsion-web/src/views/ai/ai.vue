<template>
  <div class="ai-page">
    <el-card class="chat-card" shadow="never">
      <div slot="header" class="chat-header">
        <div>
          <span class="chat-title">接稿助手</span>
          <small>基于通义千问，解答约稿流程、报价与沟通话术</small>
        </div>
      </div>

      <div class="qa-container">
        <div v-if="aiResponse" class="ai-response">
          <div class="response-title">回复</div>
          <div class="response-content" v-html="formatMessage(aiResponse)"></div>
        </div>

        <div class="question-input">
          <el-input
            type="textarea"
            v-model="userInput"
            :rows="4"
            placeholder="例如：头像稿如何报价？定金比例怎么约定？如何避免跑单？"
            :disabled="isLoading"
          />
          <el-button
            type="primary"
            class="send-btn"
            @click="sendMessage"
            :loading="isLoading"
            :disabled="!userInput.trim()"
          >
            发送
          </el-button>
        </div>

        <div class="quick-questions">
          <div class="quick-title">快捷提问</div>
          <div class="quick-btns">
            <el-button
              v-for="(question, index) in quickQuestions"
              :key="index"
              size="small"
              plain
              @click="quickAsk(question)"
            >
              {{ question }}
            </el-button>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script>
import api from '@/api/huagao.js'

export default {
  name: 'AiChat',
  data() {
    return {
      userInput: '',
      isLoading: false,
      aiResponse: '',
      quickQuestions: [
        '头像稿一般怎么定价？',
        '商用与私用授权有什么区别？',
        '定金、尾款和修改次数怎么写进说明？',
        '截稿日前客户失联怎么办？',
        '如何避免需求不清晰导致返工？',
        '压缩包交付时要注意什么？'
      ]
    }
  },
  methods: {
    async sendMessage() {
      if (!this.userInput.trim() || this.isLoading) return
      this.isLoading = true
      const savedInput = this.userInput
      try {
        const response = await api.aliTyqw({ content: savedInput })
        this.aiResponse = response.message
      } catch (error) {
        this.$message.error('请求失败，请稍后重试')
      } finally {
        this.isLoading = false
      }
    },
    quickAsk(question) {
      this.userInput = question
      this.sendMessage()
    },
    formatMessage(text) {
      if (!text) return ''
      return String(text).replace(/\n/g, '<br>')
    }
  }
}
</script>

<style scoped>
.ai-page {
  max-width: 920px;
  margin: 20px auto;
  padding: 0 12px;
}

.chat-card {
  background: #fffef9;
  border: 1px solid rgba(42, 38, 53, 0.06);
  border-radius: 16px;
}

.chat-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
}

.chat-title {
  font-size: 1.25rem;
  font-weight: 800;
  color: #2a2635;
  display: block;
  margin-bottom: 6px;
}

.chat-header small {
  display: block;
  color: rgba(42, 38, 53, 0.55);
  font-size: 0.85rem;
}

.qa-container {
  padding: 8px 4px 4px;
}

.ai-response {
  background: #f6f3ee;
  border-radius: 14px;
  padding: 18px;
  margin-bottom: 22px;
  border: 1px solid rgba(42, 38, 53, 0.06);
}

.response-title {
  font-weight: 700;
  color: #7c3aed;
  margin-bottom: 10px;
  font-size: 0.9rem;
}

.response-content {
  line-height: 1.75;
  color: #374151;
  font-size: 0.95rem;
}

.question-input {
  margin: 16px 0;
}

.send-btn {
  width: 100%;
  margin-top: 12px;
  border-radius: 999px;
  padding: 12px;
  background: linear-gradient(135deg, #2d2640, #4a3266) !important;
  border: none !important;
}

.quick-questions {
  margin-top: 24px;
  padding-top: 18px;
  border-top: 1px solid rgba(42, 38, 53, 0.08);
}

.quick-title {
  margin-bottom: 12px;
  color: rgba(42, 38, 53, 0.5);
  font-size: 0.85rem;
}

.quick-btns .el-button {
  margin: 0 8px 8px 0;
  border-radius: 999px;
  border-color: rgba(192, 132, 252, 0.45);
  color: #5b21b6;
}
</style>
