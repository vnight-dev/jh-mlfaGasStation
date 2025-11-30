const Utils = {
    wait: (ms) => new Promise(resolve => setTimeout(resolve, ms)),

    formatMoney: (amount) => {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(amount);
    },

    formatNumber: (num) => {
        return new Intl.NumberFormat('en-US').format(num);
    },

    randomId: () => {
        return Math.random().toString(36).substr(2, 9);
    }
};
