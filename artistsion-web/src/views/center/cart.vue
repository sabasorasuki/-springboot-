<template>
  <div class="center-cart-page">
    <h1 class="page-title">购物车</h1>
    <p class="page-desc">仅展示未支付的橱窗订单</p>

    <div v-if="loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
    <template v-else>
      <div v-if="orders.length" class="cart-list">
        <div v-for="item in orders" :key="item.id" class="cart-item">
          <img v-if="item.photo" :src="item.photo" class="cart-thumb" alt="">
          <div class="cart-info">
            <div class="cart-name">{{ item.name }}</div>
            <div class="cart-price">¥{{ item.price }}</div>
            <div class="cart-status">
              <el-tag type="warning" size="mini">{{ item.status }}</el-tag>
              <span v-if="item.xddate" class="cart-date">{{ item.xddate }}</span>
            </div>
          </div>
          <div class="cart-actions">
            <el-button type="primary" size="small" @click="goPayOrder(item)">去支付</el-button>
            <el-button type="text" size="small" @click="cancelOrder(item)">取消</el-button>
          </div>
        </div>
      </div>
      <el-empty v-else description="购物车为空" :image-size="120">
        <el-button type="primary" size="small" @click="$router.push('/showcase')">逛逛橱窗</el-button>
      </el-empty>

      <div v-if="total > pageSize" class="pager">
        <el-pagination background layout="prev, pager, next" :total="total" :page-size="pageSize" :current-page.sync="pageNo" @current-change="fetchOrders" />
      </div>
    </template>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import orderApi from '@/api/order'

export default {
  name: 'CenterCart',
  data() {
    return {
      loading: false,
      orders: [],
      total: 0,
      pageNo: 1,
      pageSize: 10
    }
  },
  computed: {
    ...mapGetters(['activeRole'])
  },
  created() {
    this.fetchOrders()
  },
  methods: {
    async fetchOrders() {
      this.loading = true
      try {
        const res = await orderApi.getMine({
          role: '用户角色',
          pageNo: this.pageNo,
          pageSize: this.pageSize
        })
        if (res.data && res.code === 20000) {
          // 只显示待支付的订单
          const rows = res.data.rows || []
          this.orders = rows.filter(r => r.status === '待支付')
          this.total = this.orders.length
        }
      } catch (e) {
        console.error('获取购物车失败', e)
      } finally {
        this.loading = false
      }
    },
    goPayOrder(item) {
      this.$router.push('/center/orders')
    },
    async cancelOrder(item) {
      try {
        await this.$confirm('确定取消该订单？', '提示', { type: 'warning' })
        await orderApi.update({ id: item.id, status: '已取消' })
        this.$message.success('已取消')
        this.fetchOrders()
      } catch {
        // 用户取消确认
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.center-cart-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 32px 20px;
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
.loading-box {
  text-align: center;
  padding: 60px 0;
  color: #999;
}
.cart-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.cart-item {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #fff;
  border-radius: 10px;
  padding: 14px 18px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.05);
}
.cart-thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  flex-shrink: 0;
}
.cart-info {
  flex: 1;
  min-width: 0;
}
.cart-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.cart-price {
  font-size: 16px;
  font-weight: 600;
  color: #e17055;
  margin-top: 4px;
}
.cart-status {
  margin-top: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.cart-date {
  font-size: 12px;
  color: #999;
}
.cart-actions {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex-shrink: 0;
}
.pager {
  margin-top: 20px;
  text-align: center;
}
</style>
