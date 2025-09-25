<template>
    <Layout>
        <div class="container mt-4">
            <h2>Honeypots</h2>
            <!-- Dropdown to select Honeypot -->
            <div class="mb-3">
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
        <!-- Log Table -->
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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import Layout from '../components/Layout.vue'
import { auth } from '../store/auth.js'

export default {
    name: 'HoneypotsPage',
    components: { Layout },
    setup() {
        const router = useRouter()
        
        const honeypots = ref([])
        const selectedHoneypot = ref(null)
        const logs = ref({})
        let pollingInterval = null
        
        // Fetch Helper
        async function safeFetch(url, fallback = null) {
            try {
                const res = await axios.get(url, {
                    headers: { Authorization: `Bearer ${auth.token}` }
                })
                return res.data
            } catch (err) {
                console.error(`Error fetching ${url}:`, err)
                return fallback
            }
        }
        
        // get all honeypots 
        async function fetchHoneypots() {
            const res = await safeFetch('/api/v1/analytics/honeypots', [])
            honeypots.value = res.map((hp, idx) => ({
                id: hp.honeypotId || idx + 1,
                name: `Honeypot ${hp.honeypotId || idx + 1}`
            }))
            
            if (honeypots.value.length > 0) {
                selectedHoneypot.value = honeypots.value[0].id
                await fetchLogsForHoneypot(selectedHoneypot.value)
            }
        }
        
        // get logs for current honeypot
        async function fetchLogsForHoneypot(id) {
            if (!id) return
            
            const res = await safeFetch(`/api/v1/analytics/honeypots/${id}/logs`, [])
            
            logs.value = {
                [id]: res.map(log => {
                    // Convert timestamp to human-readable date
                    let formattedDate = 'n/a'
                    if (log.timestamp) {
                        try {
                            formattedDate = new Date(log.timestamp).toLocaleString() 
                        } catch (e) {
                            console.warn('Invalid timestamp:', log.timestamp)
                        }
                    }
                    
                    return {
                        timestamp: formattedDate,
                        srcIP: log.source_ip || 'n/a',
                        message: log.message || 'n/a'
                    }
                })
            }
        }
        
        // if Honeypot is changed in frontend
        const onHoneypotChange = async () => {
            console.log('Honeypot changed to ID:', selectedHoneypot.value)
            await fetchLogsForHoneypot(selectedHoneypot.value)
        }
        
        
        const currentHoneypot = computed(() =>
        honeypots.value.find(hp => hp.id === selectedHoneypot.value) || { name: '' }
        )
        
        const currentLogs = computed(() =>
        logs.value[selectedHoneypot.value] || []
        )
        
        onMounted(async () => {
            if (!localStorage.getItem('token')) {
                router.push('/')
                return
            }
            await fetchHoneypots()
            
            // Polling 
            pollingInterval = setInterval(async () => {
                if (selectedHoneypot.value) {
                    await fetchLogsForHoneypot(selectedHoneypot.value)
                }
            }, 3000)
        })
        
        onBeforeUnmount(() => {
            if (pollingInterval) clearInterval(pollingInterval)
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
