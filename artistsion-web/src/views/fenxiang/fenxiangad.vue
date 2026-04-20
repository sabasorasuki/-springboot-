<template>
  <div class="admin-page">
    <el-card class="page-hero" shadow="never">
      <p class="page-kicker">Admin Community</p>
      <h1>社区内容管理</h1>
      <p>当前页统一处理前台帖子内容，管理员可按标题检索、查看发布信息，并对不合规内容执行删除操作。</p>
    </el-card>

    <el-card id="search" class="page-search">
      <el-row>
        <el-col :span="20">
          <el-input v-model="searchModel.title" placeholder="按内容标题搜索" clearable />
          <el-button type="primary" round icon="el-icon-search" @click="getList">查询</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="page-table">
      <el-table :data="List" stripe style="width: 100%" empty-text="暂无社区内容">
        <el-table-column prop="id" label="内容ID" width="100" />
        <el-table-column prop="title" label="内容标题" min-width="180" show-overflow-tooltip />
        <el-table-column label="封面" prop="photo" width="120">
          <template slot-scope="scope">
            <el-popover placement="top-start" trigger="hover">
              <img :src="scope.row.photo" alt="" style="width: 150px;height: 150px">
              <img slot="reference" :src="scope.row.photo" style="width: 50px;height: 50px">
            </el-popover>
          </template>
        </el-table-column>
        <el-table-column prop="fenlei" label="所属分类" width="110" />
        <el-table-column prop="fbdate" label="发布日期" width="120" />
        <el-table-column prop="username" label="发布用户" width="110" />
        <el-table-column prop="dznum" label="互动热度" width="100" />
        <el-table-column label="操作" width="160">
          <template slot-scope="scope">
            <el-button type="danger" size="mini" @click="deleteContent(scope.row)">删除内容</el-button>
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
import api from '@/api/fenxiang.js'

export default {
  name: 'AdminCommunityContent',
  data() {
    return {
      total: 0,
      searchModel: {
        pageNo: 1,
        pageSize: 10,
        title: ''
      },
      List: []
    }
  },
  created() {
    this.getList()
  },
  methods: {
    deleteContent(content) {
      this.$confirm(`确认删除社区内容《${content.title}》吗？`, '删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        api.deleteById(content.id).then(response => {
          this.$message({
            type: 'success',
            message: response.message || '社区内容已删除'
          })
          this.getList()
        })
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消删除内容'
        })
      })
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
