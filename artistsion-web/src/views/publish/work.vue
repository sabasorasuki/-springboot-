<template>
  <div class="publish-work">
    <el-card class="publish-card">
      <div class="publish-header">
        <div>
          <h2 class="publish-title">{{ publishType === 'zuopin' ? '发布作品' : '发布橱窗' }}</h2>
          <p class="publish-desc">
            {{ publishType === 'zuopin' ? '在这里发布作品内容，页面内直接切换投稿类型。' : '在这里上架橱窗商品，页面内直接切换投稿类型。' }}
          </p>
        </div>

        <el-radio-group v-model="publishType" class="publish-switch" @change="handleTypeChange">
          <el-radio-button label="zuopin">发布作品</el-radio-button>
          <el-radio-button label="huagao">发布橱窗</el-radio-button>
        </el-radio-group>
      </div>

      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <div class="type-hint">
          {{ publishType === 'zuopin' ? '作品投稿无需审核，发布后直接展示。' : '橱窗商品发布后直接上架。' }}
        </div>

        <!-- 通用字段：封面图 -->
        <el-form-item label="封面图" prop="photo">
          <el-upload
            class="avatar-uploader"
            :action="ossUploadAction('photo')"
            :show-file-list="false"
            :on-success="handlePhotoSuccess"
          >
            <img v-if="form.photo" :src="form.photo" class="avatar-preview">
            <i v-else class="el-icon-plus avatar-uploader-icon" />
          </el-upload>
        </el-form-item>

        <!-- 作品模式：标题(可选)、分类、说明(可选) -->
        <template v-if="publishType === 'zuopin'">
          <el-form-item label="标题">
            <el-input v-model="form.title" placeholder="给作品起个名字（可选）" />
          </el-form-item>

          <el-form-item label="分类" prop="fenlei">
            <el-select v-model="form.fenlei" placeholder="选择分类" clearable style="width: 100%;">
              <el-option
                v-for="item in categories"
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

        <!-- 橱窗模式：名称、价格、折扣、分类、备注、描述(wangeditor) -->
        <template v-else>
          <el-form-item label="画稿名称" prop="name">
            <el-input v-model="form.name" placeholder="给橱窗商品命名" />
          </el-form-item>

          <el-form-item label="价格" prop="price">
            <el-input-number v-model="form.price" :min="0" :precision="2" placeholder="设定价格" style="width: 100%;" />
          </el-form-item>

          <el-form-item label="折扣/元">
            <el-input-number v-model="form.zhekou" :min="0" placeholder="优惠金额（可选）" style="width: 100%;" />
          </el-form-item>

          <el-form-item label="分类">
            <el-select v-model="form.fenlei" placeholder="选择分类" clearable style="width: 100%;">
              <el-option
                v-for="item in categories"
                :key="item.id"
                :label="item.name"
                :value="item.name"
              />
            </el-select>
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
            {{ publishType === 'zuopin' ? '发布作品' : '发布上架' }}
          </el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { ossDownloadUrl, ossUploadAction, ossUploadImgServer } from '@/utils/oss'
import fenxiangApi from '@/api/fenxiang'
import huagaoApi from '@/api/huagao'
import fenleiApi from '@/api/fenlei'
import userApi from '@/api/userManage'

export default {
  name: 'PublishWork',
  data() {
    return {
      publishType: 'zuopin',
      submitting: false,
      categories: [],
      userInfo: null,
      editor: null,
      form: {
        photo: '',
        title: '',
        fenlei: '',
        content: '',
        // 橱窗专用
        name: '',
        price: undefined,
        zhekou: undefined,
        fujin: ''
      },
      rules: {
        photo: [{ required: true, message: '请上传封面图', trigger: 'change' }]
      }
    }
  },
  computed: {
    ...mapGetters(['token'])
  },
  created() {
    this.loadCategories()
    this.loadUserInfo()
    // 从 query 参数读取默认类型
    if (this.$route.query.type === 'huagao') {
      this.publishType = 'huagao'
    }
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
    handleTypeChange(val) {
      if (val === 'huagao') {
        this.$nextTick(() => this.initEditor())
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
    },
    loadCategories() {
      fenleiApi.getList1().then(res => {
        const rows = res.data.rows || []
        this.categories = rows.map(r => ({ id: r.id, name: r.fenlei }))
      })
    },
    loadUserInfo() {
      userApi.getInfo(this.token).then(res => {
        this.userInfo = res.data.userList
      })
    },
    handlePhotoSuccess(res) {
      const name = (res && res.data) || (res && res.message) || ''
      if (name) {
        this.form.photo = ossDownloadUrl(name)
        this.$refs.form && this.$refs.form.validateField('photo')
      }
    },
    handleSubmit() {
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
        photo: this.form.photo,
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
      if (!this.userInfo) {
        this.$message.error('用户信息加载中，请稍后重试')
        return
      }
      if (!this.form.name) {
        this.$message.warning('请填写画稿名称')
        return
      }
      this.submitting = true
      const data = {
        name: this.form.name,
        photo: this.form.photo,
        price: this.form.price || 0,
        zhekou: this.form.zhekou || 0,
        fenlei: this.form.fenlei || '',
        fujin: this.form.fujin || '',
        content: this.editor ? this.editor.txt.html() : '',
        type: '上架',
        status: '审核成功',
        shangjiaids: this.userInfo.id
      }
      huagaoApi.add(data).then(res => {
        this.$message.success(res.message || '发布成功')
        this.$router.push('/showcase')
      }).catch(() => {
        this.$message.error('提交失败')
      }).finally(() => {
        this.submitting = false
      })
    }
  }
}
</script>

<style scoped>
.publish-work {
  max-width: 800px;
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
