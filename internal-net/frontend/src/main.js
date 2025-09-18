import { createApp } from 'vue';
import App from './App.vue';
import axios from 'axios';
import 'bootstrap/dist/css/bootstrap.css';
import { createRouter, createWebHistory } from 'vue-router';
import LoginPage from './components/pages/LoginPage.vue';
import RegisterPage from './components/pages/RegisterPage.vue';
import DashboardPage from './components/pages/DashboardPage.vue';
import ChangePasswordPage from './components/pages/ChangePassword.vue';

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
	],
});

createApp(App).use(router).mount('#app');
