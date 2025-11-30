// ============================================================================
// MAIN.JS - Point d'entrée + NUI Listener
// ============================================================================

// Global state
let stationData = null;
let playerData = null;
let appsData = null;
let currentScreen = 'home-screen';
let canClose = false;

// ============================================================================
// NUI MESSAGE LISTENER
// ============================================================================

window.addEventListener('message', function (event) {
    const data = event.data;
    console.log('[GASMANAGER UI] Received message raw:', JSON.stringify(data));

    switch (data.type) {
        case 'open':
            console.log('[GASMANAGER UI] Opening tablet');
            UIManager.openTablet(data.data);
            break;

        case 'close':
            console.log('[GASMANAGER UI] Closing tablet');
            UIManager.closeTablet();
            break;

        case 'showPurchasePrompt':
            console.log('[GASMANAGER UI] Showing purchase prompt');
            showPurchasePrompt(data.data);
            break;

        case 'hidePurchasePrompt':
            console.log('[GASMANAGER UI] Hiding purchase prompt');
            hidePurchasePrompt();
            break;

        case 'updateData':
            console.log('[GASMANAGER UI] Updating data');
            if (data.data.station) stationData = data.data.station;
            if (data.data.player) playerData = data.data.player;
            UIManager.refreshCurrentScreen();
            break;

        default:
            console.warn('[GASMANAGER UI] Unknown message type:', data.type);
    }
});

// ============================================================================
// KEYBOARD LISTENERS
// ============================================================================

// Close on ESC
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        console.log('[GASMANAGER UI] ESC key pressed');
        if (AppState.currentScreen === 'home-screen') {
            UIManager.closeTablet();
        } else {
            UIManager.goHome();
        }
    }
});

// ============================================================================
// PURCHASE PROMPT FUNCTIONS
// ============================================================================

function showPurchasePrompt(data) {
    console.log('[PURCHASE UI] Showing purchase prompt for:', data.stationName);
    document.getElementById('prompt-station-name').textContent = data.stationName;
    document.getElementById('prompt-station-price').textContent = '$' + Utils.formatNumber(data.price);
    document.getElementById('purchase-prompt').style.display = 'flex';
}

function hidePurchasePrompt() {
    console.log('[PURCHASE UI] Hiding purchase prompt');
    document.getElementById('purchase-prompt').style.display = 'none';
}

function confirmPurchase() {
    console.log('[PURCHASE UI] Confirming purchase');
    Utils.sendNUICallback('confirmPurchase', {}, () => {
        console.log('[PURCHASE UI] Purchase confirmed');
        hidePurchasePrompt();
    });
}

function cancelPurchase() {
    console.log('[PURCHASE UI] Cancelling purchase');
    Utils.sendNUICallback('cancelPurchase', {}, () => {
        console.log('[PURCHASE UI] Purchase cancelled');
        hidePurchasePrompt();
    });
}

// Export globals for other modules
window.AppState = {
    get stationData() { return stationData; },
    set stationData(val) { stationData = val; },
    get playerData() { return playerData; },
    set playerData(val) { playerData = val; },
    get appsData() { return appsData; },
    set appsData(val) { appsData = val; },
    get currentScreen() { return currentScreen; },
    set currentScreen(val) { currentScreen = val; },
    get canClose() { return canClose; },
    set canClose(val) { canClose = val; }
};

console.log('[MLFA GASSTATION] Main.js loaded');
