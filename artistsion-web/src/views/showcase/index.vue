<template>
  <div class="showcase-page">
    <div class="page-header">
      <h1 class="page-title">橱窗</h1>
      <p class="page-desc">浏览画师们的可购画稿</p>
    </div>
    <el-empty description="橱窗频道即将上线，敬请期待" :image-size="160" />
  </div>
</template>

<script>
export default {
  name: 'Showcase'
}
</script>

<style lang="scss" scoped>
.showcase-page {
  padding: 20px 0;
}
.page-header {
  margin-bottom: 24px;
}
.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin: 0 0 8px;
}
.page-desc {
  font-size: 14px;
  color: #999;
  margin: 0;
}
</style>
