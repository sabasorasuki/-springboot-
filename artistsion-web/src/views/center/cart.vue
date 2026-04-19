<template>
  <div class="center-cart-page">
    <h1 class="page-title">购物车</h1>
    <p class="page-desc">仅展示橱窗商品</p>
    <el-empty description="购物车为空" :image-size="120" />
  </div>
</template>

<script>
export default {
  name: 'CenterCart'
}
</script>

<style lang="scss" scoped>
.center-cart-page {
  padding: 20px 0;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 4px;
}
.page-desc {
  font-size: 13px;
  color: #999;
  margin: 0 0 20px;
}
</style>
