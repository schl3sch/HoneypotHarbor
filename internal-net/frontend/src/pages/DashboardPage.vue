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
                                <div id="attackMap" style="height: 400px; width: 100%;"></div>
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
import { ref, onMounted, watch } from 'vue'
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
        
        async function fetchAttacksByTime() {
            attacksByTime.value = await safeFetch(
                '/api/v1/analytics/statistics/attacks/time', 
                [])
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
        

        const testCities = [
                { city: 'Berlin', count: 5 },
                { city: 'Paris', count: 3 },
                { city: 'London', count: 8 },
                { city: 'New York', count: 12 },
                { city: 'Tokyo', count: 7 },
                { city: 'Moscow', count: 10 },
                { city: 'Sydney', count: 2 },
                { city: 'Los Angeles', count: 4 },
                { city: 'San Francisco', count: 5 },
                { city: 'Rome', count: 3 },
                { city: 'Mexico City', count: 6 },
                { city: 'Beijing', count: 7 },
                { city: 'Singapore', count: 5 },
                { city: 'São Paulo', count: 4 },
                { city: 'Toronto', count: 3 },
                { city: 'Stockholm', count: 2 },
                { city: 'Athens', count: 3 },
                { city: 'Frankfurt', count: 5 },
                { city: 'Milan', count: 4 },
                { city: 'Shanghai', count: 6 },
                { city: 'Delhi', count: 7 },
                { city: 'Florence', count: 2 },
                { city: 'Amsterdam', count: 3 },
                { city: 'Edinburgh', count: 2 },
                { city: 'Washington D.C.', count: 5 },
                { city: 'Istanbul', count: 6 },
                { city: 'Bangkok', count: 4 },
                { city: 'Johannesburg', count: 3 },
                { city: 'Seoul', count: 7 },
                { city: 'Cairo', count: 4 },
                { city: 'Helsinki', count: 2 },
                { city: 'Lisbon', count: 3 },
                { city: 'Dubai', count: 5 },
                { city: 'Buenos Aires', count: 4 },
                { city: 'Kuala Lumpur', count: 3 },
                { city: 'Hong Kong', count: 6 },
                { city: 'Barcelona', count: 4 },
                { city: 'Oslo', count: 2 },
                { city: 'Vienna', count: 3 },
                { city: 'Lima', count: 3 },
                { city: 'Jakarta', count: 5 },
                { city: 'Manila', count: 4 }
            ]

        function loadTestCoordinates() {
            const results = [];
            for (const item of testCities) {
                const coords = cityToCoordinates(item.city);
                if (coords) {
                    results.push({ ...coords, count: item.count });
                }
            }
            attackCoordinates.value = results;
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
            map = L.map('attackMap').setView([20, 0], 2)
            L.tileLayer(
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
                { attribution: '&copy; OpenStreetMap contributors' }
            ).addTo(map)
            markersCluster = L.markerClusterGroup()
            map.addLayer(markersCluster)
            
            await Promise.all([
                fetchTopUsernames(),
                fetchTopPasswords(),
                fetchAttackCoordinates(),
                fetchTotalAttacks(),
                fetchTodayAttacks(),
                fetchAttacksByTime()
            ])

            topUsernames.value = [
                'Alice', 'Bob', 'Charlie', 'David', 'Eva',
                'Frank', 'Grace', 'Hannah', 'Ivan', 'Julia'
            ]

            topPasswords.value = [
            '123456', 'password', 'qwerty', 'abc123', 'letmein',
            'welcome', 'monkey', 'dragon', 'iloveyou', 'admin'
            ]

            totalAttacks.value = 1200
            todayAttacks.value = 45

            attacksByTime.value = [
                { time: '00:00', count: 5 },
                { time: '03:10', count: 8 },
                { time: '04:00', count: 3 },
                { time: '06:20', count: 7 },
                { time: '08:00', count: 10 },
                { time: '11:45', count: 12 },
                { time: '12:00', count: 15 },
                { time: '14:20', count: 9 },
                { time: '16:00', count: 11 },
                { time: '18:00', count: 8 },
                { time: '21:30', count: 6 },
                { time: '22:00', count: 4 }
                ]


            // Realtime Update (Polling)
            setInterval(() => {
                //fetchTopUsernames()
                //fetchTopPasswords()
                loadTestCoordinates()
                // fetchAttackCoordinates()
                //fetchTotalAttacks()
                //fetchTodayAttacks()
                //fetchAttacksByTime()
            }, 5000)
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
        
        return { topUsernames, topPasswords, attackCoordinates, totalAttacks, todayAttacks, attacksByTime }
    }
}
</script>
