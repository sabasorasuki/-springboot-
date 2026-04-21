<template>
  <el-dialog
    :visible.sync="dialogVisible"
    :title="dialogTitle"
    width="720px"
    append-to-body
    @close="handleClose"
  >
    <div v-if="tag" class="alias-header">
      <el-tag size="small" type="success">{{ tag.tagType === 'system' ? '系统标签' : '自由标签' }}</el-tag>
      <span class="alias-header__name">{{ tag.name }}</span>
      <span class="table-muted">normalized: {{ tag.normalizedName }}</span>
    </div>

    <el-form ref="aliasFormRef" :model="form" :rules="rules" inline class="alias-form">
      <el-form-item prop="aliasName">
        <el-input v-model="form.aliasName" maxlength="50" show-word-limit placeholder="输入标签别名" @keyup.enter.native="handleAdd" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="submitting" @click="handleAdd">新增别名</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="aliases" stripe>
      <el-table-column label="#" width="70">
        <template slot-scope="scope">
          {{ scope.$index + 1 }}
        </template>
      </el-table-column>
      <el-table-column prop="aliasName" label="别名" min-width="180" />
      <el-table-column prop="normalizedName" label="Normalized Name" min-width="220" />
      <el-table-column prop="createdAt" label="创建时间" min-width="170" />
      <el-table-column label="操作" width="120" fixed="right">
        <template slot-scope="scope">
          <el-button type="danger" size="mini" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div slot="footer" class="dialog-footer">
      <el-button @click="dialogVisible = false">关闭</el-button>
    </div>
  </el-dialog>
</template>

<script>
import tagAliasApi from '@/api/tagAlias'

export default {
  name: 'TagAliasDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    tag: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      loading: false,
      submitting: false,
      aliases: [],
      form: {
        aliasName: ''
      },
      rules: {
        aliasName: [
          { required: true, message: '请输入别名', trigger: 'blur' },
          { min: 1, max: 50, message: '长度需在 1 到 50 个字符之间', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    dialogVisible: {
      get() {
        return this.visible
      },
      set(value) {
        this.$emit('update:visible', value)
      }
    },
    dialogTitle() {
      return this.tag ? `别名管理 · ${this.tag.name}` : '别名管理'
    }
  },
  watch: {
    visible(value) {
      if (value && this.tag && this.tag.id) {
        this.fetchAliases()
      }
    },
    tag: {
      deep: true,
      handler(value) {
        if (this.visible && value && value.id) {
          this.fetchAliases()
        }
      }
    }
  },
  methods: {
    async fetchAliases() {
      if (!this.tag || !this.tag.id) {
        this.aliases = []
        return
      }
      this.loading = true
      try {
        const response = await tagAliasApi.listByTagId(this.tag.id)
        this.aliases = response.data || []
      } finally {
        this.loading = false
      }
    },
    handleClose() {
      this.form.aliasName = ''
      this.aliases = []
      if (this.$refs.aliasFormRef) {
        this.$refs.aliasFormRef.clearValidate()
      }
    },
    handleAdd() {
      if (!this.tag || !this.tag.id) return
      this.$refs.aliasFormRef.validate(async(valid) => {
        if (!valid) {
          return
        }
        this.submitting = true
        try {
          await tagAliasApi.add({
            tagId: this.tag.id,
            aliasName: this.form.aliasName
          })
          this.$message.success('别名已新增')
          this.form.aliasName = ''
          await this.fetchAliases()
          this.$emit('changed')
        } finally {
          this.submitting = false
        }
      })
    },
    handleDelete(row) {
      this.$confirm(`确认删除别名「${row.aliasName}」吗？`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
        await tagAliasApi.deleteById(row.id)
        this.$message.success('别名已删除')
        await this.fetchAliases()
        this.$emit('changed')
      }).catch(() => {})
    }
  }
}
</script>

<style lang="scss" scoped>
.alias-header {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 18px;
}

.alias-header__name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.alias-form {
  margin-bottom: 16px;
}

.alias-form ::v-deep .el-form-item__content {
  display: flex;
}

.alias-form .el-input {
  width: 360px;
}
</style>
