<template>
  <div>
    <!-- 搜索栏 -->
    <el-card id="search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.username" placeholder="姓名" clearable />
          <el-button type="primary" round icon="el-icon-search" @click="getList">查询</el-button>
        </el-col>
        <el-col :span="4" align="right">
          <el-button type="primary" circle icon="el-icon-plus" @click="openEditUI(null)" />
        </el-col>
      </el-row>
    </el-card>
    <!-- 结果列表 -->
    <el-card>
      <el-table :data="List" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="180" />
        <el-table-column prop="username" label="姓名" width="180" />
        <el-table-column prop="phone" label="手机号" width="180" />
        <el-table-column prop="content" label="留言内容" width="180" />
        <el-table-column prop="status" label="状态" width="180" />
        <el-table-column prop="result" label="回复内容" width="180" />
        <el-table-column label="操作" width="140">
          <template slot-scope="scope">
            <el-button type="text" @click="openReportDialog(scope.row)">举报反馈</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 分页组件 -->
    <el-pagination
      :current-page="searchModel.pageNo"
      :page-sizes="[5, 10, 20, 50]"
      :page-size="searchModel.pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />

    <!-- 用户信息编辑对话框 -->
    <el-dialog :title="title" :visible.sync="dialogFormVisible" @close="clearForm">
      <el-form ref="FormRef" :model="Form" :rules="rules">
        <el-form-item label="姓名" :label-width="formLabelWidth">
          <el-input v-model="Form.username" autocomplete="off" />
        </el-form-item>
        <el-form-item label="手机号" :label-width="formLabelWidth">
          <el-input v-model="Form.phone" autocomplete="off" />
        </el-form-item>
        <el-form-item label="留言内容" :label-width="formLabelWidth">
          <el-input v-model="Form.content" type="textarea" autocomplete="off" />
        </el-form-item>

      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="saveOrUpdate">确 定</el-button>
      </div>
    </el-dialog>

    <ReportDialog
      v-model="reportVisible"
      target-type="反馈"
      :target-id="currentReportItem ? currentReportItem.id : ''"
      :target-title="currentReportItem ? currentReportItem.content : ''"
    />
  </div>
</template>
<script>
import api from '@/api/liuyan.js'
import { ossDownloadUrl } from '@/utils/oss'
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
import ReportDialog from '@/components/ReportDialog'

export default {
  components: {
    ReportDialog
  },
  data() {
    return {
      title: '',
      total: 0,
      dialogFormVisible: false,
      searchModel: {
        pageNo: 1,
        pageSize: 5
      },
      List: [],
      Form: {
      },
      currentReportItem: null,
      reportVisible: false,
      forms: {},
      allForm: [{}],
      formLabelWidth: '130px',
      rules: {
        title: [
          { required: true, message: '请输入分类名字', trigger: 'blur' },
          { min: 3, max: 50, message: '长度在 3 到 50 个字符', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    ...mapGetters([
      'token'
    ])
  },
  created() {
    // this.getList();
    this.getInfo(this.token)
  },
  methods: {
    handleAvatarSuccess(res, file) {
      console.log(res, 'oss1')
      this.Form.photo = ossDownloadUrl(res.data)
      console.log(this.Form.avatar, 'oss12312')

      // 强制重新渲染
      this.$forceUpdate()
    },
    deleteUser(content) {
      this.$confirm(`您确认删除`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        api.deleteById(content.id).then(response => {
          this.$message({
            type: 'success',
            message: response.message
          })
          this.getList()
        })
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消删除'
        })
      })
    },
    saveOrUpdate() {
      // 触发表单验证
      this.$refs.FormRef.validate((valid) => {
        if (valid) {
          this.Form.status = '未回复'
          console.log(this.Form.userids, 'this.fthis.Form.useridsorm')
          // 再提交请求给后台
          api.saveOrUpdate(this.Form).then(response => {
            // 成功提示
            this.$message({
              message: response.message,
              type: 'success'
            })
            // 关闭对话框
            this.dialogFormVisible = false
            // 刷新表格
            this.getList()
          })
        } else {
          console.log('error submit!!')
          return false
        }
      })
    },
    clearForm() {
      this.Form = {

      }
      this.$refs.FormRef.clearValidate()
    },
    openEditUI(id) {
      if (id == null) {
        this.title = '新增'
      } else {
        this.title = '修改'
        api.getById(id).then(response => {
          this.Form = response.data
        })
      }
      this.dialogFormVisible = true
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
    },
    openReportDialog(item) {
      this.currentReportItem = item
      this.reportVisible = true
    },
    getGuanliyuan() {
      api.getGuanliyuan().then(response => {
        this.allForm = response.data
      })
    },
    getInfo(token) {
      userApi.getInfo(token).then(response => {
        this.forms = response.data.userList
        this.Form.userids = this.forms.id
        this.searchModel.userids = this.forms.id
        console.log(this.forms, 'this.form')
        console.log(this.Form.userids, 'this.fthis.Form.useridsorm')
        this.getList()
        console.log(response, 'response')
      })
    }
  }
}
</script>

<style>
#search .el-input {
    width: 200px;
    margin-right: 10px;
}

.el-dialog .el-input {
    width: 85%;
}

.avatar-uploader .el-upload {
  border: 1px dashed #d9d9d9 !important;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.avatar-uploader .el-upload:hover {
  border-color: #409EFF;
}

.avatar-uploader .avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 78px;
  line-height: 78px;
  text-align: center;
}

.avatar-uploader img {
  width: 178px;
  height: 178px;
  display: block;
}

</style>
