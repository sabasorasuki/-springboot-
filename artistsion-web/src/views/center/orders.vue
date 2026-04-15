<template>
  <div class="center-orders-page">
    <div class="orders-card">
      <div class="orders-header">
        <h1 class="page-title">我的订单</h1>
        <div v-if="hasArtistRole" class="role-toggle">
          <el-radio-group v-model="viewRole" size="small" @change="onRoleChange">
            <el-radio-button label="用户角色">买家视角</el-radio-button>
            <el-radio-button label="画师角色">画师视角</el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <div v-if="loading" class="loading-box">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <template v-else>
        <el-table v-if="orders.length" :data="orders" style="width: 100%">
          <el-table-column prop="name" label="画稿名称" min-width="160" show-overflow-tooltip />
          <el-table-column label="封面" width="80">
            <template slot-scope="{ row }">
              <img v-if="row.photo" :src="row.photo" class="order-thumb" alt="">
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column prop="price" label="价格" width="100">
            <template slot-scope="{ row }">
              <span v-if="row.price" class="price-text">¥{{ row.price }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template slot-scope="{ row }">
              <el-tag :type="statusTagType(row.status)" size="small">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="xddate" label="下单时间" width="160" />
          <el-table-column label="收件信息" min-width="180" show-overflow-tooltip>
            <template slot-scope="{ row }">
              {{ row.username }} {{ row.phone }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140">
            <template slot-scope="{ row }">
              <el-button type="text" @click="openReportDialog(row)">举报订单</el-button>
            </template>
          </el-table-column>
        </el-table>
        <el-empty v-else description="暂无订单" :image-size="120" />

        <div v-if="total > pageSize" class="pagination-wrap">
          <el-pagination
            background
            layout="prev, pager, next"
            :total="total"
            :page-size="pageSize"
            :current-page.sync="pageNo"
            @current-change="fetchOrders"
          />
        </div>
      </template>
    </div>

    <ReportDialog
      v-model="reportVisible"
      target-type="订单"
      :target-id="currentReportOrder ? currentReportOrder.id : ''"
      :target-title="currentReportOrder ? currentReportOrder.name : ''"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import orderApi from '@/api/order'
import ReportDialog from '@/components/ReportDialog'

export default {
  name: 'CenterOrders',
  components: {
    ReportDialog
  },
  data() {
    return {
      orders: [],
      total: 0,
      pageNo: 1,
      pageSize: 10,
      loading: false,
      viewRole: '用户角色',
      reportVisible: false,
      currentReportOrder: null
    }
  },
  computed: {
    ...mapGetters(['roles', 'activeRole']),
    hasArtistRole() {
      return this.roles && this.roles.includes('画师角色')
    }
  },
  created() {
    // 如有 activeRole 且为画师角色，默认画师视角
    if (this.activeRole === '画师角色' && this.hasArtistRole) {
      this.viewRole = '画师角色'
    }
    this.fetchOrders()
  },
  methods: {
    async fetchOrders() {
      this.loading = true
      try {
        const res = await orderApi.getMine({
          role: this.viewRole,
          pageNo: this.pageNo,
          pageSize: this.pageSize
        })
        if (res.data && res.code === 20000) {
          this.orders = res.data.rows || []
          this.total = res.data.total || 0
        }
      } catch (e) {
        console.error('获取订单失败', e)
        this.orders = []
        this.total = 0
      } finally {
        this.loading = false
      }
    },
    onRoleChange() {
      this.pageNo = 1
      this.fetchOrders()
    },
    openReportDialog(order) {
      this.currentReportOrder = order
      this.reportVisible = true
    },
    statusTagType(status) {
      const map = { '待支付': 'warning', '已支付': 'success', '已完成': 'success', '已取消': 'info', '退款中': 'danger' }
      return map[status] || ''
    }
  }
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

.orders-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.page-title {
  font-size: 22px;
  font-weight: 700;
  color: #333;
  margin: 0;
}

.loading-box {
  text-align: center;
  padding: 60px 0;
  color: #999;
}

.order-thumb {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 6px;
}

.price-text {
  color: #e17055;
  font-weight: 500;
}

.pagination-wrap {
  margin-top: 24px;
  text-align: center;
}
</style>
