<template>
  <div>
    <!-- 卡片 -->
    <el-card>
      <el-tabs tab-position="left" style="height:100%">
        <el-tab-pane label="个人资料">
          <el-form ref="form" :model="form" label-width="120px">
            <el-form-item label="账号">
              <el-input v-model="form.username" />
            </el-form-item>
            <el-form-item label="邮箱">
              <el-input v-model="form.email" />
            </el-form-item>
            <el-form-item label="手机号">
              <el-input v-model="form.phone" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitForm()">保存</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="修改密码">
          <el-form ref="form" :model="form" label-width="120px">
            <el-form-item label="新密码">
              <el-input v-model="form.newPassword" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitForm()">确定</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="更新头像">
          <el-form ref="form" :model="form" label-width="120px">
            <el-form-item label="头像">
              <el-upload
                class="avatar-uploader"
                action="http://localhost:9999/oss/file/upload?module=photo"
                :show-file-list="false"
                :on-success="handleAvatarSuccess"
              >
                <img v-if="form.avatar" :src="form.avatar" class="avatar">
                <i v-else class="el-icon-plus avatar-uploader-icon" />
              </el-upload>
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="submitForm()">确定</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>

  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'

export default {
  name: 'APP',
  data() {
    return {
      form: {}

    }
  },
  created() {
    console.log(this.token)
    this.getInfo(this.token)
  },
  methods: {
    handleAvatarSuccess(res, file) {
      this.form.avatar = `http://localhost:9999/oss/file/download?name=${res.data}`
      console.log(this.Form.avatar, 'oss12312')

      // 强制重新渲染
      this.$forceUpdate()
    },
    getInfo(token) {
      userApi.getInfo(token).then(response => {
        this.form = response.data.userList
        console.log(this.form, '123')
        console.log(response, 'response')
      })
    },
    submitForm() {
      // 再提交请求给后台
      // 判断是否是修改密码的，如果是修改密码就把新密码复制给密码发送给后端
      if (typeof this.form.newPassword !== 'undefined') {
        this.form.password = this.form.newPassword
      }
      console.log(this.form, 'this.form')
      userApi.updateMyUser(this.form).then(response => {
        // 成功提示
        this.$message({
          message: response.message,
          type: 'success'
        })
        // 刷新
        this.getInfo(this.token)
        // 因为修改头像需要重新登录才可以所以只要修改信息就会重新登录
        this.logout()
        // 判断是否是修改密码的，如果是修改密码的就调用注销方法，让用户重新登录
        // if (typeof this.form.newPassword != "undefined") {
        //     this.logout()
        // }
      })
    },
    async logout() {
      await this.$store.dispatch('user/logout')
      // 注销时删除所有tagview
      await this.$store.dispatch('tagsView/delAllViews')
      sessionStorage.removeItem('tabViews')
      this.$router.push(`/login`)
    }
  },
  computed: {
    ...mapGetters([
      'token'
    ])
  }
}
</script>
<style lang="scss" scoped>
.el-input {
  width: 70%;
}
.avatar-uploader .el-upload {
border: 1px dashed #d9d9d9 !important;
border-radius: 6px;
cursor: pointer;
position: relative;
overflow: hidden;
}

.avatar-uploader .el-upload:hover {
border-color: #409EFF;
}

.avatar-uploader .avatar-uploader-icon {
font-size: 28px;
color: #8c939d;
width: 178px;
height: 78px;
line-height: 78px;
text-align: center;
}

.avatar-uploader img {
width: 178px;
height: 178px;
display: block;
border-radius: 20px;
}

</style>
