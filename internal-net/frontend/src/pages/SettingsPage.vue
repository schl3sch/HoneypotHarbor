<template>
    <Layout>
        <div class="row justify-content-md-center mt-5">
            <div class="col-6">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-3">
                            Hello, 
                            <span v-if="firstname === 'Admin' && lastname === 'Admin'">Admin</span>
                            <span v-else>{{ firstname }} {{ lastname }}</span>
                        </h5>
                        <form @submit.prevent="changePassword">
                            <p v-if="Object.keys(validationErrors).length" class="text-center">
                                <small class="text-danger">Something went wrong.</small>
                            </p>
                            
                            <div class="mb-3">
                                <label for="currentPassword" class="form-label">Current Password</label>
                                <input
                                v-model="currentPassword"
                                type="password"
                                class="form-control"
                                id="currentPassword"
                                />
                            </div>
                            
                            <div class="mb-3">
                                <label for="newPassword" class="form-label">New Password</label>
                                <input
                                v-model="newPassword"
                                type="password"
                                class="form-control"
                                id="newPassword"
                                />
                                <div v-if="passwordErrors.length">
                                    <div v-for="(err, idx) in passwordErrors" :key="idx">
                                        <small class="text-danger d-block">{{ err }}</small>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="confirmationPassword" class="form-label">Confirm Password</label>
                                <input
                                v-model="confirmationPassword"
                                type="password"
                                class="form-control"
                                id="confirmationPassword"
                                />
                                <div v-if="confirmationPasswordError">
                                    <small class="text-danger d-block">{{ confirmationPasswordError }}</small>
                                </div>
                            </div>
                            
                            <div class="d-grid gap-2">
                                <button
                                :disabled="isSubmitting || hasErrors"
                                type="submit"
                                class="btn btn-primary btn-block"
                                >
                                Change Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</Layout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import { auth } from '../store/auth'
import axios from 'axios'

export default {
    name: 'SettingsPage',
    components: { Layout },
    setup() {
        const router = useRouter()
        const firstname = ref('')
        const lastname = ref('')
        
        const currentPassword = ref('')
        const newPassword = ref('')
        const confirmationPassword = ref('')
        const validationErrors = ref({})
        const isSubmitting = ref(false)
        
        // Computed validations
        const passwordErrors = computed(() => {
            const errors = []
            const pwd = newPassword.value
            if (pwd) {
                if (pwd.length < 6 || pwd.length > 15) errors.push('Password needs to be between 6-15 characters.')
                if (!/[a-z]/.test(pwd)) errors.push('Include at least one lowercase letter.')
                if (!/[A-Z]/.test(pwd)) errors.push('Include at least one uppercase letter.')
                if (!/\d/.test(pwd)) errors.push('Include at least one number.')
                if (!/[@.#$!%^&*.?]/.test(pwd)) errors.push('Include at least one special character.')
            }
            return errors
        })
        
        const confirmationPasswordError = computed(() => {
            if (confirmationPassword.value && newPassword.value !== confirmationPassword.value) {
                return 'Passwords do not match.'
            }
            return ''
        })
        
        const hasErrors = computed(() => {
            return Boolean(
            passwordErrors.value.length ||
            confirmationPasswordError.value ||
            !currentPassword.value ||
            !newPassword.value ||
            !confirmationPassword.value
            )
        })
        
        // Load user info
        const loadUserInfo = async () => {
            try {
                const res = await axios.get('/api/v1/users/name', {
                    headers: { Authorization: `Bearer ${auth.token}` }
                })
                firstname.value = res.data.firstname
                lastname.value = res.data.lastname
            } catch (err) {
                console.error('Failed to load user info', err)
            }
        }
        
        // Change password
        const changePassword = async () => {
            validationErrors.value = {}
            if (hasErrors.value) return
            
            isSubmitting.value = true
            try {
                const payload = {
                    currentPassword: currentPassword.value,
                    newPassword: newPassword.value,
                    confirmationPassword: confirmationPassword.value
                }
                const res = await axios.post('/api/v1/auth/change/password', payload, {
                    headers: { Authorization: `Bearer ${auth.token}` }
                })
                
                if (res.data.token) {
                    auth.setToken(res.data.token)
                }
                router.push('/dashboard')
            } catch (err) {
                isSubmitting.value = false
                if (err.response?.data?.errors) validationErrors.value = err.response.data.errors
                else if (err.response?.data?.error) validationErrors.value = { general: err.response.data.error }
                else validationErrors.value = { general: 'Unexpected error occurred' }
            }
        }
        
        onMounted(() => {
            if (!auth.token) {
                router.push('/login')
                return
            }
            loadUserInfo()
        })
        
        return {
            firstname,
            lastname,
            currentPassword,
            newPassword,
            confirmationPassword,
            passwordErrors,
            confirmationPasswordError,
            hasErrors,
            validationErrors,
            isSubmitting,
            changePassword
        }
    }
}
</script>
