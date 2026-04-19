<template>
  <div class="center-submissions-page">
    <h1 class="page-title">我的投稿</h1>
    <el-tabs v-model="activeTab" type="card">
      <el-tab-pane label="作品" name="works">
        <el-empty description="暂无作品投稿" :image-size="120" />
      </el-tab-pane>
      <el-tab-pane label="橱窗" name="showcase">
        <el-empty description="暂无橱窗投稿" :image-size="120" />
      </el-tab-pane>
      <el-tab-pane label="企划" name="projects">
        <el-empty description="暂无企划发布" :image-size="120" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
export default {
  name: 'CenterSubmissions',
  data() {
    return {
      activeTab: 'works'
    }
  }
}
</script>

<style lang="scss" scoped>
.center-submissions-page {
  padding: 20px 0;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px;
}
</style>
