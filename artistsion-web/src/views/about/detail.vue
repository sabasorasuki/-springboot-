<template>
  <div class="page-container">
    <the-header />

    <div class="detail-wrap">
      <div class="detail-hero">
        <h1 class="detail-page-title">稿位详情</h1>
        <p class="detail-page-sub">核对例图、价格与说明，确认后再下单。</p>
      </div>

      <div class="spot-overview">
        <el-row :gutter="28">
          <el-col :xs="24" :md="12">
            <div class="info-card">
              <h2 class="card-title">
                <i class="fa fa-info-circle" /> 基本信息
              </h2>
              <el-descriptions direction="vertical" :column="2" border>
                <el-descriptions-item label="稿位名称">
                  <span class="highlight-text">{{ course.name }}</span>
                </el-descriptions-item>
                <el-descriptions-item label="状态">
                  <el-tag size="small" type="info">{{ course.type }}</el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="分类">
                  <el-tag type="success" size="small">{{ course.fenlei }}</el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="价格">
                  <div class="price-info">
                    <span class="original-price">¥{{ course.price }}</span>
                    <span class="discount">立减 ¥{{ course.zhekou }}</span>
                    <span class="final-price">¥{{ course.price - course.zhekou }}</span>
                  </div>
                </el-descriptions-item>
                <el-descriptions-item label="补充说明" :span="2">
                  <i class="fa fa-sticky-note-o" /> {{ course.fujin }}
                </el-descriptions-item>
              </el-descriptions>

              <div v-if="this.roles ==='用户角色'" class="action-buttons">
                <el-button type="primary" class="order-btn" @click="dialogVisible=true">
                  <i class="fa fa-shopping-cart" /> 加入购物车
                </el-button>
                <el-button class="favorite-btn" @click="shoucang()">
                  <i class="fa fa-heart" /> 收藏稿位
                </el-button>
              </div>
            </div>
          </el-col>

          <el-col :xs="24" :md="12">
            <div class="image-card">
              <div class="image-wrapper">
                <img :src="course.photo" :alt="course.name">
              </div>
            </div>
          </el-col>
        </el-row>
      </div>

      <div class="spot-introduction">
        <h2 class="section-title">
          <i class="fa fa-align-left" /> 稿位说明
        </h2>
        <div class="content-card" v-html="course.content" />
      </div>
    </div>

    <el-dialog
      title="确认下单信息"
      :visible.sync="dialogVisible"
      custom-class="booking-dialog"
      width="520px"
    >
      <div class="booking-summary">
        <h3>{{ course.name }}</h3>
        <div class="price-summary">
          <div class="price-item">
            <span>标价</span>
            <span class="original">¥{{ course.price }}</span>
          </div>
          <div class="price-item">
            <span>优惠</span>
            <span class="discount">-¥{{ course.zhekou }}</span>
          </div>
          <div class="price-item total">
            <span>应付</span>
            <span class="final">¥{{ course.price - course.zhekou }}</span>
          </div>
        </div>
      </div>

      <el-form :model="Form" label-position="top">
        <el-form-item label="联系人">
          <el-input v-model="Form.username" placeholder="怎么称呼您" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="Form.phone" placeholder="便于画师核对订单" />
        </el-form-item>
        <el-form-item label="邮箱地址">
          <el-input v-model="Form.address" type="textarea" :rows="2" placeholder="如邮箱、常用社交账号、截稿日等" />
        </el-form-item>
      </el-form>

      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="onSubmit()">
          <i class="fa fa-shopping-cart" /> 加入购物车
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import TheHeader from '@/views/about/the-header'
import api from '@/api/huagao.js'
import Orderapi from '@/api/order.js'
import shouCangApi from '@/api/shoucang'

import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
export default {
  name: 'Detail',
  components: { TheHeader },
  data: function() {
    return {
      dialogVisible: false,
      dialogVisible1: false,
      formLabelWidth: '80px',
      forms: {
        username: '',
        content: '',
        mediaid: ''
      },
      Form: {},
      total: 0,
      query: {
        page: 1,
        size: 6,
        id: ''
      },
      commentData: [],
      id: '',
      course: {},
      download: '',
      searchModel: {},
      form: {},
      newComment: {
        sender: '',
        content: ''
      },
      roles: ''
    }
  },
  mounted() {
    this.query.id = this.$route.query.id

    console.log(this.token)
    this.getInfo(this.token)
  },
  methods: {
    shoucang() {
      this.searchModel.wzids = this.course.id
      this.searchModel.userids = this.forms.id
      shouCangApi.getList1(this.searchModel).then(response => {
        console.log(response, 'response.data.rows.length')
        console.log(response.data.rows.length, 'response')
        if (response.data.rows.length > 0) {
          this.$message({
            type: 'info',
            message: '已在收藏夹中'
          })
        } else {
          this.Form.title = this.course.name
          this.Form.wzids = this.course.id
          this.Form.userids = this.forms.id
          this.Form.photo = this.course.photo
          this.Form.fenlei = this.course.fenlei
          this.Form.price = this.course.price - this.course.zhekou
          shouCangApi.saveOrUpdate(this.Form).then(response => {
            this.$message({
              message: response.message,
              type: 'success'
            })
            this.dialogFormVisible = false
            this.getList()
          })
        }
      })
    },
    listNew() {
      this.searchModel.id = this.query.id
      this.searchModel.pageNo = '1'
      this.searchModel.pageSize = '6'
      api.getList(this.searchModel).then(response => {
        this.course = response.data.rows[0]
      })
    },
    onSubmit() {
      this.Form.name = this.course.name
      this.Form.city = this.course.city
      this.Form.jingdian = this.course.jingdian
      this.Form.fujin = this.course.fujin
      this.Form.spids = this.course.id
      this.Form.photo = this.course.photo
      this.Form.fenlei = this.course.fenlei
      this.Form.rydate = this.course.rydate
      this.Form.shangjiaids = this.course.shangjiaids
      this.Form.price = this.course.price - this.course.zhekou
      this.Form.zhekou = this.course.zhekou
      this.Form.userids = this.forms.id
      this.Form.username = this.forms.name
      this.Form.status = '购物车'
      Orderapi.add(this.Form).then(response => {
        this.$message({
          message: '已加入购物车',
          type: 'success'
        })
        this.$router.push({ name: 'gouwuche' })
      })
    },

    getInfo(token) {
      userApi.getInfo(token).then(response => {
        this.forms = response.data.userList

        console.log(this.forms, '1212313')
        console.log(response, 'response123123')
        console.log(response.data.roles[0], 'response123123')
        this.roles = response.data.roles[0]
        this.listNew()
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

<style scoped>
.page-container {
  min-height: 100vh;
  background: #f6f3ee;
}

.detail-wrap {
  max-width: 1180px;
  margin: 0 auto;
  padding: 1.5rem 1rem 3rem;
}

.detail-hero {
  margin-bottom: 1.5rem;
}

.detail-page-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: #2a2635;
  margin: 0 0 0.35rem;
}

.detail-page-sub {
  margin: 0;
  font-size: 0.9rem;
  color: rgba(42, 38, 53, 0.55);
}

.spot-overview {
  margin-bottom: 1.75rem;
}

.info-card {
  background: #fffef9;
  border-radius: 20px;
  padding: 1.75rem;
  box-shadow: 0 8px 32px rgba(42, 38, 53, 0.06);
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.card-title {
  font-size: 1.2rem;
  color: #2a2635;
  margin-bottom: 1.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 700;
}

.highlight-text {
  font-size: 1.05rem;
  color: #2a2635;
  font-weight: 600;
}

.price-info {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.65rem;
}

.original-price {
  color: #9ca3af;
  text-decoration: line-through;
  font-size: 0.9rem;
}

.discount {
  color: #c084fc;
  font-size: 0.85rem;
}

.final-price {
  font-size: 1.25rem;
  font-weight: 800;
  background: linear-gradient(90deg, #c084fc, #ff8fab);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.action-buttons {
  margin-top: 1.75rem;
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.order-btn {
  flex: 1;
  min-width: 140px;
  padding: 12px 16px;
  border-radius: 999px;
  background: linear-gradient(135deg, #2d2640, #4a3266) !important;
  border: none !important;
}

.favorite-btn {
  flex: 1;
  min-width: 140px;
  padding: 12px 16px;
  border-radius: 999px;
  background: #fffef9 !important;
  border: 2px solid rgba(255, 143, 171, 0.65) !important;
  color: #d9468c !important;
}

.favorite-btn:hover {
  background: rgba(255, 143, 171, 0.12) !important;
}

.image-card {
  background: #fffef9;
  border-radius: 20px;
  padding: 0.85rem;
  box-shadow: 0 8px 32px rgba(42, 38, 53, 0.06);
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.image-wrapper {
  position: relative;
  padding-top: 75%;
  overflow: hidden;
  border-radius: 14px;
  background: #1e1b2e;
}

.image-wrapper img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.spot-introduction {
  background: #fffef9;
  border-radius: 20px;
  padding: 1.75rem;
  box-shadow: 0 8px 32px rgba(42, 38, 53, 0.06);
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.section-title {
  font-size: 1.2rem;
  color: #2a2635;
  margin-bottom: 1.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 700;
}

.content-card {
  background: #f6f3ee;
  border-radius: 14px;
  padding: 1.35rem;
  line-height: 1.85;
  color: #374151;
  border: 1px solid rgba(42, 38, 53, 0.06);
}

.booking-summary {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid rgba(42, 38, 53, 0.08);
}

.booking-summary h3 {
  margin: 0 0 0.75rem;
  font-size: 1.05rem;
  color: #2a2635;
}

.price-summary {
  margin-top: 0.5rem;
}

.price-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.4rem;
  font-size: 0.9rem;
  color: #6b7280;
}

.price-item.total {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px dashed rgba(42, 38, 53, 0.12);
  font-weight: 600;
  color: #2a2635;
}

.price-item .final {
  font-size: 1.15rem;
  font-weight: 800;
  background: linear-gradient(90deg, #c084fc, #ff8fab);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

@media (max-width: 768px) {
  .action-buttons {
    flex-direction: column;
  }
  .order-btn, .favorite-btn {
    width: 100%;
  }
}
</style>
