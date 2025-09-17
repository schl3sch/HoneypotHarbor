<template>
    <layout-div>
        <div class="row justify-content-md-center mt-5">
            <div class="col-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Register</h5>
                        <form>
                            <div class="mb-3">
                                <p v-if="Object.keys(validationErrors).length != 0" class='text-center '><small class='text-danger'>Something went Wrong.</small></p>
                                <label htmlFor="firstname" class="form-label">First Name</label>
                                <input 
                                type="text"
                                class="form-control"
                                id="firstname"
                                name="firstname"
                                v-model="firstname"
                                />
                                <div v-if="firstnameError">
                                    <small class="text-danger d-block">{{ firstnameError }}</small>
                                </div>    
                            </div>
                            
                            <div class="mb-3">
                                <label htmlFor="lastname" class="form-label">Last Name</label>
                                <input 
                                type="text"
                                class="form-control"
                                id="lastname"
                                name="lastname"
                                v-model="lastname"
                                />
                                <div v-if="lastnameError">
                                    <small class="text-danger d-block">{{ lastnameError }}</small>
                                </div> 
                            </div>
                            
                            <div class="mb-3">
                                <label htmlFor="email" class="form-label">Email Address</label>
                                <input 
                                type="email"
                                class="form-control"
                                id="email"
                                name="email"
                                v-model="email"
                                />
                                <div v-if="emailErrors.length">
                                    <div v-for="(err, idx) in emailErrors" :key="idx">
                                        <small class="text-danger d-block">{{ err }}</small>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label htmlFor="password" class="form-label">Password</label>
                                <input 
                                type="password"
                                class="form-control"
                                id="password"
                                name="password"
                                v-model="password"
                                />
                                <div v-if="passwordErrors.length">
                                    <div v-for="(err, idx) in passwordErrors" :key="idx">
                                        <small class="text-danger d-block">{{ err }}</small>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label htmlFor="confirm_password" class="form-label">Confirm Password</label>
                                <input 
                                type="password"
                                class="form-control"
                                id="confirm_password"
                                name="confirm_password"
                                v-model="confirmPassword"
                                />
                                <div v-if="confirmPasswordError">
                                    <small class="text-danger d-block">{{ confirmPasswordError }}</small>
                                </div>
                            </div>
                            
                            <div class="d-grid gap-2">
                                <button 
                                :disabled="isSubmitting || hasErrors"
                                @click="registerAction"
                                type="button"
                                class="btn btn-primary btn-block">Register Now
                            </button>
                            <p class="text-center">Have already an account <router-link to="/">Login here</router-link></p>
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
    name: 'RegisterPage',
    components: { LayoutDiv },
    data() {
        return {
            firstname:'',
            lastname:'',
            email:'',
            password:'',
            confirmPassword:'',
            validationErrors:{},
            isSubmitting:false,
        };
    },
    created() {
        if(localStorage.getItem('token')) {
            this.$router.push('/dashboard');
        }
    },
    computed: {
        
        firstnameError() {
            if (this.firstname && this.firstname.length < 2 || this.firstname.length > 15) {
                return 'Firstname needs to be between 2-15 characters';
            }
            return '';
        },

        lastnameError() {
            if (this.lastname && this.lastname.length < 2 || this.lastname.length > 15) {
                return 'Lastname needs to be between 2-15 characters';
            }
            return '';
        },

        emailErrors() {
            const errors = [];
            const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (this.email && !emailRegex.test(this.email)) {
                errors.push('Please enter a valid email address.');
            }
            return errors;
        },
        passwordErrors() {
            const errors = [];
            const pwd = this.password;
            if (pwd && pwd.length < 6 || pwd.length > 15) errors.push('Password needs to be between 6-15 characters.');
            if (pwd && !/[a-z]/.test(pwd)) errors.push('Include at least one lowercase letter.');
            if (pwd && !/[A-Z]/.test(pwd)) errors.push('Include at least one uppercase letter.');
            if (pwd && !/\d/.test(pwd)) errors.push('Include at least one number.');
            if (pwd && !/[@.#$!%^&*.?]/.test(pwd)) errors.push('Include at least one special character.');
            return errors;
        },
        confirmPasswordError() {
            if (this.confirmPassword && this.password !== this.confirmPassword) {
                return 'Passwords do not match.';
            }
            return '';
            
        },
        hasErrors() {
            return Boolean(
                this.emailErrors.length ||
                this.passwordErrors.length ||
                this.confirmPasswordError ||
                this.firstnameError ||
                !this.confirmPassword ||
                this.lastnameError
            );
        }
    },
    methods: {
        registerAction() {
            this.validationErrors = {};
            
            if (this.hasErrors) return;
            
            this.isSubmitting = true;
            let payload = {
                firstname:this.firstname,
                lastname:this.lastname,
                email: this.email,
                password: this.password,
                passwordConfirmation: this.confirmPassword
            };
            
            axios.post('/api/v1/auth/register', payload)
            .then(response => {
                localStorage.setItem('token', response.data.token);
                this.$router.push('/dashboard');
            })
            .catch(error => {
                this.isSubmitting = false
                if (error.response.data.errors != undefined) {
                    this.validationErrors = error.response.data.errors
                }
                if (error.response.data.error != undefined) {
                    this.validationErrors = error.response.data.error
                }
                return error
            });
        }
    },
};
</script>
