<template>
    <Layout>
        <h2>Alerts</h2>
        <p>Currently under Development</p>
    </Layout>
</template>

<script>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import { auth } from '../store/auth.js'

export default {
    name: 'AlertsPage',
    components: { Layout },
    setup() {
        const router = useRouter()
        
        onMounted(() => {
            if (!auth.token) {
                router.push('/login')
            } else if (!['ROLE_ANALYST', 'ROLE_ADMIN'].includes(auth.role)) {
                router.push('/dashboard')
            }
        })
        
        return {}
    }
}
</script>
