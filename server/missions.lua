local ESX = exports['es_extended']:getSharedObject()
local activeMissions = {}

-- Start Mission Callback
ESX.RegisterServerCallback('mlfaGasStation:startMission', function(source, cb, stationId, missionType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({success = false, message = 'Joueur introuvable'}) end
    
    if activeMissions[source] then
        return cb({success = false, message = 'Mission en cours'})
    end
    
    GetEmployeeRank(xPlayer.identifier, stationId, function(rank)
        if not rank then
            return cb({success = false, message = 'Non employé'})
        end
        
        local permissions = {}
        for _, r in ipairs(Config.Ranks) do
            if r.name == rank then permissions = r.permissions break end
        end
        
        if not permissions.startMissions then
            return cb({success = false, message = 'Permission refusée'})
        end
        
        MySQL.insert([[
            INSERT INTO gas_missions (station_id, player_id, mission_type, status)
            VALUES (?, ?, ?, 'active')
        ]], {stationId, xPlayer.identifier, missionType}, function(missionId)
            if missionId then
                activeMissions[source] = {
                    id = missionId,
                    stationId = stationId,
                    type = missionType
                }
                
                cb({
                    success = true,
                    missionId = missionId,
                    config = Config.FuelDeliveryMission
                })
            else
                cb({success = false, message = 'Erreur création mission'})
            end
        end)
    end)
end)

-- Complete Mission
RegisterNetEvent('mlfaGasStation:completeMission')
AddEventHandler('mlfaGasStation:completeMission', function(missionId, success)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local mission = activeMissions[source]
    if not mission or mission.id ~= missionId then return end
    
    if success then
        MySQL.update('UPDATE gas_missions SET status = "completed", completed_at = NOW() WHERE id = ?', {missionId})
        
        xPlayer.addMoney(Config.FuelDeliveryMission.reward)
        UpdateStationFuel(mission.stationId, Config.FuelDeliveryMission.fuelAmount)
        AddTransaction(mission.stationId, 'fuel_purchase', 0, 
            'Livraison: +' .. Config.FuelDeliveryMission.fuelAmount .. 'L', xPlayer.identifier)
        
        TriggerClientEvent('mlfaGasStation:notify', source, 'success', 
            'Mission terminée! +$' .. Config.FuelDeliveryMission.reward)
    else
        MySQL.update('UPDATE gas_missions SET status = "failed", completed_at = NOW() WHERE id = ?', {missionId})
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Mission échouée')
    end
    
    activeMissions[source] = nil
end)

-- Cancel Mission
RegisterNetEvent('mlfaGasStation:cancelMission')
AddEventHandler('mlfaGasStation:cancelMission', function(missionId)
    local source = source
    local mission = activeMissions[source]
    
    if mission and mission.id == missionId then
        MySQL.update('UPDATE gas_missions SET status = "failed" WHERE id = ?', {missionId})
        activeMissions[source] = nil
        TriggerClientEvent('mlfaGasStation:notify', source, 'info', 'Mission annulée')
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if activeMissions[source] then
        MySQL.update('UPDATE gas_missions SET status = "failed" WHERE id = ?', {activeMissions[source].id})
        activeMissions[source] = nil
    end
end)

print('[MLFA GASSTATION] Missions server loaded')
