<template>
  <div class="artists-page">
    <section class="page-header">
      <h1 class="page-title">发现画师</h1>
      <p class="page-desc">探索风格各异的画师，找到最适合你的创作者</p>
    </section>

    <section class="section">
      <div class="filter-bar">
        <el-tag v-for="tag in styleTags" :key="tag" size="medium" effect="plain" class="filter-tag">{{ tag }}</el-tag>
      </div>
    </section>

    <section class="section">
      <div class="artist-grid">
        <div v-for="i in 6" :key="i" class="artist-card placeholder-card">
          <div class="artist-card__header">
            <div class="avatar-placeholder" />
            <div class="info-placeholder">
              <div class="placeholder-line w50" />
              <div class="placeholder-line w70" />
            </div>
          </div>
          <div class="artist-card__gallery">
            <div v-for="j in 3" :key="j" class="gallery-thumb" />
          </div>
          <div class="artist-card__tags">
            <el-tag size="mini" effect="plain">风格标签</el-tag>
            <el-tag size="mini" type="success" effect="plain">可接稿</el-tag>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'ArtistsPage',
  data() {
    return {
      styleTags: ['全部', '日系', '欧美', '国风', '写实', 'Q版', '像素']
    }
  }
}
</script>

<style lang="scss" scoped>
.artists-page {
  padding-bottom: 48px;
}

.page-header {
  text-align: center;
  padding: 40px 0 24px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px;
}

.page-desc {
  font-size: 15px;
  color: #888;
  margin: 0;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
}

.filter-tag {
  cursor: pointer;
}

.section {
  margin-top: 32px;
}

.artist-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.artist-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  }
}

.artist-card__header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;
}

.avatar-placeholder {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
  flex-shrink: 0;
}

.info-placeholder {
  flex: 1;
}

.placeholder-line {
  height: 12px;
  border-radius: 6px;
  background: #eee;
  margin-bottom: 6px;

  &.w50 { width: 50%; }
  &.w70 { width: 70%; }
}

.artist-card__gallery {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.gallery-thumb {
  flex: 1;
  padding-top: 33%;
  border-radius: 8px;
  background: linear-gradient(135deg, #e8e0f0 0%, #f0e8f5 100%);
}

.artist-card__tags {
  display: flex;
  gap: 6px;
}

@media (max-width: 900px) {
  .artist-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .artist-grid {
    grid-template-columns: 1fr;
  }
}
</style>
