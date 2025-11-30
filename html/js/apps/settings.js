// ============================================================================
// SETTINGS APP
// ============================================================================

const SettingsApp = {
    load() {
        console.log('[SETTINGS] Loading settings app');
        // Settings are loaded from HTML, just setup event handlers
    }
};

function updateFuelPrice() {
    const price = parseFloat(document.getElementById('fuel-price-input').value);
    if (price <= 0) {
        alert('Prix invalide');
        return;
    }

    Utils.sendNUICallback('updateFuelPrice', { price });
}

function withdrawMoney() {
    const amount = parseInt(document.getElementById('withdraw-amount').value);
    if (amount <= 0) {
        alert('Montant invalide');
        return;
    }

    Utils.sendNUICallback('withdrawMoney', { amount });
}

function depositMoney() {
    const amount = parseInt(document.getElementById('deposit-amount').value);
    if (amount <= 0) {
        alert('Montant invalide');
        return;
    }

    Utils.sendNUICallback('depositMoney', { amount });
}

function sellStation() {
    if (confirm('Êtes-vous sûr de vouloir vendre cette station ? Cette action est irréversible.')) {
        Utils.sendNUICallback('sellStation', {}, (result) => {
            if (result.success) {
                UIManager.closeTablet();
            } else {
                alert(result.message);
            }
        });
    }
}

console.log('[MLFA GASSTATION] Settings app loaded');
