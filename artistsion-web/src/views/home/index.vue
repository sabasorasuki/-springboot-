<template>
  <div class="home-page">
    <!-- 顶部轮播推荐区 -->
    <section v-if="carouselItems.length" class="hero-carousel">
      <el-carousel height="320px" :interval="5000" arrow="hover" indicator-position="outside">
        <el-carousel-item v-for="item in carouselItems" :key="item.id">
          <div class="carousel-slide">
            <img :src="item.lunbo" class="carousel-img" alt="">
            <div class="carousel-overlay">
              <span class="carousel-label">{{ item.name }}</span>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </section>

    <section v-if="searchKeyword" class="section site-search-section">
      <div class="section-header">
        <h2 class="section-title">全站搜索：{{ searchKeyword }}</h2>
      </div>
      <div v-if="siteSearchLoading" class="loading-placeholder">
        <i class="el-icon-loading" /> 搜索中…
      </div>
      <template v-else>
        <div class="section-header sub-section-header">
          <h3 class="sub-section-title">橱窗</h3>
          <el-button type="text" class="section-link" @click="$router.push({ path: '/showcase', query: { keyword: searchKeyword } })">查看更多</el-button>
        </div>
        <div v-if="siteSearch.huagao.length" class="card-grid">
          <div
            v-for="work in siteSearch.huagao"
            :key="'search-huagao-' + work.id"
            class="work-card"
            @click="goWorkDetail(work)"
          >
            <div class="card-cover">
              <img v-if="work.photo" :src="work.photo" alt="" class="cover-img">
              <div v-else class="cover-placeholder" />
            </div>
            <div class="card-body">
              <div class="card-title">{{ work.name }}</div>
              <div class="card-meta">
                <span v-if="work.fenlei" class="card-tag">{{ work.fenlei }}</span>
                <span v-if="work.price" class="card-price">¥{{ work.price }}</span>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-else description="没有匹配橱窗" :image-size="100" />

        <div class="section-header sub-section-header">
          <h3 class="sub-section-title">作品</h3>
          <el-button type="text" class="section-link" @click="$router.push({ path: '/works', query: { keyword: searchKeyword } })">查看更多</el-button>
        </div>
        <div v-if="siteSearch.zuopin.length" class="community-grid">
          <div
            v-for="post in siteSearch.zuopin"
            :key="'search-zuopin-' + post.id"
            class="community-card"
            @click="goPostDetail(post)"
          >
            <div class="community-cover">
              <img v-if="post.photo" :src="post.photo" alt="" class="cover-img">
              <div v-else class="cover-placeholder" />
            </div>
            <div class="community-body">
              <div class="community-title">{{ post.title || post.name }}</div>
              <div class="community-meta">
                <span v-if="post.fenlei" class="card-tag">{{ post.fenlei }}</span>
                <span class="community-author">{{ post.username || '匿名用户' }}</span>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-else description="没有匹配作品" :image-size="100" />

        <div class="section-header sub-section-header">
          <h3 class="sub-section-title">企划</h3>
          <el-button type="text" class="section-link" @click="$router.push({ path: '/projects', query: { keyword: searchKeyword } })">查看更多</el-button>
        </div>
        <div v-if="siteSearch.project.length" class="project-mini-list">
          <div
            v-for="project in siteSearch.project"
            :key="'search-project-' + project.id"
            class="project-mini-card"
            @click="goProjectDetail(project)"
          >
            <div class="project-mini-title">{{ project.title || project.name }}</div>
            <div class="project-mini-desc">{{ project.description || '暂无需求描述' }}</div>
            <div class="project-mini-meta">
              <span v-if="project.category" class="card-tag">{{ project.category }}</span>
              <span v-if="project.style" class="card-tag">{{ project.style }}</span>
              <span class="card-price">¥{{ project.budgetMin || 0 }}–{{ project.budgetMax || 0 }}</span>
            </div>
          </div>
        </div>
        <el-empty v-else description="没有匹配企划" :image-size="100" />

        <div class="section-header sub-section-header">
          <h3 class="sub-section-title">画师</h3>
          <el-button type="text" class="section-link" @click="$router.push({ path: '/artists', query: { keyword: searchKeyword } })">查看更多</el-button>
        </div>
        <div v-if="siteSearch.artist.length" class="artist-mini-grid">
          <div
            v-for="artist in siteSearch.artist"
            :key="'search-artist-' + artist.id"
            class="artist-mini-card"
            @click="goArtistDetail(artist)"
          >
            <img :src="artist.avatar || defaultAvatar" class="artist-mini-avatar" alt="">
            <div class="artist-mini-name">{{ artist.name || artist.username }}</div>
            <div class="artist-mini-stat">{{ artist.workCount || 0 }} 件橱窗</div>
          </div>
        </div>
        <el-empty v-else description="没有匹配画师" :image-size="100" />
      </template>
    </section>

    <!-- 个性化推荐 -->
    <section class="section">
      <div class="section-header">
        <h2 class="section-title">推荐橱窗</h2>
        <el-button type="text" class="section-link" @click="goShowcase">查看更多</el-button>
      </div>
      <div v-if="recommendLoading" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="recommendWorks.length" class="card-grid">
        <div
          v-for="work in recommendWorks"
          :key="work.id"
          class="work-card"
          @click="goWorkDetail(work)"
        >
          <div class="card-cover">
            <img v-if="work.photo" :src="work.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="card-body">
            <div class="card-title">{{ work.name }}</div>
            <div class="card-meta">
              <span v-if="work.fenlei" class="card-tag">{{ work.fenlei }}</span>
              <span v-if="work.price" class="card-price">¥{{ work.price }}</span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无作品" :image-size="120" />
    </section>

    <section class="section">
      <div class="section-header">
        <h2 class="section-title">推荐作品</h2>
        <el-button type="text" class="section-link" @click="goWorks">查看更多</el-button>
      </div>
      <div v-if="recWorksLoading" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="recWorks.length" class="community-grid">
        <div
          v-for="post in recWorks"
          :key="post.id"
          class="community-card"
          @click="goPostDetail(post)"
        >
          <div class="community-cover">
            <img v-if="post.photo" :src="post.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="community-body">
            <div class="community-title">{{ post.title || post.name }}</div>
            <div class="community-meta">
              <span v-if="post.fenlei" class="card-tag">{{ post.fenlei }}</span>
              <span class="community-author">{{ post.username || post.authorName || '匿名用户' }}</span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无推荐作品" :image-size="120" />
    </section>

    <section class="section">
      <div class="section-header">
        <h2 class="section-title">推荐企划</h2>
        <el-button type="text" class="section-link" @click="goProjects">查看更多</el-button>
      </div>
      <div v-if="recProjectsLoading" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="recProjects.length" class="project-mini-list">
        <div
          v-for="project in recProjects"
          :key="project.id"
          class="project-mini-card"
          @click="goProjectDetail(project)"
        >
          <div class="project-mini-title">{{ project.title || project.name }}</div>
          <div class="project-mini-desc">{{ project.description || '暂无需求描述' }}</div>
          <div class="project-mini-meta">
            <span v-if="project.category" class="card-tag">{{ project.category }}</span>
            <span v-if="project.style" class="card-tag">{{ project.style }}</span>
            <span class="card-price">¥{{ project.budgetMin || 0 }}–{{ project.budgetMax || 0 }}</span>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无推荐企划" :image-size="120" />
    </section>

    <section class="section">
      <div class="section-header">
        <h2 class="section-title">推荐画师</h2>
        <el-button type="text" class="section-link" @click="goArtists">查看更多</el-button>
      </div>
      <div v-if="recArtistsLoading" class="loading-placeholder">
        <i class="el-icon-loading" /> 加载中…
      </div>
      <div v-else-if="recArtists.length" class="artist-mini-grid">
        <div
          v-for="artist in recArtists"
          :key="artist.id"
          class="artist-mini-card"
          @click="goArtistDetail(artist)"
        >
          <img :src="artist.avatar || defaultAvatar" class="artist-mini-avatar" alt="">
          <div class="artist-mini-name">{{ artist.name || artist.username }}</div>
          <div class="artist-mini-stat">{{ artist.workCount || 0 }} 件橱窗</div>
        </div>
      </div>
      <el-empty v-else description="暂无推荐画师" :image-size="120" />
    </section>

    <!-- 热门分类 -->
    <section v-if="categories.length" class="section">
      <div class="section-header">
        <h2 class="section-title">热门分类</h2>
      </div>
      <div class="tag-group">
        <span
          v-for="cat in categories"
          :key="cat.id"
          class="category-tag"
          @click="goCategory(cat.fenlei)"
        >{{ cat.fenlei }}</span>
      </div>
    </section>

    <section v-if="communityPosts.length" class="section">
      <div class="section-header">
        <h2 class="section-title">社区精选</h2>
        <el-button type="text" class="section-link" @click="goWorks">查看更多</el-button>
      </div>
      <div class="community-grid">
        <div
          v-for="post in communityPosts"
          :key="post.id"
          class="community-card"
          @click="goPostDetail(post.id)"
        >
          <div class="community-cover">
            <img v-if="post.photo" :src="post.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="community-body">
            <div class="community-title">{{ post.title }}</div>
            <div class="community-meta">
              <span v-if="post.fenlei" class="card-tag">{{ post.fenlei }}</span>
              <span class="community-author">{{ post.username || '匿名用户' }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 全部作品浏览 -->
    <section class="section">
      <div class="section-header">
        <h2 class="section-title">最新上架</h2>
        <el-button type="text" class="section-link" @click="goShowcase">查看全部</el-button>
      </div>
      <div v-if="allWorks.length" class="card-grid">
        <div
          v-for="work in allWorks"
          :key="work.id"
          class="work-card"
          @click="goWorkDetail(work)"
        >
          <div class="card-cover">
            <img v-if="work.photo" :src="work.photo" alt="" class="cover-img">
            <div v-else class="cover-placeholder" />
          </div>
          <div class="card-body">
            <div class="card-title">{{ work.name }}</div>
            <div class="card-meta">
              <span v-if="work.fenlei" class="card-tag">{{ work.fenlei }}</span>
              <span v-if="work.price" class="card-price">¥{{ work.price }}</span>
            </div>
          </div>
        </div>
      </div>
      <div v-if="allWorks.length && allWorksTotal > allWorks.length" class="load-more">
        <el-button :loading="allWorksLoading" type="text" @click="loadMoreWorks">
          加载更多
        </el-button>
      </div>
    </section>
  </div>
</template>

<script>
import huagaoApi from '@/api/huagao'
import recApi from '@/api/rec'
import fenleiApi from '@/api/fenlei'
import lunboApi from '@/api/lunbo'
import fenxiangApi from '@/api/fenxiang'
import projectApi from '@/api/project'
import artistApi from '@/api/artist'
import { normalizeImageUrl } from '@/utils/oss'
import { createClientEventId } from '@/utils/visitor'
import { buildOtherArtistProfileRoute } from '@/utils/centerProfile'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

export default {
  name: 'HomePage',
  data() {
    return {
      defaultAvatar,
      carouselItems: [],
      recommendWorks: [],
      recommendLoading: false,
      recWorks: [],
      recWorksLoading: false,
      recProjects: [],
      recProjectsLoading: false,
      recArtists: [],
      recArtistsLoading: false,
      categories: [],
      communityPosts: [],
      allWorks: [],
      allWorksTotal: 0,
      allWorksPage: 1,
      allWorksLoading: false,
      searchKeyword: '',
      siteSearchLoading: false,
      siteSearch: {
        huagao: [],
        zuopin: [],
        project: [],
        artist: []
      }
    }
  },
  watch: {
    '$route.query.keyword': {
      immediate: true,
      handler(keyword) {
        const nextKeyword = keyword ? String(keyword).trim() : ''
        if (this.searchKeyword === nextKeyword) {
          return
        }
        this.searchKeyword = nextKeyword
        if (this.searchKeyword) {
          this.fetchSiteSearch()
        } else {
          this.resetSiteSearch()
        }
      }
    }
  },
  created() {
    this.fetchCarousel()
    this.fetchCategories()
    this.fetchCommunityPosts()
    this.fetchAllWorks()
    this.fetchRecommend()
    this.fetchDomainRecommend('zuopin', 'home_works', 'recWorks', 'recWorksLoading', 4)
    this.fetchDomainRecommend('project', 'home_projects', 'recProjects', 'recProjectsLoading', 3)
    this.fetchDomainRecommend('artist', 'home_artists', 'recArtists', 'recArtistsLoading', 4)
  },
  methods: {
    /** 轮播图 */
    fetchCarousel() {
      lunboApi.getList1().then(res => {
        this.carouselItems = (res.data.rows || []).map(this.normalizeImageRow)
      }).catch(() => {})
    },

    /** 分类标签 */
    fetchCategories() {
      fenleiApi.getFixedList().then(res => {
        this.categories = res.data.rows || []
      }).catch(() => {})
    },

    resetSiteSearch() {
      this.siteSearch = {
        huagao: [],
        zuopin: [],
        project: [],
        artist: []
      }
    },

    fetchSiteSearch() {
      if (!this.searchKeyword) return
      this.siteSearchLoading = true
      const keyword = this.searchKeyword
      Promise.all([
        huagaoApi.getList({
          pageNo: 1,
          pageSize: 8,
          keyword,
          type: '上架',
          status: '审核成功'
        }),
        fenxiangApi.getList({
          pageNo: 1,
          pageSize: 8,
          keyword
        }),
        projectApi.getList({
          pageNo: 1,
          pageSize: 6,
          keyword
        }),
        artistApi.getList({
          pageNo: 1,
          pageSize: 6,
          keyword
        })
      ]).then(([huagaoRes, zuopinRes, projectRes, artistRes]) => {
        if (this.searchKeyword !== keyword) return
        this.siteSearch = {
          huagao: ((huagaoRes.data && huagaoRes.data.rows) || []).map(this.normalizeImageRow),
          zuopin: ((zuopinRes.data && zuopinRes.data.rows) || []).map(this.normalizeImageRow),
          project: (projectRes.data && projectRes.data.rows) || [],
          artist: ((artistRes.data && artistRes.data.rows) || []).map(this.normalizeImageRow)
        }
      }).catch(() => {
        this.resetSiteSearch()
      }).finally(() => {
        if (this.searchKeyword === keyword) {
          this.siteSearchLoading = false
        }
      })
    },

    fetchCommunityPosts() {
      fenxiangApi.getList({
        pageNo: 1,
        pageSize: 4
      }).then(res => {
        this.communityPosts = (res.data.rows || []).map(this.normalizeImageRow)
      }).catch(() => {})
    },

    /** LTR 推荐，后端无结果时会降级为最新上架橱窗 */
    fetchRecommend() {
      this.recommendLoading = true
      recApi.recommendations({
        domain: 'huagao',
        pageNo: 1,
        pageSize: 12,
        scene: 'home'
      }).then(res => {
        const requestId = res.data.requestId || ''
        const rows = res.data.rows || []
        this.recommendWorks = rows.map((item, index) => {
          return Object.assign({}, this.normalizeImageRow(item), {
            trackingRequestId: requestId,
            trackingPosition: index + 1,
            trackingScene: 'home',
            trackingSource: 'home_recommend',
            trackingDomain: 'huagao',
            trackingModelVersion: res.data.modelVersion || ''
          })
        })
      }).catch(() => {
        return this.fetchLatest()
      }).finally(() => {
        this.recommendLoading = false
      })
    },

    fetchDomainRecommend(domain, scene, targetKey, loadingKey, pageSize) {
      this[loadingKey] = true
      recApi.recommendations({
        domain,
        pageNo: 1,
        pageSize,
        scene
      }).then(res => {
        const requestId = res.data.requestId || ''
        const modelVersion = res.data.modelVersion || ''
        const rows = res.data.rows || []
        this[targetKey] = rows.map((item, index) => Object.assign({}, this.normalizeImageRow(item), {
          trackingRequestId: requestId,
          trackingPosition: index + 1,
          trackingScene: scene,
          trackingSource: scene,
          trackingDomain: domain,
          trackingModelVersion: modelVersion
        }))
      }).catch(() => {
        this[targetKey] = []
      }).finally(() => {
        this[loadingKey] = false
      })
    },

    fetchLatest() {
      return huagaoApi.getzuixin({ pageNo: 1, pageSize: 12 }).then(res => {
        this.recommendWorks = (res.data.rows || []).map(this.normalizeImageRow)
      })
    },

    /** 全部作品 */
    fetchAllWorks() {
      this.allWorksLoading = true
      huagaoApi.getList({
        pageNo: this.allWorksPage,
        pageSize: 12,
        type: '上架',
        status: '审核成功'
      }).then(res => {
        const rows = (res.data.rows || []).map(this.normalizeImageRow)
        this.allWorks = this.allWorksPage === 1 ? rows : this.allWorks.concat(rows)
        this.allWorksTotal = res.data.total || 0
      }).catch(() => {}).finally(() => {
        this.allWorksLoading = false
      })
    },

    loadMoreWorks() {
      this.allWorksPage++
      this.fetchAllWorks()
    },

    normalizeImageRow(row) {
      if (!row) return row
      return Object.assign({}, row, {
        photo: normalizeImageUrl(row.photo),
        lunbo: normalizeImageUrl(row.lunbo),
        avatar: normalizeImageUrl(row.avatar),
        userAvatar: normalizeImageUrl(row.userAvatar),
        coverImage: normalizeImageUrl(row.coverImage)
      })
    },

    goWorkDetail(work) {
      const item = typeof work === 'object' ? work : { id: work }
      if (!item || !item.id) return
      const query = {}
      if (item.trackingRequestId) {
        recApi.trackAction({
          eventId: createClientEventId('click'),
          eventType: 'click_detail',
          domain: 'huagao',
          requestId: item.trackingRequestId,
          itemId: item.id,
          authorId: item.shangjiaids ? Number(item.shangjiaids) : null,
          position: item.trackingPosition,
          scene: item.trackingScene || 'home',
          source: item.trackingSource || 'home_recommend',
          modelVersion: item.trackingModelVersion || ''
        }).catch(() => {})
        query.requestId = item.trackingRequestId
        query.position = item.trackingPosition
        query.scene = item.trackingScene || 'home'
        query.source = item.trackingSource || 'home_recommend'
        query.modelVersion = item.trackingModelVersion || ''
        query.domain = 'huagao'
      }
      this.$router.push({ path: '/work/' + item.id, query })
    },

    goPostDetail(post) {
      const item = typeof post === 'object' ? post : { id: post }
      if (!item || !item.id) return
      const query = this.buildRecQuery(item, 'zuopin', 'home_works')
      this.trackDomainClick(item, 'zuopin', query)
      this.$router.push({ path: '/post/' + item.id, query })
    },

    goProjectDetail(project) {
      if (!project || !project.id) return
      const query = this.buildRecQuery(project, 'project', 'home_projects')
      this.trackDomainClick(project, 'project', query)
      this.$router.push({ path: '/project/' + project.id, query })
    },

    goArtistDetail(artist) {
      if (!artist || !artist.id) return
      const query = this.buildRecQuery(artist, 'artist', 'home_artists')
      this.trackDomainClick(artist, 'artist', query)
      const route = buildOtherArtistProfileRoute(artist.id, 'featuredWorks')
      this.$router.push({
        path: route.path,
        query: Object.assign({}, route.query, query)
      })
    },

    buildRecQuery(item, domain, scene) {
      const query = {}
      if (item.trackingRequestId) {
        query.requestId = item.trackingRequestId
        query.position = item.trackingPosition
        query.scene = item.trackingScene || scene
        query.source = item.trackingSource || scene
        query.modelVersion = item.trackingModelVersion || ''
        query.domain = domain
      }
      return query
    },

    trackDomainClick(item, domain, query) {
      if (!item || !item.id || !query.requestId) return
      recApi.trackAction({
        eventId: createClientEventId('click'),
        eventType: 'click_detail',
        domain,
        requestId: query.requestId,
        itemId: item.id,
        authorId: item.authorId || item.userId || item.userids || item.shangjiaids || item.id,
        position: query.position ? Number(query.position) : null,
        scene: query.scene || domain,
        source: query.source || domain,
        modelVersion: query.modelVersion || ''
      }).catch(() => {})
    },

    goShowcase() {
      this.$router.push('/showcase')
    },

    goWorks() {
      this.$router.push('/works')
    },

    goProjects() {
      this.$router.push('/projects')
    },

    goArtists() {
      this.$router.push('/artists')
    },

    goCategory(fenlei) {
      this.$router.push({
        path: '/showcase',
        query: fenlei ? { fenlei } : {}
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.home-page {
  padding-bottom: 60px;
}

/* ── 轮播区 ── */
.hero-carousel {
  margin-bottom: 8px;

  ::v-deep .el-carousel__indicators--outside {
    text-align: center;
  }
}

.carousel-slide {
  position: relative;
  width: 100%;
  height: 320px;
  border-radius: 16px;
  overflow: hidden;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.carousel-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.carousel-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 20px;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.45));
}

.carousel-label {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
}

/* ── 通用区块 ── */
.section {
  margin-top: 40px;
}

.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.site-search-section {
  padding-bottom: 12px;
}

.sub-section-header {
  margin-top: 28px;
  margin-bottom: 14px;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.sub-section-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.section-link {
  margin-left: auto;
  color: #6c5ce7;
}

/* ── 作品网格 ── */
.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.community-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.work-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
}

.community-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
}

.community-cover {
  position: relative;
  width: 100%;
  padding-top: 68%;
  background: #f5f5f5;
  overflow: hidden;
}

.community-body {
  padding: 14px 16px 16px;
}

.community-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  line-height: 1.5;
  min-height: 44px;
}

.community-meta {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  align-items: center;
  margin-top: 10px;
}

.community-author {
  font-size: 12px;
  color: #7b8796;
}

.card-cover {
  width: 100%;
  padding-top: 100%; /* 1:1 */
  position: relative;
  overflow: hidden;
  background: #f5f5f5;
}

.cover-img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cover-placeholder {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.card-body {
  padding: 12px 14px;
}

.card-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 6px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-tag {
  font-size: 12px;
  color: #6c5ce7;
  background: rgba(108, 92, 231, 0.08);
  padding: 2px 8px;
  border-radius: 4px;
}

.card-price {
  font-size: 13px;
  color: #e17055;
  font-weight: 500;
}

.project-mini-list {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.project-mini-card,
.artist-mini-card {
  background: #fff;
  border: 1px solid #edf0f5;
  border-radius: 12px;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
  }
}

.project-mini-card {
  padding: 18px;
}

.project-mini-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.project-mini-desc {
  height: 44px;
  font-size: 13px;
  color: #667085;
  line-height: 1.6;
  overflow: hidden;
}

.project-mini-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.artist-mini-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.artist-mini-card {
  padding: 18px;
  text-align: center;
}

.artist-mini-avatar {
  width: 58px;
  height: 58px;
  border-radius: 50%;
  object-fit: cover;
  background: #f5f5f5;
}

.artist-mini-name {
  margin-top: 10px;
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.artist-mini-stat {
  margin-top: 4px;
  font-size: 12px;
  color: #9098a6;
}

/* ── 分类标签 ── */
.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.category-tag {
  display: inline-block;
  padding: 8px 18px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 20px;
  font-size: 14px;
  color: #555;
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    color: #6c5ce7;
    border-color: #6c5ce7;
    background: rgba(108, 92, 231, 0.04);
  }
}

/* ── 加载更多 ── */
.load-more {
  text-align: center;
  margin-top: 24px;
}

.loading-placeholder {
  text-align: center;
  padding: 40px 0;
  color: #999;
  font-size: 14px;
}

/* ── 响应式 ── */
@media (max-width: 900px) {
  .card-grid,
  .community-grid,
  .project-mini-list,
  .artist-mini-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 600px) {
  .card-grid,
  .community-grid,
  .project-mini-list,
  .artist-mini-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .carousel-slide {
    height: 200px;
    border-radius: 8px;
  }

  .hero-carousel {
    ::v-deep .el-carousel {
      height: 200px !important;
    }
  }
}
</style>
