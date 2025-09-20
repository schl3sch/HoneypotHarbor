<template>
  <Layout>
    <div class="row justify-content-md-center">
      <div class="col-12">
        <h2 class="text-center mt-5">Welcome!</h2>
      </div>
    </div>
  </Layout>
</template>

<script>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import { auth } from '../store/auth.js'

export default {
  name: 'DashboardPage',
  components: { Layout },
  setup() {
    const router = useRouter()

    onMounted(() => {
      // Token prüfen
      if (!auth.token) {
        router.push('/login')
      }
    })

    return {}
  }
}
</script>
