<template>
    
    <nav class="navbar navbar-light position-fixed bg-light border-bottom w-100" style="top:0; z-index:1030;">
      <div class="container-fluid d-flex align-items-center">
        <!-- Hamburger -->
        <button class="btn btn-outline-secondary me-3" @click="$emit('toggle-sidebar')">☰</button>

        <!-- Title -->
        <span class="navbar-brand flex-grow-1 text-center mb-0">Honeypot Harbor</span>

        <!-- Logout -->
        <button class="btn btn-danger ms-3" @click="$emit('logout')">Logout</button>
      </div>
    </nav>
</template>

<script>
export default {
    name: 'TopBar'
}
</script>
