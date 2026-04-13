<template>
  <div class="auth-page">
    <div class="auth-page__left">
      <div class="brand-area">
        <h1 class="brand-name">Artistsion</h1>
        <p class="brand-slogan">画师接稿平台 · 让创作遇见需求</p>
        <div class="brand-illustration">
          <div class="illustration-placeholder" />
        </div>
        <p class="brand-desc">
          发现优秀画师，发布你的创作需求<br>
          让每一笔都有价值
        </p>
      </div>
    </div>

    <div class="auth-page__right">
      <div class="auth-card">
        <h2 class="auth-card__welcome">欢迎来到 Artistsion</h2>

        <div class="auth-tabs">
          <span
            class="auth-tab"
            :class="{ 'is-active': mode === 'login' }"
            @click="mode = 'login'"
          >登录</span>
          <span
            class="auth-tab"
            :class="{ 'is-active': mode === 'register' }"
            @click="mode = 'register'"
          >注册</span>
        </div>

        <!-- 登录表单 -->
        <el-form v-if="mode === 'login'" ref="loginForm" :model="loginForm" class="auth-form">
          <el-form-item>
            <el-input v-model="loginForm.account" placeholder="用户名或邮箱" prefix-icon="el-icon-user" />
          </el-form-item>
          <el-form-item>
            <el-input v-model="loginForm.password" type="password" placeholder="密码" prefix-icon="el-icon-lock" show-password />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" class="auth-submit" :loading="loading" @click="handleLogin">登 录</el-button>
          </el-form-item>
        </el-form>

        <!-- 注册表单 -->
        <el-form v-if="mode === 'register'" ref="registerForm" :model="registerForm" class="auth-form">
          <el-form-item>
            <el-input v-model="registerForm.username" placeholder="用户名" prefix-icon="el-icon-user" />
          </el-form-item>
          <el-form-item>
            <el-input v-model="registerForm.email" placeholder="邮箱" prefix-icon="el-icon-message" />
          </el-form-item>
          <el-form-item>
            <div class="code-row">
              <el-input v-model="registerForm.emailCode" placeholder="邮箱验证码" prefix-icon="el-icon-key" />
              <el-button size="medium" :disabled="codeCooldown > 0" @click="handleSendCode">
                {{ codeCooldown > 0 ? `${codeCooldown}s` : '发送验证码' }}
              </el-button>
            </div>
          </el-form-item>
          <el-form-item>
            <el-input v-model="registerForm.password" type="password" placeholder="密码" prefix-icon="el-icon-lock" show-password />
          </el-form-item>
          <el-form-item>
            <el-input v-model="registerForm.confirmPassword" type="password" placeholder="确认密码" prefix-icon="el-icon-lock" show-password />
          </el-form-item>
          <el-form-item>
            <el-input v-model="registerForm.nickname" placeholder="昵称" prefix-icon="el-icon-postcard" />
          </el-form-item>
          <el-form-item>
            <el-select v-model="registerForm.initialRole" placeholder="选择初始身份" style="width: 100%;">
              <el-option label="客户（约稿方）" value="client" />
              <el-option label="画师（接单方）" value="artist" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" class="auth-submit" :loading="loading" @click="handleRegister">注 册</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AuthPage',
  data() {
    return {
      mode: 'login',
      loading: false,
      codeCooldown: 0,
      loginForm: {
        account: '',
        password: ''
      },
      registerForm: {
        username: '',
        email: '',
        emailCode: '',
        password: '',
        confirmPassword: '',
        nickname: '',
        initialRole: 'client'
      }
    }
  },
  methods: {
    handleLogin() {
      // 阶段 1 占位：后续接 /auth/login 或复用旧 /user/login
      this.$message.info('登录功能将在阶段 2 接入')
    },
    handleRegister() {
      // 阶段 1 占位：后续接 /auth/register
      this.$message.info('注册功能将在阶段 2 接入')
    },
    handleSendCode() {
      // 阶段 1 占位：后续接 /auth/send-email-code
      this.$message.info('邮箱验证码将在阶段 2 接入')
    }
  }
}
</script>

<style lang="scss" scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  background: #f7f8fa;
}

.auth-page__left {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f5f0ff 0%, #ede5ff 100%);
  padding: 48px;
}

.brand-area {
  text-align: center;
  max-width: 400px;
}

.brand-name {
  font-size: 36px;
  font-weight: 800;
  color: #6c5ce7;
  margin: 0 0 8px;
}

.brand-slogan {
  font-size: 16px;
  color: #888;
  margin: 0 0 40px;
}

.illustration-placeholder {
  width: 280px;
  height: 200px;
  margin: 0 auto 32px;
  border-radius: 16px;
  background: linear-gradient(135deg, #ddd0f5 0%, #e8ddf8 100%);
}

.brand-desc {
  font-size: 14px;
  color: #999;
  line-height: 1.8;
}

.auth-page__right {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px;
}

.auth-card {
  width: 100%;
  max-width: 420px;
  background: #fff;
  border-radius: 20px;
  padding: 40px 36px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
}

.auth-card__welcome {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin: 0 0 24px;
  text-align: center;
}

.auth-tabs {
  display: flex;
  justify-content: center;
  gap: 32px;
  margin-bottom: 28px;
}

.auth-tab {
  font-size: 16px;
  font-weight: 500;
  color: #999;
  cursor: pointer;
  padding-bottom: 6px;
  border-bottom: 2px solid transparent;
  transition: color 0.2s, border-color 0.2s;

  &:hover {
    color: #555;
  }

  &.is-active {
    color: #6c5ce7;
    border-bottom-color: #6c5ce7;
  }
}

.auth-form {
  .el-form-item {
    margin-bottom: 18px;
  }
}

.code-row {
  display: flex;
  gap: 10px;

  .el-input {
    flex: 1;
  }
}

.auth-submit {
  width: 100%;
  height: 44px;
  font-size: 16px;
  border-radius: 10px;
}

/* 响应式：窄屏改为上下布局 */
@media (max-width: 900px) {
  .auth-page {
    flex-direction: column;
  }

  .auth-page__left {
    padding: 32px 24px;
  }

  .auth-page__right {
    padding: 24px;
  }

  .illustration-placeholder {
    width: 200px;
    height: 140px;
  }
}
</style>
