// ============================================================================
// UI MANAGER v6.0 - SINGULARITY
// Handles UI state, transitions, and boot sequence
// ============================================================================

const UIManager = {
    state: {
        isVisible: false,
        currentApp: 'dashboard',
        isBooting: false
    },

    elements: {
        bootScreen: document.getElementById('boot-screen'),
        bootProgress: document.querySelector('.boot-progress'),
        bootStatus: document.querySelector('.boot-status'),
        app: document.getElementById('app'),
        navItems: document.querySelectorAll('.nav-item'),
        pageTitle: document.getElementById('current-page-title'),
        mainContainer: document.getElementById('main-container')
    },

    init() {
        console.log('[UI] Initializing GasOS v6.0...');

        // Listen for NUI messages
        window.addEventListener('message', (event) => {
            const data = event.data;
            const action = data.action || data.type; // Support both formats

            if (action === 'open') {
                // Client sends { type: 'open', data: { ... } }
                // So we pass data.data if it exists, or data itself
                this.open(data.data || data);
            } else if (action === 'close') {
                this.close();
            } else if (action === 'updateData') {
                this.handleUpdate(data.data || data);
            } else if (action === 'showPurchasePrompt') {
                this.showPurchasePrompt(data.data || data);
            } else if (action === 'hidePurchasePrompt') {
                this.hidePurchasePrompt();
            }
        });

        // Setup navigation
        this.elements.navItems.forEach(item => {
            item.addEventListener('click', () => {
                const appName = item.dataset.app;
                if (appName) this.switchApp(appName);

                if (item.id === 'logout-btn') this.close();
            });
        });

        // Start clock
        this.startClock();
    },

    async open(data) {
        if (this.state.isVisible) return;

        this.state.isVisible = true;

        // Play boot sequence
        await this.playBootSequence();

        // Show main UI
        this.elements.app.classList.add('visible');

        // Load initial data
        if (data && data.station) {
            // Update station info
            const roleEl = document.querySelector('.user-role');
            if (roleEl) roleEl.textContent = data.station.label;
        }

        this.switchApp('dashboard');
    },

    close() {
        this.state.isVisible = false;
        this.elements.app.classList.remove('visible');

        // Reset boot screen for next time
        this.elements.bootScreen.classList.remove('active');
        this.elements.bootProgress.style.width = '0%';

        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    },

    async playBootSequence() {
        this.state.isBooting = true;
        this.elements.bootScreen.classList.add('active');

        const steps = [
            { progress: 20, text: 'LOADING KERNEL...' },
            { progress: 40, text: 'MOUNTING FILE SYSTEM...' },
            { progress: 60, text: 'CONNECTING TO SATELLITE...' },
            { progress: 80, text: 'LOADING USER PROFILE...' },
            { progress: 100, text: 'SYSTEM READY' }
        ];

        for (const step of steps) {
            this.elements.bootStatus.textContent = step.text;
            this.elements.bootProgress.style.width = `${step.progress}%`;
            await Utils.wait(200 + Math.random() * 300); // Random delay for realism
        }

        await Utils.wait(500);

        // Fade out boot screen
        this.elements.bootScreen.style.opacity = '0';
        await Utils.wait(500);
        this.elements.bootScreen.classList.remove('active');
        this.elements.bootScreen.style.opacity = ''; // Reset opacity

        this.state.isBooting = false;
    },

    switchApp(appName) {
        // Update nav
        this.elements.navItems.forEach(item => {
            if (item.dataset.app === appName) item.classList.add('active');
            else item.classList.remove('active');
        });

        // Update title
        const appLabel = appName.charAt(0).toUpperCase() + appName.slice(1);
        if (this.elements.pageTitle) this.elements.pageTitle.textContent = appLabel;

        // Load app content (placeholder for now)
        // In a real implementation, this would load the specific app module
        console.log(`[UI] Switched to ${appName}`);

        // Trigger app specific load function if exists
        if (window[`${appName}App`] && window[`${appName}App`].load) {
            window[`${appName}App`].load();
        }
    },

    handleUpdate(data) {
        // Dispatch update to active app
        const currentAppObj = window[`${this.state.currentApp}App`];
        if (currentAppObj && currentAppObj.update) {
            currentAppObj.update(data);
        }
    },

    // Purchase Prompt
    showPurchasePrompt(data) {
        const nameEl = document.getElementById('prompt-station-name');
        const priceEl = document.getElementById('prompt-station-price');
        const promptEl = document.getElementById('purchase-prompt');

        if (nameEl) nameEl.textContent = data.stationName;
        if (priceEl) priceEl.textContent = '$' + Utils.formatNumber(data.price);
        if (promptEl) promptEl.style.display = 'flex';
    },

    hidePurchasePrompt() {
        const promptEl = document.getElementById('purchase-prompt');
        if (promptEl) promptEl.style.display = 'none';
    },

    confirmPurchase() {
        fetch(`https://${GetParentResourceName()}/confirmPurchase`, {
            method: 'POST',
            body: JSON.stringify({})
        });
        this.hidePurchasePrompt();
    },

    cancelPurchase() {
        fetch(`https://${GetParentResourceName()}/cancelPurchase`, {
            method: 'POST',
            body: JSON.stringify({})
        });
        this.hidePurchasePrompt();
    },

    startClock() {
        setInterval(() => {
            const now = new Date();
            const options = { weekday: 'long', hour: 'numeric', minute: 'numeric', hour12: true };
            const dateEl = document.getElementById('current-date');
            if (dateEl) dateEl.textContent = now.toLocaleDateString('en-US', options);
        }, 1000);
    },

    showNotification(type, message) {
        // Create notification element
        const notif = document.createElement('div');
        notif.className = `notification ${type}`;
        notif.innerHTML = `
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
            <span>${message}</span>
        `;

        document.body.appendChild(notif);

        // Animate in
        requestAnimationFrame(() => notif.classList.add('show'));

        // Remove after 3s
        setTimeout(() => {
            notif.classList.remove('show');
            setTimeout(() => notif.remove(), 300);
        }, 3000);
    }
};

// Initialize on load
document.addEventListener('DOMContentLoaded', () => UIManager.init());
