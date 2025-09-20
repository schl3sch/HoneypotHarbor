<template>
  <Layout>
    <h2>Settings</h2>
    <!-- Hier später Settings-Formulare oder Inhalte einfügen -->
  </Layout>
</template>

<script>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import { auth } from '../store/auth.js'

export default {
  name: 'SettingsPage',
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
