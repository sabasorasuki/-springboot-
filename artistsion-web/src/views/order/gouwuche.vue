<template>
  <div>
    <!-- 搜索栏 -->
    <el-card id="search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.name" placeholder="画稿名字" clearable />
          <el-button type="primary" round icon="el-icon-search" @click="getList">查询</el-button>
        </el-col>
        <!-- <el-col :span="4" align="right">
                    <el-button @click="openEditUI(null)" type="primary" circle icon="el-icon-plus"></el-button>
                </el-col> -->
      </el-row>
    </el-card>
    <!-- 结果列表 -->
    <el-card>
      <el-table :data="List" stripe style="width: 100%">

        <el-table-column prop="id" label="ID" width="180" />
        <el-table-column prop="name" label="画稿名字" width="180" />
        <el-table-column prop="price" label="价格" width="180" />
        <el-table-column prop="username" label="姓名" width="180" />
        <el-table-column prop="phone" label="手机号" width="180" />
        <el-table-column prop="address" label="邮箱地址" width="180" />
        <el-table-column prop="status" label="状态" width="180" />
        <el-table-column label="操作" width="280">
          <template slot-scope="scope">
            <el-button type="primary" icon="el-icon-edit" @click="openEditUI(scope.row.id)">下单</el-button>
            <el-button type="danger" icon="el-icon-delete" @click="deleteUser(scope.row)">删除购物车</el-button>
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
        <el-form-item label="画稿名字" :label-width="formLabelWidth">
          <el-input v-model="Form.name" readonly autocomplete="off" />
        </el-form-item>
        <el-form-item label="价格" :label-width="formLabelWidth">
          <el-input v-model="Form.price" readonly autocomplete="off" />
        </el-form-item>
        <el-form-item label="姓名" :label-width="formLabelWidth">
          <el-input v-model="Form.username" autocomplete="off" />
        </el-form-item>
        <el-form-item label="手机号" :label-width="formLabelWidth">
          <el-input v-model="Form.phone" autocomplete="off" />
        </el-form-item>
        <el-form-item label="邮箱地址" :label-width="formLabelWidth">
          <el-input v-model="Form.address" autocomplete="off" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="saveOrUpdate">支付</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import api from '@/api/order.js'
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'

export default {
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
  created() {
    // this.getList();
    this.getInfo(this.token)
  },
  methods: {
    handleAvatarSuccess(res, file) {
      console.log(res, 'oss1')
      this.Form.photo = `http://localhost:9999/oss/file/download?name=${res.data}`
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
          console.log(this.Form.userids, 'this.fthis.Form.useridsorm')
          // 再提交请求给后台

          this.Form.order_number = '1132221232312'
          this.Form.order_detail = this.Form.name
          this.Form.goods_info = '支付宝支付'
          this.Form.order_price = this.Form.price
          this.Form.orderids = this.Form.id
          this.Form.status = '已付款'

          api.alipay(this.Form).then(resp => {
            console.log(resp.data.rows, 'respresprespresp')
            // 添加之前先删除一下，如果单页面，页面不刷新，添加进去的内容会一直保留在页面中，二次调用form表单会出错
            const divForm = document.getElementsByTagName('div')
            if (divForm.length) {
              document.body.removeChild(divForm[0])
            }
            const div = document.createElement('div')
            div.innerHTML = resp.data.rows // data就是接口返回的form 表单字符串
            document.body.appendChild(div)
            // document.forms[0].setAttribute("target", "_blank"); // 新开窗口跳转
            document.forms[0].submit()
          })

          // this.Form.price = this.Form.price - this.Form.zhekou
          api.saveOrUpdate(this.Form).then(response => {
            // 成功提示
            // this.$message({
            //     message: "付款成功",
            //     type: 'success'
            // });
            // //关闭对话框
            // this.dialogFormVisible = false;
            // //刷新表格
            // this.getList();
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
        this.title = '下单'
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
      this.searchModel.status = '购物车'
      api.getList(this.searchModel).then(response => {
        this.List = response.data.rows
        this.total = response.data.total
      })
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
  },
  computed: {
    ...mapGetters([
      'token'
    ])
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
