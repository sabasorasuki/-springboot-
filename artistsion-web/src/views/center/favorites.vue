<template>
  <div class="center-favorites-page">
    <h1 class="page-title">我的收藏</h1>

    <div v-if="loading" class="loading-box"><i class="el-icon-loading" /> 加载中…</div>
    <template v-else>
      <div v-if="list.length" class="fav-grid">
        <div v-for="item in list" :key="item.id" class="fav-card">
          <div class="fav-thumb-wrap" @click="goDetail(item)">
            <img v-if="item.photo" :src="item.photo" class="fav-thumb" alt="">
            <div v-else class="fav-thumb fav-thumb--empty"><i class="el-icon-picture-outline" /></div>
            <span v-if="item.price" class="price-badge">¥{{ item.price }}</span>
          </div>
          <div class="fav-info">
            <div class="fav-title">{{ item.title || '未命名' }}</div>
            <div class="fav-meta">
              <span v-if="item.fenlei" class="fav-tag">{{ item.fenlei }}</span>
            </div>
            <el-button type="text" size="mini" class="unfav-btn" @click="handleUnfav(item)">
              <i class="el-icon-star-on" /> 取消收藏
            </el-button>
          </div>
        </div>
      </div>
      <el-empty v-else description="还没有收藏内容" :image-size="120" />

      <div v-if="total > pageSize" class="pager">
        <el-pagination background layout="prev, pager, next" :total="total" :page-size="pageSize" :current-page.sync="pageNo" @current-change="fetchList" />
      </div>
    </template>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import shoucangApi from '@/api/shoucang'
import userApi from '@/api/userManage'

export default {
  name: 'CenterFavorites',
  data() {
    return {
      loading: false,
      list: [],
      total: 0,
      pageNo: 1,
      pageSize: 12,
      userId: null
    }
  },
  computed: {
    ...mapGetters(['token'])
  },
  async created() {
    const res = await userApi.getInfo(this.token)
    this.userId = res.data.userList.id
    this.fetchList()
  },
  methods: {
    async fetchList() {
      this.loading = true
      try {
        const res = await shoucangApi.getList({ userids: this.userId, pageNo: this.pageNo, pageSize: this.pageSize })
        this.list = res.data.rows || []
        this.total = res.data.total || 0
      } finally { this.loading = false }
    },
    goDetail(item) {
      // wzids 存的是对应物品的 id — 如果有 price 字段就当橱窗商品跳详情
      if (item.wzids) {
        this.$router.push('/work/' + item.wzids)
      }
    },
    async handleUnfav(item) {
      try {
        await shoucangApi.deleteById(item.id)
        this.$message.success('已取消收藏')
        this.fetchList()
      } catch {
        this.$message.error('操作失败')
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.center-favorites-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 32px 20px;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px;
}
.loading-box {
  text-align: center;
  padding: 60px 0;
  color: #999;
}
.fav-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
}
.fav-card {
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(0,0,0,0.06);
  transition: box-shadow 0.2s;
  &:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.10); }
}
.fav-thumb-wrap {
  position: relative;
  cursor: pointer;
}
.fav-thumb {
  width: 100%;
  height: 150px;
  object-fit: cover;
  display: block;
}
.fav-thumb--empty {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  i { font-size: 32px; color: #ccc; }
}
.price-badge {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0,0,0,0.6);
  color: #fff;
  font-size: 13px;
  padding: 2px 8px;
  border-radius: 4px;
}
.fav-info {
  padding: 10px 12px 12px;
}
.fav-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.fav-meta {
  margin-top: 4px;
  font-size: 12px;
  color: #999;
}
.fav-tag {
  background: #f0f0f0;
  padding: 1px 6px;
  border-radius: 3px;
}
.unfav-btn {
  margin-top: 6px;
  color: #f39c12;
}
.pager {
  margin-top: 20px;
  text-align: center;
}
</style>
