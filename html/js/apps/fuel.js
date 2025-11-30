// ============================================================================
// FUEL APP
// ============================================================================

const FuelApp = {
    load() {
        console.log('[FUEL] Loading fuel app');

        if (!AppState.stationData) return;

        const fuelPercent = (AppState.stationData.fuel_stock / 10000) * 100;
        document.getElementById('fuel-gauge').style.width = `${fuelPercent}%`;
        document.getElementById('fuel-current').textContent = `${AppState.stationData.fuel_stock}L`;
        document.getElementById('current-fuel-price').textContent = `$${AppState.stationData.fuel_price}`;
    }
};

console.log('[MLFA GASSTATION] Fuel app loaded');
