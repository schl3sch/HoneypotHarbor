<template>
	<div class="d-flex">
		<!-- Sidebar -->
		<side-nav :show="showSidebar" @close="showSidebar = false" />
		
		<div class="flex-grow-1">
			<!-- Topbar -->
			<top-bar @toggle-sidebar="toggleSidebar" @logout="logoutAction" />
			
			<!-- Page Content -->
			<div class="container-fluid mt-3">
				<slot></slot>
			</div>
		</div>
	</div>
</template>

<script>
import TopBar from './TopBar.vue'
import SideNav from './SideNav.vue'
import axios from 'axios'

export default {
	name: 'Layout',
	components: { TopBar, SideNav },
	data() {
		return {
			showSidebar: false,
		}
	},
	created() {
	},
	methods: {
		toggleSidebar() {
			this.showSidebar = !this.showSidebar
		},
		logoutAction() {
			axios.post('/api/v1/auth/logout',{}, { headers:{Authorization: 'Bearer ' + localStorage.getItem('token')}})
			.then((r) => {
				localStorage.setItem('token', "")
				this.$router.push('/')
				return r
			})
			.catch((e) => {
				return e
			});
		}
	}
}
</script>
