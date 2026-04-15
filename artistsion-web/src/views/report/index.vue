<template>
  <div class="report-center-page">
    <el-card class="page-hero" shadow="never">
      <div class="hero-copy">
        <p class="page-kicker">Admin Moderation</p>
        <h1>举报与审核中心</h1>
        <p>
          当前中心统一承接作品、社区内容、反馈与订单相关举报。管理员可在同一处查看详情、筛选状态，并完成处理或驳回闭环。
        </p>
      </div>
      <div class="hero-actions">
        <el-tag size="medium" effect="dark" type="warning">待处理优先</el-tag>
        <el-tag size="medium" effect="plain">同一产品视觉体系</el-tag>
      </div>
    </el-card>

    <el-card class="page-filters">
      <div class="filters-grid">
        <el-select v-model="searchModel.status" placeholder="处理状态" clearable>
          <el-option v-for="item in statusOptions" :key="item" :label="item" :value="item" />
        </el-select>
        <el-select v-model="searchModel.targetType" placeholder="对象类型" clearable>
          <el-option v-for="item in targetTypeOptions" :key="item" :label="item" :value="item" />
        </el-select>
        <el-select v-model="searchModel.reason" placeholder="举报原因" clearable>
          <el-option v-for="item in reasonOptions" :key="item" :label="item" :value="item" />
        </el-select>
        <el-input v-model="searchModel.keyword" clearable placeholder="搜索对象标题、详情、举报人或处理备注" />
        <el-button type="primary" round icon="el-icon-search" @click="handleSearch">查询</el-button>
        <el-button round @click="resetFilters">重置</el-button>
      </div>
    </el-card>

    <div class="summary-strip">
      <el-card shadow="hover" class="summary-card">
        <div class="summary-label">当前列表总数</div>
        <div class="summary-value">{{ total }}</div>
      </el-card>
      <el-card shadow="hover" class="summary-card">
        <div class="summary-label">当前页待处理</div>
        <div class="summary-value">{{ pendingCount }}</div>
      </el-card>
      <el-card shadow="hover" class="summary-card">
        <div class="summary-label">当前页已处理/驳回</div>
        <div class="summary-value">{{ resolvedCount }}</div>
      </el-card>
    </div>

    <el-card class="page-table">
      <el-table v-loading="loading" :data="list" stripe empty-text="暂无举报记录">
        <el-table-column prop="id" label="举报ID" width="92" />
        <el-table-column label="状态" width="110">
          <template slot-scope="scope">
            <el-tag size="mini" :type="statusTagType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="对象类型" width="120">
          <template slot-scope="scope">
            <el-tag size="mini" effect="plain" :type="targetTagType(scope.row.targetType)">{{ scope.row.targetType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="举报对象" min-width="220">
          <template slot-scope="scope">
            <div class="target-summary">
              <div class="target-summary__title" :title="scope.row.targetTitle">{{ scope.row.targetTitle }}</div>
              <div class="target-summary__meta">对象 ID #{{ scope.row.targetId }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="reason" label="举报原因" width="140" show-overflow-tooltip />
        <el-table-column prop="reporterUsername" label="举报人" width="110" />
        <el-table-column prop="createdAt" label="创建时间" width="170" />
        <el-table-column prop="handledAt" label="处理时间" width="170" />
        <el-table-column label="操作" width="280" fixed="right">
          <template slot-scope="scope">
            <el-button type="text" @click="openDetail(scope.row)">查看详情</el-button>
            <el-button type="text" @click="openTarget(scope.row)">{{ targetAction(scope.row).label }}</el-button>
            <el-button type="text" @click="openHandle(scope.row)">
              {{ scope.row.status === '待处理' ? '处理举报' : '更新处理' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-pagination
      :current-page="searchModel.pageNo"
      :page-sizes="[10, 20, 50]"
      :page-size="searchModel.pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />

    <el-drawer
      :visible.sync="detailVisible"
      :with-header="false"
      size="440px"
      custom-class="report-detail-drawer"
    >
      <div v-if="detailRecord" class="detail-panel">
        <div class="detail-header">
          <p class="page-kicker">Report Detail</p>
          <h2>举报详情</h2>
          <p>查看对象信息、举报内容与当前处理状态。</p>
        </div>
        <div class="detail-grid">
          <div class="detail-item">
            <span>举报状态</span>
            <strong>{{ detailRecord.status }}</strong>
          </div>
          <div class="detail-item">
            <span>对象类型</span>
            <strong>{{ detailRecord.targetType }}</strong>
          </div>
          <div class="detail-item detail-item--full">
            <span>举报对象</span>
            <strong>{{ detailRecord.targetTitle }}</strong>
          </div>
          <div class="detail-item">
            <span>举报人</span>
            <strong>{{ detailRecord.reporterUsername }}</strong>
          </div>
          <div class="detail-item">
            <span>举报原因</span>
            <strong>{{ detailRecord.reason }}</strong>
          </div>
          <div class="detail-item detail-item--full">
            <span>举报详情</span>
            <p>{{ detailRecord.detail || '举报人未补充额外说明' }}</p>
          </div>
          <div class="detail-item">
            <span>创建时间</span>
            <strong>{{ detailRecord.createdAt || '未记录' }}</strong>
          </div>
          <div class="detail-item">
            <span>处理时间</span>
            <strong>{{ detailRecord.handledAt || '尚未处理' }}</strong>
          </div>
          <div class="detail-item detail-item--full">
            <span>处理备注</span>
            <p>{{ detailRecord.handlerResult || '尚未填写处理备注' }}</p>
          </div>
          <div class="detail-item">
            <span>处理人</span>
            <strong>{{ detailRecord.handlerUsername || '尚未分配' }}</strong>
          </div>
          <div class="detail-item detail-item--full">
            <span>对象定位</span>
            <div class="detail-actions">
              <el-button
                v-if="targetAction(detailRecord).canOpen"
                type="primary"
                round
                @click="openTarget(detailRecord)"
              >{{ targetAction(detailRecord).label }}</el-button>
              <el-alert
                v-else
                :closable="false"
                type="info"
                :title="targetAction(detailRecord).note"
              />
            </div>
          </div>
        </div>
      </div>
    </el-drawer>

    <el-dialog
      :visible.sync="handleVisible"
      width="520px"
      title="处理举报"
      :close-on-click-modal="false"
    >
      <el-form :model="handleForm" label-position="top">
        <el-form-item label="处理状态">
          <el-radio-group v-model="handleForm.status">
            <el-radio-button label="已处理" />
            <el-radio-button label="已驳回" />
          </el-radio-group>
        </el-form-item>
        <el-form-item label="处理备注">
          <el-input
            v-model="handleForm.handlerResult"
            type="textarea"
            :rows="5"
            placeholder="请记录处理依据、执行动作或驳回说明"
          />
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button round @click="handleVisible = false">取消</el-button>
        <el-button type="primary" round :loading="submitting" @click="submitHandle">保存处理结果</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import reportApi from '@/api/report'
import {
  REPORT_REASON_OPTIONS,
  REPORT_TARGET_TYPE_OPTIONS,
  resolveReportTargetNavigation
} from '@/utils/reporting'

const defaultSearchModel = () => ({
  pageNo: 1,
  pageSize: 10,
  status: '',
  targetType: '',
  reason: '',
  keyword: ''
})

export default {
  name: 'AdminReportCenter',
  data() {
    return {
      loading: false,
      submitting: false,
      total: 0,
      list: [],
      detailVisible: false,
      handleVisible: false,
      detailRecord: null,
      currentRecord: null,
      searchModel: defaultSearchModel(),
      handleForm: {
        id: null,
        status: '已处理',
        handlerResult: ''
      },
      statusOptions: ['待处理', '已处理', '已驳回'],
      targetTypeOptions: REPORT_TARGET_TYPE_OPTIONS,
      reasonOptions: REPORT_REASON_OPTIONS
    }
  },
  computed: {
    pendingCount() {
      return this.list.filter(item => item.status === '待处理').length
    },
    resolvedCount() {
      return this.list.filter(item => item.status === '已处理' || item.status === '已驳回').length
    }
  },
  created() {
    this.getList()
  },
  methods: {
    statusTagType(status) {
      if (status === '已处理') {
        return 'success'
      }
      if (status === '已驳回') {
        return 'info'
      }
      return 'warning'
    },
    targetTagType(targetType) {
      if (targetType === '作品') {
        return 'danger'
      }
      if (targetType === '社区内容') {
        return 'info'
      }
      if (targetType === '反馈') {
        return 'warning'
      }
      return 'success'
    },
    targetAction(record) {
      if (!record) {
        return {
          canOpen: false,
          label: '查看原对象',
          note: '当前举报记录尚未加载，暂时无法定位原对象。'
        }
      }
      const target = resolveReportTargetNavigation(record.targetType, record.targetId)
      return {
        label: target.label || '查看原对象',
        canOpen: !!target.canOpen,
        path: target.path,
        query: target.query,
        note: target.note || '当前对象暂不支持直接跳转，请根据对象标题手动定位。'
      }
    },
    openTarget(record) {
      const target = this.targetAction(record)
      if (!target.canOpen) {
        this.$message.info(target.note)
        return
      }
      const resolved = this.$router.resolve({
        path: target.path,
        query: target.query || {}
      })
      window.open(resolved.href, '_blank')
    },
    handleSearch() {
      this.searchModel.pageNo = 1
      this.getList()
    },
    resetFilters() {
      this.searchModel = defaultSearchModel()
      this.getList()
    },
    handleSizeChange(pageSize) {
      this.searchModel.pageSize = pageSize
      this.getList()
    },
    handleCurrentChange(pageNo) {
      this.searchModel.pageNo = pageNo
      this.getList()
    },
    async getList() {
      this.loading = true
      try {
        const response = await reportApi.getList(this.searchModel)
        this.list = response.data.rows || []
        this.total = response.data.total || 0
      } finally {
        this.loading = false
      }
    },
    async openDetail(row) {
      const response = await reportApi.getById(row.id)
      this.detailRecord = response.data
      this.detailVisible = true
    },
    openHandle(row) {
      this.currentRecord = row
      this.handleForm = {
        id: row.id,
        status: row.status === '已驳回' ? '已驳回' : '已处理',
        handlerResult: row.handlerResult || ''
      }
      this.handleVisible = true
    },
    async submitHandle() {
      if (!this.handleForm.handlerResult.trim()) {
        this.$message.warning('请填写处理备注')
        return
      }
      this.submitting = true
      try {
        const response = await reportApi.handle(this.handleForm)
        this.$message.success(response.message || '处理结果已更新')
        this.handleVisible = false
        await this.getList()
        if (this.detailVisible && this.currentRecord) {
          await this.openDetail(this.currentRecord)
        }
      } finally {
        this.submitting = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.report-center-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.page-hero {
  border: none;
  border-radius: 24px;
  background:
    radial-gradient(circle at top right, rgba(255, 209, 143, 0.28), transparent 34%),
    linear-gradient(135deg, #102542 0%, #1d436d 42%, #2f5a86 100%);
  color: #fff;
}

.hero-copy {
  max-width: 760px;
}

.hero-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 18px;
}

.page-kicker {
  margin: 0 0 8px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.72);
}

.page-hero h1 {
  margin: 0;
  font-size: 30px;
}

.page-hero p {
  margin: 12px 0 0;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.84);
}

.page-filters,
.page-table,
.summary-card {
  border-radius: 20px;
}

.filters-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 12px;
  align-items: center;
}

.summary-strip {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.summary-card {
  border: 1px solid #e9eef6;
}

.summary-label {
  font-size: 13px;
  color: #6f7d90;
}

.summary-value {
  margin-top: 10px;
  font-size: 28px;
  font-weight: 700;
  color: #102542;
}

.target-summary__title {
  color: #102542;
  font-weight: 600;
  line-height: 1.5;
  word-break: break-word;
}

.target-summary__meta {
  margin-top: 6px;
  font-size: 12px;
  color: #7b8796;
}

.detail-panel {
  padding: 24px;
}

.detail-header h2 {
  margin: 0;
  font-size: 26px;
  color: #102542;
}

.detail-header p:last-child {
  margin-top: 10px;
  color: #5f6b7a;
  line-height: 1.7;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
  margin-top: 24px;
}

.detail-item {
  padding: 16px;
  border-radius: 18px;
  background: #f7f9fc;
  border: 1px solid #e7edf6;
}

.detail-item--full {
  grid-column: 1 / -1;
}

.detail-item span {
  display: block;
  font-size: 12px;
  color: #7b8796;
  margin-bottom: 10px;
}

.detail-item strong,
.detail-item p {
  margin: 0;
  color: #102542;
  line-height: 1.7;
  word-break: break-word;
}

.detail-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

@media (max-width: 900px) {
  .detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>
