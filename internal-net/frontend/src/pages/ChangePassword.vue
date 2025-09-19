<template>
    <layout-div>
        <div class="row justify-content-md-center mt-5">
            <div class="col-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Change Password</h5>
                        <form @submit.prevent="changePassword">
                            <p v-if="Object.keys(validationErrors).length != 0" class='text-center '><small class='text-danger'>Something went Wrong.</small></p>
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
                            
                            <div class="mb-3">
                                <label htmlFor="newPassword" class="form-label">New Password</label>
                                <input 
                                type="password"
                                class="form-control"
                                id="newPassword"
                                name="newPassword"
                                v-model="newPassword"
                                />
                                <div v-if="passwordErrors.length">
                                    <div v-for="(err, idx) in passwordErrors" :key="idx">
                                        <small class="text-danger d-block">{{ err }}</small>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label htmlFor="confirmationPassword" class="form-label">Confirm Password</label>
                                <input 
                                type="password"
                                class="form-control"
                                id="confirmationPassword"
                                name="confirmationPassword"
                                v-model="confirmationPassword"
                                />
                                <div v-if="confirmationPasswordError">
                                    <small class="text-danger d-block">{{confirmationPasswordError }}</small>
                                </div>
                            </div>
                            
                            <div class="d-grid gap-2">
                                <button 
                                :disabled="isSubmitting || newPassword.length < 1 || confirmationPassword.length < 1" 
                                type="submit"
                                class="btn btn-primary btn-block">
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
import axios from 'axios';
import LayoutDiv from '../components/LayoutDiv.vue';

export default {
    name: 'ChangePasswordPage',
    components: { LayoutDiv },
    data() {
        return {
            currentPassword: '',
            newPassword: '',
            confirmationPassword: '',
            validationErrors: '',
            isSubmitting: false,
        };
    },
    created() {
        if(localStorage.getItem('token')) {
            this.$router.push('/dashboard');
        }
        if(this.$route.query.email) {
            this.email = this.$route.query.email;
        } else {
            this.$router.push('/');
        }
        axios.get('/api/v1/auth/check-change-password', {
            params: { email: this.$route.query.email }
        })
        .then(response => {
           
        })
        .catch(error => {
            this.$router.push('/');
        });
    },
    computed: {
        passwordErrors() {
            const errors = [];
            const pwd = this.newPassword;
            if (pwd && pwd.length < 6 || pwd.length > 15) errors.push('Password needs to be between 6-15 characters.');
            if (pwd && !/[a-z]/.test(pwd)) errors.push('Include at least one lowercase letter.');
            if (pwd && !/[A-Z]/.test(pwd)) errors.push('Include at least one uppercase letter.');
            if (pwd && !/\d/.test(pwd)) errors.push('Include at least one number.');
            if (pwd && !/[@.#$!%^&*.?]/.test(pwd)) errors.push('Include at least one special character.');
            return errors;
        },
        confirmationPasswordError() {
            if (this.confirmationPassword && this.newPassword !== this.confirmationPassword) {
                return 'Passwords do not match.';
            }
            return '';
            
        },
        hasErrors() {
            return Boolean(
            this.passwordErrors.length ||
            this.confirmationPasswordError ||
            !this.confirmationPassword
            );
        }
    },
    methods: {
        changePassword() {
            this.validationErrors = {};
            
            if (this.newPassword !== this.confirmationPassword) {
                this.validationErrors = { confirmationPassword: "New password and confirmation do not match." };
                return;
            }
            
            this.isSubmitting = true;
            let payload = {
                email: this.email,
                currentPassword: this.currentPassword,
                newPassword: this.newPassword,
                confirmationPassword: this.confirmationPassword
            };
            
            axios.post('/api/v1/auth/change/password', payload)
            .then(response => {
                if (response.data.token) {
                    localStorage.setItem('token', response.data.token);
                }
                this.$router.push('/dashboard');
            })
            .catch(error => {
                this.isSubmitting = false;
                if (error.response.data.errors != undefined) {
                    this.validationErrors = error.response.data.errors;
                }
                if (error.response.data.error != undefined) {
                    this.validationErrors = error.response.data.error;
                }
                return error;
            });
        }
    }
};
</script>
