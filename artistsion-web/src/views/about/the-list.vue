<template>
  <main role="main">
    <div class="search-nav">
      <div class="container">
        <div class="search-head">
          <h1 class="page-heading">橱窗稿位</h1>
          <p class="page-sub">按分类筛选或搜索标题，找到心仪画风与价位。</p>
        </div>
        <div class="search-wrapper">
          <div class="category-tabs">
            <a v-on:click="listCourse()"
               :class="{'active': !searchModel.fenlei}"
               class="category-tab">
              <i class="fa fa-th-large"></i> 全部
            </a>
            <a v-for="o in level1"
               @click="listCourse(o.fenlei)"
               :key="o.fenlei"
               :class="{'active': searchModel.fenlei === o.fenlei}"
               class="category-tab">
              <i class="fa fa-tag"></i> {{o.fenlei}}
            </a>
          </div>

          <div class="search-controls">
            <el-input
              v-model="searchModel.name"
              placeholder="搜索稿位名称…"
              class="search-input"
              prefix-icon="el-icon-search">
            </el-input>
            <el-button type="primary"
                      @click="listCourse"
                      class="search-btn">
              <i class="fa fa-search"></i> 搜索
            </el-button>
            <el-button type="info"
                      @click="qiantai()"
                      class="back-btn">
              <i class="fa fa-arrow-left"></i> 回首页
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <div class="main-content">
      <div class="container">
        <div class="pagination-wrapper">
          <el-pagination
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
              :current-page="searchModel.pageNo"
              :page-sizes="[6, 12, 24, 36]"
              :page-size="searchModel.pageSize"
              layout="total, sizes, prev, pager, next, jumper"
              :total="total"
              background>
          </el-pagination>
        </div>

        <div class="spots-grid">
          <div v-for="o in courses" :key="o.id" class="spot-item">
            <the-course :course="o"></the-course>
          </div>
          <div v-show="courses.length === 0" class="no-data">
            <i class="fa fa-picture-o fa-3x"></i>
            <h3>暂无符合条件的稿位</h3>
            <p>换个关键词或分类试试</p>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script>
import TheCourse from "@/views/about/the-course";
import api from '@/api/huagao.js'
import fenleiApi from '@/api/fenlei.js'

export default {
  components: { TheCourse },
  name: 'the-list',
  data() {
    return {
      courses: [],
      level1: [],
      level2: [],
      categorys: [],
      level1Id: "",
      level2Id: "",
      total: 0,
      searchModel: {
        pageNo: 1,
        pageSize: 6,
        title: '',
        fenlei: null,
      },
    }
  },
  mounted() {
    this.listCourse();
    this.listCourselevel();
  },
  methods: {
    listCourselevel() {
      fenleiApi.getList(this.searchModel).then(response => {
        this.level1 = response.data.rows;
        console.log(this.level1);
      });
    },
    listCourse(fenlei) {
      if (fenlei === undefined) {
        this.searchModel.fenlei = null;
      } else {
        this.searchModel.fenlei = fenlei;
      }

      console.log(fenlei, "fenlei");

      this.searchModel.type = "上架";
      this.searchModel.status = "审核成功";
      api.getList(this.searchModel).then(response => {
        this.courses = response.data.rows;
        console.log(this.courses);
        this.total = response.data.total;
      });
    },
    qiantai() {
      this.$router.push('/mas')
    },
    handleSizeChange(val) {
      console.log(`每页 ${val} 条`);
      this.searchModel.pageSize = val;
      this.listCourse();
    },
    handleCurrentChange(val) {
      console.log(`当前页: ${val}`);
      this.searchModel.pageNo = val;
      this.listCourse();
    },
  }
}
</script>

<style scoped>
.search-nav {
  background: linear-gradient(135deg, #1e1b2e 0%, #352848 100%);
  padding: 1.75rem 0 2rem;
  box-shadow: 0 12px 40px rgba(30, 27, 46, 0.25);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(255, 143, 171, 0.12);
}

.search-head {
  margin-bottom: 1.25rem;
}

.page-heading {
  color: #faf7f2;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 0.35rem;
}

.page-sub {
  margin: 0;
  font-size: 0.875rem;
  color: rgba(250, 247, 242, 0.6);
}

.search-wrapper {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.category-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.65rem;
}

.category-tab {
  padding: 0.55rem 1.15rem;
  color: rgba(250, 247, 242, 0.75);
  text-decoration: none;
  border-radius: 999px;
  transition: all 0.2s ease;
  background: rgba(255, 255, 255, 0.08);
  cursor: pointer;
  font-size: 0.9rem;
  border: 1px solid transparent;
}

.category-tab:hover {
  color: #fff;
  background: rgba(255, 143, 171, 0.15);
  border-color: rgba(255, 143, 171, 0.25);
}

.category-tab.active {
  background: linear-gradient(135deg, #ff8fab, #c084fc);
  color: #1e1b2e;
  font-weight: 600;
  box-shadow: 0 6px 20px rgba(192, 132, 252, 0.35);
}

.search-controls {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  flex-wrap: wrap;
}

.search-input {
  max-width: 280px;
}

.search-input :deep(.el-input__inner) {
  border-radius: 999px;
  border: 1px solid rgba(42, 38, 53, 0.08);
  background: #fffef9;
}

.search-btn {
  border-radius: 999px;
  padding: 11px 22px;
  background: linear-gradient(135deg, #a78bfa, #c084fc) !important;
  border: none !important;
}

.back-btn {
  border-radius: 999px;
  padding: 11px 22px;
  background: rgba(255, 255, 255, 0.12) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: #faf7f2 !important;
}

.main-content {
  background: #f6f3ee;
  padding: 2.5rem 0;
  min-height: calc(100vh - 200px);
}

.pagination-wrapper {
  margin-bottom: 1.75rem;
  display: flex;
  justify-content: center;
}

.spots-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  padding: 0.25rem;
}

.spot-item {
  transition: transform 0.2s;
}

.spot-item:hover {
  transform: translateY(-4px);
}

.no-data {
  grid-column: 1 / -1;
  text-align: center;
  padding: 3.5rem 1rem;
  color: rgba(42, 38, 53, 0.5);
  background: #fffef9;
  border-radius: 20px;
  border: 1px dashed rgba(42, 38, 53, 0.12);
}

.no-data i {
  margin-bottom: 1rem;
  color: rgba(192, 132, 252, 0.5);
}

.no-data h3 {
  font-weight: 600;
  color: #2a2635;
  margin-bottom: 0.35rem;
}

.no-data p {
  margin: 0;
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .category-tabs {
    justify-content: flex-start;
  }
  .search-controls {
    width: 100%;
  }
  .search-input {
    width: 100%;
    max-width: none;
  }
  .spots-grid {
    grid-template-columns: 1fr;
  }
}
</style>
