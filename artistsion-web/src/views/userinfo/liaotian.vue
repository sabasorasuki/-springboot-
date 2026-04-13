<template>
  <div class="lt-wrap">
    <div class="chat-shell">
      <div class="chat-title">{{ richtexttitle }}</div>
      <div class="chat-hint">支持文字、图片预览与附件下载（如 zip 压缩包）。附件通过服务端存储，点击下载即可。</div>
      <div ref="msgBox" class="messages">
        <div
          v-for="message in messages"
          :key="message.id"
          class="message"
          :class="{ own: message.own }"
        >
          <div class="avatar">
            <img :src="message.avatar || defaultAvatar" alt="">
          </div>
          <div class="message-content">
            <div class="message-header">
              <span class="message-name">{{ message.name }}</span>
              <span class="message-time">{{ message.time }}</span>
            </div>
            <div class="bubble" :class="{ 'bubble-own': message.own }">
              <div v-if="message.payload.kind === 'text'" class="text-content">{{ message.payload.text }}</div>
              <div v-else-if="message.payload.kind === 'image'" class="img-wrap">
                <el-image
                  :src="message.payload.url"
                  :preview-src-list="[message.payload.url]"
                  fit="contain"
                  class="msg-img"
                >
                  <div slot="error" class="img-err">加载失败</div>
                </el-image>
                <div class="img-tip">点击图片可预览、放大</div>
              </div>
              <div v-else-if="message.payload.kind === 'file'" class="file-wrap">
                <i class="el-icon-document" />
                <span class="fname">{{ message.payload.name }}</span>
                <el-button type="text" class="dl-btn" @click="downloadFile(message.payload)">下载</el-button>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="toolbar">
        <el-upload
          class="lt-upload"
          :action="uploadActionPhoto"
          :show-file-list="false"
          :on-success="(res, file) => onUploadSuccess(res, file, 'image')"
          :on-error="onUploadError"
          accept="image/*"
        >
          <el-button size="small" icon="el-icon-picture-outline">图片</el-button>
        </el-upload>
        <el-upload
          class="lt-upload"
          :action="uploadActionPhoto"
          :show-file-list="false"
          :before-upload="beforeFileUpload"
          :on-success="(res, file) => onUploadSuccess(res, file, 'file')"
          :on-error="onUploadError"
          accept=".zip,.rar,.7z,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.psd"
        >
          <el-button size="small" icon="el-icon-paperclip">文件</el-button>
        </el-upload>
      </div>
      <div class="input-area">
        <el-input
          v-model="form.content"
          type="textarea"
          :rows="2"
          placeholder="输入文字后发送；或使用上方按钮传图 / 附件"
        />
        <el-button type="primary" class="send-btn" @click="sendText">发送</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { ossBase } from '@/utils/oss'
import userApi from '@/api/userManage'
import api from '@/api/order.js'
import Xiaoxiapi from '@/api/xiaoxi.js'

export default {
  data() {
    return {
      id: null,
      baseApi: process.env.VUE_APP_BASE_API,
      defaultAvatar: 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png',
      currentUserName: '',
      form: { content: '' },
      messages: [],
      richtexttitle: '会话',
      searchModel: {
        pageNo: 1,
        pageSize: 99
      },
      timer: null,
      forms: {}
    }
  },
  created() {
    this.id = this.$route.params.id
    this.form.tsids = this.id
    this.getInfo(this.token)
    if (this.id) {
      this.searchModel.tsids = this.id
      api.getById(this.id).then(response => {
        this.richtexttitle = (response.data.name || '订单') + ' · 沟通'
      })
    }
    this.startTimer()
  },
  beforeDestroy() {
    this.clearTimer()
  },
  computed: {
    ...mapGetters(['token']),
    ossHost() {
      const b = (this.baseApi && String(this.baseApi).trim()) || ''
      return b.replace(/\/$/, '') || ossBase
    },
    uploadActionPhoto() {
      return `${this.ossHost}/oss/file/upload?module=photo`
    }
  },
  methods: {
    extractUploadStoredName(res) {
      if (!res) {
        return ''
      }
      const code = res.code
      if (code != null && Number(code) !== 20000 && String(code) !== '20000') {
        return ''
      }
      let d = res.data
      if (d && typeof d === 'object' && d.url) {
        d = d.url
      }
      if (typeof d === 'string' && d) {
        return d
      }
      const msg = res.message
      if (typeof msg === 'string' && msg.trim()) {
        return msg.trim()
      }
      return ''
    },
    beforeFileUpload(file) {
      if (file.type && file.type.indexOf('image/') === 0) {
        this.$message.warning('请用「图片」按钮发送图片')
        return false
      }
      return true
    },
    buildOssDownloadUrl(storedName) {
      return `${this.ossHost}/oss/file/download?name=${storedName}`
    },
    parseNameFromUrl(u) {
      if (!u || typeof u !== 'string') {
        return ''
      }
      const m = u.match(/[?&]name=([^&]*)/)
      return m ? decodeURIComponent(m[1]) : ''
    },
    parseContent(raw) {
      if (raw == null || raw === '') {
        return { kind: 'text', text: '' }
      }
      const s = String(raw).trim()
      if (s.startsWith('{')) {
        try {
          const o = JSON.parse(s)
          if (o.msgType === 'image') {
            const file = o.file || this.parseNameFromUrl(o.url)
            const url = o.url || (file ? this.buildOssDownloadUrl(file) : '')
            if (file || url) {
              return { kind: 'image', file: file || this.parseNameFromUrl(url), name: o.name || file || '图片', url }
            }
          }
          if (o.msgType === 'file') {
            const file = o.file || this.parseNameFromUrl(o.url)
            const url = o.url || (file ? this.buildOssDownloadUrl(file) : '')
            if (file || url) {
              return { kind: 'file', file: file || this.parseNameFromUrl(url), name: o.name || file || '附件', url }
            }
          }
        } catch (e) {
          /* plain text */
        }
      }
      return { kind: 'text', text: raw }
    },
    downloadFile(payload) {
      const base = this.buildOssDownloadUrl(payload.file)
      window.open(`${base}&attachment=true&originalName=${encodeURIComponent(payload.name || payload.file || 'file')}`)
    },
    buildBody(content) {
      return {
        tsids: String(this.id),
        name: this.forms.name,
        avatar: this.forms.avatar,
        content
      }
    },
    onUploadSuccess(res, file, kind) {
      const stored = this.extractUploadStoredName(res)
      if (!stored) {
        this.$message.error('上传失败')
        return
      }
      const accessUrl = this.buildOssDownloadUrl(stored)
      const msgType = kind === 'image' ? 'image' : 'file'
      const body = this.buildBody(JSON.stringify({
        msgType,
        file: stored,
        name: (file && file.name) || String(stored),
        url: accessUrl
      }))
      Xiaoxiapi.saveOrUpdate(body).then(r => {
        this.$message({ message: r.message || '已发送', type: 'success' })
        this.getList()
        this.scrollBottom()
      }).catch(() => {
        this.$message.error('消息发送失败')
      })
    },
    onUploadError() {
      this.$message.error('上传失败')
    },
    sendText() {
      const t = (this.form.content || '').trim()
      if (!t) {
        return
      }
      const body = this.buildBody(t)
      Xiaoxiapi.saveOrUpdate(body).then(res => {
        this.$message({ message: res.message || '已发送', type: 'success' })
        this.form.content = ''
        this.getList()
        this.scrollBottom()
      }).catch(() => {
        this.$message.error('发送失败')
      })
    },
    scrollBottom() {
      this.$nextTick(() => {
        const el = this.$refs.msgBox
        if (el) {
          el.scrollTop = el.scrollHeight
        }
      })
    },
    startTimer() {
      this.timer = setInterval(() => {
        if (this.id) {
          this.getList()
        }
      }, 2000)
    },
    clearTimer() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = null
      }
    },
    getInfo(token) {
      userApi.getInfo(token).then(response => {
        this.forms = response.data.userList
        this.currentUserName = this.forms.name
        this.form.name = this.forms.name
        this.form.avatar = this.forms.avatar
        if (this.id) {
          this.getList()
        }
      })
    },
    getList() {
      if (!this.id) {
        return
      }
      this.searchModel.tsids = this.id
      Xiaoxiapi.getList(this.searchModel).then(response => {
        const fetchedMessages = response.data.rows.map(item => ({
          id: item.id,
          payload: this.parseContent(item.content),
          own: item.name === this.currentUserName,
          name: item.name,
          avatar: item.avatar,
          time: item.lydate
        }))
        if (JSON.stringify(this.messages) !== JSON.stringify(fetchedMessages)) {
          this.messages = fetchedMessages
          this.scrollBottom()
        }
      })
    }
  }
}
</script>

<style scoped>
.lt-wrap {
  padding: 16px;
  min-height: calc(100vh - 100px);
  background: #f6f3ee;
}

.chat-shell {
  max-width: 880px;
  margin: 0 auto;
  height: calc(100vh - 140px);
  min-height: 520px;
  display: flex;
  flex-direction: column;
  background: #fffef9;
  border-radius: 18px;
  border: 1px solid rgba(42, 38, 53, 0.08);
  box-shadow: 0 12px 40px rgba(30, 27, 46, 0.08);
  overflow: hidden;
}

.chat-title {
  text-align: center;
  font-size: 1.15rem;
  font-weight: 800;
  color: #2a2635;
  padding: 14px 16px 6px;
}

.chat-hint {
  text-align: center;
  font-size: 0.78rem;
  color: rgba(42, 38, 53, 0.5);
  padding: 0 20px 10px;
  line-height: 1.5;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #f0ebe3;
}

.message {
  display: flex;
  margin-bottom: 14px;
  align-items: flex-start;
}

.message.own {
  flex-direction: row-reverse;
}

.message.own .message-content {
  align-items: flex-end;
}

.message-content {
  display: flex;
  flex-direction: column;
  max-width: 72%;
}

.message-header {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  width: 100%;
  font-size: 0.8rem;
  color: rgba(42, 38, 53, 0.55);
  margin-bottom: 4px;
}

.message-name {
  font-weight: 600;
  color: #2a2635;
}

.bubble {
  padding: 10px 14px;
  border-radius: 14px;
  background: #fff;
  border: 1px solid rgba(42, 38, 53, 0.06);
  word-break: break-word;
}

.bubble-own {
  background: linear-gradient(135deg, #ede9fe, #fce7f3);
  border-color: rgba(192, 132, 252, 0.25);
}

.text-content {
  line-height: 1.55;
  font-size: 0.92rem;
  color: #374151;
}

.img-wrap {
  max-width: 260px;
}

.msg-img {
  width: 220px;
  max-height: 220px;
  border-radius: 10px;
  display: block;
  cursor: zoom-in;
}

.img-tip {
  font-size: 11px;
  color: rgba(42, 38, 53, 0.45);
  margin-top: 4px;
}

.img-err {
  width: 220px;
  height: 120px;
  line-height: 120px;
  text-align: center;
  background: #f3f4f6;
  color: #9ca3af;
  border-radius: 10px;
}

.file-wrap {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: #2a2635;
}

.fname {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.dl-btn {
  color: #7c3aed !important;
  font-weight: 600;
}

.avatar img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.message:not(.own) .avatar {
  margin-right: 10px;
}

.message.own .avatar {
  margin-left: 10px;
}

.toolbar {
  display: flex;
  gap: 10px;
  padding: 10px 16px 0;
  background: #fffef9;
  border-top: 1px solid rgba(42, 38, 53, 0.06);
}

.input-area {
  display: flex;
  gap: 10px;
  align-items: flex-end;
  padding: 12px 16px 16px;
  background: #fffef9;
}

.input-area .el-textarea {
  flex: 1;
}

.send-btn {
  border-radius: 999px;
  padding: 12px 22px;
  background: linear-gradient(135deg, #2d2640, #4a3266) !important;
  border: none !important;
}
</style>

<style>
.lt-wrap .el-image-viewer__wrapper {
  z-index: 5000 !important;
}
</style>
