<template>
  <div class="center-follows-page">
    <h1 class="page-title">关注</h1>
    <el-tabs v-model="activeTab" type="card">
      <el-tab-pane label="已关注" name="following">
        <el-empty description="暂无关注" :image-size="120" />
      </el-tab-pane>
      <el-tab-pane label="好友" name="friends">
        <el-empty description="暂无好友" :image-size="120" />
      </el-tab-pane>
      <el-tab-pane label="粉丝" name="followers">
        <el-empty description="暂无粉丝" :image-size="120" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
export default {
  name: 'CenterFollows',
  data() {
    return {
      activeTab: 'following'
    }
  }
}
</script>

<style lang="scss" scoped>
.center-follows-page {
  padding: 20px 0;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px;
}
</style>
