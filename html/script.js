let stationData = null;
let playerData = null;
let appsData = null;
let currentScreen = 'home-screen';
let canClose = false;

// ============================================================================
// NUI MESSAGE LISTENER (CRITICAL - HANDLES LUA MESSAGES)
// ============================================================================

window.addEventListener('message', function (event) {
    const data = event.data;
    console.log('[GASMANAGER UI] Received message:', data);

    switch (data.type) {
        case 'open':
            console.log('[GASMANAGER UI] Opening tablet');
            openTablet(data.data);
            break;

        case 'close':
            console.log('[GASMANAGER UI] Closing tablet');
            closeTablet();
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
            refreshCurrentScreen();
            break;

        default:
            console.warn('[GASMANAGER UI] Unknown message type:', data.type);
    }
});

// ============================================================================
// PURCHASE PROMPT FUNCTIONS
// ============================================================================

function showPurchasePrompt(data) {
    console.log('[PURCHASE UI] Showing purchase prompt for:', data.stationName);
    document.getElementById('prompt-station-name').textContent = data.stationName;
    document.getElementById('prompt-station-price').textContent = '$' + formatNumber(data.price);
    document.getElementById('purchase-prompt').style.display = 'flex';
}

function hidePurchasePrompt() {
    console.log('[PURCHASE UI] Hiding purchase prompt');
    document.getElementById('purchase-prompt').style.display = 'none';
}

function confirmPurchase() {
    console.log('[PURCHASE UI] Confirming purchase');
    fetch(`https://${GetParentResourceName()}/confirmPurchase`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(() => {
        console.log('[PURCHASE UI] Purchase confirmed');
        hidePurchasePrompt();
    }).catch(err => {
        console.error('[PURCHASE UI] Error confirming purchase:', err);
    });
}

function cancelPurchase() {
    console.log('[PURCHASE UI] Cancelling purchase');
    fetch(`https://${GetParentResourceName()}/cancelPurchase`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(() => {
        console.log('[PURCHASE UI] Purchase cancelled');
        hidePurchasePrompt();
    }).catch(err => {
        console.error('[PURCHASE UI] Error cancelling purchase:', err);
    });
}

// ============================================================================
// UTILITY FUNCTION
// ============================================================================

function GetParentResourceName() {
    const resourceName = window.location.hostname;
    return resourceName !== '' ? resourceName : 'jh-mlfaGasStation';
}

function refreshCurrentScreen() {
    if (currentScreen === 'dashboard-app') {
        loadDashboard();
    } else if (currentScreen === 'fuel-app') {
        loadFuelApp();
    }
}

// ============================================================================
// APPS CONFIGURATION
// ============================================================================

// Apps Configuration
const APPS = {
    'dashboard': { icon: 'fas fa-chart-line', label: 'Dashboard', screen: 'dashboard-app' },
    'fuel': { icon: 'fas fa-gas-pump', label: 'Carburant', screen: 'fuel-app' },
    'employees': { icon: 'fas fa-users', label: 'Personnel', screen: 'employees-app' },
    'permissions': { icon: 'fas fa-shield-alt', label: 'Permissions', screen: 'permissions-app' },
    'missions': { icon: 'fas fa-tasks', label: 'Missions', screen: 'missions-app' },
    'reports': { icon: 'fas fa-file-alt', label: 'Rapports', screen: 'reports-app' },
    'settings': { icon: 'fas fa-cog', label: 'Paramètres', screen: 'settings-app' }
};

// Open Tablet
function openTablet(data) {
    console.log('[GASMANAGER UI] Opening tablet with data:', data);

    if (!data || !data.station || !data.player) {
        console.error('[GASMANAGER UI] Invalid data received:', data);
        alert('Erreur: Données invalides reçues du serveur');
        return;
    }

    stationData = data.station;
    playerData = data.player;
    appsData = data.apps;

    console.log('[GASMANAGER UI] Station data:', stationData);
    console.log('[GASMANAGER UI] Player data:', playerData);
    console.log('[GASMANAGER UI] Apps data:', appsData);

    // Update header - use label from Config if available
    const stationName = stationData.label || stationData.name || 'Station';
    document.getElementById('station-name').textContent = stationName;
    document.getElementById('user-role').textContent = playerData.rank === 'visitor' ? 'Visiteur' : (playerData.rank || 'Employé');

    // Show app
    document.getElementById('app').style.display = 'flex';

    // Determine which screen to show
    if (!stationData.owner || stationData.owner === '' || stationData.owner === null) {
        // Station not owned - show purchase screen
        console.log('[GASMANAGER UI] Station not owned, showing purchase screen');
        showScreen('purchase-screen');
        document.getElementById('purchase-price').textContent = `$${formatNumber(500000)}`;
    } else {
        // Station owned - show home screen
        console.log('[GASMANAGER UI] Station owned, showing home screen');
        showScreen('home-screen');
        loadHomeScreen();
    }

    console.log('[GASMANAGER UI] Tablet opened successfully');

    // Allow closing after 500ms to prevent immediate close
    canClose = false;
    setTimeout(() => {
        canClose = true;
        console.log('[GASMANAGER UI] Tablet can now be closed');
    }, 500);
}

// Close Tablet
function closeTablet() {
    if (!canClose) {
        console.log('[GASMANAGER UI] Close blocked - tablet not ready to close yet');
        return;
    }

    console.log('[GASMANAGER UI] Closing tablet, hiding app');
    canClose = false;
    document.getElementById('app').style.display = 'none';

    // Send close callback to Lua
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(() => {
        console.log('[GASMANAGER UI] Close callback sent');
    }).catch(err => {
        console.error('[GASMANAGER UI] Error sending close callback:', err);
    });
}

// Show Screen
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    document.getElementById(screenId).classList.add('active');
    currentScreen = screenId;

    // Show/hide home button
    const homeBtn = document.querySelector('.home-btn');
    if (screenId === 'home-screen' || screenId === 'purchase-screen') {
        homeBtn.style.display = 'none';
    } else {
        homeBtn.style.display = 'flex';
    }
}

// Go Home
function goHome() {
    showScreen('home-screen');
}

// Load Home Screen
function loadHomeScreen() {
    const grid = document.getElementById('app-grid');
    grid.innerHTML = '';

    for (const [appKey, appData] of Object.entries(APPS)) {
        // Check if player has access to this app
        if (appsData && appsData[appKey]) {
            const card = document.createElement('div');
            card.className = 'app-card';
            card.onclick = () => openApp(appData.screen);
            card.innerHTML = `
                <div class="app-icon">
                    <i class="${appData.icon}"></i>
                </div>
                <div class="app-label">${appData.label}</div>
            `;
            grid.appendChild(card);
        }
    }
}

// Open App
function openApp(screenId) {
    showScreen(screenId);

    // Load app-specific data
    if (screenId === 'dashboard-app') {
        loadDashboard();
    } else if (screenId === 'fuel-app') {
        loadFuelApp();
    } else if (screenId === 'employees-app') {
        loadEmployees(stationData.employees || []);
    } else if (screenId === 'missions-app') {
        loadMissions();
    } else if (screenId === 'permissions-app') {
        loadPermissions();
    } else if (screenId === 'reports-app') {
        loadReports();
    }
}

// Purchase Station
function purchaseStation() {
    if (confirm('Acheter cette station pour $500,000 ?')) {
        fetch(`https://${GetParentResourceName()}/purchaseStation`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ stationId: stationData.id })
        }).then(resp => resp.json()).then(result => {
            if (result.success) {
                stationData.owner = result.owner;
                showScreen('home-screen');
                loadHomeScreen();
            } else {
                alert(result.message);
            }
        });
    }
}

// Load Dashboard
function loadDashboard() {
    // Update stats
    if (stationData) {
        document.getElementById('fuel-stock').textContent = `${stationData.fuel_stock}L`;
        document.getElementById('station-money').textContent = `$${formatNumber(stationData.money)}`;
        document.getElementById('employee-count').textContent = stationData.employees ? stationData.employees.length : 0;
    }

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

// Load Fuel App
function loadFuelApp() {
    if (stationData) {
        const fuelPercent = (stationData.fuel_stock / 10000) * 100;
        document.getElementById('fuel-gauge').style.width = `${fuelPercent}%`;
        document.getElementById('fuel-current').textContent = `${stationData.fuel_stock}L`;
        document.getElementById('current-fuel-price').textContent = `$${stationData.fuel_price}`;
    }
}

// Load Employees
function loadEmployees(employees) {
    const container = document.getElementById('employees-list');
    container.innerHTML = '';

    if (!employees || employees.length === 0) {
        container.innerHTML = '<p class="empty-message">Aucun employé</p>';
        return;
    }

    employees.forEach(emp => {
        const card = document.createElement('div');
        card.className = 'employee-card';
        card.innerHTML = `
            <div class="employee-info">
                <i class="fas fa-user-circle"></i>
                <div>
                    <h4>${emp.firstname} ${emp.lastname}</h4>
                    <span>${emp.rank}</span>
                </div>
            </div>
            <div class="employee-actions">
                <span class="salary">$${formatNumber(emp.salary)}/h</span>
                ${playerData.permissions.fireEmployees ? `
                    <button class="btn btn-danger btn-sm" onclick="fireEmployee(${emp.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                ` : ''}
            </div>
        `;
        container.appendChild(card);
    });
}

// Load Permissions
function loadPermissions() {
    const container = document.getElementById('ranks-list');
    container.innerHTML = '';

    const ranks = [
        { name: 'owner', label: 'Propriétaire', permissions: ['manageMoney', 'hireEmployees', 'fireEmployees', 'startMissions', 'changeSettings', 'viewReports'] },
        { name: 'manager', label: 'Gérant', permissions: ['hireEmployees', 'fireEmployees', 'startMissions', 'changeSettings', 'viewReports'] },
        { name: 'employee', label: 'Employé', permissions: ['startMissions'] }
    ];

    ranks.forEach(rank => {
        const card = document.createElement('div');
        card.className = 'rank-card';

        const permissionsList = [
            { key: 'manageMoney', label: 'Gérer l\'argent' },
            { key: 'hireEmployees', label: 'Embaucher' },
            { key: 'fireEmployees', label: 'Licencier' },
            { key: 'startMissions', label: 'Missions' },
            { key: 'changeSettings', label: 'Paramètres' },
            { key: 'viewReports', label: 'Rapports' }
        ];

        let permissionsHTML = '';
        permissionsList.forEach(perm => {
            const isActive = rank.permissions.includes(perm.key);
            permissionsHTML += `
                <div class="permission-item">
                    <div class="permission-toggle ${isActive ? 'active' : ''}" 
                         onclick="togglePermission('${rank.name}', '${perm.key}')"></div>
                    <span>${perm.label}</span>
                </div>
            `;
        });

        card.innerHTML = `
            <div class="rank-header">
                <h3>${rank.label}</h3>
            </div>
            <div class="permissions-grid">
                ${permissionsHTML}
            </div>
        `;
        container.appendChild(card);
    });
}

// Toggle Permission
function togglePermission(rankName, permissionKey) {
    fetch(`https://${GetParentResourceName()}/togglePermission`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rankName, permissionKey })
    }).then(() => {
        loadPermissions();
    });
}

// Load Missions
function loadMissions() {
    const container = document.getElementById('missions-grid');
    container.innerHTML = '';

    const missions = [
        {
            icon: 'fas fa-truck',
            title: 'Livraison de Carburant',
            description: 'Livrez un camion citerne pour réapprovisionner la station',
            rewards: [
                { icon: 'fas fa-gas-pump', text: '+500L' },
                { icon: 'fas fa-dollar-sign', text: '$1,500' }
            ],
            type: 'FuelDelivery'
        },
        {
            icon: 'fas fa-wrench',
            title: 'Maintenance',
            description: 'Effectuez la maintenance des équipements de la station',
            rewards: [
                { icon: 'fas fa-dollar-sign', text: '$800' }
            ],
            type: 'Maintenance'
        }
    ];

    missions.forEach(mission => {
        const card = document.createElement('div');
        card.className = 'mission-card';

        const rewardsHTML = mission.rewards.map(r =>
            `<span><i class="${r.icon}"></i> ${r.text}</span>`
        ).join('');

        card.innerHTML = `
            <div class="mission-icon">
                <i class="${mission.icon}"></i>
            </div>
            <h3>${mission.title}</h3>
            <p>${mission.description}</p>
            <div class="mission-rewards">
                ${rewardsHTML}
            </div>
            <button class="btn btn-primary" onclick="startMission('${mission.type}')">
                Démarrer
            </button>
        `;
        container.appendChild(card);
    });
}

// Start Mission
function startMission(missionType) {
    fetch(`https://${GetParentResourceName()}/startMission`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ missionType })
    }).then(resp => resp.json()).then(result => {
        if (result.success) {
            closeTablet();
        } else {
            alert(result.message);
        }
    });
}

// Load Reports
function loadReports() {
    // Filter buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            const period = this.getAttribute('data-period');
            loadReportData(period);
        });
    });

    loadReportData('today');
}

// Load Report Data
function loadReportData(period) {
    // This would fetch from server in real implementation
    document.getElementById('report-revenue').textContent = '$5,250';
    document.getElementById('report-expenses').textContent = '$1,800';
    document.getElementById('report-profit').textContent = '$3,450';
    document.getElementById('report-fuel-sold').textContent = '2,100L';
}

// Load Transactions
function loadTransactions(transactions) {
    const tbody = document.getElementById('transactions-tbody');
    if (!tbody) return;

    tbody.innerHTML = '';

    if (!transactions || transactions.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="empty-message">Aucune transaction</td></tr>';
        return;
    }

    transactions.slice(0, 20).forEach(trans => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${formatDate(trans.created_at)}</td>
            <td>${trans.type}</td>
            <td>${trans.description || '-'}</td>
            <td class="${trans.amount > 0 ? 'positive' : 'negative'}">
                ${trans.amount > 0 ? '+' : ''}$${formatNumber(Math.abs(trans.amount))}
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Update Stats
function updateStats(stats) {
    if (stats.today) {
        document.getElementById('today-sales').textContent = `${stats.today.total_liters || 0}L`;
    }
    if (stats.week) {
        document.getElementById('week-fuel-sales').textContent = `${stats.week.total_liters || 0}L`;
        document.getElementById('week-fuel-revenue').textContent = `$${formatNumber(stats.week.total_revenue || 0)}`;
    }
}

// Fire Employee
function fireEmployee(employeeId) {
    if (confirm('Licencier cet employé ?')) {
        fetch(`https://${GetParentResourceName()}/fireEmployee`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ employeeId })
        });
    }
}

// Update Fuel Price
function updateFuelPrice() {
    const price = parseFloat(document.getElementById('fuel-price-input').value);
    if (price <= 0) {
        alert('Prix invalide');
        return;
    }

    fetch(`https://${GetParentResourceName()}/updateFuelPrice`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ price })
    });
}

// Withdraw Money
function withdrawMoney() {
    const amount = parseInt(document.getElementById('withdraw-amount').value);
    if (amount <= 0) {
        alert('Montant invalide');
        return;
    }

    fetch(`https://${GetParentResourceName()}/withdrawMoney`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount })
    });
}

// Deposit Money
function depositMoney() {
    const amount = parseInt(document.getElementById('deposit-amount').value);
    if (amount <= 0) {
        alert('Montant invalide');
        return;
    }

    fetch(`https://${GetParentResourceName()}/depositMoney`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount })
    });
}

// Sell Station
function sellStation() {
    if (confirm('Êtes-vous sûr de vouloir vendre cette station ? Cette action est irréversible.')) {
        fetch(`https://${GetParentResourceName()}/sellStation`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(result => {
            if (result.success) {
                closeTablet();
            } else {
                alert(result.message);
            }
        });
    }
}

// Utility Functions
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function formatDate(dateStr) {
    const date = new Date(dateStr);
    return date.toLocaleDateString('fr-FR') + ' ' + date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
}
console.log('[MLFA GASSTATION] UI Script loaded');
