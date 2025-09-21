<template>
    <Layout>
        <h2>Settings</h2>
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
            if (!auth.token) {
                router.push('/login')
            }
        })
        
        return {}
    }
}
</script>
