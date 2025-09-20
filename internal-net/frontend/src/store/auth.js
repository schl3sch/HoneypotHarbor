import { reactive } from 'vue'
import axios from 'axios'

export const auth = reactive({
  token: localStorage.getItem('token') || '',
  role: null,

  isTokenExpired() {
    if (!this.token) return true 
    try {
      const decodedToken = JSON.parse(atob(this.token.split('.')[1]))
      const exp = decodedToken.exp * 1000 
      return Date.now() >= exp
    } catch (e) {
      return true
    }
  },

  async refreshRole() {
    if (!this.token || this.isTokenExpired()) {
      this.logout()
      return
    }
    try {
      const res = await axios.get('/api/v1/users/role', {
        headers: { Authorization: `Bearer ${this.token}` }
      })
      this.role = res.data.role
    } catch (e) {
      console.error(e)
      this.role = null
    }
  },

  setToken(token) {
    localStorage.setItem('token', token)
    this.token = token
    this.refreshRole()
  },

  logout(router) {
    localStorage.removeItem('token')
    this.token = ''
    this.role = null
    router.push('/login')
  }
})
