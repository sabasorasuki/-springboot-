<template>
  <div class="legacy-publish-redirect">
    <el-card shadow="never">
      <div class="legacy-publish-redirect__content">
        <i class="el-icon-refresh-right" />
        <span>正在跳转到新版橱窗发布页…</span>
      </div>
    </el-card>
  </div>
</template>

<script>
export default {
  name: 'LegacyFabuspRedirect',
  created() {
    const id = this.$route.params.id
    const query = { type: 'huagao' }
    if (id) {
      query.id = id
    }
    this.$router.replace({ path: '/publish/work', query })
  }
}
</script>

<style scoped>
.legacy-publish-redirect {
  max-width: 640px;
  margin: 48px auto;
  padding: 0 20px;
}

.legacy-publish-redirect__content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  min-height: 120px;
  color: #606266;
  font-size: 15px;
}

.legacy-publish-redirect__content i {
  font-size: 18px;
}
</style>
