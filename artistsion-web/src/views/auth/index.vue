<template>
  <div class="auth-page">
    <div class="auth-background" aria-hidden="true">
      <div
        v-for="(image, index) in backgroundImages"
        :key="image"
        class="auth-background__slide"
        :style="{ backgroundImage: `url(${image})`, animationDelay: `${index * 9 - 3}s, ${index * -3}s` }"
      />
    </div>
    <div class="auth-page__veil" aria-hidden="true" />

    <main class="auth-shell">
      <section class="auth-card">
        <div class="auth-card__brand">
          <span class="brand-mark">A</span>
          <div>
            <h1>Artistsion</h1>
            <p>画师接稿平台</p>
          </div>
        </div>

        <h2 class="auth-card__welcome">欢迎回来</h2>

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

        <el-form v-if="mode === 'register'" ref="registerForm" :model="registerForm" class="auth-form auth-form--register">
          <el-form-item>
            <el-input v-model="registerForm.username" placeholder="用户名" prefix-icon="el-icon-user" />
          </el-form-item>
          <el-form-item>
            <el-input v-model="registerForm.email" placeholder="邮箱" prefix-icon="el-icon-message" />
          </el-form-item>
          <el-form-item v-if="requireEmailCode">
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
      </section>
    </main>
  </div>
</template>

<script>
import { authRegister, getRegisterOptions, sendEmailCode } from '@/api/auth'

const backgroundImages = [
  require('../../../../static/photo/元气壁纸_1775037240806.jpg'),
  require('../../../../static/photo/元气壁纸_1775036067438.jpg'),
  require('../../../../static/photo/元气壁纸_1778338865757.jpg'),
  require('../../../../static/photo/元气壁纸_1775035980337.jpg'),
  require('../../../../static/photo/元气壁纸_1777730565658.png'),
  require('../../../../static/photo/元气壁纸_1778338502669.jpg')
]

export default {
  name: 'AuthPage',
  data() {
    return {
      mode: 'login',
      loading: false,
      requireEmailCode: true,
      codeCooldown: 0,
      codeCooldownTimer: null,
      backgroundImages,
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
  created() {
    this.fetchRegisterOptions()
  },
  beforeDestroy() {
    if (this.codeCooldownTimer) {
      clearInterval(this.codeCooldownTimer)
    }
  },
  methods: {
    async fetchRegisterOptions() {
      try {
        const response = await getRegisterOptions()
        this.applyRegisterOptions(response.data)
      } catch (error) {
        this.requireEmailCode = true
      }
    },
    applyRegisterOptions(options = {}) {
      this.requireEmailCode = options.requireEmailCode !== false
      if (!this.requireEmailCode) {
        this.registerForm.emailCode = ''
        if (this.codeCooldownTimer) {
          clearInterval(this.codeCooldownTimer)
          this.codeCooldownTimer = null
        }
        this.codeCooldown = 0
      }
    },
    async handleLogin() {
      if (!this.loginForm.account || !this.loginForm.password) {
        this.$message.warning('请输入账号和密码')
        return
      }
      this.loading = true
      try {
        await this.$store.dispatch('user/authLogin', {
          account: this.loginForm.account,
          password: this.loginForm.password
        })
        const redirect = this.$route.query.redirect || '/home'
        this.$router.push({ path: redirect })
      } catch (err) {
        this.$message.error(err.message || '登录失败')
      } finally {
        this.loading = false
      }
    },
    async handleRegister() {
      const f = this.registerForm
      if (!f.username || !f.email || !f.password || (this.requireEmailCode && !f.emailCode)) {
        this.$message.warning('请填写所有必填项')
        return
      }
      if (f.password !== f.confirmPassword) {
        this.$message.warning('两次输入的密码不一致')
        return
      }
      this.loading = true
      try {
        await authRegister({
          username: f.username,
          email: f.email,
          emailCode: f.emailCode,
          password: f.password,
          nickname: f.nickname,
          initialRole: f.initialRole
        })
        this.$message.success('注册成功，请登录')
        this.mode = 'login'
        this.loginForm.account = f.username
      } catch (err) {
        this.$message.error(err.message || '注册失败')
      } finally {
        this.loading = false
      }
    },
    async handleSendCode() {
      if (!this.requireEmailCode) {
        this.$message.info('当前已关闭邮箱验证码校验')
        return
      }
      if (!this.registerForm.email || !this.registerForm.email.includes('@')) {
        this.$message.warning('请输入有效邮箱')
        return
      }
      try {
        await sendEmailCode({ email: this.registerForm.email })
        this.$message.success('验证码已发送，请查收邮箱')
        this.codeCooldown = 60
        this.codeCooldownTimer = setInterval(() => {
          this.codeCooldown--
          if (this.codeCooldown <= 0) {
            clearInterval(this.codeCooldownTimer)
            this.codeCooldownTimer = null
          }
        }, 1000)
      } catch (err) {
        this.$message.error(err.message || '发送失败')
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.auth-page {
  min-height: 100vh;
  position: relative;
  overflow: hidden;
  background: #111827;
}

.auth-background,
.auth-page__veil {
  position: fixed;
  inset: 0;
}

.auth-background {
  z-index: 0;
  background: #111827;
}

.auth-background__slide {
  position: absolute;
  inset: -4vh -4vw;
  background-position: center;
  background-size: cover;
  opacity: 0;
  will-change: opacity, transform;
  animation-name: authBgFade, authBgDrift;
  animation-duration: 54s, 24s;
  animation-timing-function: ease-in-out, ease-in-out;
  animation-iteration-count: infinite, infinite;
  transform: scale(1.08) translate3d(0, 0, 0);

  &:first-child {
    opacity: 1;
  }
}

.auth-page__veil {
  z-index: 1;
  background:
    radial-gradient(circle at 18% 20%, rgba(255, 255, 255, 0.24), transparent 32%),
    radial-gradient(circle at 80% 76%, rgba(94, 234, 212, 0.18), transparent 34%),
    linear-gradient(135deg, rgba(7, 10, 22, 0.38), rgba(20, 17, 39, 0.46) 58%, rgba(6, 12, 22, 0.68));
  pointer-events: none;
}

.auth-shell {
  position: relative;
  z-index: 2;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
}

.auth-card {
  width: 100%;
  max-width: 430px;
  max-height: calc(100vh - 64px);
  overflow-y: auto;
  padding: 34px 34px 32px;
  border: 1px solid rgba(255, 255, 255, 0.58);
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.75);
  box-shadow: 0 28px 80px rgba(14, 116, 144, 0.18), inset 0 1px 0 rgba(255, 255, 255, 0.58);
}

.auth-card__brand {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 22px;

  h1 {
    margin: 0;
    color: #161923;
    font-size: 24px;
    font-weight: 800;
    line-height: 1.1;
  }

  p {
    margin: 4px 0 0;
    color: rgba(22, 25, 35, 0.56);
    font-size: 13px;
  }
}

.brand-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 14px;
  color: #075985;
  font-size: 20px;
  font-weight: 800;
  background: linear-gradient(135deg, #e0f2fe 0%, #93c5fd 52%, #67e8f9 100%);
  box-shadow: 0 14px 28px rgba(56, 189, 248, 0.24);
}

.auth-card__welcome {
  margin: 0 0 20px;
  text-align: center;
  color: #111827;
  font-size: 22px;
  font-weight: 700;
}

.auth-tabs {
  display: flex;
  width: 176px;
  height: 40px;
  margin: 0 auto 26px;
  padding: 4px;
  border: 1px solid rgba(17, 24, 39, 0.08);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.56);
}

.auth-tab {
  flex: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  font-size: 16px;
  font-weight: 600;
  color: rgba(17, 24, 39, 0.54);
  cursor: pointer;
  transition: color 0.2s, background 0.2s, box-shadow 0.2s;

  &:hover {
    color: #111827;
  }

  &.is-active {
    color: #075985;
    background: linear-gradient(135deg, #e0f2fe, #93c5fd 58%, #67e8f9);
    box-shadow: 0 8px 20px rgba(56, 189, 248, 0.2);
  }
}

.auth-form {
  .el-form-item {
    margin-bottom: 16px;
  }

  ::v-deep .el-input__inner {
    height: 46px;
    border: 1px solid rgba(17, 24, 39, 0.1);
    border-radius: 14px;
    color: #111827;
    background: rgba(255, 255, 255, 0.76);
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.7);
    transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
  }

  ::v-deep .el-input__inner:focus {
    border-color: rgba(14, 165, 233, 0.62);
    background: rgba(255, 255, 255, 0.92);
    box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.12);
  }

  ::v-deep .el-input__prefix,
  ::v-deep .el-input__suffix {
    color: rgba(17, 24, 39, 0.46);
  }

  ::v-deep .el-select .el-input.is-focus .el-input__inner {
    border-color: rgba(14, 165, 233, 0.62);
  }
}

.auth-form--register {
  .el-form-item {
    margin-bottom: 13px;
  }
}

.code-row {
  display: flex;
  gap: 10px;

  .el-input {
    flex: 1;
  }

  .el-button {
    min-width: 104px;
    height: 46px;
    border: 0;
    border-radius: 14px;
    color: #075985;
    background: linear-gradient(135deg, #dbeafe, #7dd3fc);
  }
}

.auth-submit {
  width: 100%;
  height: 46px;
  margin-top: 4px;
  border: 0;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0;
  color: #075985;
  background: linear-gradient(135deg, #e0f2fe, #93c5fd 56%, #67e8f9);
  box-shadow: 0 14px 30px rgba(56, 189, 248, 0.24);

  &:hover,
  &:focus {
    color: #075985;
    background: linear-gradient(135deg, #bae6fd, #7dd3fc 56%, #22d3ee);
  }
}

::v-deep .el-alert {
  border-radius: 14px;
  background-color: rgba(236, 244, 255, 0.82);
}

@keyframes authBgFade {
  0% {
    opacity: 0;
  }
  4% {
    opacity: 1;
  }
  19% {
    opacity: 1;
  }
  26% {
    opacity: 0;
  }
  100% {
    opacity: 0;
  }
}

@keyframes authBgDrift {
  0% {
    transform: scale(1.08) translate3d(-1.4vw, -1.2vh, 0);
  }
  50% {
    transform: scale(1.13) translate3d(1.6vw, 1.2vh, 0);
  }
  100% {
    transform: scale(1.08) translate3d(-1.4vw, -1.2vh, 0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .auth-background__slide {
    animation: none;
    opacity: 0;
  }

  .auth-background__slide:first-child {
    opacity: 1;
  }
}

@media (max-width: 560px) {
  .auth-shell {
    align-items: center;
    padding: 18px;
  }

  .auth-card {
    max-height: calc(100vh - 36px);
    padding: 28px 22px 24px;
    border-radius: 16px;
  }

  .auth-card__brand {
    margin-bottom: 18px;
  }

  .auth-card__welcome {
    font-size: 20px;
  }

  .code-row {
    gap: 8px;

    .el-button {
      min-width: 92px;
      padding-right: 12px;
      padding-left: 12px;
    }
  }
}
</style>
