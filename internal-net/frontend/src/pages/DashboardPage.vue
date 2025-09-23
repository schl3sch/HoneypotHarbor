<template>
    <Layout>
        <div class="container-fluid px-3 py-3"> 
            <div class="row g-3">
                
                <!-- Left Column -->
                <div class="col-lg-5 d-flex flex-column gap-3"> 
                    <!-- Top Usernames + Top Passwords Row -->
                    <div class="row g-3 flex-grow-1">
                        <div class="col-6">
                            <div class="card h-100">
                                <div class="card-header text-center">Top 10 Usernames</div>
                                <div class="card-body p-2">
                                    <table class="table table-sm table-striped mb-0">
                                        <thead>
                                            <tr><th>#</th><th>Username</th></tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="(user,i) in topUsernames" :key="'user'+i">
                                                <td>{{ i+1 }}</td>
                                                <td>{{ user }}</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-6">
                            <div class="card h-100">
                                <div class="card-header text-center">Top 10 Passwords</div>
                                <div class="card-body p-2">
                                    <table class="table table-sm table-striped mb-0">
                                        <thead>
                                            <tr><th>#</th><th>Password</th></tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="(pw,i) in topPasswords" :key="'pw'+i">
                                                <td>{{ i+1 }}</td>
                                                <td>{{ pw }}</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Attacks by Time -->
                    <div class="card flex-grow-1 d-flex flex-column justify-content-center">
                        <div class="card-header text-center">Attacks by Time</div>
                        <div class="card-body d-flex align-items-center justify-content-center">
                            <canvas id="attacksChart" style="width:100%;height:100px;"></canvas>
                        </div>
                    </div>
                </div>
                
                <!-- Right Column -->
                <div class="col-lg-7 d-flex flex-column gap-3">
                    <div class="d-flex flex-column flex-grow-1 gap-3">
                        <!-- Map -->
                        <div class="card flex-grow-1 d-flex flex-column justify-content-center">
                            <div class="card-header text-center">Map</div>
                            <div class="card-body p-0">
                                <l-map
                                style="height: 400px; width: 100%;"
                                :zoom="2"
                                :center="[20, 0]"
                                >
                                    <!-- Map BG -->
                                    <l-tile-layer
                                        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                        attribution="&copy; OpenStreetMap contributors"
                                    />

                                    <!-- Attack Marker -->
                                    <l-marker
                                        v-for="(attack, index) in attackCoordinates"
                                        :key="index"
                                        :lat-lng="[attack.lat, attack.lng]"
                                    >
                                        <l-popup>
                                            <div>
                                                <strong>Attacks:</strong> {{ attack.count }}
                                                <br>
                                                Coordinates: {{ attack.lat }}, {{ attack.lng }}
                                            </div>
                                        </l-popup>
                                    </l-marker>
                                </l-map>
                            </div>
                        </div>
                        
                        <!-- Stats Row -->
                        <div class="row g-3">
                            <div class="col-6">
                                <div class="card text-center p-3">Attacks Today: {{ todayAttacks }}</div>
                            </div>
                            <div class="col-6">
                                <div class="card text-center p-3">Total Attacks: {{ totalAttacks }}</div>
                            </div>
                        </div>
                    </div>
                </div>
                
            </div>
        </div>
    </Layout>
</template>



<script>
import Layout from '../components/Layout.vue'
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Chart, registerables } from 'chart.js'
import { LMap, LTileLayer, LMarker, LPopup } from "@vue-leaflet/vue-leaflet"

Chart.register(...registerables)

export default {
    name: 'DashboardPage',
    components: { Layout, LMap, LTileLayer, LMarker, LPopup },
    setup() {
        const router = useRouter()
    
        const topUsernames = ref([])
        const topPasswords = ref([])
        const attackCoordinates = ref([])
        const totalAttacks = ref(0)
        const todayAttacks = ref(0)
        const attacksByTime = ref([])
        let chartInstance = null
        
        // Helper function for safe fetching
        async function safeFetch(url, fallback = null) {
            try {
                const res = await fetch(url)
                if (!res.ok) throw new Error(`HTTP error! Status: ${res.status}`)
                return await res.json()
            } catch (err) {
                console.error(`Error fetching ${url}:`, err)
                return fallback
            }
        }

        async function fetchTopUsernames() {
            topUsernames.value = await safeFetch(
                '/api/v1/analytics/statistics/top-usernames',
                [] 
            )
        }

        async function fetchTopPasswords() {
            topPasswords.value = await safeFetch(
                '/api/v1/analytics/statistics/top-passwords',
                []
            )
        }

        async function fetchAttackCoordinates() {
            attackCoordinates.value = await safeFetch(
                '/api/v1/analytics/statistics/location',
                []
            )
        }

        async function fetchTotalAttacks() {
            totalAttacks.value = await safeFetch(
                '/api/v1/analytics/statistics/attacks/all',
                { count: 0 }
            )
        }

        async function fetchTodayAttacks() {
            todayAttacks.value = await safeFetch(
                '/api/v1/analytics/statistics/attacks/today',
                { count: 0 }
            )
        }
        
        async function fetchAttacksByTime() {
            attacksByTime.value = await safeFetch(
                '/api/v1/analytics/statistics/attacks/time',
                []
            )

            if (chartInstance) {
                chartInstance.data.labels = attacksByTime.value.map(a => a.time)
                chartInstance.data.datasets[0].data = attacksByTime.value.map(a => a.count)
                chartInstance.update()
            }
        }
        
        onMounted(async () => {
            if (!localStorage.getItem('token')) {
                router.push('/')
                return
            }
            
            // initialize Chart 
            const ctx = document.getElementById('attacksChart').getContext('2d')
            chartInstance = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: [],
                    datasets: [{
                        label: 'Attacks per Time',
                        data: [],
                        backgroundColor: 'rgba(54, 162, 235, 0.6)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: { y: { beginAtZero: true } },
                    plugins: { legend: { display: false } }
                }
            })
            
            // Initialize Data
            await Promise.all([
                fetchTopUsernames(),
                fetchTopPasswords(),
                fetchAttackCoordinates(),
                fetchTotalAttacks(),
                fetchTodayAttacks(),
                fetchAttacksByTime()
            ])

            attackCoordinates.value = [
                { lat: 52.52, lng: 13.405, count: 5 },   // Berlin
                { lat: 40.7128, lng: -74.006, count: 12 }, // New York
                { lat: 35.6895, lng: 139.6917, count: 7 }  // Tokyo
            ]
            
            // Polling:
            setInterval(() => {
                fetchTopUsernames()
                fetchTopPasswords()
                fetchAttackCoordinates()
                fetchTotalAttacks()
                fetchTodayAttacks()
                fetchAttacksByTime()
            }, 5000)
        })
        
        return {
            topUsernames,
            topPasswords,
            attackCoordinates,
            totalAttacks,
            todayAttacks,
            attacksByTime
        }
    }
}
</script>