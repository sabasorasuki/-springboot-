<template>
  <div class="home-page">
    <section class="hero-section">
      <h1 class="hero-title">发现优秀画作</h1>
      <p class="hero-desc">浏览来自全球画师的精彩作品，找到你心仪的创作者</p>
    </section>

    <section class="section">
      <h2 class="section-title">推荐作品</h2>
      <div class="card-grid">
        <div v-for="i in 8" :key="i" class="work-card placeholder-card">
          <div class="card-cover" />
          <div class="card-body">
            <div class="placeholder-line w60" />
            <div class="placeholder-line w40" />
          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <h2 class="section-title">热门标签</h2>
      <div class="tag-group">
        <el-tag v-for="tag in placeholderTags" :key="tag" size="medium" effect="plain">{{ tag }}</el-tag>
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'HomePage',
  data() {
    return {
      placeholderTags: ['插画', '立绘', '头像', '同人', '原创', 'Q版', '场景', '人设']
    }
  }
}
</script>

<style lang="scss" scoped>
.home-page {
  padding-bottom: 48px;
}

.hero-section {
  text-align: center;
  padding: 48px 0 32px;
}

.hero-title {
  font-size: 32px;
  font-weight: 700;
  color: #333;
  margin: 0 0 12px;
}

.hero-desc {
  font-size: 16px;
  color: #888;
  margin: 0;
}

.section {
  margin-top: 40px;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.work-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  }
}

.card-cover {
  width: 100%;
  padding-top: 100%;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.card-body {
  padding: 12px 14px;
}

.placeholder-line {
  height: 14px;
  border-radius: 7px;
  background: #eee;
  margin-bottom: 8px;

  &.w60 { width: 60%; }
  &.w40 { width: 40%; }
}

.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

@media (max-width: 900px) {
  .card-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 600px) {
  .card-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
