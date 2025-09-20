import { createApp } from 'vue';
import App from './App.vue';
import axios from 'axios';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import { createRouter, createWebHistory } from 'vue-router';
import LoginPage from './pages/LoginPage.vue';
import RegisterPage from './pages/RegisterPage.vue';
import DashboardPage from './pages/DashboardPage.vue';
import ChangePasswordPage from './pages/ChangePassword.vue';
import HoneypotsPage from './pages/HoneypotsPage.vue'
import AlertsPage from './pages/AlertsPage.vue'
import AdministrateRolesPage from './pages/AdministrateRolesPage.vue'
import SettingsPage from './pages/SettingsPage.vue'


axios.defaults.baseURL = ""
axios.interceptors.request.use(function (config) {
	config.headers['X-Api-Key'] = import.meta.env.VITE_API_KEY;
	return config;
});


const router = createRouter({
	history: createWebHistory(),
	routes: [
		{ path: '/', component: LoginPage },
		{ path: '/register', component: RegisterPage },
		{ path: '/dashboard', component: DashboardPage },
		{ path: '/change-password', component: ChangePasswordPage },
		{ path: '/honeypots', component: HoneypotsPage },
    	{ path: '/alerts', component: AlertsPage },
    	{ path: '/roles', component: AdministrateRolesPage },
    	{ path: '/settings', component: SettingsPage },
	],
});

createApp(App).use(router).mount('#app');
