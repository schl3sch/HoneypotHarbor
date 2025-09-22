<template>
    <Layout>
        <div class="container mt-4">
            <h2>Honeypots</h2>
            
            <div class="mb-3">
                <label for="honeypotSelect" class="form-label">choose Honeypot</label>
                <select
                id="honeypotSelect"
                class="form-select"
                v-model="selectedHoneypot"
                @change="onHoneypotChange"
                >
                <option v-for="hp in honeypots" :key="hp.id" :value="hp.id">
                    {{ hp.name }}
                </option>
            </select>
        </div>
        
        <div class="card">
            <div class="card-header text-center">
                Logs für: {{ currentHoneypot.name }}
            </div>
            <div class="card-body p-0">
                <table class="table table-striped table-sm mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Timestamp</th>
                            <th>Source IP</th>
                            <th>Message</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(log, index) in currentLogs" :key="index">
                            <td>{{ index + 1 }}</td>
                            <td>{{ log.timestamp }}</td>
                            <td>{{ log.srcIP }}</td>
                            <td>{{ log.message }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</Layout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'

export default {
    name: 'HoneypotsPage',
    components: { Layout },
    setup() {
        const router = useRouter()
        
        const honeypots = ref([
        { id: 1, name: 'Honeypot Alpha' },
        { id: 2, name: 'Honeypot Beta' },
        { id: 3, name: 'Honeypot Gamma' }
        ])
        
        const selectedHoneypot = ref(1)
        
        const logs = ref({
            1: [
            { timestamp: '2025-09-20 10:00:00', srcIP: '192.168.1.10', message: 'Login failed' },
            { timestamp: '2025-09-20 10:05:00', srcIP: '192.168.1.11', message: 'SSH scan detected' }
            ],
            2: [
            { timestamp: '2025-09-20 11:00:00', srcIP: '192.168.1.20', message: 'Port scan' },
            { timestamp: '2025-09-20 11:15:00', srcIP: '192.168.1.21', message: 'Malware attempt' }
            ],
            3: [
            { timestamp: '2025-09-20 12:00:00', srcIP: '192.168.1.30', message: 'Brute force login' },
            { timestamp: '2025-09-20 12:20:00', srcIP: '192.168.1.31', message: 'Suspicious request' }
            ]
        })
        
        const currentHoneypot = computed(() =>
        honeypots.value.find(hp => hp.id === selectedHoneypot.value) || { name: '' }
        )
        
        const currentLogs = computed(() => logs.value[selectedHoneypot.value] || [])
        
        const onHoneypotChange = () => {
            console.log('Honeypot changed to ID:', selectedHoneypot.value)
        }
        
        onMounted(() => {
            if (!localStorage.getItem('token')) {
                router.push('/')
            }
        })
        
        return {
            honeypots,
            selectedHoneypot,
            currentHoneypot,
            currentLogs,
            onHoneypotChange
        }
    }
}
</script>
