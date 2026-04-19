<template>
  <div class="publish-project">
    <el-card class="publish-card">
      <h2 class="publish-title">发布企划需求</h2>

      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="企划标题" prop="title">
          <el-input v-model="form.title" placeholder="简要描述您的需求" maxlength="80" show-word-limit />
        </el-form-item>

        <el-form-item label="分类" prop="category">
          <el-select v-model="form.category" placeholder="选择分类" clearable style="width: 100%;">
            <el-option label="插画" value="插画" />
            <el-option label="立绘" value="立绘" />
            <el-option label="头像" value="头像" />
            <el-option label="漫画" value="漫画" />
            <el-option label="设计" value="设计" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>

        <el-form-item label="风格偏好">
          <el-input v-model="form.style" placeholder="例如：二次元、写实、Q版、赛博朋克…（可选）" />
        </el-form-item>

        <el-form-item label="预算范围">
          <div class="budget-row">
            <el-input-number v-model="form.budgetMin" :min="0" :precision="0" placeholder="最低" controls-position="right" style="width: 45%;" />
            <span class="budget-sep">—</span>
            <el-input-number v-model="form.budgetMax" :min="0" :precision="0" placeholder="最高" controls-position="right" style="width: 45%;" />
          </div>
        </el-form-item>

        <el-form-item label="截止日期">
          <el-date-picker
            v-model="form.deadline"
            type="date"
            placeholder="选择截止日期（可选）"
            value-format="yyyy-MM-dd"
            style="width: 100%;"
          />
        </el-form-item>

        <el-form-item label="需求描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="6"
            placeholder="详细描述您的需求：场景、人物、尺寸、交付格式等"
            maxlength="2000"
            show-word-limit
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            发布企划
          </el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import projectApi from '@/api/project'
import userApi from '@/api/userManage'

export default {
  name: 'PublishProject',
  data() {
    return {
      submitting: false,
      userInfo: null,
      form: {
        title: '',
        category: '',
        style: '',
        budgetMin: undefined,
        budgetMax: undefined,
        deadline: '',
        description: ''
      },
      rules: {
        title: [{ required: true, message: '请输入企划标题', trigger: 'blur' }],
        description: [{ required: true, message: '请描述您的需求', trigger: 'blur' }]
      }
    }
  },
  computed: {
    ...mapGetters(['token'])
  },
  created() {
    this.loadUserInfo()
  },
  methods: {
    loadUserInfo() {
      userApi.getInfo(this.token).then(res => {
        this.userInfo = res.data.userList
      })
    },
    handleSubmit() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (!this.userInfo) {
          this.$message.error('用户信息加载中，请稍后重试')
          return
        }
        this.submitting = true
        const data = {
          title: this.form.title,
          description: this.form.description,
          category: this.form.category || '',
          style: this.form.style || '',
          budgetMin: this.form.budgetMin || null,
          budgetMax: this.form.budgetMax || null,
          deadline: this.form.deadline || null,
          status: '招募中',
          userId: this.userInfo.id,
          username: this.userInfo.name,
          userAvatar: this.userInfo.photo || ''
        }
        projectApi.add(data).then(res => {
          this.$message.success(res.message || '发布成功')
          this.$router.push('/projects')
        }).catch(() => {
          this.$message.error('发布失败')
        }).finally(() => {
          this.submitting = false
        })
      })
    }
  }
}
</script>

<style scoped>
.publish-project {
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
  margin-bottom: 24px;
  color: #303133;
}
.budget-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.budget-sep {
  color: #c0c4cc;
}
</style>
