<template>
  <header class="site-header">
    <nav class="navbar navbar-expand-lg top-nav">
      <div class="container">
        <router-link class="navbar-brand brand-link" to="/mas">
          <span class="brand-mark">绘</span>
          <span class="brand-text">画师接稿</span>
        </router-link>
        <button class="navbar-toggler nav-toggle" type="button" data-toggle="collapse" data-target="#navbarSupportedContent"
                aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarSupportedContent">
          <ul class="navbar-nav mr-auto nav-main">
            <li class="nav-item">
              <router-link class="nav-link" to="/mas">
                <i class="fa fa-home"></i> 首页
              </router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link" to="/theList">
                <i class="fa fa-paint-brush"></i> 橱窗稿位
              </router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link" to="/community">
                <i class="fa fa-comments"></i> 交流区
              </router-link>
            </li>
          </ul>
          <div class="user-section">
            <span v-if="this.formInline.zhi == 'youZhi'" class="welcome-text">
              <i class="fa fa-user-circle"></i> {{ formInline.username }}
            </span>
            <el-button type="primary" @click="gotohome()" v-if="this.formInline.zhi == 'youZhi'" class="admin-btn">
              <i class="fa fa-cog"></i> 后台
            </el-button>
            <button v-if="this.formInline.zhi == 'meiYouZhi'" v-on:click="openLoginModal()" class="login-btn">
              <i class="fa fa-sign-in"></i> 登录 / 注册
            </button>
          </div>
        </div>
      </div>
    </nav>

  </header>
</template>

<script>
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'

export default {
  name: 'theHeader',
  data: function () {
    return {
      formInline: {
        username:"",
        content: '',
        zhi:"",
      },
    }
  },
  computed: {
        ...mapGetters([
            'token'
        ])
    },
  mounted() {
    let zhi = this.token;
    let username = SessionStorage.get("USERNAME");
    this.formInline.username = username;
    if(typeof(zhi)== 'undefined'){
      this.formInline.zhi = "meiYouZhi";
    }else{
      this.formInline.zhi = "youZhi";
      this.getInfo(this.token)
    }

  },
  methods: {
    getInfo(token) {
            userApi.getInfo(token).then(response => {
                this.forms = response.data.userList
                this.formInline.username =this.forms.name
                console.log(this.forms, "this.formsforms")
            })
        },

    gotohome(){
      this.$router.push({path: '/'});
    },
    openLoginModal() {
      this.$router.push({path: '/login'});
    }



  }
}
</script>

<style scoped>
.site-header {
  position: sticky;
  top: 0;
  z-index: 1030;
}

.top-nav {
  background: linear-gradient(135deg, #1e1b2e 0%, #2d2640 45%, #3d2f55 100%);
  padding: 0.85rem 0;
  box-shadow: 0 8px 32px rgba(30, 27, 46, 0.35);
  border-bottom: 1px solid rgba(255, 182, 193, 0.15);
}

.brand-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #faf7f2 !important;
  font-size: 1.35rem;
  font-weight: 700;
  letter-spacing: 0.02em;
  text-decoration: none !important;
}

.brand-mark {
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 12px;
  background: linear-gradient(145deg, #ff8fab, #c084fc);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  color: #1e1b2e;
  box-shadow: 0 4px 14px rgba(192, 132, 252, 0.45);
}

.brand-text {
  background: linear-gradient(90deg, #faf7f2, #f5d0dc);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.nav-toggle {
  border-color: rgba(250, 247, 242, 0.35);
}

.nav-main .nav-link {
  color: rgba(250, 247, 242, 0.88) !important;
  margin: 0 6px;
  padding: 8px 16px;
  border-radius: 999px;
  transition: color 0.2s, background 0.2s, transform 0.2s;
}

.nav-main .nav-link:hover {
  background: rgba(255, 143, 171, 0.18);
  color: #fff !important;
  transform: translateY(-1px);
}

.user-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.welcome-text {
  color: rgba(250, 247, 242, 0.85);
  font-size: 0.875rem;
  max-width: 140px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.admin-btn {
  background: linear-gradient(135deg, #a78bfa, #c084fc) !important;
  border: none !important;
  padding: 8px 18px;
  border-radius: 999px;
  box-shadow: 0 4px 16px rgba(167, 139, 250, 0.4);
}

.admin-btn:hover {
  filter: brightness(1.08);
  transform: translateY(-1px);
}

.login-btn {
  background: transparent;
  border: 1px solid rgba(255, 182, 193, 0.55);
  color: #faf7f2;
  padding: 8px 18px;
  border-radius: 999px;
  transition: all 0.2s ease;
  cursor: pointer;
}

.login-btn:hover {
  background: rgba(255, 143, 171, 0.2);
  border-color: #ff8fab;
  color: #fff;
}
</style>
