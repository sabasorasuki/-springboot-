<template>
  <div class="auth-page">
    <div class="auth-left">
      <div class="auth-brand">
        <span class="mark">绘</span>
        <div>
          <h1>加入画师接稿</h1>
          <p>注册后即可发布稿位、接单与使用后台</p>
        </div>
      </div>
      <ul class="auth-bullets">
        <li>用户：浏览橱窗、下单与沟通</li>
        <li>画师：维护商品、处理订单</li>
        <li>同一账号体系，角色在注册时选择</li>
      </ul>
    </div>
    <div class="auth-right">
      <div class="auth-card">
        <h2 class="auth-title">注册</h2>
        <p class="auth-sub">填写以下信息完成开户</p>
        <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="auth-form" label-position="top">
          <el-form-item prop="username" label="账号">
            <el-input
              ref="username"
              v-model="loginForm.username"
              placeholder="登录账号"
              name="username"
              type="text"
              tabindex="1"
              auto-complete="on"
              prefix-icon="el-icon-user"
            />
          </el-form-item>
          <el-form-item prop="password" label="密码">
            <el-input
              :key="passwordType"
              ref="password"
              v-model="loginForm.password"
              :type="passwordType"
              placeholder="不少于 6 位"
              name="password"
              tabindex="2"
              auto-complete="on"
              prefix-icon="el-icon-lock"
              @keyup.enter.native="handleLogin"
            >
              <i slot="suffix" class="el-input__icon el-icon-view pwd-toggle" @click="showPwd" />
            </el-input>
          </el-form-item>
          <el-form-item prop="name" label="昵称 / 姓名">
            <el-input v-model="loginForm.name" placeholder="展示给对方的名称" type="text" auto-complete="on" prefix-icon="el-icon-s-custom" />
          </el-form-item>
          <el-form-item prop="role" label="角色">
            <el-select v-model="loginForm.role" placeholder="请选择" class="full-select">
              <el-option label="用户（约稿方）" value="3" />
              <el-option label="画师（接单方）" value="7" />
            </el-select>
          </el-form-item>
          <el-button :loading="loading" type="primary" class="auth-primary" @click.native.prevent="handleLogin">注 册</el-button>
          <el-button class="auth-secondary" @click="too">已有账号？去登录</el-button>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script>
import { validUsername } from '@/utils/validate'
import userApi from '@/api/userManage'

export default {
  name: 'Register',
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
    const validateRequired = (rule, value, callback) => {
      if (!value || String(value).trim() === '') {
        callback(new Error('此项不能为空'))
      } else {
        callback()
      }
    }
    return {
      loginForm: {
        username: '',
        password: '',
        name: '',
        role: ''
      },
      loginRules: {
        username: [{ required: true, trigger: 'blur', validator: validateUsername }],
        password: [{ required: true, trigger: 'blur', validator: validatePassword }],
        name: [{ required: true, trigger: 'blur', validator: validateRequired }],
        role: [{ required: true, trigger: 'change', validator: validateRequired }]
      },
      loading: false,
      passwordType: 'password',
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler: function(route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  methods: {
    too() {
      this.$router.push(`/login`)
    },
    showPwd() {
      this.passwordType = this.passwordType === 'password' ? '' : 'password'
      this.$nextTick(() => {
        this.$refs.password.focus()
      })
    },
    handleLogin() {
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true
          userApi.register(this.loginForm).then(response => {
            this.$message({ message: response.message, type: 'success' })
          }).catch(() => {}).finally(() => {
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
  background: radial-gradient(circle, rgba(192, 132, 252, 0.25) 0%, transparent 70%);
  bottom: -100px;
  left: -80px;
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

.full-select {
  width: 100%;
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
    min-height: 200px;
    padding: 2rem;
  }
}
</style>
