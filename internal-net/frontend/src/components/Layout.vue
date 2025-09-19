<template>
  <div class="d-flex">
    <!-- Sidebar -->
    <side-nav :is-admin="isAdmin" :show="showSidebar" @close="showSidebar = false" />

    <div class="flex-grow-1">
      <!-- Topbar -->
      <top-bar @toggle-sidebar="toggleSidebar" @logout="logout" />

      <!-- Page Content -->
      <div class="container-fluid mt-3">
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script>
import TopBar from './TopBar.vue'
import SideNav from './SideNav.vue'
import axios from 'axios'

export default {
  name: 'Layout',
  components: { TopBar, SideNav },
  data() {
    return {
      showSidebar: false,
      isAdmin: false
    }
  },
  created() {
    this.checkRole()
  },
  methods: {
    toggleSidebar() {
      this.showSidebar = !this.showSidebar
    },
    logout() {
      axios.post('/api/v1/auth/logout', {}, { headers:{ Authorization: 'Bearer ' + localStorage.getItem('token')}})
        .then(() => {
          localStorage.removeItem('token')
          this.$router.push('/')
        })
    },
    async checkRole() {
      try {
        const res = await axios.get('/api/user', { headers:{ Authorization: 'Bearer ' + localStorage.getItem('token')}})
        this.isAdmin = res.data.role === 'admin'
      } catch (e) {
        console.error(e)
      }
    }
  }
}
</script>
