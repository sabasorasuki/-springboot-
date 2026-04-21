<template>
  <div class="admin-page">
    <el-card class="page-hero">
      <div class="page-hero__content">
        <div>
          <p class="page-kicker">Tag Console</p>
          <h1>标签管理</h1>
          <p>统一维护系统标签与自由标签状态，并在同一处处理标签别名，保障 normalized_name 的唯一性和后续推荐特征稳定性。</p>
        </div>
      </div>
    </el-card>

    <el-card class="page-search">
      <el-row :gutter="12">
        <el-col :xs="24" :sm="12" :md="8">
          <el-input v-model="searchModel.name" clearable placeholder="搜索标签名称" @keyup.enter.native="handleSearch" />
        </el-col>
        <el-col :xs="12" :sm="6" :md="4">
          <el-select v-model="searchModel.tagType" clearable placeholder="标签类型" @change="handleSearch">
            <el-option label="系统标签" value="system" />
            <el-option label="自由标签" value="free" />
          </el-select>
        </el-col>
        <el-col :xs="12" :sm="6" :md="4">
          <el-select v-model="searchModel.tagGroup" clearable placeholder="标签分组" @change="handleSearch">
            <el-option v-for="item in groupOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-col>
        <el-col :xs="12" :sm="6" :md="4">
          <el-select v-model="searchModel.status" clearable placeholder="状态" @change="handleSearch">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-col>
        <el-col :xs="12" :sm="18" :md="4" class="toolbar-actions">
          <el-button type="primary" icon="el-icon-search" @click="handleSearch">查询</el-button>
          <el-button icon="el-icon-refresh-left" @click="resetSearch">重置</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="page-table">
      <div class="table-toolbar">
        <div class="table-toolbar__summary table-muted">系统标签可新增和编辑，自由标签当前仅开放查看与启用/禁用。</div>
        <el-button type="primary" icon="el-icon-plus" @click="openCreateDialog">新增系统标签</el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column label="#" width="70">
          <template slot-scope="scope">
            {{ (searchModel.pageNo - 1) * searchModel.pageSize + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column prop="name" label="标签名称" min-width="180" />
        <el-table-column prop="normalizedName" label="Normalized Name" min-width="220" />
        <el-table-column label="标签类型" width="120">
          <template slot-scope="scope">
            <el-tag :type="scope.row.tagType === 'system' ? 'success' : 'info'" size="small">
              {{ scope.row.tagType === 'system' ? '系统' : '自由' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="tagGroup" label="标签分组" min-width="130">
          <template slot-scope="scope">
            <span v-if="scope.row.tagGroup">{{ scope.row.tagGroup }}</span>
            <span v-else class="table-muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="useCount" label="使用次数" width="110" />
        <el-table-column label="状态" width="120">
          <template slot-scope="scope">
            <el-switch
              v-model="scope.row.status"
              :active-value="1"
              :inactive-value="0"
              active-text="启用"
              inactive-text="禁用"
              @change="handleStatusChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template slot-scope="scope">
            <el-button
              v-if="scope.row.tagType === 'system'"
              type="primary"
              size="mini"
              @click="openEditDialog(scope.row)"
            >
              编辑
            </el-button>
            <el-button size="mini" @click="openAliasDialog(scope.row)">别名</el-button>
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

    <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="560px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="标签名称" prop="name">
          <el-input v-model="form.name" maxlength="50" show-word-limit placeholder="请输入系统标签名称" />
        </el-form-item>
        <el-form-item label="标签分组" prop="tagGroup">
          <el-select v-model="form.tagGroup" placeholder="请选择标签分组" style="width: 100%;">
            <el-option v-for="item in groupOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">保存</el-button>
      </div>
    </el-dialog>

    <tag-alias-dialog
      :visible.sync="aliasDialogVisible"
      :tag="currentAliasTag"
      @changed="handleAliasChanged"
    />
  </div>
</template>

<script>
import tagApi from '@/api/tag'
import TagAliasDialog from '@/components/admin/TagAliasDialog'

const GROUP_OPTIONS = ['风格', '人物', '构图', '情绪', '发型发色', '服装', '场景', '配色', '用途', '生产属性']

export default {
  name: 'TagAdminPage',
  components: {
    TagAliasDialog
  },
  data() {
    return {
      loading: false,
      submitting: false,
      dialogVisible: false,
      aliasDialogVisible: false,
      dialogMode: 'create',
      total: 0,
      list: [],
      currentAliasTag: null,
      groupOptions: GROUP_OPTIONS,
      searchModel: {
        name: '',
        tagType: '',
        tagGroup: '',
        status: undefined,
        pageNo: 1,
        pageSize: 10
      },
      form: {
        id: null,
        name: '',
        tagGroup: '风格',
        status: 1
      },
      rules: {
        name: [
          { required: true, message: '请输入标签名称', trigger: 'blur' },
          { min: 1, max: 50, message: '长度需在 1 到 50 个字符之间', trigger: 'blur' }
        ],
        tagGroup: [
          { required: true, message: '请选择标签分组', trigger: 'change' }
        ],
        status: [
          { required: true, message: '请选择状态', trigger: 'change' }
        ]
      }
    }
  },
  computed: {
    dialogTitle() {
      return this.dialogMode === 'create' ? '新增系统标签' : '编辑系统标签'
    }
  },
  created() {
    this.getList()
  },
  methods: {
    async getList() {
      this.loading = true
      try {
        const response = await tagApi.getList(this.searchModel)
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
        name: '',
        tagType: '',
        tagGroup: '',
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
    openCreateDialog() {
      this.dialogMode = 'create'
      this.resetForm()
      this.dialogVisible = true
    },
    openEditDialog(row) {
      this.dialogMode = 'edit'
      this.form = {
        id: row.id,
        name: row.name,
        tagGroup: row.tagGroup || '风格',
        status: row.status
      }
      this.dialogVisible = true
    },
    resetForm() {
      this.form = {
        id: null,
        name: '',
        tagGroup: '风格',
        status: 1
      }
      if (this.$refs.formRef) {
        this.$refs.formRef.clearValidate()
      }
    },
    submitForm() {
      this.$refs.formRef.validate(async(valid) => {
        if (!valid) {
          return
        }
        this.submitting = true
        try {
          if (this.dialogMode === 'create') {
            await tagApi.add(this.form)
            this.$message.success('系统标签已新增')
          } else {
            await tagApi.update(this.form)
            this.$message.success('系统标签已更新')
          }
          this.dialogVisible = false
          this.getList()
        } finally {
          this.submitting = false
        }
      })
    },
    async handleStatusChange(row) {
      const nextStatus = row.status
      const previousStatus = nextStatus === 1 ? 0 : 1
      try {
        await tagApi.update({
          id: row.id,
          status: nextStatus
        })
        this.$message.success('标签状态已更新')
      } catch (error) {
        row.status = previousStatus
      }
    },
    openAliasDialog(row) {
      this.currentAliasTag = row
      this.aliasDialogVisible = true
    },
    handleAliasChanged() {
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

.table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.table-toolbar__summary {
  flex: 1;
}

.el-select {
  width: 100%;
}

@media (max-width: 768px) {
  .toolbar-actions,
  .table-toolbar {
    justify-content: flex-start;
    flex-wrap: wrap;
  }
}
</style>
