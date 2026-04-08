<template>
  <footer class="site-footer">
    <div class="container">
      <div class="footer-grid">
        <div class="footer-brand-block">
          <h3 class="footer-title"><span class="ft-mark">绘</span> 画师接稿平台</h3>
          <p class="slogan">约稿透明 · 档期清晰 · 作品有迹可循</p>
          <p class="copyright">© {{ year }} 画师接稿 · 仅供学习演示</p>
        </div>

        <div class="footer-links">
          <div class="link-group">
            <h4>平台</h4>
            <ul>
              <li><router-link to="/theList"><i class="fa fa-angle-right"></i> 浏览稿位</router-link></li>
              <li><router-link to="/community"><i class="fa fa-angle-right"></i> 交流区</router-link></li>
              <li><a href="#"><i class="fa fa-angle-right"></i> 约稿须知</a></li>
              <li><a href="#"><i class="fa fa-angle-right"></i> 隐私说明</a></li>
            </ul>
          </div>

          <div class="link-group">
            <h4>联系</h4>
            <div class="social-links">
              <a href="#" title="微信"><i class="fa fa-weixin"></i></a>
              <a href="#" title="微博"><i class="fa fa-weibo"></i></a>
              <a href="#" title="QQ"><i class="fa fa-qq"></i></a>
            </div>
          </div>
        </div>
      </div>

      <div class="back-to-top">
        <a href="#" title="回顶部" @click.prevent="scrollTop">
          <i class="fa fa-chevron-up"></i>
        </a>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'theFooter',
  data() {
    return {
      year: new Date().getFullYear()
    }
  },
  methods: {
    scrollTop() {
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }
}
</script>

<style scoped>
.site-footer {
  background: linear-gradient(160deg, #1a1726 0%, #2a2438 100%);
  color: rgba(250, 247, 242, 0.9);
  padding: 3rem 0 2rem;
  margin-top: 0;
  border-top: 1px solid rgba(255, 143, 171, 0.12);
}

.footer-grid {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 2.5rem;
}

.footer-brand-block {
  flex: 1;
  min-width: 260px;
}

.footer-title {
  font-size: 1.35rem;
  margin-bottom: 0.75rem;
  color: #faf7f2;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.ft-mark {
  width: 2rem;
  height: 2rem;
  border-radius: 10px;
  background: linear-gradient(145deg, #ff8fab, #c084fc);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
  color: #1e1b2e;
}

.slogan {
  font-size: 0.95rem;
  color: rgba(250, 247, 242, 0.65);
  margin-bottom: 1rem;
  line-height: 1.6;
}

.copyright {
  font-size: 0.8rem;
  color: rgba(250, 247, 242, 0.45);
}

.footer-links {
  display: flex;
  gap: 3rem;
}

.link-group h4 {
  color: #f5d0dc;
  margin-bottom: 1rem;
  font-size: 0.95rem;
  font-weight: 600;
}

.link-group ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.link-group ul li {
  margin-bottom: 0.45rem;
}

.link-group a {
  color: rgba(250, 247, 242, 0.7);
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.2s, padding-left 0.2s;
}

.link-group a:hover {
  color: #ff8fab;
  padding-left: 4px;
}

.social-links {
  display: flex;
  gap: 0.85rem;
}

.social-links a {
  color: rgba(250, 247, 242, 0.85);
  font-size: 1.35rem;
  transition: transform 0.2s, color 0.2s;
}

.social-links a:hover {
  transform: translateY(-3px);
  color: #c084fc;
}

.back-to-top {
  text-align: right;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
}

.back-to-top a {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  background: rgba(255, 143, 171, 0.15);
  color: #ff8fab;
  border-radius: 50%;
  text-decoration: none;
  transition: all 0.2s ease;
  border: 1px solid rgba(255, 143, 171, 0.25);
}

.back-to-top a:hover {
  background: rgba(192, 132, 252, 0.25);
  color: #e9d5ff;
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .footer-grid {
    flex-direction: column;
  }
  .footer-links {
    flex-direction: column;
    gap: 1.5rem;
  }
}
</style>
