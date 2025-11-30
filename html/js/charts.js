// ============================================================================
// DASHBOARD CHARTS - Chart.js Integration
// Real-time graphs for revenue, sales, and statistics
// ============================================================================

const DashboardCharts = {
    charts: {},

    init(data) {
        console.log('[DASHBOARD CHARTS] Initializing...');
        this.createRevenueChart(data);
        this.createSalesChart(data);
        this.createCustomersChart(data);
        this.createComparisonChart(data);
    },

    // Revenue Chart (Last 7 Days)
    createRevenueChart(data) {
        const ctx = document.getElementById('revenueChart');
        if (!ctx) return;

        // Destroy existing chart
        if (this.charts.revenue) {
            this.charts.revenue.destroy();
        }

        this.charts.revenue = new Chart(ctx, {
            type: 'line',
            data: {
                labels: this.getLast7Days(),
                datasets: [{
                    label: 'Revenus ($)',
                    data: data.revenue || [0, 0, 0, 0, 0, 0, 0],
                    borderColor: '#00F2EA',
                    backgroundColor: 'rgba(0, 242, 234, 0.1)',
                    borderWidth: 3,
                    tension: 0.4,
                    fill: true,
                    pointBackgroundColor: '#00F2EA',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(26, 26, 46, 0.95)',
                        titleColor: '#00F2EA',
                        bodyColor: '#fff',
                        borderColor: '#00F2EA',
                        borderWidth: 1,
                        padding: 12,
                        displayColors: false,
                        callbacks: {
                            label: (context) => `$${context.parsed.y.toLocaleString()}`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.05)'
                        },
                        ticks: {
                            color: 'rgba(255, 255, 255, 0.7)',
                            callback: (value) => `$${value.toLocaleString()}`
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            color: 'rgba(255, 255, 255, 0.7)'
                        }
                    }
                }
            }
        });
    },

    // Sales Chart (Liters Sold)
    createSalesChart(data) {
        const ctx = document.getElementById('salesChart');
        if (!ctx) return;

        if (this.charts.sales) {
            this.charts.sales.destroy();
        }

        this.charts.sales = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: this.getLast7Days(),
                datasets: [{
                    label: 'Litres Vendus',
                    data: data.sales || [0, 0, 0, 0, 0, 0, 0],
                    backgroundColor: 'rgba(0, 201, 167, 0.8)',
                    borderColor: '#00C9A7',
                    borderWidth: 2,
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(26, 26, 46, 0.95)',
                        titleColor: '#00C9A7',
                        bodyColor: '#fff',
                        borderColor: '#00C9A7',
                        borderWidth: 1,
                        padding: 12,
                        displayColors: false,
                        callbacks: {
                            label: (context) => `${context.parsed.y.toLocaleString()}L`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.05)'
                        },
                        ticks: {
                            color: 'rgba(255, 255, 255, 0.7)',
                            callback: (value) => `${value}L`
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            color: 'rgba(255, 255, 255, 0.7)'
                        }
                    }
                }
            }
        });
    },

    // Customers Chart (Traffic)
    createCustomersChart(data) {
        const ctx = document.getElementById('customersChart');
        if (!ctx) return;

        if (this.charts.customers) {
            this.charts.customers.destroy();
        }

        this.charts.customers = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['NPC', 'Joueurs'],
                datasets: [{
                    data: data.customers || [80, 20],
                    backgroundColor: [
                        'rgba(0, 242, 234, 0.8)',
                        'rgba(255, 217, 61, 0.8)'
                    ],
                    borderColor: [
                        '#00F2EA',
                        '#FFD93D'
                    ],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#fff',
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(26, 26, 46, 0.95)',
                        titleColor: '#00F2EA',
                        bodyColor: '#fff',
                        borderColor: '#00F2EA',
                        borderWidth: 1,
                        padding: 12,
                        callbacks: {
                            label: (context) => `${context.label}: ${context.parsed}%`
                        }
                    }
                }
            }
        });
    },

    // Station Comparison Chart
    createComparisonChart(data) {
        const ctx = document.getElementById('comparisonChart');
        if (!ctx) return;

        if (this.charts.comparison) {
            this.charts.comparison.destroy();
        }

        this.charts.comparison = new Chart(ctx, {
            type: 'radar',
            data: {
                labels: ['Revenus', 'Ventes', 'Clients', 'Stock', 'Employés'],
                datasets: [{
                    label: 'Ma Station',
                    data: data.myStation || [80, 75, 90, 70, 60],
                    borderColor: '#00F2EA',
                    backgroundColor: 'rgba(0, 242, 234, 0.2)',
                    borderWidth: 2,
                    pointBackgroundColor: '#00F2EA',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                }, {
                    label: 'Moyenne Serveur',
                    data: data.serverAverage || [60, 65, 70, 75, 50],
                    borderColor: '#FFD93D',
                    backgroundColor: 'rgba(255, 217, 61, 0.2)',
                    borderWidth: 2,
                    pointBackgroundColor: '#FFD93D',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#fff',
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(26, 26, 46, 0.95)',
                        titleColor: '#00F2EA',
                        bodyColor: '#fff',
                        borderColor: '#00F2EA',
                        borderWidth: 1,
                        padding: 12
                    }
                },
                scales: {
                    r: {
                        beginAtZero: true,
                        max: 100,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        angleLines: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: 'rgba(255, 255, 255, 0.7)',
                            backdropColor: 'transparent'
                        },
                        pointLabels: {
                            color: '#fff',
                            font: {
                                size: 12
                            }
                        }
                    }
                }
            }
        });
    },

    // Update charts with new data
    update(data) {
        if (this.charts.revenue && data.revenue) {
            this.charts.revenue.data.datasets[0].data = data.revenue;
            this.charts.revenue.update('none');
        }

        if (this.charts.sales && data.sales) {
            this.charts.sales.data.datasets[0].data = data.sales;
            this.charts.sales.update('none');
        }

        if (this.charts.customers && data.customers) {
            this.charts.customers.data.datasets[0].data = data.customers;
            this.charts.customers.update('none');
        }

        if (this.charts.comparison && data.myStation && data.serverAverage) {
            this.charts.comparison.data.datasets[0].data = data.myStation;
            this.charts.comparison.data.datasets[1].data = data.serverAverage;
            this.charts.comparison.update('none');
        }
    },

    // Helper: Get last 7 days labels
    getLast7Days() {
        const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
        const result = [];
        const today = new Date();

        for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            result.push(days[date.getDay()]);
        }

        return result;
    }
};

// Export for use in dashboard.js
window.DashboardCharts = DashboardCharts;

console.log('[DASHBOARD CHARTS] Script loaded');
