<template>
  <main role="main" class="home-root">
    <section class="hero-section">
      <div class="hero-glow"></div>
      <div class="container hero-inner">
        <p class="hero-eyebrow">COMMISSION · 画师橱窗</p>
        <h1 class="hero-title">把灵感，落成一笔一画</h1>
        <p class="hero-subtitle">
          精选上架稿位、接稿攻略与画师动态，下单前先看例图与说明，沟通更省心。
        </p>
        <router-link to="/theList" class="explore-btn">
          <i class="fa fa-paint-brush"></i> 逛橱窗
        </router-link>
      </div>
    </section>

    <div class="main-content">
      <div class="container">
        <div class="carousel-section">
          <el-carousel :interval="5000" arrow="always" height="420px" class="custom-carousel">
            <el-carousel-item v-for="(item, index) in carouselItems" :key="index">
              <div class="carousel-image" :style="{ backgroundImage: `url(${item.lunbo})` }">
                <div class="carousel-overlay"></div>
              </div>
            </el-carousel-item>
          </el-carousel>
        </div>

        <section class="section-container">
          <h2 class="section-title">
            <span class="title-bar"></span>
            <i class="fa fa-lightbulb-o"></i> 接稿攻略
          </h2>
          <p class="section-desc">流程、排期、修改次数——先看帖再开口，效率翻倍。</p>
          <div class="row">
            <div v-for="o in news1" class="col-md-4">
              <the-coursetiezi v-bind:course="o"></the-coursetiezi>
            </div>
          </div>
        </section>

        <section class="section-container">
          <h2 class="section-title">
            <span class="title-bar accent"></span>
            <i class="fa fa-fire"></i> 热门稿位
          </h2>
          <p class="section-desc">近期咨询多、反馈好的橱窗，库存与价格以详情页为准。</p>
          <div class="row">
            <div v-for="o in news" class="col-md-4">
              <the-course v-bind:course="o"></the-course>
            </div>
          </div>
        </section>
      </div>
    </div>

    <aside class="recommendation-sidebar">
      <div class="sidebar-header">
        <i class="fa fa-star"></i> 为你推荐
      </div>
      <div class="sidebar-content">
        <div v-for="o in tuijian11" :key="o.id" class="sidebar-item">
          <the-course v-bind:course="o"></the-course>
        </div>
      </div>
    </aside>
  </main>
</template>

<script>

import TheCourse from "@/views/about/the-course";
import TheCoursetiezi from "@/views/about/the-coursetiezi";
import api from '@/api/huagao.js'
import tiezipi from '@/api/fenxiang.js'
import LunboApi from '@/api/lunbo.js'
import TuijianApi from '@/api/tuijian.js'
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
export default {
  name: 'theIndex',
  components: {TheCourse, TheCoursetiezi},
  data: function () {
    return {
      news: [],
      news1: [],
      carouselItems: [],
      searchModel: {
        pageNo: 1,
        pageSize: 6,
        title: '',
      },
      Form:{},
      Tuijian:{},
      tuijian11:[],
    }
  },
  mounted() {
    this.listNew();
    this.listNew1();
    this.listNew2();


  },

  methods: {
    gettuijian() {
      let userid = this.searchModel.userids
      TuijianApi.recommendations(userid).then(response => {
        this.Tuijian = response.data;
        console.log(this.Tuijian,"tuijiasn1")
        this.gettuijianjieguo();
      })
    },
    gettuijianjieguo() {
      this.searchModel.type = "上架";
      this.searchModel.status = "审核成功";
      this.searchModel.tuijian  = this.Tuijian
      api.getListtuijian(this.searchModel).then(response => {
        this.tuijian11 = response.data.rows;
        console.log(this.tuijian11,"this.tuijian11")
      });
    },
    getzuixin() {
      api.getzuixin(this.searchModel).then(response => {
        this.tuijian11 = response.data.rows;
      });
    },
    listNew() {
      this.searchModel.type = "上架";
      this.searchModel.status = "审核成功";
      api.getList(this.searchModel).then(response => {
        this.news = response.data.rows;
      });
    },
    listNew1() {
      tiezipi.getList(this.searchModel).then(response => {
        this.news1 = response.data.rows;
      });
    },
    listNew2() {
      LunboApi.getList(this.searchModel).then(response => {
        this.carouselItems = response.data.rows;
      });
    },
    getInfo(token) {
            userApi.getInfo(token).then(response => {
                this.forms = response.data.userList
                this.searchModel.userids = this.forms.id
                this.gettuijian();
                console.log(response, "response")
            })
        },
  },
  created() {
    console.log(this.token, "tokthistokenen");
    if (this.token === undefined || this.token === null || this.token === '') {
       this.getzuixin()
    } else {
        this.getInfo(this.token);
    }
    },
  computed: {
        ...mapGetters([
            'token'
        ])
    },
}
</script>

<style scoped>
.home-root {
  --paper: #f6f3ee;
  --ink: #2a2635;
  --accent: #c084fc;
  --accent-warm: #ff8fab;
}

.hero-section {
  position: relative;
  background: linear-gradient(145deg, #1e1b2e 0%, #352848 55%, #4a3266 100%);
  color: #faf7f2;
  padding: 4.5rem 0 4rem;
  text-align: center;
  overflow: hidden;
}

.hero-glow {
  position: absolute;
  width: 480px;
  height: 480px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255, 143, 171, 0.35) 0%, transparent 70%);
  top: -120px;
  right: -80px;
  pointer-events: none;
}

.hero-inner {
  position: relative;
  z-index: 1;
}

.hero-eyebrow {
  letter-spacing: 0.28em;
  font-size: 0.72rem;
  color: rgba(250, 247, 242, 0.55);
  margin-bottom: 1rem;
}

.hero-title {
  font-size: clamp(2rem, 4vw, 3.25rem);
  font-weight: 800;
  margin-bottom: 1rem;
  line-height: 1.2;
  background: linear-gradient(90deg, #fff, #f5d0dc 60%, #e9d5ff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 1.05rem;
  max-width: 520px;
  margin: 0 auto 2rem;
  color: rgba(250, 247, 242, 0.72);
  line-height: 1.65;
}

.explore-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.9rem 2rem;
  font-size: 1rem;
  color: #1e1b2e;
  background: linear-gradient(135deg, #ff8fab, #c084fc);
  border-radius: 999px;
  text-decoration: none;
  font-weight: 600;
  transition: transform 0.2s, box-shadow 0.2s;
  box-shadow: 0 8px 28px rgba(192, 132, 252, 0.45);
}

.explore-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 36px rgba(255, 143, 171, 0.4);
  color: #1e1b2e;
}

.main-content {
  background: var(--paper);
  padding: 2.75rem 0 3.5rem;
}

.carousel-section {
  margin-bottom: 2.5rem;
}

.custom-carousel {
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(42, 38, 53, 0.12);
  border: 1px solid rgba(42, 38, 53, 0.06);
}

.carousel-image {
  height: 100%;
  background-size: cover;
  background-position: center;
  position: relative;
}

.carousel-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(30, 27, 46, 0.55), rgba(30, 27, 46, 0.1));
}

.section-container {
  margin-bottom: 2.75rem;
  padding: 2rem 1.75rem;
  background: #fffef9;
  border-radius: 20px;
  box-shadow: 0 4px 24px rgba(42, 38, 53, 0.06);
  border: 1px solid rgba(42, 38, 53, 0.05);
}

.section-title {
  font-size: 1.45rem;
  color: var(--ink);
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.65rem;
  font-weight: 700;
}

.title-bar {
  width: 4px;
  height: 1.35em;
  border-radius: 4px;
  background: linear-gradient(180deg, #ff8fab, #c084fc);
}

.title-bar.accent {
  background: linear-gradient(180deg, #c084fc, #818cf8);
}

.section-desc {
  color: rgba(42, 38, 53, 0.55);
  font-size: 0.9rem;
  margin-bottom: 1.5rem;
  padding-left: calc(4px + 0.65rem + 1em);
}

.recommendation-sidebar {
  position: fixed;
  top: 22%;
  right: 16px;
  width: 320px;
  background: #fffef9;
  border-radius: 20px;
  box-shadow: 0 16px 48px rgba(30, 27, 46, 0.14);
  z-index: 99;
  max-height: 68vh;
  overflow-y: auto;
  border: 1px solid rgba(42, 38, 53, 0.06);
}

.sidebar-header {
  padding: 1.1rem 1.25rem;
  background: linear-gradient(135deg, #2d2640, #4a3266);
  color: #faf7f2;
  font-size: 1rem;
  font-weight: 600;
  border-radius: 20px 20px 0 0;
}

.sidebar-content {
  padding: 1rem;
}

.sidebar-item {
  margin-bottom: 1rem;
  transition: transform 0.2s;
}

.sidebar-item:hover {
  transform: translateY(-2px);
}

.recommendation-sidebar::-webkit-scrollbar {
  width: 6px;
}

.recommendation-sidebar::-webkit-scrollbar-track {
  background: rgba(42, 38, 53, 0.05);
  border-radius: 3px;
}

.recommendation-sidebar::-webkit-scrollbar-thumb {
  background: rgba(192, 132, 252, 0.45);
  border-radius: 3px;
}

@media (max-width: 1200px) {
  .recommendation-sidebar {
    display: none;
  }
}

@media (max-width: 768px) {
  .section-desc {
    padding-left: 0;
  }
}
</style>
