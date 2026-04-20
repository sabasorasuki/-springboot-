<template>
  <div class="admin-page">
    <el-card class="page-hero" shadow="never">
      <p class="page-kicker">Admin Support</p>
      <h1>反馈工单</h1>
      <p>当前页用于处理平台收到的用户反馈。管理员可统一检索提交人、跟进处理结果，并保留工单状态流转记录。</p>
    </el-card>

    <el-card id="search" class="page-search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.username" placeholder="按提交人搜索" clearable />
          <el-button type="primary" round icon="el-icon-search" @click="getList">查询</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-alert
      v-if="focusTicketId"
      :closable="false"
      class="page-alert"
      show-icon
      type="info"
      :title="`当前已根据举报上下文定位反馈工单 #${focusTicketId}`"
    />

    <el-card class="page-table">
      <el-table :data="List" stripe style="width: 100%" empty-text="暂无反馈工单">
        <el-table-column prop="id" label="工单ID" width="100" />
        <el-table-column prop="username" label="提交人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="content" label="反馈内容" min-width="200" show-overflow-tooltip />
        <el-table-column label="处理状态" width="110">
          <template slot-scope="scope">
            <el-tag size="mini" :type="statusType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="result" label="处理结果" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="180">
          <template slot-scope="scope">
            <el-button v-if="scope.row.status === '未回复'" type="primary" size="mini" @click="openEditUI(scope.row.id)">处理工单</el-button>
            <el-button type="danger" size="mini" @click="deleteTicket(scope.row)">删除记录</el-button>
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

    <el-dialog :title="title" :visible.sync="dialogFormVisible" @close="clearForm">
      <el-form ref="FormRef" :model="Form" :rules="rules">
        <el-form-item label="提交人" :label-width="formLabelWidth">
          <el-input v-model="Form.username" readonly autocomplete="off" />
        </el-form-item>
        <el-form-item label="联系电话" :label-width="formLabelWidth">
          <el-input v-model="Form.phone" readonly autocomplete="off" />
        </el-form-item>
        <el-form-item label="反馈详情" :label-width="formLabelWidth">
          <el-input v-model="Form.content" readonly type="textarea" autocomplete="off" />
        </el-form-item>
        <el-form-item label="处理结果" :label-width="formLabelWidth">
          <el-input v-model="Form.result" type="textarea" autocomplete="off" />
        </el-form-item>
        <el-form-item label="处理状态" :label-width="formLabelWidth">
          <el-select v-model="Form.status" placeholder="请选择处理状态">
            <el-option label="未回复" value="未回复" />
            <el-option label="已回复" value="已回复" />
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取消</el-button>
        <el-button type="primary" @click="saveOrUpdate">保存处理结果</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/liuyan.js'

export default {
  name: 'AdminTicketCenter',
  data() {
    return {
      title: '处理反馈工单',
      total: 0,
      dialogFormVisible: false,
      searchModel: {
        pageNo: 1,
        pageSize: 10,
        id: '',
        username: ''
      },
      List: [],
      Form: {},
      formLabelWidth: '130px',
      rules: {},
      focusTicketId: ''
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
      this.focusTicketId = focusId
      this.searchModel.id = focusId
      if (!focusId) {
        return
      }
      this.searchModel.pageNo = 1
      this.searchModel.username = ''
    },
    deleteTicket(ticket) {
      this.$confirm(`确认删除工单 #${ticket.id} 吗？`, '删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        api.deleteById(ticket.id).then(response => {
          this.$message({
            type: 'success',
            message: response.message || '工单记录已删除'
          })
          this.getList()
        })
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消删除工单记录'
        })
      })
    },
    saveOrUpdate() {
      this.$refs.FormRef.validate(valid => {
        if (!valid) {
          return false
        }
        api.saveOrUpdate(this.Form).then(response => {
          this.$message({
            message: response.message || '工单处理结果已保存',
            type: 'success'
          })
          this.dialogFormVisible = false
          this.getList()
        })
      })
    },
    clearForm() {
      this.Form = {}
      if (this.$refs.FormRef) {
        this.$refs.FormRef.clearValidate()
      }
    },
    openEditUI(id) {
      this.title = '处理反馈工单'
      api.getById(id).then(response => {
        this.Form = response.data
        this.dialogFormVisible = true
      })
    },
    statusType(status) {
      return status === '已回复' ? 'success' : 'warning'
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
/* page styles inherited from admin-page.scss */
</style>
