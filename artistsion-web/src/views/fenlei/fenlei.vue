<template>
  <div class="admin-page">
    <el-card class="page-hero">
      <div class="page-hero__content">
        <div>
          <p class="page-kicker">Operation Config</p>
          <h1>分类管理</h1>
          <p>固定分类统一锁定名称与 code，只开放排序和启用状态；legacy 分类继续保留，等后续历史映射完成后再统一治理。</p>
        </div>
      </div>
    </el-card>

    <el-alert
      class="page-alert"
      title="固定分类不允许改名或删除，本页仅维护排序与启用状态。"
      type="info"
      :closable="false"
      show-icon
    />

    <el-card class="page-search">
      <el-row :gutter="12">
        <el-col :xs="24" :sm="10" :md="8">
          <el-input v-model="searchModel.fenlei" clearable placeholder="搜索分类名称" @keyup.enter.native="getList" />
        </el-col>
        <el-col :xs="24" :sm="8" :md="6">
          <el-select v-model="searchModel.status" clearable placeholder="全部状态" @change="handleSearch">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-col>
        <el-col :xs="24" :sm="6" :md="10" class="toolbar-actions">
          <el-button type="primary" icon="el-icon-search" @click="handleSearch">查询</el-button>
          <el-button icon="el-icon-refresh-left" @click="resetSearch">重置</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="page-table">
      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column label="#" width="70">
          <template slot-scope="scope">
            {{ (searchModel.pageNo - 1) * searchModel.pageSize + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column prop="fenlei" label="分类名称" min-width="180" />
        <el-table-column prop="code" label="Code" min-width="180">
          <template slot-scope="scope">
            <span v-if="scope.row.code">{{ scope.row.code }}</span>
            <span v-else class="table-muted">legacy</span>
          </template>
        </el-table-column>
        <el-table-column label="分类类型" width="120">
          <template slot-scope="scope">
            <el-tag v-if="scope.row.isFixed === 1" type="success" size="small">固定分类</el-tag>
            <el-tag v-else type="info" size="small">legacy</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="排序" width="140">
          <template slot-scope="scope">
            <el-input-number v-model="scope.row.sort" :min="0" :step="10" controls-position="right" />
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template slot-scope="scope">
            <el-switch
              v-model="scope.row.status"
              :active-value="1"
              :inactive-value="0"
              active-text="启用"
              inactive-text="禁用"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template slot-scope="scope">
            <el-button type="primary" size="mini" @click="saveRow(scope.row)">保存</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-pagination
      :current-page="searchModel.pageNo"
      :page-sizes="[10, 20, 50, 100]"
      :page-size="searchModel.pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
  </div>
</template>

<script>
import api from '@/api/fenlei'

export default {
  name: 'FenleiAdminPage',
  data() {
    return {
      loading: false,
      total: 0,
      list: [],
      searchModel: {
        fenlei: '',
        status: undefined,
        pageNo: 1,
        pageSize: 10
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    async getList() {
      this.loading = true
      try {
        const response = await api.getAdminList(this.searchModel)
        this.list = response.data.rows
        this.total = response.data.total
      } finally {
        this.loading = false
      }
    },
    handleSearch() {
      this.searchModel.pageNo = 1
      this.getList()
    },
    resetSearch() {
      this.searchModel = {
        fenlei: '',
        status: undefined,
        pageNo: 1,
        pageSize: 10
      }
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
    async saveRow(row) {
      await api.update({
        id: row.id,
        sort: row.sort,
        status: row.status
      })
      this.$message.success('分类已更新')
      this.getList()
    }
  }
}
</script>

<style lang="scss" scoped>
.toolbar-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.el-select {
  width: 100%;
}

.el-input-number {
  width: 100%;
}

@media (max-width: 768px) {
  .toolbar-actions {
    margin-top: 12px;
    justify-content: flex-start;
  }
}
</style>
