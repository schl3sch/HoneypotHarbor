import { createRouter, createWebHistory } from 'vue-router'
import { auth } from '../store/auth.js'
import LoginPage from '../pages/LoginPage.vue'
import RegisterPage from '../pages/RegisterPage.vue'
import DashboardPage from '../pages/DashboardPage.vue'
import ChangePasswordPage from '../pages/ChangePassword.vue'
import HoneypotsPage from '../pages/HoneypotsPage.vue'
import AlertsPage from '../pages/AlertsPage.vue'
import AdministrateRolesPage from '../pages/AdministrateRolesPage.vue'
import SettingsPage from '../pages/SettingsPage.vue'

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/login', component: LoginPage },
  { path: '/register', component: RegisterPage },
  { path: '/dashboard', component: DashboardPage },
  { path: '/change-password', component: ChangePasswordPage },
  { 
    path: '/honeypots', 
    component: HoneypotsPage,
    meta: { requiresRoles: ['ROLE_ANALYST', 'ROLE_ADMIN'] }
  },
  { 
    path: '/alerts', 
    component: AlertsPage,
    meta: { requiresRoles: ['ROLE_ANALYST', 'ROLE_ADMIN'] }
  },
  { path: '/roles', component: AdministrateRolesPage, meta: { requiresAdmin: true } },
  { path: '/settings', component: SettingsPage },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {

  // route user to login page when there is not token + user not already on register/login page
  if (!auth.token && !['/login', '/register'].includes(to.path)) {
    return next('/login')
  }

  // check if the auth Token is expired if yes than logout (remove the token) 
  if (auth.token && auth.isTokenExpired()) {
    auth.logout(router)
    return next('/login')
  }

  // update Role if there is a token but not a role
  if (auth.token && !auth.role) {
    await auth.refreshRole()
  }

  next()
})

export default router
