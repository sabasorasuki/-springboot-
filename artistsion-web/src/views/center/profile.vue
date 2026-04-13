<template>
  <div class="center-profile-page">
    <!-- 基本信息卡片 -->
    <div class="profile-card">
      <div class="profile-header">
        <el-avatar :size="80" :src="avatar" icon="el-icon-user" class="profile-avatar" />
        <div class="profile-intro">
          <h1 class="profile-name">{{ name }}</h1>
          <div class="profile-role">
            <span v-for="role in roles" :key="role" class="role-badge">{{ role }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑资料卡 -->
    <div class="edit-card">
      <h2 class="card-title">编辑资料</h2>
      <el-form ref="profileForm" :model="form" label-width="80px" class="profile-form">
        <el-form-item label="用户名">
          <el-input v-model="form.username" disabled />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="form.name" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.phone" placeholder="请输入电话" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" round @click="handleSave">保存修改</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 快捷入口卡 -->
    <div class="shortcut-card">
      <h2 class="card-title">常用功能</h2>
      <div class="shortcut-grid">
        <div class="shortcut-item" @click="$router.push('/center/orders')">
          <i class="el-icon-s-order" />
          <span>我的订单</span>
        </div>
        <div class="shortcut-item" @click="$router.push('/fabusp')">
          <i class="el-icon-edit" />
          <span>发布作品</span>
        </div>
        <div class="shortcut-item" @click="$router.push('/myfenxiang')">
          <i class="el-icon-share" />
          <span>我的分享</span>
        </div>
        <div class="shortcut-item" @click="$router.push('/liaotian')">
          <i class="el-icon-chat-dot-round" />
          <span>我的消息</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { getInfo } from '@/api/user'
import userManageApi from '@/api/userManage'

export default {
  name: 'CenterProfile',
  data() {
    return {
      form: {
        id: null,
        username: '',
        name: '',
        email: '',
        phone: '',
        address: ''
      },
      saving: false
    }
  },
  computed: {
    ...mapGetters(['avatar', 'name', 'roles', 'token'])
  },
  created() {
    this.fetchProfile()
  },
  methods: {
    async fetchProfile() {
      try {
        const res = await getInfo(this.token)
        if (res.data && res.code === 20000) {
          const u = res.data.userList
          if (u) {
            this.form.id = u.id
            this.form.username = u.username || ''
            this.form.name = u.name || ''
            this.form.email = u.email || ''
            this.form.phone = u.phone || ''
            this.form.address = u.address || ''
          }
        }
      } catch (e) {
        console.error('获取用户信息失败', e)
      }
    },
    async handleSave() {
      this.saving = true
      try {
        await userManageApi.updateMyUser(this.form)
        this.$message.success('保存成功')
        // 刷新 store
        this.$store.dispatch('user/getInfo')
      } catch (e) {
        this.$message.error('保存失败')
      } finally {
        this.saving = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.center-profile-page {
  max-width: 720px;
  margin: 0 auto;
  padding: 32px 20px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* ── 基本信息 ── */
.profile-card {
  background: #fff;
  border-radius: 16px;
  padding: 28px 32px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 20px;
}

.profile-avatar {
  flex-shrink: 0;
}

.profile-name {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin: 0 0 6px 0;
}

.profile-role {
  display: flex;
  gap: 8px;
}

.role-badge {
  font-size: 12px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 2px 10px;
  border-radius: 4px;
}

/* ── 编辑卡 ── */
.edit-card, .shortcut-card {
  background: #fff;
  border-radius: 16px;
  padding: 28px 32px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px 0;
}

.profile-form {
  max-width: 480px;
}

/* ── 快捷入口 ── */
.shortcut-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.shortcut-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 18px 0;
  border-radius: 12px;
  cursor: pointer;
  transition: background 0.2s;

  i {
    font-size: 28px;
    color: #6c5ce7;
  }

  span {
    font-size: 13px;
    color: #555;
  }

  &:hover {
    background: rgba(108, 92, 231, 0.04);
  }
}
</style>
