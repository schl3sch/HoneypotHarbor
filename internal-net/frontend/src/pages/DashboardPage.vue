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
import axios from 'axios'
import Layout from '../components/Layout.vue'

export default {
    name: 'DashboardPage',
    components: { Layout },
    data() {
    },
    created() {
        if(localStorage.getItem('token') == "" || localStorage.getItem('token') == null){
            this.$router.push('/')
        }
    }
}
</script>
