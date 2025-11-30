// ============================================================================
// EMPLOYEES APP
// ============================================================================

const EmployeesApp = {
    load() {
        console.log('[EMPLOYEES] Loading employees app');

        const employees = AppState.stationData?.employees || [];
        const container = document.getElementById('employees-list');
        container.innerHTML = '';

        if (employees.length === 0) {
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
                    <span class="salary">$${Utils.formatNumber(emp.salary)}/h</span>
                    ${AppState.playerData.permissions.fireEmployees ? `
                        <button class="btn btn-danger btn-sm" onclick="fireEmployee(${emp.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    ` : ''}
                </div>
            `;
            container.appendChild(card);
        });
    }
};

function fireEmployee(employeeId) {
    if (confirm('Licencier cet employé ?')) {
        Utils.sendNUICallback('fireEmployee', { employeeId });
    }
}

console.log('[MLFA GASSTATION] Employees app loaded');
