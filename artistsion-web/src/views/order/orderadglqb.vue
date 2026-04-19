<template>
  <div class="admin-page">
    <el-card class="page-hero" shadow="never">
      <p class="page-kicker">Admin Commerce</p>
      <h1>交易订单总览</h1>
      <p>当前列表展示全站交易订单，已排除购物车记录。管理员可统一查看交易状态、买家信息与沟通入口。</p>
    </el-card>

    <el-card id="search" class="page-search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.name" placeholder="按作品标题搜索订单" clearable />
          <el-button type="primary" round icon="el-icon-search" @click="getList">查询</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-alert
      v-if="focusOrderId"
      :closable="false"
      class="page-alert"
      show-icon
      type="info"
      :title="`当前已根据举报上下文定位交易订单 #${focusOrderId}`"
    />

    <el-card class="page-table">
      <el-table :data="List" stripe style="width: 100%" empty-text="暂无交易订单">
        <el-table-column prop="id" label="订单ID" width="100" />
        <el-table-column prop="name" label="作品标题" min-width="150" show-overflow-tooltip />
        <el-table-column prop="price" label="成交金额" width="100" />
        <el-table-column prop="username" label="下单用户" width="110" />
        <el-table-column prop="phone" label="联系电话" width="120" />
        <el-table-column prop="address" label="联系邮箱" min-width="180" show-overflow-tooltip />
        <el-table-column prop="xddate" label="下单日期" width="120" />
        <el-table-column label="交易状态" width="120">
          <template slot-scope="scope">
            <el-tag size="mini" :type="statusType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="评价结果" width="100">
          <template slot-scope="scope">
            <span>{{ scope.row.pingjia || '--' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template slot-scope="scope">
            <el-button size="mini" @click="enterChat(scope.row)">查看沟通记录</el-button>
            <el-button type="danger" size="mini" @click="deleteOrder(scope.row)">删除订单记录</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-pagination
      :current-page="searchModel.pageNo"
      :page-sizes="[5, 10, 20, 50]"
      :page-size="searchModel.pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
  </div>
</template>

<script>
import api from '@/api/order.js'

export default {
  name: 'AdminOrderOverview',
  data() {
    return {
      total: 0,
      searchModel: {
        pageNo: 1,
        pageSize: 10,
        id: '',
        name: '',
        status: '购物车1'
      },
      List: [],
      focusOrderId: ''
    }
  },
  watch: {
    '$route.query.focusId'() {
      this.applyFocusQuery()
      this.getList()
    }
  },
  created() {
    this.applyFocusQuery()
    this.getList()
  },
  methods: {
    applyFocusQuery() {
      const focusId = this.$route.query.focusId ? String(this.$route.query.focusId) : ''
      this.focusOrderId = focusId
      this.searchModel.id = focusId
      if (!focusId) {
        return
      }
      this.searchModel.pageNo = 1
      this.searchModel.name = ''
    },
    enterChat(order) {
      this.$router.push({ name: 'liaotian', params: { id: order.id }})
    },
    deleteOrder(order) {
      this.$confirm(`确认删除订单 #${order.id} 吗？该操作会移除当前订单记录。`, '删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        api.deleteById(order.id).then(response => {
          this.$message({
            type: 'success',
            message: response.message || '订单记录已删除'
          })
          this.getList()
        })
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消删除订单记录'
        })
      })
    },
    statusType(status) {
      if (status === '已完成' || status === '已评价') {
        return 'success'
      }
      if (status === '已付款' || status === '已发货') {
        return 'warning'
      }
      if (status === '购物车') {
        return 'info'
      }
      return ''
    },
    handleSizeChange(pageSize) {
      this.searchModel.pageSize = pageSize
      this.getList()
    },
    handleCurrentChange(pageNo) {
      this.searchModel.pageNo = pageNo
      this.getList()
    },
    getList() {
      api.getList(this.searchModel).then(response => {
        this.List = response.data.rows
        this.total = response.data.total
      })
    }
  }
}
</script>

<style scoped>
.admin-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.page-hero {
  border: none;
  border-radius: 20px;
  background: linear-gradient(135deg, #1f2937 0%, #334155 55%, #475569 100%);
  color: #fff;
}

.page-kicker {
  margin: 0 0 8px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.72);
}

.page-alert {
  border-radius: 18px;
}

.page-hero h1 {
  margin: 0;
  font-size: 28px;
}

.page-hero p {
  margin: 12px 0 0;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.82);
}

#search .el-input {
  width: 260px;
  margin-right: 10px;
}
</style>
