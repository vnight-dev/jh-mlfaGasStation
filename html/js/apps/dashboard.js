// ============================================================================
// DASHBOARD APP
// ============================================================================

const DashboardApp = {
    load() {
        console.log('[DASHBOARD] Loading dashboard');

        if (!AppState.stationData) return;

        // Update stats
        document.getElementById('fuel-stock').textContent = `${AppState.stationData.fuel_stock}L`;
        document.getElementById('station-money').textContent = `$${Utils.formatNumber(AppState.stationData.money)}`;
        document.getElementById('employee-count').textContent = AppState.stationData.employees ? AppState.stationData.employees.length : 0;

        // Load recent activity
        const activityList = document.getElementById('recent-activity-list');
        activityList.innerHTML = `
            <div class="activity-item">
                <i class="fas fa-gas-pump"></i>
                <span>Vente de carburant - 50L</span>
                <span class="time">Il y a 5 min</span>
            </div>
            <div class="activity-item">
                <i class="fas fa-truck"></i>
                <span>Livraison effectuée</span>
                <span class="time">Il y a 1h</span>
            </div>
        `;
    }
};

console.log('[MLFA GASSTATION] Dashboard app loaded');
