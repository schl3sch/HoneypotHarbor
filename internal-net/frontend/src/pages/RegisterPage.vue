<template>
    <LayoutDiv>
        <div class="row justify-content-md-center mt-5">
            <div class="col-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Register</h5>
                        
                        <form>
                            <p v-if="Object.keys(validationErrors).length !== 0" class="text-center">
                                <small class="text-danger">Something went wrong.</small>
                            </p>
                            
                            <!-- Firstname -->
                            <div class="mb-3">
                                <label for="firstname" class="form-label">First Name</label>
                                <input v-model="firstname" type="text" class="form-control" id="firstname" />
                                <small v-if="firstnameError" class="text-danger d-block">{{ firstnameError }}</small>
                            </div>
                            
                            <!-- Lastname -->
                            <div class="mb-3">
                                <label for="lastname" class="form-label">Last Name</label>
                                <input v-model="lastname" type="text" class="form-control" id="lastname" />
                                <small v-if="lastnameError" class="text-danger d-block">{{ lastnameError }}</small>
                            </div>
                            
                            <!-- Email -->
                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address</label>
                                <input v-model="email" type="email" class="form-control" id="email" />
                                <div v-for="(err, idx) in emailErrors" :key="idx">
                                    <small class="text-danger d-block">{{ err }}</small>
                                </div>
                            </div>
                            
                            <!-- Password -->
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input v-model="password" type="password" class="form-control" id="password" />
                                <div v-for="(err, idx) in passwordErrors" :key="idx">
                                    <small class="text-danger d-block">{{ err }}</small>
                                </div>
                            </div>
                            
                            <!-- Password Confirmation -->
                            <div class="mb-3">
                                <label for="confirm_password" class="form-label">Confirm Password</label>
                                <input v-model="confirmPassword" type="password" class="form-control" id="confirm_password" />
                                <small v-if="confirmPasswordError" class="text-danger d-block">{{ confirmPasswordError }}</small>
                            </div>
                            
                            
                            <div class="d-grid gap-2">
                                <!-- Submit Button -->
                                <button :disabled="isSubmitting || hasErrors" 
                                @click="registerAction" 
                                type="button" 
                                class="btn btn-primary btn-block"
                                >
                                Register Now
                                </button>
                                <!-- Link to Login -->
                                <p class="text-center">Have already an account? <router-link to="/">Login here</router-link></p>
                            </div>
                        </form>
                        
                    </div>
                </div>
            </div>
        </div>
    </LayoutDiv>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { auth } from '../store/auth.js'
import LayoutDiv from '../components/LayoutDiv.vue'

export default {
    name: 'RegisterPage',
    components: { LayoutDiv },
    setup() {
        const router = useRouter()
        const firstname = ref('')
        const lastname = ref('')
        const email = ref('')
        const password = ref('')
        const confirmPassword = ref('')
        const validationErrors = ref({})
        const isSubmitting = ref(false)
        
        const firstnameError = computed(() => {
            if (firstname.value && (firstname.value.length < 2 || firstname.value.length > 15))
            return 'Firstname needs to be between 2-15 characters'
            return ''
        })
        
        const lastnameError = computed(() => {
            if (lastname.value && (lastname.value.length < 2 || lastname.value.length > 15))
            return 'Lastname needs to be between 2-15 characters'
            return ''
        })
        
        // email validation
        const emailErrors = computed(() => {
            const errors = []
            const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
            if (email.value && !emailRegex.test(email.value)) errors.push('Please enter a valid email address.')
            return errors
        })
        
        // password validation
        const passwordErrors = computed(() => {
            const errors = []
            const pwd = password.value
            if (pwd && (pwd.length < 6 || pwd.length > 15)) errors.push('Password needs to be between 6-15 characters.')
            if (pwd && !/[a-z]/.test(pwd)) errors.push('Include at least one lowercase letter.')
            if (pwd && !/[A-Z]/.test(pwd)) errors.push('Include at least one uppercase letter.')
            if (pwd && !/\d/.test(pwd)) errors.push('Include at least one number.')
            if (pwd && !/[@.#$!%^&*.?]/.test(pwd)) errors.push('Include at least one special character.')
            return errors
        })
        
        const confirmPasswordError = computed(() => {
            if (confirmPassword.value && password.value !== confirmPassword.value)
            return 'Passwords do not match.'
            return ''
        })
        
        const hasErrors = computed(() => {
            return Boolean(
            firstnameError.value ||
            lastnameError.value ||
            emailErrors.value.length ||
            passwordErrors.value.length ||
            confirmPasswordError.value ||
            !confirmPassword.value
            )
        })
        
        onMounted(() => {
            if (auth.token) {
                router.push('/dashboard')
            }
        })
        
        // Handle form submission
        const registerAction = async () => {
            if (hasErrors.value) return
            isSubmitting.value = true
            validationErrors.value = {}
            
            try {
                const payload = {
                    firstname: firstname.value,
                    lastname: lastname.value,
                    email: email.value,
                    password: password.value,
                    passwordConfirmation: confirmPassword.value
                }
                const response = await axios.post('/api/v1/auth/register', payload)
                auth.setToken(response.data.token)
                router.push('/dashboard')
            } catch (error) {
                isSubmitting.value = false
                if (error.response?.data?.errors) validationErrors.value = error.response.data.errors
                else if (error.response?.data?.error) validationErrors.value = error.response.data.error
            }
        }
        
        return {
            firstname,
            lastname,
            email,
            password,
            confirmPassword,
            validationErrors,
            isSubmitting,
            firstnameError,
            lastnameError,
            emailErrors,
            passwordErrors,
            confirmPasswordError,
            hasErrors,
            registerAction
        }
    }
}
</script>
