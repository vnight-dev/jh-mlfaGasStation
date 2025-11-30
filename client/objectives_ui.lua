-- ============================================================================
-- MISSION OBJECTIVES UI SYSTEM
-- Real-time mission tracking with progress bars and objectives
-- ============================================================================

local activeMissions = {} -- {missionId, type, objectives, currentStep, startTime, duration}
local uiVisible = false

-- ============================================================================
-- MISSION TRACKING
-- ============================================================================

-- Start tracking a mission
function StartMissionTracking(missionData)
    local missionId = #activeMissions + 1
    
    activeMissions[missionId] = {
        id = missionId,
        type = missionData.type,
        title = missionData.title,
        objectives = missionData.objectives or {},
        currentStep = 1,
        startTime = GetGameTimer(),
        duration = missionData.duration or 0,
        reward = missionData.reward or 0,
        completed = false
    }
    
    -- Show UI
    ShowObjectivesUI()
    
    -- Send to NUI
    SendNUIMessage({
        type = 'updateObjectives',
        missions = activeMissions
    })
    
    print('[OBJECTIVES] Mission started: ' .. missionData.title)
end

-- Update mission progress
function UpdateMissionProgress(missionId, stepIndex, completed)
    if not activeMissions[missionId] then return end
    
    local mission = activeMissions[missionId]
    
    if completed then
        mission.currentStep = stepIndex + 1
        
        -- Check if all objectives completed
        if mission.currentStep > #mission.objectives then
            CompleteMission(missionId)
        else
            -- Update UI
            SendNUIMessage({
                type = 'updateObjectives',
                missions = activeMissions
            })
        end
    end
end

-- Complete mission
function CompleteMission(missionId)
    if not activeMissions[missionId] then return end
    
    local mission = activeMissions[missionId]
    mission.completed = true
    
    -- Show completion notification
    SendNUIMessage({
        type = 'missionComplete',
        mission = mission
    })
    
    -- Remove after 5 seconds
    Citizen.SetTimeout(5000, function()
        activeMissions[missionId] = nil
        
        -- Hide UI if no more missions
        if #activeMissions == 0 then
            HideObjectivesUI()
        else
            SendNUIMessage({
                type = 'updateObjectives',
                missions = activeMissions
            })
        end
    end)
    
    print('[OBJECTIVES] Mission completed: ' .. mission.title)
end

-- Cancel mission
function CancelMission(missionId)
    if not activeMissions[missionId] then return end
    
    activeMissions[missionId] = nil
    
    if #activeMissions == 0 then
        HideObjectivesUI()
    else
        SendNUIMessage({
            type = 'updateObjectives',
            missions = activeMissions
        })
    end
end

-- ============================================================================
-- UI CONTROL
-- ============================================================================

function ShowObjectivesUI()
    if uiVisible then return end
    
    uiVisible = true
    SendNUIMessage({
        type = 'showObjectives'
    })
end

function HideObjectivesUI()
    uiVisible = false
    SendNUIMessage({
        type = 'hideObjectives'
    })
end

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Start fuel delivery mission
RegisterNetEvent('mlfaGasStation:startFuelDelivery')
AddEventHandler('mlfaGasStation:startFuelDelivery', function(stationId, stationName)
    StartMissionTracking({
        type = 'fuel_delivery',
        title = 'Livraison de Carburant',
        objectives = {
            {text = 'Récupérer le camion-citerne', completed = false},
            {text = 'Se rendre à la station ' .. stationName, completed = false},
            {text = 'Livrer le carburant', completed = false}
        },
        duration = Config.Missions.FuelDelivery.DeliveryTime,
        reward = Config.Missions.FuelDelivery.Reward
    })
end)

-- Start maintenance mission
RegisterNetEvent('mlfaGasStation:startMaintenance')
AddEventHandler('mlfaGasStation:startMaintenance', function(stationId, stationName)
    StartMissionTracking({
        type = 'maintenance',
        title = 'Maintenance de la Station',
        objectives = {
            {text = 'Vérifier les pompes', completed = false},
            {text = 'Nettoyer les filtres', completed = false},
            {text = 'Tester le système', completed = false}
        },
        duration = Config.Missions.Maintenance.Duration,
        reward = Config.Missions.Maintenance.Reward
    })
end)

-- Start cleaning mission
RegisterNetEvent('mlfaGasStation:startCleaning')
AddEventHandler('mlfaGasStation:startCleaning', function(stationId, stationName)
    StartMissionTracking({
        type = 'cleaning',
        title = 'Nettoyage de la Station',
        objectives = {
            {text = 'Nettoyer les pompes', completed = false},
            {text = 'Nettoyer le sol', completed = false}
        },
        duration = Config.Missions.Cleaning.Duration,
        reward = Config.Missions.Cleaning.Reward
    })
end)

-- Update objective
RegisterNetEvent('mlfaGasStation:updateObjective')
AddEventHandler('mlfaGasStation:updateObjective', function(missionId, stepIndex)
    UpdateMissionProgress(missionId, stepIndex, true)
end)

-- Complete mission
RegisterNetEvent('mlfaGasStation:completeMission')
AddEventHandler('mlfaGasStation:completeMission', function(missionId)
    CompleteMission(missionId)
end)

-- Cancel mission
RegisterNetEvent('mlfaGasStation:cancelMission')
AddEventHandler('mlfaGasStation:cancelMission', function(missionId)
    CancelMission(missionId)
end)

-- ============================================================================
-- TIMER UPDATE
-- ============================================================================

Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Update every second
        
        if #activeMissions > 0 then
            local currentTime = GetGameTimer()
            
            for missionId, mission in pairs(activeMissions) do
                if mission and not mission.completed then
                    local elapsed = (currentTime - mission.startTime) / 1000
                    local remaining = mission.duration - elapsed
                    
                    if remaining <= 0 then
                        -- Mission failed (timeout)
                        CancelMission(missionId)
                        TriggerEvent('mlfaGasStation:notify', 'error', 'Mission échouée: Temps écoulé')
                    else
                        -- Update timer
                        SendNUIMessage({
                            type = 'updateTimer',
                            missionId = missionId,
                            remaining = remaining
                        })
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('StartMission', StartMissionTracking)
exports('UpdateObjective', UpdateMissionProgress)
exports('CompleteMission', CompleteMission)
exports('CancelMission', CancelMission)
exports('GetActiveMissions', function() return activeMissions end)

print('[MLFA GASSTATION] Mission objectives UI loaded')
