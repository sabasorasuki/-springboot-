<template>
  <div>
    <el-form :model="loginData" label-width="80px">
      <el-form-item label="用户名">
        <el-input v-model="loginData.username" />
      </el-form-item>
      <el-form-item label="密码">
        <el-input v-model="loginData.password" type="password" />
      </el-form-item>
      <el-form-item label="验证码">
        <el-input v-model="loginData.captcha" />
        <img :src="captchaImageUrl" @click="refreshCaptcha">
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">登录</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      loginData: {
        username: '',
        password: '',
        captcha: ''
      },
      captchaImageUrl: ''
    }
  },
  mounted() {
    this.refreshCaptcha()
  },
  methods: {
    submitForm() {
      // 校验验证码是否正确
      if (this.loginData.captcha !== this.captchaCode) {
        alert('验证码错误')
        return
      }

      // 发送登录请求
      // 可以在这里调用登录接口，并将 this.loginData.username、this.loginData.password 作为参数发送到后端
    },
    refreshCaptcha() {
      // 刷新验证码
      // 可以调用后端接口获取新的验证码图片地址，并更新 this.captchaImageUrl
      // 在这个示例中，我们使用随机数作为验证码的演示
      this.captchaCode = Math.random().toString(36).substr(2, 6)
      this.captchaImageUrl = `https://dummyimage.com/100x40/000/fff&text=${this.captchaCode}`
    }
  }
}
</script>
