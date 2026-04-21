<template>
  <div v-loading="loading" class="dashboard-page">
    <section class="dashboard-hero">
      <div class="hero-copy">
        <p class="hero-kicker">Admin Console</p>
        <h1>管理控制台</h1>
        <p class="hero-description">
          平台运营数据一览，快速进入各管理模块。
        </p>
      </div>
      <div class="hero-actions">
        <el-button type="primary" @click="go('/shangp/shangpsh')">作品审核</el-button>
        <el-button @click="go('/order/orderadglqb')">交易订单</el-button>
        <el-button @click="go('/fenxiang/fenxiangad')">社区内容</el-button>
        <el-button @click="go('/liuyan/liuyan')">反馈工单</el-button>
        <el-button @click="go('/report/center')">举报与审核</el-button>
        <el-button @click="go('/sys/user')">用户管理</el-button>
      </div>
    </section>

    <el-alert
      v-if="loadWarnings.length"
      :closable="false"
      class="dashboard-alert"
      show-icon
      :title="`部分概览加载失败：${loadWarnings.join('、')}`"
      type="warning"
    />

    <el-row :gutter="16" class="metric-grid">
      <el-col v-for="metric in metrics" :key="metric.key" :xs="24" :sm="12" :lg="6">
        <el-card :class="['metric-card', `metric-card--${metric.tone}`]" shadow="hover">
          <div class="metric-label">{{ metric.label }}</div>
          <div class="metric-value">{{ metric.value }}</div>
          <div class="metric-helper">{{ metric.helper }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="panel-grid">
      <el-col :xs="24" :lg="8">
        <el-card class="panel-card">
          <div slot="header" class="panel-header">
            <div>
              <h3>待审核作品</h3>
              <p>优先处理仍处于未审核状态的稿件。</p>
            </div>
            <el-button type="text" @click="go('/shangp/shangpsh')">进入作品审核</el-button>
          </div>
          <el-table :data="pendingWorks" stripe empty-text="当前没有待审核作品">
            <el-table-column prop="name" label="作品标题" min-width="120" show-overflow-tooltip />
            <el-table-column prop="fenlei" label="分类" width="100" />
            <el-table-column prop="price" label="报价" width="100" />
            <el-table-column label="审核状态" width="100">
              <template slot-scope="scope">
                <el-tag size="mini" :type="auditStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :xs="24" :lg="8">
        <el-card class="panel-card">
          <div slot="header" class="panel-header">
            <div>
              <h3>最近订单</h3>
              <p>当前展示全站最近创建的交易订单，已排除购物车记录。</p>
            </div>
            <el-button type="text" @click="go('/order/orderadglqb')">查看全部订单</el-button>
          </div>
          <el-table :data="recentOrders" stripe empty-text="暂无订单数据">
            <el-table-column prop="name" label="作品标题" min-width="120" show-overflow-tooltip />
            <el-table-column prop="username" label="下单用户" width="110" />
            <el-table-column label="交易状态" width="110">
              <template slot-scope="scope">
                <el-tag size="mini" :type="orderStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="xddate" label="下单日期" width="110" />
          </el-table>
        </el-card>
      </el-col>

      <el-col :xs="24" :lg="8">
        <el-card class="panel-card">
          <div slot="header" class="panel-header">
            <div>
              <h3>最近操作日志</h3>
              <p>用于快速回看近期后台动作，详细筛查仍在日志页完成。</p>
            </div>
            <el-button type="text" @click="go('/rizhi/rizhi')">进入操作日志</el-button>
          </div>
          <el-table :data="recentLogs" stripe empty-text="暂无日志数据">
            <el-table-column prop="rizhi" label="日志内容" min-width="180" show-overflow-tooltip />
            <el-table-column prop="jldate" label="记录时间" width="120" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import adminDashboardApi from '@/api/adminDashboard'

export default {
  name: 'AdminDashboard',
  data() {
    return {
      loading: false,
      metrics: [],
      loadWarnings: [],
      pendingWorks: [],
      recentOrders: [],
      recentLogs: []
    }
  },
  created() {
    this.loadDashboard()
  },
  methods: {
    async loadDashboard() {
      this.loading = true
      this.loadWarnings = []
      try {
        const response = await adminDashboardApi.getSummary()
        const payload = response.data || {}
        const metrics = payload.metrics || {}

        this.metrics = [
          this.createMetric('users', '用户总数', metrics.userTotal, '来自后台管理员汇总接口', 'slate'),
          this.createMetric('works', '作品总数', metrics.workTotal, '来自后台管理员汇总接口', 'teal'),
          this.createMetric('orders', '订单总数', metrics.orderTotal, '已排除购物车记录', 'ocean'),
          this.createMetric('pendingWorks', '待审核作品', metrics.pendingWorkTotal, '由后端直接统计未审核作品', 'indigo'),
          this.createMetric('pendingFeedback', '待处理反馈', metrics.pendingFeedbackTotal, '由后端直接统计未回复工单', 'ice'),
          this.createMetric('categories', '分类总数', metrics.categoryTotal, '来自后台管理员汇总接口', 'steel'),
          this.createMetric('banners', '轮播总数', metrics.bannerTotal, '来自后台管理员汇总接口', 'azure')
        ]

        this.pendingWorks = Array.isArray(payload.pendingWorks) ? payload.pendingWorks : []
        this.recentOrders = Array.isArray(payload.recentOrders) ? payload.recentOrders : []
        this.recentLogs = Array.isArray(payload.recentLogs) ? payload.recentLogs : []
      } catch (error) {
        this.loadWarnings = ['首页汇总接口']
        this.metrics = [
          this.createMetric('users', '用户总数', '--', '汇总接口加载失败', 'slate'),
          this.createMetric('works', '作品总数', '--', '汇总接口加载失败', 'teal'),
          this.createMetric('orders', '订单总数', '--', '汇总接口加载失败', 'ocean'),
          this.createMetric('pendingWorks', '待审核作品', '--', '汇总接口加载失败', 'indigo'),
          this.createMetric('pendingFeedback', '待处理反馈', '--', '汇总接口加载失败', 'ice'),
          this.createMetric('categories', '分类总数', '--', '汇总接口加载失败', 'steel'),
          this.createMetric('banners', '轮播总数', '--', '汇总接口加载失败', 'azure')
        ]
        this.pendingWorks = []
        this.recentOrders = []
        this.recentLogs = []
      } finally {
        this.loading = false
      }
    },
    createMetric(key, label, value, helper, tone) {
      return {
        key,
        label,
        value: typeof value === 'number' ? value : '--',
        helper,
        tone
      }
    },
    go(path) {
      this.$router.push(path)
    },
    auditStatusType(status) {
      if (status === '审核成功') {
        return 'success'
      }
      if (status === '审核失败') {
        return 'danger'
      }
      if (status === '未审核') {
        return 'warning'
      }
      return 'info'
    },
    orderStatusType(status) {
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
    }
  }
}
</script>

<style lang="scss" scoped>
.dashboard-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.dashboard-hero {
  display: flex;
  justify-content: space-between;
  gap: 24px;
  padding: 28px 32px;
  border-radius: 20px;
  background: linear-gradient(135deg, #6c5ce7 0%, #a78bfa 55%, #c4b5fd 100%);
  color: #fff;
}

.hero-copy {
  max-width: 720px;
}

.hero-kicker {
  margin: 0 0 12px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.72);
}

.hero-copy h1 {
  margin: 0;
  font-size: 32px;
  line-height: 1.15;
}

.hero-description,
.hero-note {
  margin: 14px 0 0;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.84);
}

.hero-note {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.7);
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  justify-content: flex-end;
  gap: 12px;
  min-width: 240px;
}

.hero-actions .el-button {
  margin-left: 0;
}

.dashboard-alert {
  margin-bottom: 0;
}

.metric-grid,
.panel-grid {
  margin-top: 0;
}

.panel-grid {
  display: flex;
  flex-wrap: wrap;
}

.panel-grid > .el-col {
  display: flex;
}

.metric-card {
  border: none;
  border-radius: 16px;
}

.metric-card ::v-deep .el-card__body {
  padding: 20px 22px;
}

.metric-card--slate {
  background: linear-gradient(135deg, #334155 0%, #64748b 100%);
  color: #fff;
}

.metric-card--teal {
  background: linear-gradient(135deg, #115e59 0%, #0f766e 100%);
  color: #fff;
}

.metric-card--ocean {
  background: linear-gradient(135deg, #0f3d5e 0%, #2563eb 100%);
  color: #fff;
}

.metric-card--indigo {
  background: linear-gradient(135deg, #312e81 0%, #6366f1 100%);
  color: #fff;
}

.metric-card--ice {
  background: linear-gradient(135deg, #155e75 0%, #06b6d4 100%);
  color: #fff;
}

.metric-card--steel {
  background: linear-gradient(135deg, #1e3a5f 0%, #3b82f6 100%);
  color: #fff;
}

.metric-card--azure {
  background: linear-gradient(135deg, #1d4ed8 0%, #38bdf8 100%);
  color: #fff;
}

.metric-label {
  font-size: 13px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.8);
}

.metric-value {
  margin-top: 10px;
  font-size: 34px;
  font-weight: 700;
  line-height: 1;
}

.metric-helper {
  margin-top: 12px;
  font-size: 12px;
  line-height: 1.5;
  color: rgba(255, 255, 255, 0.78);
}

.panel-card {
  width: 100%;
  height: 100%;
  border-radius: 16px;
}

.panel-card ::v-deep .el-card__header {
  padding-bottom: 14px;
}

.panel-card ::v-deep .el-card__body {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding-top: 0;
}

.panel-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  min-height: 82px;
}

.panel-header h3 {
  margin: 0;
  font-size: 18px;
}

.panel-header p {
  margin: 6px 0 0;
  font-size: 13px;
  line-height: 1.6;
  color: #6b7280;
}

.panel-card ::v-deep .el-table {
  flex: 1;
}

.panel-card ::v-deep .el-table__body-wrapper {
  min-height: 252px;
}

@media (max-width: 991px) {
  .dashboard-hero {
    flex-direction: column;
    padding: 24px;
  }

  .hero-actions {
    justify-content: flex-start;
    min-width: 0;
  }

  .panel-grid {
    display: block;
  }

  .panel-grid > .el-col {
    display: block;
  }

  .panel-header {
    min-height: 0;
  }
}
</style>
