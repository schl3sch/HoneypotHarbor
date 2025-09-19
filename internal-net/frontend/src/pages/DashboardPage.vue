<template>
  <Layout>
    <div class="row justify-content-md-center">
      <div class="col-12">
        <h2 class="text-center mt-5">Welcome, {{ user.name || 'User' }}!</h2>
      </div>
    </div>
  </Layout>
</template>

<script>
import axios from 'axios'
import Layout from '../components/Layout.vue'

export default {
  name: 'DashboardPage',
  components: { Layout },
  data() {
    return {
      user: {}
    }
  },
  async created() {
    const token = localStorage.getItem('token')
    if (!token) {
      this.$router.push('/')
      return
    }

    try {
      const res = await axios.get('/api/user', {
        headers: { Authorization: 'Bearer ' + token }
      })
      this.user = res.data
    } catch (err) {
      console.error('Fehler beim Laden des Users:', err)
      this.$router.push('/')
    }
  }
}
</script>
