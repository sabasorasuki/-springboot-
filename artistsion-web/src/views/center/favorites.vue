<template>
  <div class="center-favorites-page">
    <h1 class="page-title">我的收藏</h1>
    <el-tabs v-model="activeTab" type="card">
      <el-tab-pane label="作品" name="works">
        <el-empty description="暂无收藏作品" :image-size="120" />
      </el-tab-pane>
      <el-tab-pane label="橱窗" name="showcase">
        <el-empty description="暂无收藏橱窗" :image-size="120" />
      </el-tab-pane>
      <el-tab-pane label="企划" name="projects">
        <el-empty description="暂无收藏企划" :image-size="120" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
export default {
  name: 'CenterFavorites',
  data() {
    return {
      activeTab: 'works'
    }
  }
}
</script>

<style lang="scss" scoped>
.center-favorites-page {
  padding: 20px 0;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px;
}
</style>
