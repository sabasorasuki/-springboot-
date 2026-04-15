<template>
  <div :class="{'has-logo':showLogo}">
    <logo v-if="showLogo" :collapse="isCollapse" />
    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :background-color="variables.menuBg"
        :text-color="variables.menuText"
        :unique-opened="false"
        :active-text-color="variables.menuActiveText"
        :collapse-transition="false"
        mode="vertical"
      >
        <sidebar-item v-for="route in routes" :key="route.path" :item="route" :base-path="route.path" />
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Logo from './Logo'
import SidebarItem from './SidebarItem'
import variables from '@/styles/variables.scss'
import { canAccessAdminConsole } from '@/utils/adminConsole'

export default {
  components: { SidebarItem, Logo },
  computed: {
    ...mapGetters([
      'sidebar',
      'roles',
      'activeRole'
    ]),
    routes() {
      const rawRoutes = this.$router.options.routes.concat(global.myRoutes || [])
      const canAccessAdmin = canAccessAdminConsole(this.roles, this.activeRole)
      return rawRoutes.reduce((result, route) => {
        if (route.path !== '/') {
          result.push(route)
          return result
        }
        const current = Object.assign({}, route)
        current.children = (route.children || []).filter(child => canAccessAdmin || child.name !== 'Dashboard')
        if (current.children.length) {
          result.push(current)
        }
        return result
      }, [])
    },
    activeMenu() {
      const route = this.$route
      const { meta, path } = route
      // if set path, the sidebar will highlight the path you set
      if (meta.activeMenu) {
        return meta.activeMenu
      }
      return path
    },
    showLogo() {
      return this.$store.state.settings.sidebarLogo
    },
    variables() {
      return variables
    },
    isCollapse() {
      return !this.sidebar.opened
    }
  }
}
</script>
