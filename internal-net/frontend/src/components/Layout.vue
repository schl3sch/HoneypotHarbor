<template>
  <div>
    <!-- Top Bar -->
    <top-bar @toggle-sidebar="toggleSidebar" @logout="handleLogout" />

    <div class="d-flex">
      <!-- Sidebar -->
      <side-nav :show="showSidebar" class="sidebar" />

      <!-- Main Content -->
      <div :class="['flex-grow-1', { 'margin-left: 250px': showSidebar}]"> <!-- Dynamischer Abstand -->
        <div class="container-fluid mt-3">
          <slot></slot>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import TopBar from './TopBar.vue'
import SideNav from './SideNav.vue'
import { auth } from '../store/auth.js'

export default {
  name: 'Layout',
  components: { TopBar, SideNav },
  setup() {
    const router = useRouter()
    const showSidebar = ref(true)

    const toggleSidebar = () => {
      showSidebar.value = !showSidebar.value
    }

    const handleLogout = () => {
      auth.logout(router)
    }

    return { showSidebar, toggleSidebar, handleLogout }
  }
}
</script>
