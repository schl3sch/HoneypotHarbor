<template>
    <layout-div>
        <div class="row justify-content-md-center mt-5">
            <div class="col-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Sign In</h5>
                        <form>
                            <p v-if="Object.keys(validationErrors).length != 0" class='text-center '><small class='text-danger'>Incorrect Email or Password</small></p>
                            <div class="mb-3">
                                <label 
                                htmlFor="email"
                                class="form-label">
                                Email address   
                            </label>
                            <input 
                            v-model="email"
                            type="email"
                            class="form-control"
                            id="email"
                            name="email"
                            />
                        </div>
                        <div class="mb-3">
                            <label 
                            htmlFor="password"
                            class="form-label">Password
                        </label>
                        <input 
                        v-model="password"
                        type="password"
                        class="form-control"
                        id="password"
                        name="password"
                        />
                    </div>
                    <div class="d-grid gap-2">
                        <button 
                        :disabled="isSubmitting || password.length < 1 || email.length < 1" 
                        @click="loginAction()"
                        type="button"
                        class="btn btn-primary btn-block">Login</button>
                        <p class="text-center">Don't have account? 
                            <router-link to="/register">Register here </router-link>
                        </p>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

</layout-div>
</template>

<script>
import axios from 'axios';
import LayoutDiv from '../LayoutDiv.vue';

export default {
    name: 'LoginPage',
    components: {
        LayoutDiv,
    },
    data() {
        return {
            email:'',
            password:'',
            validationErrors:{},
            isSubmitting:false,
        };
    },
    created() {
        if(localStorage.getItem('token') != "" && localStorage.getItem('token') != null){
            this.$router.push('/dashboard')
        }
    },
    methods: {
        loginAction() {
            this.isSubmitting = true;
            let payload = {
                email: this.email,
                password: this.password,
            };
            axios.post('/api/v1/auth/authenticate', payload)
            .then(response => {
                if (response.data.token) {
                    localStorage.setItem('token', response.data.token);
                    this.$router.push('/dashboard');
                }
            })
            .catch(error => {
                this.isSubmitting = false;
                
                if (error.response?.status === 403 && error.response?.data?.message === "Initial admin must change password.") {
                    this.$router.push({ path: '/change-password', query: { email: this.email } });
                    return;
                }
                
                if (error.response?.data?.errors) {
                    this.validationErrors = error.response.data.errors;
                } else if (error.response?.data?.error) {
                    this.validationErrors = error.response.data.error;
                } else {
                    this.validationErrors = { general: 'Unexpected error occurred' };
                }
            });
        }
    }
    
};
</script>