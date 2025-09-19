<template>
  <div v-if="show" class="bg-light border-end vh-100 position-fixed" style="width: 250px;">
    <div class="p-3">
      <h5>Navigation</h5>
      <hr />
      <ul class="nav flex-column">
        <li class="nav-item">
          <router-link class="nav-link" to="/dashboard">Dashboard</router-link>
        </li>
      </ul>

      <h6 class="mt-3">Manage</h6>
      <ul class="nav flex-column">
        <li><router-link class="nav-link" to="/honeypots">Honeypots</router-link></li>
        <li><router-link class="nav-link" to="/alerts">Alerts</router-link></li>
      </ul>

      <div v-if="isAdmin">
        <h6 class="mt-3">Administration</h6>
        <ul class="nav flex-column">
          <li><router-link class="nav-link" to="/roles">Roles</router-link></li>
        </ul>
      </div>

      <h6 class="mt-3">Account</h6>
      <ul class="nav flex-column">
        <li><router-link class="nav-link" to="/access">Access</router-link></li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SideNav',
  props: {
    isAdmin: { type: Boolean, default: false },
    show: { type: Boolean, default: true }
  }
}
</script>
