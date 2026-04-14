<template>
  <div class="dashboard-page" v-loading="loading">
    <section class="dashboard-hero">
      <div class="hero-copy">
        <p class="hero-kicker">Admin Console</p>
        <h1>管理控制台</h1>
        <p class="hero-description">
          当前首页聚合了用户、作品、订单、反馈、分类、轮播与操作日志数据，先为 admin 入口提供稳定的管理概览。
        </p>
        <p class="hero-note">管理员账号设置已迁移到右上角头像菜单，dashboard 不再承担个人资料页职责。</p>
      </div>
      <div class="hero-actions">
        <el-button type="primary" @click="go('/shangp/shangpsh')">作品审核</el-button>
        <el-button @click="go('/order/orderadglqb')">交易订单</el-button>
        <el-button @click="go('/fenxiang/fenxiangad')">社区内容</el-button>
        <el-button @click="go('/liuyan/liuyan')">反馈工单</el-button>
        <el-button @click="go('/sys/user')">用户管理</el-button>
      </div>
    </section>

    <el-alert
      :closable="false"
      class="dashboard-alert"
      show-icon
      title="当前看板使用现有列表接口聚合数据，避免重写后端菜单体系；待处理反馈暂按已拉取列表估算。"
      type="info"
    />

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
import userApi from '@/api/userManage'
import huagaoApi from '@/api/huagao'
import orderApi from '@/api/order'
import liuyanApi from '@/api/liuyan'
import fenleiApi from '@/api/fenlei'
import lunboApi from '@/api/lunbo'
import rizhiApi from '@/api/rizhi'

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

      const [
        userResult,
        workResult,
        orderResult,
        pendingWorkResult,
        feedbackResult,
        categoryResult,
        bannerResult,
        logResult
      ] = await Promise.allSettled([
        userApi.getUserList({ pageNo: 1, pageSize: 1 }),
        huagaoApi.getList({ pageNo: 1, pageSize: 1 }),
        orderApi.getList({ pageNo: 1, pageSize: 5, status: '购物车1' }),
        huagaoApi.getList({ pageNo: 1, pageSize: 5, status: '未审核' }),
        liuyanApi.getList({ pageNo: 1, pageSize: 200 }),
        fenleiApi.getList({ pageNo: 1, pageSize: 1 }),
        lunboApi.getList({ pageNo: 1, pageSize: 1 }),
        rizhiApi.getList({ pageNo: 1, pageSize: 5 })
      ])

      this.collectWarning(userResult, '用户概览')
      this.collectWarning(workResult, '作品概览')
      this.collectWarning(orderResult, '订单概览')
      this.collectWarning(pendingWorkResult, '待审核作品')
      this.collectWarning(feedbackResult, '反馈工单')
      this.collectWarning(categoryResult, '分类统计')
      this.collectWarning(bannerResult, '轮播统计')
      this.collectWarning(logResult, '操作日志')

      const feedbackRows = this.getRows(feedbackResult)
      const feedbackTotal = this.getTotal(feedbackResult, feedbackRows.length)
      const pendingFeedbackCount = feedbackRows.filter(item => item.status === '未回复').length
      const feedbackMetricValue = feedbackResult.status === 'fulfilled' ? pendingFeedbackCount : '--'
      const feedbackHelper = feedbackResult.status !== 'fulfilled'
        ? '反馈接口加载失败，请从反馈工单页重试'
        : feedbackTotal > feedbackRows.length
            ? '缺少待处理汇总接口，当前按已拉取反馈列表估算'
            : '基于现有反馈列表实时统计'

      this.metrics = [
        this.createMetric('users', '用户总数', this.getTotal(userResult), '来自用户列表接口', 'ink'),
        this.createMetric('works', '作品总数', this.getTotal(workResult), '来自全站作品列表', 'cyan'),
        this.createMetric('orders', '订单总数', this.getTotal(orderResult), '已排除购物车记录', 'amber'),
        this.createMetric('pendingWorks', '待审核作品', this.getTotal(pendingWorkResult), '可直接进入作品审核页处理', 'red'),
        this.createMetric('pendingFeedback', '待处理反馈', feedbackMetricValue, feedbackHelper, 'violet'),
        this.createMetric('categories', '分类总数', this.getTotal(categoryResult), '来自分类管理模块', 'green'),
        this.createMetric('banners', '轮播总数', this.getTotal(bannerResult), '来自轮播运营模块', 'blue')
      ]

      this.pendingWorks = this.getRows(pendingWorkResult)
      this.recentOrders = this.getRows(orderResult)
      this.recentLogs = this.getRows(logResult)
      this.loading = false
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
    collectWarning(result, label) {
      if (result.status === 'rejected') {
        this.loadWarnings.push(label)
      }
    },
    getPayload(result) {
      if (result.status !== 'fulfilled' || !result.value || !result.value.data) {
        return {}
      }
      return result.value.data
    },
    getRows(result) {
      const payload = this.getPayload(result)
      return Array.isArray(payload.rows) ? payload.rows : []
    },
    getTotal(result, fallback = '--') {
      const payload = this.getPayload(result)
      const total = Number(payload.total)
      return Number.isFinite(total) ? total : fallback
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
  border-radius: 24px;
  background:
    radial-gradient(circle at top right, rgba(255, 219, 143, 0.35), transparent 36%),
    linear-gradient(135deg, #102542 0%, #1d436d 42%, #2f5a86 100%);
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

.metric-card {
  border: none;
  border-radius: 20px;
}

.metric-card ::v-deep .el-card__body {
  padding: 20px 22px;
}

.metric-card--ink {
  background: linear-gradient(135deg, #111827 0%, #1f2937 100%);
  color: #fff;
}

.metric-card--cyan {
  background: linear-gradient(135deg, #0f766e 0%, #14b8a6 100%);
  color: #fff;
}

.metric-card--amber {
  background: linear-gradient(135deg, #92400e 0%, #f59e0b 100%);
  color: #fff;
}

.metric-card--red {
  background: linear-gradient(135deg, #9f1239 0%, #ef4444 100%);
  color: #fff;
}

.metric-card--violet {
  background: linear-gradient(135deg, #5b21b6 0%, #8b5cf6 100%);
  color: #fff;
}

.metric-card--green {
  background: linear-gradient(135deg, #166534 0%, #22c55e 100%);
  color: #fff;
}

.metric-card--blue {
  background: linear-gradient(135deg, #1d4ed8 0%, #60a5fa 100%);
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
  border-radius: 20px;
}

.panel-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
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

@media (max-width: 991px) {
  .dashboard-hero {
    flex-direction: column;
    padding: 24px;
  }

  .hero-actions {
    justify-content: flex-start;
    min-width: 0;
  }
}
</style>
