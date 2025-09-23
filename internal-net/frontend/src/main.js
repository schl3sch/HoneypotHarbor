import { createApp } from 'vue';
import App from './App.vue';
import axios from 'axios';
import router from './router'
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import 'leaflet/dist/leaflet.css';


axios.defaults.baseURL = ""
axios.interceptors.request.use(function (config) {
	config.headers['X-Api-Key'] = import.meta.env.VITE_API_KEY;
	return config;
});

createApp(App)
  .use(router)
  .mount('#app')
