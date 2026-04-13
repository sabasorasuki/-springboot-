<template>
  <div class="projects-page">
    <section class="page-header">
      <h1 class="page-title">企划大厅</h1>
      <p class="page-desc">浏览委托需求，找到适合的项目机会</p>
    </section>

    <section class="section">
      <div class="project-list">
        <div v-for="i in 6" :key="i" class="project-card placeholder-card">
          <div class="project-card__body">
            <div class="placeholder-line w70" style="height: 18px; margin-bottom: 10px;" />
            <div class="placeholder-line w90" />
            <div class="placeholder-line w60" />
          </div>
          <div class="project-card__meta">
            <el-tag size="mini" effect="plain">插画</el-tag>
            <span class="meta-text">预算 ¥---</span>
            <span class="meta-text">截止 ----/--/--</span>
          </div>
          <div class="project-card__actions">
            <el-button size="small" type="primary" plain>查看详情</el-button>
            <el-button size="small" plain>立即应征</el-button>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'ProjectsPage'
}
</script>

<style lang="scss" scoped>
.projects-page {
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

.section {
  margin-top: 32px;
}

.project-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.project-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  }
}

.project-card__body {
  margin-bottom: 14px;
}

.placeholder-line {
  height: 13px;
  border-radius: 6px;
  background: #eee;
  margin-bottom: 8px;

  &.w70 { width: 70%; }
  &.w90 { width: 90%; }
  &.w60 { width: 60%; }
}

.project-card__meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 14px;
}

.meta-text {
  font-size: 13px;
  color: #999;
}

.project-card__actions {
  display: flex;
  gap: 10px;
}
</style>
