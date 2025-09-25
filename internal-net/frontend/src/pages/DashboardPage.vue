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
                                            <tr v-for="(user,i) in sortedUsernames" :key="'user'+i">
                                                <td>{{ i+1 }}</td>
                                                <td>{{ user.username }}</td>
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
                                            <tr v-for="(pw,i) in sortedPasswords" :key="'pw'+i">
                                                <td>{{ i+1 }}</td>
                                                <td>{{ pw.password }}</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Attacks by Time -->
                    <div class="card flex-grow-1 d-flex flex-column">
                        <div class="card-header text-center">Attacks by Time</div>
                        <div class="card-body d-flex justify-content-center" style="height:150px;">
                            <canvas id="attacksChart"></canvas>
                        </div>
                    </div>

                </div>
                
                <!-- Right Column -->
                <div class="col-lg-7 d-flex flex-column gap-3">
                    <div class="d-flex flex-column flex-grow-1 gap-3">
                        <!-- Map -->
                        <div class="card flex-grow-1 d-flex flex-column">
                        <div class="card-header text-center">Map</div>
                        <div class="card-body p-0 d-flex flex-grow-1">
                            <div id="attackMap" class="flex-grow-1"></div>
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
import { ref, onMounted, watch, computed } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import { auth } from '../store/auth.js'
import { Chart, registerables } from 'chart.js'
import L from 'leaflet'
import cities from 'cities.json';
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png'
import markerIcon from 'leaflet/dist/images/marker-icon.png'
import markerShadow from 'leaflet/dist/images/marker-shadow.png'

delete L.Icon.Default.prototype._getIconUrl

L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow
})


// registrate all charts -> out of box possibility for extensions
Chart.register(...registerables)

export default {
    name: 'DashboardPage',
    components: { Layout },
    setup() {
        const router = useRouter()
        
        const topUsernames = ref([])
        const topPasswords = ref([])
        const attackCoordinates = ref([])
        const totalAttacks = ref(0)
        const todayAttacks = ref(0)
        const attacksByTime = ref([])
        let chartInstance = null
        let map, markersCluster
        
        // Helper function for safe fetching
        async function safeFetch(url, fallback = null) {
            try {
                const res = await axios.get(url, {
                headers: {
                    Authorization: `Bearer ${auth.token}`
                }
                })
                return res.data
            } catch (err) {
                console.error(`Error fetching ${url}:`, err)
                return fallback
            }
        }

        const sortedUsernames = computed(() =>
            [...topUsernames.value].sort((a, b) => b.count - a.count)
        )

        const sortedPasswords = computed(() =>
            [...topPasswords.value].sort((a, b) => b.count - a.count)
        )

                    
        async function fetchTopUsernames() {
            topUsernames.value = await safeFetch(
                    '/api/v1/analytics/statistics/top-usernames',
                    [])
        }
        
        async function fetchTopPasswords() {
            topPasswords.value = await safeFetch(
                '/api/v1/analytics/statistics/top-passwords', 
                [])
        }
        
        async function fetchTotalAttacks() {
            const res = await safeFetch(
                '/api/v1/analytics/statistics/attacks/all', 
                { count: 0 })
            totalAttacks.value = res.count
        }
        
        async function fetchTodayAttacks() {
            const res = await safeFetch(
                '/api/v1/analytics/statistics/attacks/today', 
                { count: 0 })
            todayAttacks.value = res.count
        }

        // group logs for better visualization in chart
        function groupLogsByFiveMinutes(logs) {
            const intervals = {}

            logs.forEach(log => {
                const date = new Date(log.timestamp)

                // Calculate the 5-minute bucket
                const minutes = Math.floor(date.getMinutes() / 5) * 5
                const intervalKey = `${date.getHours().toString().padStart(2,'0')}:${minutes.toString().padStart(2,'0')}`
                if (!intervals[intervalKey]) intervals[intervalKey] = 0
                intervals[intervalKey] += 1
            })

            // Convert intervals to an array sorted by time
            const sortedIntervals = Object.keys(intervals)
                .sort((a, b) => {
                    const [ha, ma] = a.split(':').map(Number)
                    const [hb, mb] = b.split(':').map(Number)
                    return ha !== hb ? ha - hb : ma - mb
                })
                .map(key => ({ time: key, count: intervals[key] }))

            return sortedIntervals
}
        
        async function fetchAttacksByTime() {
            const rawLogs = await safeFetch('/api/v1/analytics/statistics/attacks/time', [])
            // Group logs into 5-minute intervals
            attacksByTime.value = groupLogsByFiveMinutes(rawLogs)

            if (chartInstance) {
                chartInstance.data.labels = attacksByTime.value.map(a => a.time)
                chartInstance.data.datasets[0].data = attacksByTime.value.map(a => a.count)
                chartInstance.update()
            }
        }

        async function fetchAttackCoordinates() {
            const cities = await safeFetch(
                '/api/v1/analytics/statistics/location', 
                [])
            const results = []
            for (const cityObj of cities) {
                const coords = await cityToCoordinates(cityObj.city)
                if (coords) {
                    results.push({ ...coords, count: cityObj.count })
                }
            }
            attackCoordinates.value = results
        }

        function cityToCoordinates(city) {
            const found = cities.find(c => c.name.toLowerCase() === city.toLowerCase());
            if (!found) {
                console.warn(`City not found in local cities.json: ${city}`);
                return null;
            }
            return { lat: parseFloat(found.lat), lng: parseFloat(found.lng) };
        }

        
        onMounted(async () => {
            if (!localStorage.getItem('token')) {
                router.push('/')
                return
            }
            
            // initialize chart
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
            
            // initilize map 
            map = L.map('attackMap').setView([51.1657, 10.4515], 3)
            L.tileLayer(
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
                { attribution: '&copy; OpenStreetMap contributors' }
            ).addTo(map)
            markersCluster = L.markerClusterGroup()
            map.addLayer(markersCluster)

            setTimeout(() => {
                map.invalidateSize();
            }, 100);
            
            await Promise.all([
                fetchTopUsernames(),
                fetchTopPasswords(),
                fetchAttackCoordinates(),
                fetchTotalAttacks(),
                fetchTodayAttacks(),
                fetchAttacksByTime()
            ])

            // Realtime Update (Polling)
            setInterval(() => {
                fetchTopUsernames()
                fetchTopPasswords()
                fetchAttackCoordinates()
                fetchTotalAttacks()
                fetchTodayAttacks()
                fetchAttacksByTime()
            }, 3000)
        })
        
        // Watch attackCoordinates update cluster
        watch(attackCoordinates, (newData) => {
            if (!markersCluster) return
            markersCluster.clearLayers()
            newData.forEach((attack) => {
                const marker = L.marker([attack.lat, attack.lng])
                marker.bindPopup(`<strong>Attacks:</strong> ${attack.count}<br>Coordinates: ${attack.lat}, ${attack.lng}`)
                markersCluster.addLayer(marker)
            })
        })
        
        return { 
            sortedUsernames,
            sortedPasswords,
            attackCoordinates, 
            totalAttacks, 
            todayAttacks, 
            attacksByTime 
        }
    }
}
</script>
