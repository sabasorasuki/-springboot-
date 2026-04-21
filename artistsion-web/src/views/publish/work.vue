<template>
  <div class="publish-work">
    <el-card class="publish-card">
      <div class="publish-header">
        <div>
          <h2 class="publish-title">{{ pageTitle }}</h2>
          <p class="publish-desc">{{ pageDesc }}</p>
        </div>

        <el-radio-group
          v-model="publishType"
          class="publish-switch"
          :disabled="isHuagaoEditMode"
          @change="handleTypeChange"
        >
          <el-radio-button label="zuopin">发布作品</el-radio-button>
          <el-radio-button label="huagao">发布橱窗</el-radio-button>
        </el-radio-group>
      </div>

      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <div class="type-hint">
          {{ publishType === 'zuopin' ? '作品投稿无需标签配置。' : '橱窗发布需选择固定分类、系统标签与可选自由标签。' }}
        </div>

        <el-form-item label="封面图" prop="photo">
          <el-upload
            class="avatar-uploader"
            :action="ossUploadAction('photo')"
            :show-file-list="false"
            :on-success="handlePhotoSuccess"
            :on-error="handlePhotoError"
          >
            <img v-if="previewPhoto" :src="previewPhoto" class="avatar-preview" @error="handlePreviewError">
            <div v-else class="avatar-placeholder">
              <i class="el-icon-plus avatar-uploader-icon" />
              <span class="avatar-placeholder__text">上传可直接展示的封面图</span>
            </div>
          </el-upload>
        </el-form-item>

        <template v-if="publishType === 'zuopin'">
          <el-form-item label="标题">
            <el-input v-model="form.title" placeholder="给作品起个名字（可选）" />
          </el-form-item>

          <el-form-item label="分类" prop="fenlei">
            <el-select v-model="form.fenlei" placeholder="选择分类" clearable style="width: 100%;">
              <el-option
                v-for="item in categoryOptions"
                :key="item.id"
                :label="item.name"
                :value="item.name"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="说明">
            <el-input v-model="form.content" type="textarea" :rows="4" placeholder="补充说明（可选）" />
          </el-form-item>
        </template>

        <template v-else>
          <el-form-item label="橱窗标题" prop="name">
            <el-input v-model="form.name" placeholder="给橱窗商品命名" maxlength="255" show-word-limit />
          </el-form-item>

          <el-form-item label="价格" prop="price">
            <el-input-number v-model="form.price" :min="0" :precision="2" placeholder="设定价格" style="width: 100%;" />
          </el-form-item>

          <el-form-item label="折扣/元">
            <el-input-number v-model="form.zhekou" :min="0" placeholder="优惠金额（可选）" style="width: 100%;" />
          </el-form-item>

          <el-form-item label="分类" prop="fenlei">
            <el-select v-model="form.fenlei" placeholder="选择分类" clearable style="width: 100%;">
              <el-option
                v-for="item in categoryOptions"
                :key="item.id"
                :label="item.name"
                :value="item.name"
              />
            </el-select>
            <div class="field-hint">当前发布入口默认只提供固定分类；编辑 legacy 橱窗时会保留原分类供回填。</div>
          </el-form-item>

          <el-form-item label="系统标签" prop="systemTagIds">
            <el-select
              v-model="form.systemTagIds"
              multiple
              filterable
              collapse-tags
              clearable
              style="width: 100%;"
              placeholder="请选择 3~8 个系统标签"
            >
              <el-option-group
                v-for="group in groupedSystemTags"
                :key="group.name"
                :label="group.name"
              >
                <el-option
                  v-for="item in group.items"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-option-group>
            </el-select>
            <div class="field-hint">已选 {{ form.systemTagIds.length }} 个，发布时必须选择 3~8 个系统标签。</div>
          </el-form-item>

          <el-form-item label="自由标签" prop="freeTagNames">
            <el-select
              v-model="form.freeTagNames"
              multiple
              filterable
              allow-create
              default-first-option
              reserve-keyword
              clearable
              style="width: 100%;"
              placeholder="输入后按回车，可填写角色名、IP 名、OC 名、CP 名等"
              @change="handleFreeTagsChange"
            >
              <el-option
                v-for="item in freeTagSuggestions"
                :key="item"
                :label="item"
                :value="item"
              />
            </el-select>
            <div class="field-hint">最多 10 个，每个标签 2~20 个字符；保存时会自动 trim、去重并做归一化。</div>
          </el-form-item>

          <el-form-item label="备注">
            <el-input v-model="form.fujin" type="textarea" :rows="2" placeholder="备注信息（可选）" />
          </el-form-item>

          <el-form-item label="描述">
            <div ref="editorContainer" style="z-index: 0; line-height: normal;" />
          </el-form-item>
        </template>

        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            {{ publishButtonText }}
          </el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { extractUploadFileName, normalizeImageUrl, ossDownloadUrl, ossUploadAction, ossUploadImgServer } from '@/utils/oss'
import fenxiangApi from '@/api/fenxiang'
import huagaoApi from '@/api/huagao'
import fenleiApi from '@/api/fenlei'
import tagApi from '@/api/tag'
import userApi from '@/api/userManage'

const TAG_GROUP_ORDER = ['风格', '人物', '构图', '情绪', '发型发色', '服装', '场景', '配色', '用途', '生产属性']
const INVISIBLE_SPACE_RE = /[\u200B\u200C\u200D\u2060\uFEFF\u00A0\u3000\r\n\t]/g

export default {
  name: 'PublishWork',
  data() {
    const validateHuagaoCategory = (rule, value, callback) => {
      if (this.publishType === 'huagao' && !value) {
        callback(new Error('请选择分类'))
        return
      }
      callback()
    }
    const validateSystemTags = (rule, value, callback) => {
      if (this.publishType !== 'huagao') {
        callback()
        return
      }
      const count = Array.isArray(value) ? value.length : 0
      if (count < 3 || count > 8) {
        callback(new Error('请选择 3~8 个系统标签'))
        return
      }
      callback()
    }
    const validateFreeTags = (rule, value, callback) => {
      if (this.publishType !== 'huagao') {
        callback()
        return
      }
      const next = this.normalizeFreeTagNames(value)
      if (next.length > 10) {
        callback(new Error('自由标签最多 10 个'))
        return
      }
      const invalid = next.find(item => item.length < 2 || item.length > 20)
      if (invalid) {
        callback(new Error('自由标签长度需控制在 2~20 个字符之间'))
        return
      }
      callback()
    }

    return {
      publishType: 'zuopin',
      submitting: false,
      loadingOptions: false,
      userInfo: null,
      editor: null,
      editorHtmlCache: '',
      categoryOptions: [],
      systemTagOptions: [],
      freeTagSuggestions: [],
      editingHuagaoId: null,
      form: {
        photo: '',
        title: '',
        fenlei: '',
        content: '',
        name: '',
        price: undefined,
        zhekou: 0,
        fujin: '',
        systemTagIds: [],
        freeTagNames: []
      },
      rules: {
        photo: [{ required: true, message: '请上传封面图', trigger: 'change' }],
        name: [{ required: true, message: '请填写橱窗标题', trigger: 'blur' }],
        price: [{ required: true, message: '请填写价格', trigger: 'change' }],
        fenlei: [{ validator: validateHuagaoCategory, trigger: 'change' }],
        systemTagIds: [{ validator: validateSystemTags, trigger: 'change' }],
        freeTagNames: [{ validator: validateFreeTags, trigger: 'change' }]
      }
    }
  },
  computed: {
    ...mapGetters(['token']),
    previewPhoto() {
      return normalizeImageUrl(this.form.photo)
    },
    isHuagaoEditMode() {
      return this.publishType === 'huagao' && !!this.editingHuagaoId
    },
    pageTitle() {
      if (this.isHuagaoEditMode) {
        return '编辑橱窗'
      }
      return this.publishType === 'zuopin' ? '发布作品' : '发布橱窗'
    },
    pageDesc() {
      if (this.isHuagaoEditMode) {
        return '在这里修改橱窗内容，分类和标签会自动回填。'
      }
      return this.publishType === 'zuopin'
        ? '在这里发布作品内容，页面内直接切换投稿类型。'
        : '在这里上架橱窗商品，并补充分类、系统标签和自由标签。'
    },
    publishButtonText() {
      if (this.isHuagaoEditMode) {
        return '保存橱窗'
      }
      return this.publishType === 'zuopin' ? '发布作品' : '发布上架'
    },
    groupedSystemTags() {
      return TAG_GROUP_ORDER.map(groupName => ({
        name: groupName,
        items: this.systemTagOptions.filter(item => item.tagGroup === groupName)
      })).filter(group => group.items.length > 0)
    }
  },
  created() {
    this.resolveRouteState()
    this.loadUserInfo()
    this.loadPublishOptions()
  },
  mounted() {
    if (this.publishType === 'huagao') {
      this.$nextTick(() => this.initEditor())
    }
  },
  beforeDestroy() {
    if (this.editor) {
      this.editor.destroy()
      this.editor = null
    }
  },
  methods: {
    ossUploadAction,
    resolveRouteState() {
      if (this.$route.query.type === 'huagao') {
        this.publishType = 'huagao'
      }
      if (this.$route.query.id) {
        this.editingHuagaoId = Number(this.$route.query.id)
        this.publishType = 'huagao'
      }
    },
    async loadPublishOptions() {
      this.loadingOptions = true
      try {
        const tasks = [fenleiApi.getFixedList()]
        if (this.publishType === 'huagao' || this.editingHuagaoId) {
          tasks.push(tagApi.getSystemOptions())
        }
        const responses = await Promise.all(tasks)
        const categoryRows = responses[0].data.rows || []
        this.categoryOptions = categoryRows.map(row => ({ id: row.id, name: row.fenlei }))
        if (responses[1]) {
          this.systemTagOptions = responses[1].data || []
        }
        if (this.editingHuagaoId) {
          await this.loadHuagaoDetail(this.editingHuagaoId)
        }
      } finally {
        this.loadingOptions = false
      }
    },
    loadUserInfo() {
      userApi.getInfo(this.token).then(res => {
        this.userInfo = res.data.userList
      })
    },
    handleTypeChange(val) {
      if (val === 'huagao') {
        this.$nextTick(() => this.initEditor())
        if (this.systemTagOptions.length === 0) {
          tagApi.getSystemOptions().then(res => {
            this.systemTagOptions = res.data || []
          })
        }
      } else if (this.editor) {
        this.editor.destroy()
        this.editor = null
      }
    },
    initEditor() {
      if (this.editor || !this.$refs.editorContainer) return
      const E = require('wangeditor')
      this.editor = new E(this.$refs.editorContainer)
      this.editor.config.height = 300
      this.editor.config.zIndex = 0
      this.editor.config.pasteFilterStyle = false
      this.editor.config.uploadImgServer = ossUploadImgServer
      this.editor.config.withCredentials = true
      this.editor.config.uploadFileName = 'myFileName'
      this.editor.config.uploadImgMaxSize = 5 * 1024 * 1024
      this.editor.config.uploadImgMaxLength = 1
      this.editor.config.uploadImgHooks = {
        customInsert: (insertImg, result) => {
          insertImg(ossDownloadUrl(result.data.url))
        }
      }
      this.editor.config.showLinkImgAlt = false
      this.editor.config.showLinkImgHref = false
      this.editor.create()
      if (this.editorHtmlCache) {
        this.editor.txt.html(this.editorHtmlCache)
      }
    },
    async loadHuagaoDetail(id) {
      const response = await huagaoApi.getById(id)
      const detail = response.data
      this.form = {
        photo: detail.photo || '',
        title: '',
        fenlei: detail.fenlei || '',
        content: '',
        name: detail.name || '',
        price: detail.price,
        zhekou: detail.zhekou || 0,
        fujin: detail.fujin || '',
        systemTagIds: detail.systemTagIds || [],
        freeTagNames: detail.freeTagNames || []
      }
      this.editorHtmlCache = detail.content || ''
      this.freeTagSuggestions = [...(detail.freeTagNames || [])]
      this.ensureCurrentCategoryOption(detail.fenlei)
      this.mergeSystemTagOptions(detail.systemTags || [])
      if (this.editor) {
        this.editor.txt.html(this.editorHtmlCache)
      } else {
        this.$nextTick(() => this.initEditor())
      }
    },
    ensureCurrentCategoryOption(categoryName) {
      if (!categoryName) return
      const exists = this.categoryOptions.some(item => item.name === categoryName)
      if (!exists) {
        this.categoryOptions = [
          { id: `legacy-${categoryName}`, name: categoryName },
          ...this.categoryOptions
        ]
      }
    },
    mergeSystemTagOptions(tags) {
      const existingIds = new Set(this.systemTagOptions.map(item => item.id))
      tags.forEach(tag => {
        if (!existingIds.has(tag.id)) {
          this.systemTagOptions.push(tag)
          existingIds.add(tag.id)
        }
      })
    },
    handlePhotoSuccess(res) {
      const name = extractUploadFileName(res)
      if (!name) {
        this.$message.error((res && res.message) || '封面上传失败')
        return
      }

      const finalUrl = normalizeImageUrl(name)
      if (!finalUrl) {
        this.$message.error('封面地址无效，请重新上传')
        return
      }

      this.form.photo = finalUrl
      this.$refs.form && this.$refs.form.validateField('photo')
    },
    handlePhotoError() {
      this.$message.error('封面上传失败，请稍后重试')
    },
    handlePreviewError() {
      this.form.photo = ''
    },
    normalizeFreeTagNames(tagNames = []) {
      const seen = new Set()
      const result = []
      tagNames.forEach(rawItem => {
        const rawValue = typeof rawItem === 'string' ? rawItem : ''
        const cleaned = rawValue.trim().replace(INVISIBLE_SPACE_RE, '')
        if (!cleaned) {
          return
        }
        const displayValue = cleaned.normalize('NFKC')
        const normalizedValue = cleaned.toLowerCase().normalize('NFKC')
        if (!seen.has(normalizedValue)) {
          seen.add(normalizedValue)
          result.push(displayValue)
        }
      })
      return result
    },
    handleFreeTagsChange(values) {
      const normalized = this.normalizeFreeTagNames(values)
      this.form.freeTagNames = normalized
      this.freeTagSuggestions = Array.from(new Set([...this.freeTagSuggestions, ...normalized]))
    },
    handleSubmit() {
      this.handleFreeTagsChange(this.form.freeTagNames)
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (this.publishType === 'zuopin') {
          this.submitZuopin()
        } else {
          this.submitHuagao()
        }
      })
    },
    submitZuopin() {
      if (!this.userInfo) {
        this.$message.error('用户信息加载中，请稍后重试')
        return
      }
      this.submitting = true
      const data = {
        photo: normalizeImageUrl(this.form.photo),
        title: this.form.title || '',
        fenlei: this.form.fenlei || '',
        content: this.form.content || '',
        userids: this.userInfo.id,
        username: this.userInfo.name
      }
      fenxiangApi.add(data).then(res => {
        this.$message.success(res.message || '发布成功')
        this.$router.push('/works')
      }).catch(() => {
        this.$message.error('发布失败')
      }).finally(() => {
        this.submitting = false
      })
    },
    submitHuagao() {
      if (!this.token) {
        this.$message.error('请先登录后再操作')
        return
      }
      this.submitting = true
      const data = {
        id: this.editingHuagaoId || undefined,
        name: this.form.name,
        photo: normalizeImageUrl(this.form.photo),
        price: this.form.price || 0,
        zhekou: this.form.zhekou || 0,
        fenlei: this.form.fenlei || '',
        fujin: this.form.fujin || '',
        content: this.editor ? this.editor.txt.html() : this.editorHtmlCache,
        type: '上架',
        status: this.isHuagaoEditMode ? undefined : '审核成功',
        systemTagIds: this.form.systemTagIds,
        freeTagNames: this.normalizeFreeTagNames(this.form.freeTagNames)
      }
      huagaoApi.publish(data).then(res => {
        this.$message.success(res.message || '保存成功')
        this.$router.push('/showcase')
      }).catch(() => {
        this.$message.error(this.isHuagaoEditMode ? '保存失败' : '提交失败')
      }).finally(() => {
        this.submitting = false
      })
    }
  }
}
</script>

<style scoped>
.publish-work {
  max-width: 860px;
  margin: 30px auto;
  padding: 0 20px;
}

.publish-card {
  border-radius: 8px;
}

.publish-title {
  font-size: 22px;
  font-weight: 600;
  margin: 0;
  color: #303133;
}

.publish-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 24px;
}

.publish-desc {
  margin: 8px 0 0;
  font-size: 13px;
  color: #909399;
}

.publish-switch {
  flex-shrink: 0;
}

.type-hint {
  margin: 0 0 18px;
  font-size: 12px;
  color: #909399;
}

.field-hint {
  margin-top: 6px;
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

.avatar-uploader >>> .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  overflow: hidden;
}

.avatar-uploader >>> .el-upload:hover {
  border-color: #409eff;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  line-height: 178px;
  text-align: center;
}

.avatar-placeholder {
  width: 178px;
  height: 178px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: linear-gradient(135deg, #f3efe8 0%, #f8f6f1 100%);
}

.avatar-placeholder__text {
  width: 132px;
  text-align: center;
  font-size: 12px;
  line-height: 1.5;
  color: #909399;
}

.avatar-preview {
  width: 178px;
  height: 178px;
  display: block;
  object-fit: cover;
}

@media (max-width: 768px) {
  .publish-header {
    flex-direction: column;
  }
}
</style>
