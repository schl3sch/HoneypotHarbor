<template>
  <nav class="navbar navbar-light bg-light border-bottom">
    <div class="container-fluid d-flex justify-content-between align-items-center">
      <!-- Hamburger -->
      <button class="btn btn-outline-secondary" @click="$emit('toggle-sidebar')">
        ☰
      </button>

      <!-- Title -->
      <span class="navbar-brand mx-auto">Honeypot Harbor</span>

      <!-- Logout -->
      <button class="btn btn-danger" @click="$emit('logout')">
        Logout
      </button>
    </div>
  </nav>
</template>

<script>
export default {
  name: 'TopBar'
}
</script>
