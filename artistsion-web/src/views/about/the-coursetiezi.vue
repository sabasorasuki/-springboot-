<template>
  <div class="guide-card">
    <div class="guide-image">
      <img v-bind:src="course.photo" :alt="course.title">
      <span class="guide-tag">攻略</span>
      <div class="guide-overlay"></div>
    </div>

    <div class="guide-body">
      <div class="guide-head">
        <h3 class="guide-title">
          <i class="fa fa-bookmark"></i> {{course.title}}
        </h3>
        <div class="guide-author">
          <i class="fa fa-pencil"></i> {{course.username}}
        </div>
      </div>

      <div class="guide-info">
        <div class="guide-date">
          <i class="fa fa-clock-o"></i> {{course.fbdate}}
        </div>
      </div>

      <div class="guide-actions">
        <el-button v-if="this.formInline.zhi == 'meiYouZhi'"
                  class="login-hint-btn">
          <i class="fa fa-lock"></i> 登录阅读全文
        </el-button>
        <router-link v-if="this.formInline.zhi == 'youZhi'"
                     v-bind:to="'/details?id=' + course.id"
                     class="details-btn">
          <i class="fa fa-arrow-circle-right"></i> 阅读全文
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'the-coursetiezi',
  props: {
    course: {}
  },
  computed: {
    ...mapGetters([
      'token'
    ])
  },
  created() {
    let zhi = this.token;
    if(typeof(zhi) == 'undefined'){
      this.formInline.zhi = "meiYouZhi";
    }else {
      this.formInline.zhi = "youZhi";
    }
  },
  data: function () {
    return {
      formInline: {
        username: "",
        content: '',
        zhi: "",
        label: ""
      },
    }
  },
}
</script>

<style scoped>
.guide-card {
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

.guide-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(30, 27, 46, 0.12);
}

.guide-image {
  position: relative;
  padding-top: 72%;
  overflow: hidden;
}

.guide-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.35s ease;
}

.guide-tag {
  position: absolute;
  top: 12px;
  left: 12px;
  z-index: 2;
  font-size: 0.7rem;
  font-weight: 700;
  padding: 0.25rem 0.55rem;
  border-radius: 6px;
  background: linear-gradient(135deg, #ff8fab, #c084fc);
  color: #1e1b2e;
}

.guide-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 45%;
  background: linear-gradient(to top, rgba(30, 27, 46, 0.45), transparent);
  pointer-events: none;
}

.guide-card:hover .guide-image img {
  transform: scale(1.04);
}

.guide-body {
  padding: 1.15rem 1.25rem 1.25rem;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.guide-head {
  margin-bottom: 0.75rem;
}

.guide-title {
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

.guide-author {
  color: rgba(42, 38, 53, 0.55);
  font-size: 0.82rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.guide-info {
  margin-bottom: 1rem;
  flex-grow: 1;
}

.guide-date {
  color: rgba(192, 132, 252, 0.95);
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.guide-actions {
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
  background: linear-gradient(135deg, #c084fc, #a78bfa);
  color: #1e1b2e;
  text-align: center;
  text-decoration: none;
  border-radius: 999px;
  font-weight: 600;
  font-size: 0.9rem;
  transition: transform 0.2s, box-shadow 0.2s;
}

.details-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 22px rgba(192, 132, 252, 0.45);
  color: #1e1b2e;
}

.fa {
  margin-right: 4px;
}

@media (max-width: 768px) {
  .guide-body {
    padding: 1rem;
  }
}
</style>
