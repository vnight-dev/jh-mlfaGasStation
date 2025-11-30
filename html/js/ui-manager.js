// ============================================================================
// UI-MANAGER.JS - Gestion des écrans et navigation
// ============================================================================

const UIManager = {
    // Apps configuration
    APPS: {
        'dashboard': { icon: 'fas fa-chart-line', label: 'Dashboard', screen: 'dashboard-app' },
        'fuel': { icon: 'fas fa-gas-pump', label: 'Carburant', screen: 'fuel-app' },
        'employees': { icon: 'fas fa-users', label: 'Personnel', screen: 'employees-app' },
        'permissions': { icon: 'fas fa-shield-alt', label: 'Permissions', screen: 'permissions-app' },
        'missions': { icon: 'fas fa-tasks', label: 'Missions', screen: 'missions-app' },
        'reports': { icon: 'fas fa-file-alt', label: 'Rapports', screen: 'reports-app' },
        'settings': { icon: 'fas fa-cog', label: 'Paramètres', screen: 'settings-app' }
    },

    // Open tablet
    openTablet(data) {
        console.log('[UI MANAGER] Opening tablet with data:', data);

        try {
            if (!data || !data.station || !data.player) {
                console.error('[UI MANAGER] Invalid data received:', data);
                Utils.sendNUICallback('close', {}); // Release focus
                return;
            }

            AppState.stationData = data.station;
            AppState.playerData = data.player;
            AppState.appsData = data.apps;

            // Update header
            const stationName = data.station.label || data.station.name || 'Station';
            document.getElementById('station-name').textContent = stationName;
            document.getElementById('user-role').textContent = data.player.rank === 'visitor' ? 'Visiteur' : (data.player.rank || 'Employé');

            // Show app
            document.getElementById('app').style.display = 'flex';

            // Show home screen
            this.showScreen('home-screen');
            this.loadHomeScreen();

            // Allow closing after 500ms
            AppState.canClose = false;
            setTimeout(() => {
                AppState.canClose = true;
            }, 500);
        } catch (err) {
            console.error('[UI MANAGER] Error opening tablet:', err);
            Utils.sendNUICallback('close', {}); // Release focus on error
        }
    },

    // Close tablet
    closeTablet() {
        if (!AppState.canClose) {
            console.log('[UI MANAGER] Close blocked');
            return;
        }

        console.log('[UI MANAGER] Closing tablet');
        AppState.canClose = false;
        document.getElementById('app').style.display = 'none';

        Utils.sendNUICallback('close', {});
    },

    // Show screen
    showScreen(screenId) {
        document.querySelectorAll('.screen').forEach(screen => {
            screen.classList.remove('active');
        });
        document.getElementById(screenId).classList.add('active');
        AppState.currentScreen = screenId;

        // Show/hide home button
        const homeBtn = document.querySelector('.home-btn');
        if (screenId === 'home-screen') {
            homeBtn.style.display = 'none';
        } else {
            homeBtn.style.display = 'flex';
        }
    },

    // Go home
    goHome() {
        this.showScreen('home-screen');
    },

    // Load home screen
    loadHomeScreen() {
        const grid = document.getElementById('app-grid');
        grid.innerHTML = '';

        for (const [appKey, appData] of Object.entries(this.APPS)) {
            if (AppState.appsData && AppState.appsData[appKey]) {
                const card = document.createElement('div');
                card.className = 'app-card';
                card.onclick = () => this.openApp(appData.screen);
                card.innerHTML = `
                    <div class="app-icon">
                        <i class="${appData.icon}"></i>
                    </div>
                    <div class="app-label">${appData.label}</div>
                `;
                grid.appendChild(card);
            }
        }
    },

    // Open app
    openApp(screenId) {
        this.showScreen(screenId);

        // Load app-specific data
        if (screenId === 'dashboard-app') {
            DashboardApp.load();
        } else if (screenId === 'fuel-app') {
            FuelApp.load();
        } else if (screenId === 'employees-app') {
            EmployeesApp.load();
        } else if (screenId === 'missions-app') {
            MissionsApp.load();
        } else if (screenId === 'reports-app') {
            ReportsApp.load();
        } else if (screenId === 'settings-app') {
            SettingsApp.load();
        }
    },

    // Refresh current screen
    refreshCurrentScreen() {
        if (AppState.currentScreen === 'dashboard-app') {
            DashboardApp.load();
        } else if (AppState.currentScreen === 'fuel-app') {
            FuelApp.load();
        }
    }
};

// Global functions for HTML onclick
function closeTablet() {
    UIManager.closeTablet();
}

function goHome() {
    UIManager.goHome();
}

function openApp(screenId) {
    UIManager.openApp(screenId);
}

console.log('[MLFA GASSTATION] UI-Manager.js loaded');
