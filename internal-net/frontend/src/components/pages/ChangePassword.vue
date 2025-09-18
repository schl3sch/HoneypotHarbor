<template>
  <layout-div>
    <div class="row justify-content-md-center mt-5">
      <div class="col-4">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title mb-4">Change Password</h5>
            <form @submit.prevent="changePassword">
              
              <div class="mb-3">
                <label for="oldPassword" class="form-label">Old Password</label>
                <input 
                  v-model="oldPassword"
                  type="password"
                  class="form-control"
                  id="oldPassword"
                  name="oldPassword"
                />
              </div>

              <div class="mb-3">
                <label for="newPassword" class="form-label">New Password</label>
                <input 
                  v-model="newPassword"
                  type="password"
                  class="form-control"
                  id="newPassword"
                  name="newPassword"
                />
              </div>

              <div class="mb-3">
                <label for="confirmPassword" class="form-label">Confirm Password</label>
                <input 
                  v-model="confirmPassword"
                  type="password"
                  class="form-control"
                  id="confirmPassword"
                  name="confirmPassword"
                />
              </div>

              <p v-if="validationErrors" class="text-danger text-center"><small>{{ validationErrors }}</small></p>

              <div class="d-grid gap-2">
                <button 
                  :disabled="isSubmitting || newPassword.length < 1 || confirmPassword.length < 1" 
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
import LayoutDiv from '../LayoutDiv.vue';

export default {
  name: 'ChangePasswordPage',
  components: { LayoutDiv },
  data() {
    return {
      oldPassword: '',
      newPassword: '',
      confirmPassword: '',
      validationErrors: '',
      isSubmitting: false,
      email: '',
    };
  },
  created() {
    if(this.$route.query.email) {
      this.email = this.$route.query.email;
    }
  },
  methods: {
    async changePassword() {
      this.validationErrors = '';
      
      if (this.newPassword !== this.confirmPassword) {
        this.validationErrors = "New password and confirmation do not match.";
        return;
      }

      this.isSubmitting = true;
      try {
        await axios.post('/api/v1/auth/change/password', {
          email: this.email,
          currentPassword: this.oldPassword,
          newPassword: this.newPassword,
          confirmationPassword: this.confirmPassword
        });

        alert("Password changed successfully!");
        this.$router.push('/login');
      } catch (error) {
        this.isSubmitting = false;
        if(error.response && error.response.data.message) {
          this.validationErrors = error.response.data.message;
        } else {
          this.validationErrors = "An error occurred. Please try again.";
        }
      }
    }
  }
};
</script>
