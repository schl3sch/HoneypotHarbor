<template>
    <div :class="['vh-100 sidebar p-3 bg-light border-end', { show: show }]" style="width: 250px;">
        <!-- Navigation -->
        <h5>Navigation</h5>
        <hr />
        <div class="d-flex flex-column gap-2">
            <router-link
            to="/dashboard"
            class="p-3 border rounded text-decoration-none w-100"
            :class="{'bg-primary text-white': isActive('/dashboard'), 'bg-white text-dark': !isActive('/dashboard')}"
            >
            Dashboard
        </router-link>
    </div>
    
    <!-- Manage -->
    <h6 class="mt-3">Manage</h6>
    <div class="d-flex flex-column gap-2">
        <router-link
        to="/honeypots"
        class="p-3 border rounded text-decoration-none w-100"
        :class="{'bg-primary text-white': isActive('/honeypots'), 'bg-white text-dark': !isActive('/honeypots')}"
        >
        Honeypots
        </router-link>
    
        <router-link
            to="/alerts"
            class="p-3 border rounded text-decoration-none w-100"
            :class="{'bg-primary text-white': isActive('/alerts'), 'bg-white text-dark': !isActive('/alerts')}"
            >
            Alerts
        </router-link>
    </div>

    <!-- Administration -->
    <div v-if="isAdmin">
        <h6 class="mt-3">Administration</h6>
        <div class="d-flex flex-column gap-2">
            <router-link
            to="/roles"
            class="p-3 border rounded text-decoration-none w-100"
            :class="{'bg-primary text-white': isActive('/roles'), 'bg-white text-dark': !isActive('/roles')}"
            >
            Roles
            </router-link>
        </div>
    </div>

    <!-- Account -->
    <h6 class="mt-3">Account</h6>
    <div class="d-flex flex-column gap-2">
        <router-link
            to="/access"
            class="p-3 border rounded text-decoration-none w-100"
            :class="{'bg-primary text-white': isActive('/access'), 'bg-white text-dark': !isActive('/access')}"
            >
            Access
        </router-link>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'SideNav',
    props: { show: { type: Boolean, default: false } },
    data() { return { isAdmin: false }; },
    mounted() {
        this.fetchUserRole();
    },
    methods: {
        async fetchUserRole() {
            try {
                const response = await axios.get('/api/v1/users/role', {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem('token')}`
                    }
                });
                this.isAdmin = response.data.role === 'ROLE_ADMIN';
            } catch (error) {
                console.error('Could not load the role of the user.', error);
            }
        },
        isActive(path) {
            return this.$route.path.startsWith(path);
        }
    }
}
</script>

