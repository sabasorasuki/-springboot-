<template>
  <div class="admin-page">
    <el-card class="page-hero" shadow="never">
      <div class="page-hero__content">
        <div>
          <p class="page-kicker">Admin Review</p>
          <h1>作品审核</h1>
          <p>当前页用于处理全站稿件审核。未审核作品可直接执行通过或驳回，历史审核结果也会继续保留在列表中。</p>
        </div>
      </div>
    </el-card>

    <el-card id="search" class="page-search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.name" placeholder="按作品标题搜索" clearable />
          <el-button type="primary" round icon="el-icon-search" @click="getList">查询</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="page-table">
      <el-table :data="List" stripe style="width: 100%" empty-text="暂无作品审核记录">
        <el-table-column prop="id" label="ID" width="90" />
        <el-table-column prop="name" label="作品标题" min-width="160" show-overflow-tooltip />
        <el-table-column label="封面" prop="photo" width="120">
          <template slot-scope="scope">
            <el-popover placement="top-start" trigger="hover">
              <img :src="scope.row.photo" alt="" style="width: 150px;height: 150px">
              <img slot="reference" :src="scope.row.photo" style="width: 50px;height: 50px">
            </el-popover>
          </template>
        </el-table-column>
        <el-table-column prop="price" label="报价" width="100" />
        <el-table-column prop="fenlei" label="分类" width="120" />
        <el-table-column prop="type" label="上架状态" width="120" />
        <el-table-column label="审核状态" width="120">
          <template slot-scope="scope">
            <el-tag size="mini" :type="auditStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template slot-scope="scope">
            <el-button
              v-if="scope.row.status === '未审核'"
              type="primary"
              size="mini"
              @click="updateAuditStatus(scope.row, '审核成功', '通过审核')"
            >
              通过审核
            </el-button>
            <el-button
              v-if="scope.row.status === '未审核'"
              type="danger"
              size="mini"
              @click="updateAuditStatus(scope.row, '审核失败', '驳回作品')"
            >
              驳回作品
            </el-button>
            <span v-else class="table-muted">已完成审核</span>
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
import api from '@/api/huagao.js'

export default {
  name: 'AdminWorkReview',
  data() {
    return {
      total: 0,
      searchModel: {
        pageNo: 1,
        pageSize: 10
      },
      List: []
    }
  },
  created() {
    this.getList()
  },
  methods: {
    updateAuditStatus(row, status, actionLabel) {
      this.$confirm(`确认将作品《${row.name}》设为“${actionLabel}”吗？`, '审核确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        api.saveOrUpdate({ id: row.id, status: status }).then(response => {
          this.$message({
            message: response.message || `${actionLabel}成功`,
            type: 'success'
          })
          this.getList()
        })
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消本次审核操作'
        })
      })
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
  background: linear-gradient(135deg, #13293d 0%, #1f4565 60%, #295e85 100%);
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

.table-muted {
  color: #909399;
  font-size: 13px;
}
</style>
