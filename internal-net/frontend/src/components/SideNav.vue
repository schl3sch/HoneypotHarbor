<template>
  <div :class="['vh-100 position-fixed sidebar p-3 bg-light border-end', { show }]" style="width: 250px;">
    <!-- Navigation -->
    <h5>Navigation</h5>
    <hr />
    <div class="d-flex flex-column gap-2">
      <router-link
        to="/dashboard"
        class="p-3 border rounded text-decoration-none w-100 text-center"
        :class="linkClass('/dashboard')"
      >
        Dashboard
      </router-link>
    </div>

    <!-- Manage -->
    <h6 class="mt-3">Manage</h6>
    <div class="d-flex flex-column gap-2">
      <router-link
        v-if="['ROLE_ANALYST','ROLE_ADMIN'].includes(auth.role)"
        to="/honeypots"
        class="p-3 border rounded text-decoration-none w-100 text-center"
        :class="linkClass('/honeypots')"
      >
        Honeypots
      </router-link>

      <router-link
        v-if="['ROLE_ANALYST','ROLE_ADMIN'].includes(auth.role)"
        to="/alerts"
        class="p-3 border rounded text-decoration-none w-100 text-center"
        :class="linkClass('/alerts')"
      >
        Alerts
      </router-link>
    </div>

    <!-- Administration -->
    <div v-if="auth.role === 'ROLE_ADMIN'">
      <h6 class="mt-3">Administration</h6>
      <div class="d-flex flex-column gap-2">
        <router-link
          to="/roles"
          class="p-3 border rounded text-decoration-none w-100 text-center"
          :class="linkClass('/roles')"
        >
          Roles
        </router-link>
      </div>
    </div>

    <!-- Account -->
    <h6 class="mt-3">Account</h6>
    <div class="d-flex flex-column gap-2">
      <router-link
        to="/settings"
        class="p-3 border rounded text-decoration-none w-100 text-center"
        :class="linkClass('/settings')"
      >
        Settings
      </router-link>
    </div>
  </div>
</template>

<script>
import { useRoute } from 'vue-router'
import { auth } from '../store/auth.js'

export default {
  name: 'SideNav',
  props: {
    show: { type: Boolean, default: true }
  },
  setup() {
    const route = useRoute()

    const linkClass = (path) => ({
      'bg-primary text-white': route.path === path,
      'bg-white text-dark': route.path !== path
    })

    return { linkClass, auth }
  }
}
</script>

<style scoped>
.sidebar {
  transition: all 0.3s;
}
.sidebar.show {
  transform: translateX(0);
}
.sidebar:not(.show) {
  transform: translateX(-260px);
}
</style>
