// ============================================================================
// MISSION OBJECTIVES UI - JAVASCRIPT
// Handles dynamic mission tracking and updates
// ============================================================================

const ObjectivesUI = {
    container: null,
    missions: {},

    init() {
        this.container = document.getElementById('objectives-container');
        this.setupMessageListener();
        console.log('[OBJECTIVES UI] Initialized');
    },

    setupMessageListener() {
        window.addEventListener('message', (event) => {
            const data = event.data;

            switch (data.type) {
                case 'showObjectives':
                    this.show();
                    break;
                case 'hideObjectives':
                    this.hide();
                    break;
                case 'updateObjectives':
                    this.updateMissions(data.missions);
                    break;
                case 'updateTimer':
                    this.updateTimer(data.missionId, data.remaining);
                    break;
                case 'missionComplete':
                    this.completeMission(data.mission);
                    break;
            }
        });
    },

    show() {
        this.container.classList.remove('hidden');
    },

    hide() {
        this.container.classList.add('hidden');
    },

    updateMissions(missions) {
        // Clear existing missions
        this.container.innerHTML = '';
        this.missions = {};

        // Add each mission
        for (const missionId in missions) {
            const mission = missions[missionId];
            if (mission && !mission.completed) {
                this.addMissionCard(mission);
            }
        }
    },

    addMissionCard(mission) {
        const card = document.createElement('div');
        card.className = 'mission-card';
        card.id = `mission-${mission.id}`;

        // Calculate progress
        const totalObjectives = mission.objectives.length;
        const completedObjectives = mission.currentStep - 1;
        const progress = (completedObjectives / totalObjectives) * 100;

        card.innerHTML = `
            <div class="mission-header">
                <div class="mission-title">${mission.title}</div>
                <div class="mission-reward">$${mission.reward.toLocaleString()}</div>
            </div>

            <ul class="objectives-list">
                ${mission.objectives.map((obj, index) => `
                    <li class="objective-item ${index < mission.currentStep ? 'completed' : ''}">
                        <div class="objective-checkbox"></div>
                        <div class="objective-text">${obj.text}</div>
                    </li>
                `).join('')}
            </ul>

            <div class="mission-progress">
                <div class="progress-label">
                    <span>Progression</span>
                    <span>${completedObjectives}/${totalObjectives}</span>
                </div>
                <div class="progress-bar-container">
                    <div class="progress-bar-fill" style="width: ${progress}%"></div>
                </div>
            </div>

            ${mission.duration > 0 ? `
                <div class="mission-timer">
                    <span class="timer-icon">⏱️</span>
                    <span class="timer-text" id="timer-${mission.id}">--:--</span>
                </div>
            ` : ''}
        `;

        this.container.appendChild(card);
        this.missions[mission.id] = mission;
    },

    updateTimer(missionId, remaining) {
        const timerElement = document.getElementById(`timer-${missionId}`);
        if (!timerElement) return;

        const minutes = Math.floor(remaining / 60);
        const seconds = Math.floor(remaining % 60);
        const timeString = `${minutes}:${seconds.toString().padStart(2, '0')}`;

        timerElement.textContent = timeString;

        // Color coding
        timerElement.classList.remove('warning', 'danger');
        if (remaining < 60) {
            timerElement.classList.add('danger');
        } else if (remaining < 180) {
            timerElement.classList.add('warning');
        }
    },

    completeMission(mission) {
        const card = document.getElementById(`mission-${mission.id}`);
        if (!card) return;

        // Show completion overlay
        const overlay = document.createElement('div');
        overlay.className = 'mission-complete-overlay';
        overlay.innerHTML = `
            <div class="complete-icon">✅</div>
            <div class="complete-text">Mission Terminée !</div>
        `;

        card.appendChild(overlay);

        // Mark card as completed
        setTimeout(() => {
            card.classList.add('completed');
        }, 2000);

        // Remove after animation
        setTimeout(() => {
            card.remove();
            delete this.missions[mission.id];

            // Hide container if no more missions
            if (Object.keys(this.missions).length === 0) {
                this.hide();
            }
        }, 2500);
    }
};

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    ObjectivesUI.init();
});

console.log('[OBJECTIVES UI] Script loaded');
