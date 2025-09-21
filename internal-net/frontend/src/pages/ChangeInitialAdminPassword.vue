<template>
    <layout-div>
        <div class="row justify-content-md-center mt-5">
            <div class="col-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Change Password</h5>
                        
                        <form @submit.prevent="changePassword">
                            <p v-if="Object.keys(validationErrors).length" class="text-center">
                                <small class="text-danger">Something went wrong.</small>
                            </p>
                            <!-- Current Password -->
                            <div class="mb-3">
                                <label for="currentPassword" class="form-label">Current Password</label>
                                <input
                                v-model="currentPassword"
                                type="password"
                                class="form-control"
                                id="currentPassword"
                                name="currentPassword"
                                />
                            </div>
                            
                            <!-- New Password -->
                            <div class="mb-3">
                                <label for="newPassword" class="form-label">New Password</label>
                                <input
                                v-model="newPassword"
                                type="password"
                                class="form-control"
                                id="newPassword"
                                name="newPassword"
                                />
                                <div v-if="passwordErrors.length">
                                    <div v-for="(err, idx) in passwordErrors" :key="idx">
                                        <small class="text-danger d-block">{{ err }}</small>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Confirm New Password -->
                            <div class="mb-3">
                                <label for="confirmationPassword" class="form-label">Confirm Password</label>
                                <input
                                v-model="confirmationPassword"
                                type="password"
                                class="form-control"
                                id="confirmationPassword"
                                name="confirmationPassword"
                                />
                                <div v-if="confirmationPasswordError">
                                    <small class="text-danger d-block">{{ confirmationPasswordError }}</small>
                                </div>
                            </div>
                            
                            <!-- Submit Button -->
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
</layout-div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import LayoutDiv from '../components/LayoutDiv.vue'
import { useRouter, useRoute } from 'vue-router'
import { auth } from '../store/auth'

export default {
    name: 'ChangeInitialAdminPasswordPage',
    components: { LayoutDiv },
    setup() {
        const router = useRouter()
        const route = useRoute()
        const email = ref('')
        const currentPassword = ref('')
        const newPassword = ref('')
        const confirmationPassword = ref('')
        const validationErrors = ref({})
        const isSubmitting = ref(false)
        
        onMounted(() => {
            if (localStorage.getItem('token')) {
                router.push('/dashboard')
                return
            }
            
            // back to login if there was no email parameter in the url 
            if (route.query.email) {
                email.value = route.query.email
            } else {
                router.push('/login')
                return
            }
            
            // check if its still the initial admin password
            axios
            .get('/api/v1/auth/check-change-password', {
                params: { email: email.value }
            })
            .catch(() => {
                router.push('/login')
            })
        })
        
        // frontend password validation
        const passwordErrors = computed(() => {
            const errors = []
            const pwd = newPassword.value
            
            if (pwd) {
                if (pwd.length < 6 || pwd.length > 15) {
                    errors.push('Password needs to be between 6-15 characters.')
                }
                if (!/[a-z]/.test(pwd)) errors.push('Include at least one lowercase letter.')
                if (!/[A-Z]/.test(pwd)) errors.push('Include at least one uppercase letter.')
                if (!/\d/.test(pwd)) errors.push('Include at least one number.')
                if (!/[@.#$!%^&*.?]/.test(pwd)) errors.push('Include at least one special character.')
            }
            
            return errors
        })
        
        // confirmation pass needs to be the same as the new pass
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
        
        // send password change api request
        const changePassword = async () => {
            validationErrors.value = {}
            
            if (hasErrors.value) return
            
            isSubmitting.value = true
            try {
                const response = await axios.post('/api/v1/auth/change/password', {
                    email: email.value,
                    currentPassword: currentPassword.value,
                    newPassword: newPassword.value,
                    confirmationPassword: confirmationPassword.value
                })
                
                if (response.data.token) {
                    auth.setToken(response.data.token)
                }
                
                router.push('/dashboard')

            } catch (error) {
                isSubmitting.value = false
                if (error.response?.data?.errors) {
                    validationErrors.value = error.response.data.errors
                } else if (error.response?.data?.error) {
                    validationErrors.value = { general: error.response.data.error }
                } else {
                    validationErrors.value = { general: 'Unexpected error occurred' }
                }
            }
        }
        
        return {
            email,
            currentPassword,
            newPassword,
            confirmationPassword,
            validationErrors,
            isSubmitting,
            passwordErrors,
            confirmationPasswordError,
            hasErrors,
            changePassword
        }
    }
}
</script>
