// ============================================================================
// MISSIONS APP
// ============================================================================

const MissionsApp = {
    missions: [
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
    ],

    load() {
        console.log('[MISSIONS] Loading missions app');

        const container = document.getElementById('missions-grid');
        container.innerHTML = '';

        this.missions.forEach(mission => {
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
};

function startMission(missionType) {
    Utils.sendNUICallback('startMission', { missionType }, (result) => {
        if (result.success) {
            UIManager.closeTablet();
        } else {
            alert(result.message);
        }
    });
}

console.log('[MLFA GASSTATION] Missions app loaded');
