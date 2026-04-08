<template>
  <div class="auth-page">
    <div class="auth-left">
      <div class="auth-brand">
        <span class="mark">绘</span>
        <div>
          <h1>画师接稿平台</h1>
          <p>橱窗 · 订单 · 沟通，一站式管理</p>
        </div>
      </div>
      <ul class="auth-bullets">
        <li>上架稿位与例图，买家一目了然</li>
        <li>订单与聊天集中处理，减少漏单</li>
        <li>数据与权限后台可控</li>
      </ul>
    </div>
    <div class="auth-right">
      <div class="auth-card">
        <h2 class="auth-title">登录</h2>
        <p class="auth-sub">使用账号登录管理后台</p>
        <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="auth-form" label-position="top">
          <el-form-item prop="username" label="账号">
            <el-input ref="username" v-model="loginForm.username" placeholder="请输入账号" name="username" type="text"
              tabindex="1" auto-complete="on" prefix-icon="el-icon-user" />
          </el-form-item>
          <el-form-item prop="password" label="密码">
            <el-input :key="passwordType" ref="password" v-model="loginForm.password" :type="passwordType"
              placeholder="请输入密码" name="password" tabindex="2" auto-complete="on" prefix-icon="el-icon-lock"
              @keyup.enter.native="handleLogin">
              <i slot="suffix" class="el-input__icon el-icon-view pwd-toggle" @click="showPwd" />
            </el-input>
          </el-form-item>
          <el-form-item label="验证码">
            <div class="captcha-row">
              <el-input v-model="loginForm.captcha" placeholder="请输入右侧字符" />
              <img class="captcha-img" :src="captchaImageUrl" alt="captcha" @click="refreshCaptcha" />
            </div>
          </el-form-item>
          <el-button :loading="loading" type="primary" class="auth-primary" @click.native.prevent="handleLogin">登 录</el-button>
          <el-button class="auth-secondary" @click="too">没有账号？去注册</el-button>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script>
import { validUsername } from '@/utils/validate'

export default {
  name: 'Login',
  data() {
    const validateUsername = (rule, value, callback) => {
      if (!validUsername(value)) {
        callback(new Error('请输入正确的账号'))
      } else {
        callback()
      }
    }
    const validatePassword = (rule, value, callback) => {
      if (value.length < 6) {
        callback(new Error('密码不能少于6位'))
      } else {
        callback()
      }
    }
    return {
      loginForm: {
        username: '',
        password: '',
        captcha: ''
      },
      captchaImageUrl: '',
      captchaCode: '',
      loginRules: {
        username: [{ required: true, trigger: 'blur', validator: validateUsername }],
        password: [{ required: true, trigger: 'blur', validator: validatePassword }]
      },
      loading: false,
      passwordType: 'password',
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler: function (route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  mounted() {
    this.refreshCaptcha()
  },
  methods: {
    too() {
      this.$router.push(`/register`)
    },
    showPwd() {
      this.passwordType = this.passwordType === 'password' ? '' : 'password'
      this.$nextTick(() => {
        this.$refs.password.focus()
      })
    },
    refreshCaptcha() {
      this.captchaCode = Math.random().toString(36).substr(2, 6)
      this.captchaImageUrl = `https://dummyimage.com/120x40/2d2640/f5d0dc&text=${this.captchaCode}`
    },
    handleLogin() {
      if (this.loginForm.captcha !== this.captchaCode) {
        this.$notify.error({ title: '错误', message: '验证码错误' })
        return
      }
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true
          this.$store.dispatch('user/login', this.loginForm).then(() => {
            this.$router.push({ path: this.redirect || '/' })
            this.loading = false
          }).catch(() => {
            this.loading = false
          })
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.auth-page {
  display: flex;
  min-height: 100vh;
  width: 100%;
}

.auth-left {
  flex: 1;
  min-width: 320px;
  padding: 3rem 3.5rem;
  background: linear-gradient(160deg, #1e1b2e 0%, #352848 55%, #4a3266 100%);
  color: #faf7f2;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.auth-left::after {
  content: '';
  position: absolute;
  width: 360px;
  height: 360px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255, 143, 171, 0.28) 0%, transparent 70%);
  top: -80px;
  right: -60px;
  pointer-events: none;
}

.auth-brand {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2.5rem;
  position: relative;
  z-index: 1;
}

.auth-brand h1 {
  margin: 0 0 0.35rem;
  font-size: 1.65rem;
  font-weight: 800;
}

.auth-brand p {
  margin: 0;
  opacity: 0.72;
  font-size: 0.95rem;
}

.mark {
  width: 3rem;
  height: 3rem;
  border-radius: 14px;
  background: linear-gradient(145deg, #ff8fab, #c084fc);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.35rem;
  font-weight: 800;
  color: #1e1b2e;
  flex-shrink: 0;
}

.auth-bullets {
  margin: 0;
  padding-left: 1.2rem;
  line-height: 2;
  opacity: 0.85;
  font-size: 0.95rem;
  position: relative;
  z-index: 1;
}

.auth-right {
  flex: 1;
  min-width: 320px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background: #f6f3ee;
}

.auth-card {
  width: 100%;
  max-width: 420px;
  background: #fffef9;
  border-radius: 20px;
  padding: 2.25rem 2rem;
  box-shadow: 0 20px 50px rgba(30, 27, 46, 0.1);
  border: 1px solid rgba(42, 38, 53, 0.06);
}

.auth-title {
  margin: 0 0 0.35rem;
  font-size: 1.5rem;
  color: #2a2635;
  font-weight: 800;
}

.auth-sub {
  margin: 0 0 1.5rem;
  font-size: 0.875rem;
  color: rgba(42, 38, 53, 0.55);
}

.auth-form ::v-deep .el-form-item__label {
  color: #2a2635;
  font-weight: 600;
  padding-bottom: 4px;
}

.captcha-row {
  display: flex;
  gap: 10px;
  align-items: center;
}

.captcha-row .el-input {
  flex: 1;
}

.captcha-img {
  height: 40px;
  border-radius: 8px;
  cursor: pointer;
  border: 1px solid rgba(42, 38, 53, 0.1);
}

.auth-primary {
  width: 100%;
  margin-top: 0.5rem;
  border-radius: 999px;
  padding: 12px;
  background: linear-gradient(135deg, #2d2640, #4a3266) !important;
  border: none !important;
}

.auth-secondary {
  width: 100%;
  margin-top: 12px;
  border-radius: 999px;
  border: 1px solid rgba(192, 132, 252, 0.45) !important;
  color: #6b21a8 !important;
  background: transparent !important;
}

.pwd-toggle {
  cursor: pointer;
}

@media (max-width: 900px) {
  .auth-page {
    flex-direction: column;
  }
  .auth-left {
    min-height: 220px;
    padding: 2rem;
  }
}
</style>
