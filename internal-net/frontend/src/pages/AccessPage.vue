<template>
    <layout>
        <h2>Access</h2>
    </layout>
</template>

<script>
import axios from 'axios';
import Layout from '../components/Layout.vue';
export default {
    name: 'AccessPage',
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
