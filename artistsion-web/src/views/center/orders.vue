<template>
  <div class="center-orders-page">
    <div class="orders-card">
      <h1 class="page-title">我的订单</h1>
      <el-empty description="订单功能即将上线，敬请期待" :image-size="160" />
    </div>
  </div>
</template>

<script>
export default {
  name: 'CenterOrders'
}
</script>

<style lang="scss" scoped>
.center-orders-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 32px 20px;
}

.orders-card {
  background: #fff;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.page-title {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin: 0 0 24px 0;
}
</style>
