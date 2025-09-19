<template>
  <layout>
    <h2>Administration</h2>

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
          <td>{{ user.role }}</td>
          <td>
            <div class="dropdown">
              <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                ☰
              </button>
              <ul class="dropdown-menu">
                <li v-for="roleOption in roles" :key="roleOption">
                  <a class="dropdown-item" href="#" @click.prevent="confirmRoleChange(user, roleOption)">
                    {{ roleOption }}
                  </a>
                </li>
              </ul>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </layout>
</template>

<script>
import axios from 'axios';
import Layout from '../components/Layout.vue';
export default {
    name: 'RolesPage',
    components: { Layout },
  data() {
    return {
      users: [],
      roles: ['ROLE_USER', 'ROLE_ANALYST', 'ROLE_ADMIN'],
    };
  },
  created() {
    const token = localStorage.getItem('token');
    if (!token) {
      this.$router.push('/');
    } else {
      this.checkIfAdmin(token);
    }
  },
  methods: {
    checkIfAdmin(token) {
      axios.get('/api/v1/users/role', {
        headers: { Authorization: `Bearer ${token}` }
      })
      .then(response => {
        if (response.data.role !== 'ROLE_ADMIN') {
          this.$router.push('/dashboard');
        } else {
          this.loadUsers(token);
        }
      })
      .catch(error => {
        console.error('Failed to check role', error);
        this.$router.push('/dashboard');
      });
    },
    loadUsers(token) {
      axios.get('/api/v1/admin/users', {
        headers: { Authorization: `Bearer ${token}` }
      })
      .then(response => {
        this.users = response.data;
      })
      .catch(error => console.error('Failed to load users', error));
    },
    confirmRoleChange(user, newRole) {
      if (confirm(`Change role of ${user.firstname} ${user.lastname} to ${newRole}?`)) {
        this.changeUserRole(user, newRole);
      }
    },
    changeUserRole(user, newRole) {
      const token = localStorage.getItem('token');
      axios.put(`/api/v1/admin/users/${user.id}/role?role=${newRole}`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      .then(response => {
        user.role = response.data.role;
      })
      .catch(error => console.error('Failed to change role', error));
    }
  }
}
</script>
