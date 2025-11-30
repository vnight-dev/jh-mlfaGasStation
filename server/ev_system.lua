-- ============================================================================
-- EV CHARGING SYSTEM - V6.0
-- Electric Vehicle charging infrastructure management
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local EVConfig = {
    Enabled = true,
    
    -- Charging speeds (kW)
    ChargerTypes = {
        standard = { speed = 22, price = 0.30 },   -- AC Charger
        fast = { speed = 50, price = 0.45 },       -- DC Fast Charger
        super = { speed = 150, price = 0.60 }      -- Supercharger
    },
    
    -- Electricity cost for station owner (per kWh)
    ElectricityCost = 0.15,
    
    -- Supported vehicles (hashes)
    ElectricVehicles = {
        [`neon`] = { capacity = 100 },      -- 100 kWh battery
        [`raiden`] = { capacity = 90 },
        [`cyclone`] = { capacity = 110 },
        [`voltic`] = { capacity = 60 },
        [`tezeract`] = { capacity = 120 },
        [`dilettante`] = { capacity = 40 }, -- Hybrid
        [`khamelion`] = { capacity = 80 }
    }
}

-- Active charging sessions
local chargingSessions = {} -- [vehicleNetId] = {stationId, chargerType, startTime, kwhDelivered}

-- ============================================================================
-- CHARGING LOGIC
-- ============================================================================

-- Start charging session
RegisterServerEvent('mlfaGasStation:startCharging')
AddEventHandler('mlfaGasStation:startCharging', function(stationId, vehicleNetId, chargerType)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not EVConfig.Enabled then return end
    
    -- Verify vehicle is electric
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    local model = GetEntityModel(vehicle)
    
    if not EVConfig.ElectricVehicles[model] then
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Ce véhicule n\'est pas électrique !')
        return
    end
    
    -- Start session
    chargingSessions[vehicleNetId] = {
        stationId = stationId,
        chargerType = chargerType,
        startTime = os.time(),
        kwhDelivered = 0,
        owner = xPlayer.identifier
    }
    
    TriggerClientEvent('mlfaGasStation:chargingStarted', source, vehicleNetId)
    TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Recharge commencée...')
    
    print(string.format('[EV] Charging started: Station %d, Vehicle %d', stationId, vehicleNetId))
end)

-- Stop charging session
RegisterServerEvent('mlfaGasStation:stopCharging')
AddEventHandler('mlfaGasStation:stopCharging', function(vehicleNetId)
    local source = source
    local session = chargingSessions[vehicleNetId]
    
    if not session then return end
    
    local charger = EVConfig.ChargerTypes[session.chargerType]
    local duration = os.time() - session.startTime
    
    -- Calculate kWh delivered (simplified physics)
    -- Speed (kW) * Time (hours) = kWh
    local hours = duration / 3600
    local kwh = charger.speed * hours
    
    -- Calculate cost
    local cost = kwh * charger.price
    local electricityCost = kwh * EVConfig.ElectricityCost
    local profit = cost - electricityCost
    
    -- Process payment
    local xPlayer = ESX.GetPlayerFromIdentifier(session.owner)
    if xPlayer then
        if xPlayer.getMoney() >= cost then
            xPlayer.removeMoney(math.floor(cost))
            
            -- Add to station money
            if session.stationId then
                MySQL.update('UPDATE gas_stations SET money = money + ? WHERE id = ?', {
                    profit, session.stationId
                })
                
                -- Log transaction
                MySQL.insert('INSERT INTO gas_transactions (station_id, type, amount, description, created_by) VALUES (?, ?, ?, ?, ?)', {
                    session.stationId, 'ev_charge', cost, 
                    string.format('Recharge EV: %.2f kWh', kwh), 'system'
                })
            end
            
            TriggerClientEvent('mlfaGasStation:notify', source, 'success', 
                string.format('Recharge terminée: $%.2f (%.2f kWh)', cost, kwh))
        else
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Paiement refusé (fonds insuffisants)')
        end
    end
    
    chargingSessions[vehicleNetId] = nil
    TriggerClientEvent('mlfaGasStation:chargingStopped', source, vehicleNetId)
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('IsElectricVehicle', function(modelHash)
    return EVConfig.ElectricVehicles[modelHash] ~= nil
end)

print('[MLFA GASSTATION] EV Charging system loaded')
