<template>
  <div class="commission-card">
    <div class="card-image">
      <img :src="course.photo" :alt="course.title">
      <div class="card-badge">橱窗</div>
      <div class="card-overlay" />
    </div>

    <div class="card-body">
      <div class="card-head">
        <h3 class="card-title">{{ course.name }}</h3>
        <div class="card-artist">
          <i class="fa fa-user-circle" /> {{ course.jingdian }}
        </div>
      </div>

      <div class="card-meta">
        <span class="price">¥{{ course.price }}</span>
        <span class="price-hint">起</span>
      </div>

      <div class="card-actions">
        <el-button
          v-if="this.formInline.zhi == 'meiYouZhi'"
          class="login-hint-btn"
        >
          <i class="fa fa-lock" /> 登录后查看详情
        </el-button>
        <router-link
          v-if="this.formInline.zhi == 'youZhi'"
          :to="'/detail?id=' + course.id"
          class="details-btn"
        >
          <i class="fa fa-arrow-right" /> 查看详情
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'TheCourse',
  props: {
    course: {}
  },
  computed: {
    ...mapGetters([
      'token'
    ])
  },
  created() {
    const zhi = this.token
    if (typeof (zhi) === 'undefined') {
      this.formInline.zhi = 'meiYouZhi'
    } else {
      this.formInline.zhi = 'youZhi'
    }
  },
  data: function() {
    return {
      formInline: {
        username: '',
        content: '',
        zhi: '',
        label: ''
      }
    }
  }
}
</script>

<style scoped>
.commission-card {
  background: #fffef9;
  border-radius: 18px;
  overflow: hidden;
  box-shadow: 0 8px 28px rgba(42, 38, 53, 0.08);
  transition: box-shadow 0.25s, transform 0.25s;
  height: 100%;
  display: flex;
  flex-direction: column;
  border: 1px solid rgba(42, 38, 53, 0.06);
}

.commission-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(30, 27, 46, 0.12);
}

.card-image {
  position: relative;
  padding-top: 72%;
  overflow: hidden;
}

.card-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.35s ease;
}

.card-badge {
  position: absolute;
  top: 12px;
  left: 12px;
  z-index: 2;
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  padding: 0.25rem 0.55rem;
  border-radius: 6px;
  background: rgba(30, 27, 46, 0.72);
  color: #faf7f2;
  backdrop-filter: blur(6px);
}

.card-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 45%;
  background: linear-gradient(to top, rgba(30, 27, 46, 0.5), transparent);
  pointer-events: none;
}

.commission-card:hover .card-image img {
  transform: scale(1.04);
}

.card-body {
  padding: 1.15rem 1.25rem 1.25rem;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.card-head {
  margin-bottom: 0.75rem;
}

.card-title {
  font-size: 1.05rem;
  font-weight: 700;
  color: #2a2635;
  margin: 0 0 0.35rem 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-artist {
  color: rgba(42, 38, 53, 0.55);
  font-size: 0.82rem;
}

.card-meta {
  margin-bottom: 1rem;
  flex-grow: 1;
  display: flex;
  align-items: baseline;
  gap: 0.25rem;
}

.price {
  font-size: 1.2rem;
  font-weight: 800;
  background: linear-gradient(90deg, #c084fc, #ff8fab);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.price-hint {
  font-size: 0.75rem;
  color: rgba(42, 38, 53, 0.4);
}

.card-actions {
  margin-top: auto;
}

.login-hint-btn {
  width: 100%;
  background: #f0ebe3;
  border: none;
  color: rgba(42, 38, 53, 0.55);
  padding: 10px;
  border-radius: 999px;
  transition: all 0.2s ease;
}

.login-hint-btn:hover {
  background: #e8e0d4;
  color: #2a2635;
}

.details-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  width: 100%;
  padding: 10px;
  background: linear-gradient(135deg, #2d2640, #4a3266);
  color: #faf7f2;
  text-align: center;
  text-decoration: none;
  border-radius: 999px;
  font-weight: 600;
  font-size: 0.9rem;
  transition: transform 0.2s, box-shadow 0.2s;
}

.details-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 22px rgba(74, 50, 102, 0.35);
  color: #fff;
}

.fa {
  margin-right: 4px;
}

@media (max-width: 768px) {
  .card-body {
    padding: 1rem;
  }
}
</style>
