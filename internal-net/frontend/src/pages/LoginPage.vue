<template>
    <LayoutDiv>
        <div class="row justify-content-md-center mt-5">
            <div class="col-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Sign In</h5>
                        
                        <form>
                            <p v-if="Object.keys(validationErrors).length !== 0" class="text-center">
                                <small class="text-danger">Incorrect Email or Password</small>
                            </p>
                            
                            <!-- Email -->
                            <div class="mb-3">
                                <label for="email" class="form-label">Email address</label>
                                <input
                                v-model="email"
                                type="email"
                                class="form-control"
                                id="email"
                                name="email"
                                />
                            </div>
                            
                            <!-- Password -->
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input
                                v-model="password"
                                type="password"
                                class="form-control"
                                id="password"
                                name="password"
                                />
                            </div>
                            
                            <!-- Submit Button -->
                            <div class="d-grid gap-2">
                                <button
                                :disabled="isSubmitting || !email || !password"
                                @click="loginAction"
                                type="button"
                                class="btn btn-primary btn-block"
                                >
                                Login
                                </button>
                            
                                <!-- Link to Register Page -->
                                <p class="text-center">
                                    Don't have an account?
                                    <router-link to="/register">Register here</router-link>
                                </p>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </LayoutDiv>
</template>

<script>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import LayoutDiv from '../components/LayoutDiv.vue'
import { auth } from '../store/auth.js'

export default {
    name: 'LoginPage',
    components: { LayoutDiv },
    setup() {
        const router = useRouter()
        const email = ref('')
        const password = ref('')
        const validationErrors = ref({})
        const isSubmitting = ref(false)
        
        onMounted(() => {
            if (auth.token) router.push('/dashboard')
        })
        
        const loginAction = async () => {
            isSubmitting.value = true
            validationErrors.value = {}
            
            try {
                const response = await axios.post('/api/v1/auth/authenticate', {
                    email: email.value,
                    password: password.value
                })
                
                if (response.data.token) {
                    auth.setToken(response.data.token)
                    router.push('/dashboard')
                }
                
            } catch (error) {
                isSubmitting.value = false;
                // when admin logs in with default creds -> needs to change pass
                if (
                    error.response?.status === 403 &&
                    error.response?.data?.message === "Initial admin must change password."
                ) {
                    router.push({ path: '/change-password', query: { email: email.value } })
                    return
                }
                
                if (error.response?.data?.errors) {
                    validationErrors.value = error.response.data.errors
                } else if (error.response?.data?.error) {
                    validationErrors.value = error.response.data.error
                } else {
                    validationErrors.value = { general: 'Unexpected error occurred' }
                }
            }
        }
        
        return { email, password, validationErrors, isSubmitting, loginAction }
    }
}
</script>
