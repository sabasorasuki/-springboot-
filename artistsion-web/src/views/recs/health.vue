<template>
  <div class="admin-page rec-health-page">
    <el-card class="page-hero">
      <div class="page-hero__content">
        <div>
          <p class="page-kicker">Recommendation Health</p>
          <h1>推荐健康</h1>
          <p>查看各内容域 active 模型、推荐覆盖和日志回流状态。</p>
        </div>
        <el-button icon="el-icon-refresh" :loading="loading" @click="loadHealth">刷新</el-button>
      </div>
    </el-card>

    <div v-loading="loading" class="health-summary">
      <el-card v-for="item in models" :key="item.domain" class="health-domain">
        <div class="health-domain__head">
          <div>
            <div class="health-domain__name">{{ domainLabel(item.domain) }}</div>
            <div class="health-domain__version">{{ item.modelVersion || '-' }}</div>
          </div>
          <el-tag :type="isFallback(item) ? 'warning' : 'success'" size="small">
            {{ isFallback(item) ? 'Baseline' : 'LTR' }}
          </el-tag>
        </div>
        <div class="health-domain__metrics">
          <span>样本 {{ item.sampleCount || 0 }}</span>
          <span>正样本 {{ item.positiveSampleCount || 0 }}</span>
          <span>推荐 {{ item.recommendationRows || 0 }}</span>
          <span>Global {{ item.globalRows || 0 }}</span>
        </div>
      </el-card>
    </div>

    <el-card class="health-table-card">
      <div class="table-toolbar">
        <div>
          <div class="table-toolbar__title">模型与覆盖</div>
          <div class="table-toolbar__desc">active 模型、排序策略和候选覆盖。</div>
        </div>
      </div>
      <el-table :data="models" size="small" stripe>
        <el-table-column prop="domain" label="域" width="90">
          <template slot-scope="{ row }">{{ domainLabel(row.domain) }}</template>
        </el-table-column>
        <el-table-column prop="algorithm" label="算法" min-width="130" />
        <el-table-column prop="trainSource" label="来源" width="80" />
        <el-table-column prop="sampleCount" label="样本" width="90" />
        <el-table-column prop="positiveSampleCount" label="正样本" width="90" />
        <el-table-column prop="actorCount" label="Actor" width="90" />
        <el-table-column prop="itemCount" label="物品" width="90" />
        <el-table-column prop="recommendationActors" label="覆盖Actor" width="110" />
        <el-table-column prop="recommendationItems" label="覆盖物品" width="110" />
        <el-table-column label="策略" width="100">
          <template slot-scope="{ row }">
            <el-tag :type="isFallback(row) ? 'warning' : 'success'" size="mini">
              {{ isFallback(row) ? 'baseline' : 'ranker' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-card class="health-table-card">
      <div class="table-toolbar">
        <div>
          <div class="table-toolbar__title">日志回流</div>
          <div class="table-toolbar__desc">请求、曝光和行为日志按域统计。</div>
        </div>
      </div>
      <el-table :data="logRows" size="small" stripe>
        <el-table-column prop="domain" label="域" width="120">
          <template slot-scope="{ row }">{{ domainLabel(row.domain) }}</template>
        </el-table-column>
        <el-table-column prop="request" label="请求" />
        <el-table-column prop="impression" label="曝光" />
        <el-table-column prop="action" label="行为" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import recApi from '@/api/rec'

const DOMAIN_LABELS = {
  huagao: '橱窗',
  zuopin: '作品',
  project: '企划',
  artist: '画师'
}

export default {
  name: 'RecHealthPage',
  data() {
    return {
      loading: false,
      models: [],
      logs: []
    }
  },
  computed: {
    logRows() {
      const byDomain = {}
      this.logs.forEach(item => {
        if (!byDomain[item.domain]) {
          byDomain[item.domain] = {
            domain: item.domain,
            request: 0,
            impression: 0,
            action: 0
          }
        }
        byDomain[item.domain][item.logType] = item.rowCount || 0
      })
      return Object.keys(byDomain).sort().map(domain => byDomain[domain])
    }
  },
  created() {
    this.loadHealth()
  },
  methods: {
    async loadHealth() {
      this.loading = true
      try {
        const response = await recApi.health()
        this.models = response.data.models || []
        this.logs = response.data.logs || []
      } finally {
        this.loading = false
      }
    },
    domainLabel(domain) {
      return DOMAIN_LABELS[domain] || domain || '-'
    },
    parseMetrics(row) {
      if (!row || !row.metricsJson) return {}
      try {
        return JSON.parse(row.metricsJson)
      } catch (error) {
        return {}
      }
    },
    isFallback(row) {
      return this.parseMetrics(row).fallbackRanker === true
    }
  }
}
</script>

<style lang="scss" scoped>
.rec-health-page {
  .page-hero__content {
    align-items: center;
    justify-content: space-between;
  }
}

.health-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 14px;
  margin-bottom: 16px;
}

.health-domain__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.health-domain__name {
  font-size: 18px;
  font-weight: 700;
  color: #1f2937;
}

.health-domain__version {
  margin-top: 4px;
  max-width: 170px;
  color: #6b7280;
  font-size: 12px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.health-domain__metrics {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
  margin-top: 18px;
  color: #4b5563;
  font-size: 13px;
}

.health-table-card {
  margin-top: 16px;
}

.table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}

.table-toolbar__title {
  font-size: 18px;
  font-weight: 700;
  color: #1f2937;
}

.table-toolbar__desc {
  margin-top: 4px;
  color: #6b7280;
  font-size: 13px;
}

@media (max-width: 768px) {
  .rec-health-page .page-hero__content,
  .table-toolbar {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
