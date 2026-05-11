<template>
  <div class="admin-page">
    <el-card class="page-hero">
      <div class="page-hero__content">
        <div>
          <p class="page-kicker">Auth Config</p>
          <h1>注册配置</h1>
          <p>控制前台注册时是否必须填写并校验邮箱验证码。关闭后，适合批量创建测试或运营账号；开启后，恢复正常注册校验流程。</p>
        </div>
      </div>
    </el-card>

    <el-alert
      class="page-alert"
      title="该开关同时影响前台注册页展示和后端 /auth/register 校验逻辑。"
      type="warning"
      :closable="false"
      show-icon
    />

    <el-card v-loading="loading" class="setting-card">
      <div class="setting-card__header">
        <div>
          <div class="setting-card__title">邮箱验证码校验</div>
          <div class="setting-card__desc">开启时，用户注册必须先获取并提交邮箱验证码。</div>
        </div>
        <el-tag :type="form.requireEmailCode ? 'success' : 'info'" size="medium">
          {{ form.requireEmailCode ? '已开启' : '已关闭' }}
        </el-tag>
      </div>

      <div class="setting-card__body">
        <el-switch
          v-model="form.requireEmailCode"
          :active-value="true"
          :inactive-value="false"
          active-text="注册必须验证邮箱"
          inactive-text="跳过邮箱验证码"
        />

        <p class="setting-card__hint">
          {{ form.requireEmailCode ? '当前为标准注册模式，前台会展示验证码输入与发送按钮。' : '当前为快速注册模式，前台会隐藏验证码输入并直接允许注册。' }}
        </p>
      </div>

      <div class="setting-card__footer">
        <el-button icon="el-icon-refresh-left" @click="loadConfig">重新加载</el-button>
        <el-button type="primary" :loading="saving" @click="saveConfig">保存配置</el-button>
      </div>
    </el-card>
  </div>
</template>

<script>
import siteSettingApi from '@/api/siteSetting'

export default {
  name: 'SiteSettingPage',
  data() {
    return {
      loading: false,
      saving: false,
      form: {
        requireEmailCode: true
      }
    }
  },
  created() {
    this.loadConfig()
  },
  methods: {
    async loadConfig() {
      this.loading = true
      try {
        const response = await siteSettingApi.getAuthConfig()
        this.form.requireEmailCode = response.data.requireEmailCode !== false
      } finally {
        this.loading = false
      }
    },
    async saveConfig() {
      this.saving = true
      try {
        await siteSettingApi.updateAuthConfig(this.form)
        this.$message.success('注册配置已更新')
        this.loadConfig()
      } finally {
        this.saving = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.setting-card {
  max-width: 860px;
}

.setting-card__header,
.setting-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.setting-card__title {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
}

.setting-card__desc,
.setting-card__hint {
  margin: 8px 0 0;
  color: #6b7280;
  line-height: 1.7;
}

.setting-card__body {
  padding: 32px 0;
}

@media (max-width: 768px) {
  .setting-card__header,
  .setting-card__footer {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
