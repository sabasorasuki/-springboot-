<template>
  <div class="admin-page">
    <!-- 搜索栏 -->
    <el-card id="search" class="page-search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.name" placeholder="轮播图姓名" clearable />
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
        <el-table-column label="#" width="80">
          <template slot-scope="scope">
            {{ (searchModel.pageNo - 1) * searchModel.pageSize + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column prop="id" label="ID" width="180" />
        <el-table-column prop="name" label="轮播图姓名" width="180" />

        <el-table-column label="轮播图">
          <template slot-scope="scope">
            <el-popover placement="top-start" title="" trigger="hover">
              <img :src="scope.row.lunbo" alt="" style="width: 150px;height: 150px">
              <img slot="reference" :src="scope.row.lunbo" style="width: 50px;height: 50px">
            </el-popover>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="180">
          <template slot-scope="scope">
            <el-button
              type="primary"
              icon="el-icon-edit"
              circle
              size="mini"
              @click="openEditUI(scope.row.id)"
            />
            <el-button
              type="danger"
              icon="el-icon-delete"
              circle
              size="mini"
              @click="deleteUser(scope.row)"
            />
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
        <el-form-item label="轮播图姓名" :label-width="formLabelWidth">
          <el-input v-model="Form.name" autocomplete="off" />
        </el-form-item>

        <el-form-item label="轮播图" :label-width="formLabelWidth">
          <el-upload
            class="avatar-uploader"
            :action="ossUploadAction('lunbo')"
            :show-file-list="false"
            :on-success="handleAvatarSuccess"
            :on-change="onBannerFileChange"
            :auto-upload="true"
          >
            <img v-if="Form.lunbo" :src="Form.lunbo" class="avatar">
            <i v-else class="el-icon-plus avatar-uploader-icon" />
          </el-upload>
          <el-button
            v-if="Form.lunbo"
            type="text"
            icon="el-icon-crop"
            style="margin-top: 6px;"
            @click="openCropperForExisting"
          >
            调整图片位置
          </el-button>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="saveOrUpdate">确 定</el-button>
      </div>
    </el-dialog>

    <!-- 裁剪对话框 -->
    <el-dialog
      :visible.sync="cropperVisible"
      title="调整轮播图位置"
      width="720px"
      append-to-body
      destroy-on-close
      @closed="onCropperClosed"
    >
      <div class="cropper-container">
        <vue-cropper
          ref="cropper"
          :img="cropperImageUrl"
          :output-size="1"
          output-type="png"
          :auto-crop="true"
          :auto-crop-width="1200"
          :auto-crop-height="400"
          :fixed="true"
          :fixed-number="[3, 1]"
          :center-box="true"
          :can-move-box="true"
          :can-scale="true"
          :full="true"
          :high="true"
          :enlarge="2"
        />
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="cropperVisible = false">取消</el-button>
        <el-button type="primary" :loading="cropperUploading" @click="handleCropConfirm">确认裁剪</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import api from '@/api/lunbo.js'
import { ossDownloadUrl, ossUploadAction } from '@/utils/oss'
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
import { VueCropper } from 'vue-cropper'
import axios from 'axios'

export default {
  components: { VueCropper },
  data() {
    return {
      title: '',
      total: 0,
      dialogFormVisible: false,
      cropperVisible: false,
      cropperImageUrl: '',
      cropperUploading: false,
      searchModel: {
        pageNo: 1,
        pageSize: 5
      },
      List: [],
      Form: {
      },
      allForm: [{}],
      formLabelWidth: '130px',
      rules: {
        title: [
          { required: true, message: '请输入名字', trigger: 'blur' },
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
    this.getList()
    // this.getInfo(this.token);
  },
  methods: {
    ossUploadAction,

    handleAvatarSuccess(res, file) {
      this.Form.lunbo = ossDownloadUrl(res.data)
      this.$forceUpdate()
    },
    onBannerFileChange(file) {
      if (!file || !file.raw) return
      this.cropperImageUrl = URL.createObjectURL(file.raw)
      this.cropperVisible = true
    },
    openCropperForExisting() {
      if (this.Form.lunbo) {
        this.cropperImageUrl = this.Form.lunbo
        this.cropperVisible = true
      }
    },
    onCropperClosed() {
      if (this.cropperImageUrl && this.cropperImageUrl.startsWith('blob:')) {
        URL.revokeObjectURL(this.cropperImageUrl)
      }
      this.cropperImageUrl = ''
    },
    handleCropConfirm() {
      this.$refs.cropper.getCropBlob(blob => {
        if (!blob) {
          this.$message.error('裁剪失败')
          return
        }
        this.cropperUploading = true
        const formData = new FormData()
        formData.append('file', blob, `lunbo_${Date.now()}.png`)
        const uploadUrl = ossUploadAction('lunbo')
        axios.post(uploadUrl, formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        }).then(res => {
          const response = res.data
          this.Form.lunbo = ossDownloadUrl(response.data)
          this.$forceUpdate()
          this.cropperVisible = false
          this.$message.success('裁剪上传成功')
        }).catch(() => {
          this.$message.error('上传失败')
        }).finally(() => {
          this.cropperUploading = false
        })
      })
    },
    deleteUser(content) {
      this.$confirm(`您确认删除名字 ${content.name} ?`, '提示', {
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
    getGuanliyuan() {
      api.getGuanliyuan().then(response => {
        this.allForm = response.data
      })
    }, getInfo(token) {
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

/* ── Cropper dialog ── */
.cropper-container {
  width: 100%;
  height: 400px;
}

</style>
