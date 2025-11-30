// ============================================================================
// THEME ENGINE - V6.0
// Real-time UI customization and theme management
// ============================================================================

const ThemeEngine = {
    currentTheme: 'default',

    presets: {
        default: {
            '--primary': '#00F2EA',
            '--secondary': '#1a1a2e',
            '--accent': '#FF0055',
            '--text': '#ffffff',
            '--success': '#00C9A7',
            '--warning': '#FFD93D',
            '--danger': '#FF6B6B',
            '--glass-opacity': '0.85',
            '--blur': '20px',
            '--radius': '16px',
            '--font-family': '"Inter", sans-serif'
        },
        cyberpunk: {
            '--primary': '#F0E800',
            '--secondary': '#000000',
            '--accent': '#00FF9F',
            '--text': '#F0E800',
            '--success': '#00FF9F',
            '--warning': '#FF0055',
            '--danger': '#FF0000',
            '--glass-opacity': '0.95',
            '--blur': '0px',
            '--radius': '0px',
            '--font-family': '"Courier New", monospace'
        },
        minimal: {
            '--primary': '#000000',
            '--secondary': '#ffffff',
            '--accent': '#666666',
            '--text': '#000000',
            '--success': '#4CAF50',
            '--warning': '#FFC107',
            '--danger': '#F44336',
            '--glass-opacity': '1',
            '--blur': '0px',
            '--radius': '8px',
            '--font-family': '"Helvetica Neue", sans-serif'
        },
        midnight: {
            '--primary': '#7F5AF0',
            '--secondary': '#16161A',
            '--accent': '#2CB67D',
            '--text': '#FFFFFE',
            '--success': '#2CB67D',
            '--warning': '#FF8906',
            '--danger': '#EF4565',
            '--glass-opacity': '0.9',
            '--blur': '30px',
            '--radius': '24px',
            '--font-family': '"Poppins", sans-serif'
        }
    },

    init() {
        console.log('[THEME ENGINE] Initializing v6.0 Singularity...');
        this.loadTheme();
    },

    applyTheme(themeName) {
        if (!this.presets[themeName]) return;

        const theme = this.presets[themeName];
        const root = document.documentElement;

        for (const [property, value] of Object.entries(theme)) {
            root.style.setProperty(property, value);
        }

        this.currentTheme = themeName;
        localStorage.setItem('gasstation_theme', themeName);

        // Notify user
        if (window.UIManager) {
            UIManager.showNotification('success', `Thème ${themeName} appliqué !`);
        }
    },

    applyCustomProperties(properties) {
        const root = document.documentElement;
        for (const [property, value] of Object.entries(properties)) {
            root.style.setProperty(property, value);
        }
    },

    loadTheme() {
        const savedTheme = localStorage.getItem('gasstation_theme') || 'default';
        this.applyTheme(savedTheme);
    },

    // Export for the Customizer App
    getPresets() {
        return Object.keys(this.presets);
    }
};

window.ThemeEngine = ThemeEngine;
document.addEventListener('DOMContentLoaded', () => ThemeEngine.init());
