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
                                            <tr v-for="i in 10" :key="'user'+i">
                                                <td>{{ i }}</td>
                                                <td>User{{ i }}</td>
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
                                            <tr v-for="i in 10" :key="'pw'+i">
                                                <td>{{ i }}</td>
                                                <td>*******</td>
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
                            <div class="card-body d-flex justify-content-center align-items-center">
                                <div class="bg-secondary w-100 h-100 d-flex justify-content-center align-items-center text-white">
                                    Map Placeholder
                                </div>
                            </div>
                        </div>
                        
                        <!-- Stats Row -->
                        <div class="row g-3">
                            <div class="col-6">
                                <div class="card text-center p-3">Attacks Today: 123</div>
                            </div>
                            <div class="col-6">
                                <div class="card text-center p-3">Total Attacks: 4567</div>
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
import { onMounted } from 'vue'
import { Chart, registerables } from 'chart.js'

Chart.register(...registerables)

export default {
    name: 'DashboardPage',
    components: { Layout },
    setup(_, { router }) {
        onMounted(() => {
            if (!localStorage.getItem('token')) {
                router.push('/')
                return
            }
            
            const ctx = document.getElementById('attacksChart').getContext('2d')
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['00:00','04:00','08:00','12:00','16:00','20:00'],
                    datasets: [{
                        label: 'Anzahl Angriffe',
                        data: [12, 19, 7, 15, 9, 22],
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
        })
    }
}
</script>
