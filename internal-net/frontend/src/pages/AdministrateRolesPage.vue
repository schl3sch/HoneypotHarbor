<template>
    <Layout>
        <h2>Administration</h2>
        <!-- Table which Displays every user -->
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Firstname</th>
                    <th>Lastname</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="user in users" :key="user.id">
                    <td>{{ user.firstname }}</td>
                    <td>{{ user.lastname }}</td>
                    <td>{{ user.email }}</td>
                    <td>{{ roleMapping[user.role]}}</td>
                    <td>
                        <!-- Dropdown to select the Role to update -->
                        <div class="dropdown">
                            <button
                            class="btn btn-secondary dropdown-toggle"
                            type="button"
                            data-bs-toggle="dropdown"
                            >
                            ☰
                        </button>
                        <ul class="dropdown-menu">
                            <li v-for="roleOption in roles" :key="roleOption">
                                <a
                                class="dropdown-item"
                                href="#"
                                @click.prevent="confirmRoleChange(user, roleOption)"
                                >
                                {{ roleMapping[roleOption] }}
                            </a>
                        </li>
                    </ul>
                </div>
            </td>
        </tr>
    </tbody>
</table>
</Layout>
</template>

<script>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import Layout from '../components/Layout.vue'
import axios from 'axios'
import { auth } from '../store/auth.js'
import { useRouter } from 'vue-router'

export default {
    name: 'AdministrateRolesPage',
    components: { Layout },
    setup() {
        const router = useRouter()
        const users = ref([])
        const roles = ['ROLE_USER', 'ROLE_ANALYST', 'ROLE_ADMIN']
        const roleMapping = {
            ROLE_USER: 'User',
            ROLE_ANALYST: 'Analyst',
            ROLE_ADMIN: 'Admin'
        }
        let intervalId = null
        
        // Fetch helper funktion
        async function safeFetch(url, fallback = null) {
            try {
                const res = await axios.get(url, {
                    headers: { Authorization: `Bearer ${auth.token}` }
                })
                return res.data
            } catch (err) {
                console.error(`Error fetching ${url}:`, err)
                return fallback
            }
        }
        
        // get all user information
        const loadUsers = async () => {
            const res = await safeFetch('/api/v1/admin/users', [])
            users.value = res
        }
        
        // check if current user in afmin
        const checkIfAdmin = async () => {
            try {
                const res = await safeFetch('/api/v1/users/role', null)
                if (!res || res.role !== 'ROLE_ADMIN') {
                    router.push('/dashboard')
                } else {
                    await loadUsers()
                }
            } catch (err) {
                console.error('Failed to check role', err)
                router.push('/dashboard')
            }
        }
        
        onMounted(async () => {
            if (!auth.token) {
                router.push('/login')
                return
            }
            await checkIfAdmin()
            
            // Polling
            intervalId = setInterval(loadUsers, 5000)
        })
        
        onBeforeUnmount(() => {
            if (intervalId) clearInterval(intervalId)
        })
        
        const confirmRoleChange = (user, newRole) => {
            if (confirm(`Change role of ${user.firstname} ${user.lastname} to ${roleMapping[newRole]}?`)) {
                changeUserRole(user, newRole)
            }
        }
        
        // Change role for user
        const changeUserRole = async (user, newRole) => {
            try {
                await axios.put(
                `/api/v1/admin/users/${user.id}/role`,
                { role: newRole },
                { headers: { Authorization: `Bearer ${auth.token}` } }
                )
                user.role = newRole
            } catch (err) {
                console.error('Failed to change role', err)
            }
        }
        
        return { 
            users, 
            roles, 
            roleMapping, 
            confirmRoleChange
        }
    }
}
</script>
