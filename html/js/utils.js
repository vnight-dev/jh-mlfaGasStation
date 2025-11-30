// ============================================================================
// UTILS.JS - Fonctions utilitaires
// ============================================================================

const Utils = {
    // Format number with commas
    formatNumber(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    // Format date
    formatDate(dateStr) {
        const date = new Date(dateStr);
        return date.toLocaleDateString('fr-FR') + ' ' + date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
    },

    // Get parent resource name
    getParentResourceName() {
        const resourceName = window.location.hostname;
        return resourceName !== '' ? resourceName : 'jh-mlfaGasStation';
    },

    // Send NUI callback
    sendNUICallback(endpoint, data, callback) {
        fetch(`https://${this.getParentResourceName()}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        })
            .then(resp => {
                // Check if response has content
                const contentType = resp.headers.get('content-type');
                if (contentType && contentType.includes('application/json')) {
                    return resp.json();
                }
                return {}; // Return empty object if no JSON
            })
            .then(result => {
                if (callback) callback(result);
            })
            .catch(err => {
                console.error(`[UTILS] Error sending NUI callback to ${endpoint}:`, err);
                if (callback) callback({ success: false, error: err.message });
            });
    }
};

console.log('[MLFA GASSTATION] Utils.js loaded');
