// ============================================================================
// REPORTS APP
// ============================================================================

const ReportsApp = {
    load() {
        console.log('[REPORTS] Loading reports app');

        // Setup filter buttons
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                const period = this.getAttribute('data-period');
                ReportsApp.loadData(period);
            });
        });

        this.loadData('today');
    },

    loadData(period) {
        // This would fetch from server in real implementation
        document.getElementById('report-revenue').textContent = '$5,250';
        document.getElementById('report-expenses').textContent = '$1,800';
        document.getElementById('report-profit').textContent = '$3,450';
        document.getElementById('report-fuel-sold').textContent = '2,100L';
    }
};

console.log('[MLFA GASSTATION] Reports app loaded');
