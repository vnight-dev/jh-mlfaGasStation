-- ============================================================================
-- MOBILE PHONE APP INTEGRATION
-- Manage your gas station from your in-game phone
-- Compatible with: lb-phone, qb-phone, qs-smartphone
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- PHONE DETECTION
-- ============================================================================

local phoneResource = nil
local phoneType = nil

Citizen.CreateThread(function()
    -- Detect phone resource
    if GetResourceState('lb-phone') == 'started' then
        phoneResource = 'lb-phone'
        phoneType = 'lb'
    elseif GetResourceState('qb-phone') == 'started' then
        phoneResource = 'qb-phone'
        phoneType = 'qb'
    elseif GetResourceState('qs-smartphone') == 'started' then
        phoneResource = 'qs-smartphone'
        phoneType = 'qs'
    end
    
    if phoneResource then
        print('[PHONE APP] Detected: ' .. phoneResource)
        RegisterPhoneApp()
    else
        print('[PHONE APP] No compatible phone resource detected')
    end
end)

-- ============================================================================
-- APP REGISTRATION
-- ============================================================================

function RegisterPhoneApp()
    if phoneType == 'lb' then
        -- LB Phone Integration
        exports['lb-phone']:AddCustomApp({
            identifier = 'gasstation',
            name = 'Gas Manager',
            description = 'Gérez votre station-service',
            icon = 'https://i.imgur.com/gasstation.png',
            ui = GetCurrentResourceName() .. '/html/phone_app.html',
            script = GetCurrentResourceName() .. '/html/js/phone_app.js'
        })
    elseif phoneType == 'qb' then
        -- QB Phone Integration
        TriggerEvent('qb-phone:client:AddCustomApp', {
            app = 'gasstation',
            color = '#00F2EA',
            icon = 'fas fa-gas-pump',
            tooltipText = 'Gas Manager',
            tooltipPos = 'right',
            job = false,
            blockedJobs = {},
            slot = 16,
            Alerts = 0
        })
    elseif phoneType == 'qs' then
        -- QS Smartphone Integration
        exports['qs-smartphone']:AddApp({
            app = 'gasstation',
            image = './img/apps/gasstation.png',
            ui = GetCurrentResourceName() .. '/html/phone_app.html',
            script = GetCurrentResourceName() .. '/html/js/phone_app.js'
        })
    end
    
    print('[PHONE APP] Gas Manager app registered')
end

-- ============================================================================
-- APP DATA PROVIDER
-- ============================================================================

RegisterNUICallback('phone:getStationData', function(data, cb)
    ESX.TriggerServerCallback('mlfaGasStation:getMyStations', function(stations)
        cb({
            success = true,
            stations = stations
        })
    end)
end)

RegisterNUICallback('phone:getStationStats', function(data, cb)
    local stationId = data.stationId
    
    ESX.TriggerServerCallback('mlfaGasStation:getStationStats', function(stats)
        cb({
            success = true,
            stats = stats
        })
    end, stationId)
end)

RegisterNUICallback('phone:startMission', function(data, cb)
    local stationId = data.stationId
    local missionType = data.missionType
    
    ESX.TriggerServerCallback('mlfaGasStation:startMission', function(result)
        cb(result)
    end, stationId, missionType)
end)

RegisterNUICallback('phone:manageEmployee', function(data, cb)
    local action = data.action
    local stationId = data.stationId
    local targetId = data.targetId
    
    ESX.TriggerServerCallback('mlfaGasStation:manageEmployee', function(result)
        cb(result)
    end, action, stationId, targetId)
end)

RegisterNUICallback('phone:withdrawMoney', function(data, cb)
    local stationId = data.stationId
    local amount = data.amount
    
    ESX.TriggerServerCallback('mlfaGasStation:withdrawMoney', function(result)
        cb(result)
    end, stationId, amount)
end)

RegisterNUICallback('phone:depositMoney', function(data, cb)
    local stationId = data.stationId
    local amount = data.amount
    
    ESX.TriggerServerCallback('mlfaGasStation:depositMoney', function(result)
        cb(result)
    end, stationId, amount)
end)

-- ============================================================================
-- PUSH NOTIFICATIONS TO PHONE
-- ============================================================================

function SendPhoneNotification(title, message, icon)
    if not phoneResource then return end
    
    if phoneType == 'lb' then
        exports['lb-phone']:SendNotification({
            app = 'gasstation',
            title = title,
            content = message,
            icon = icon or 'fas fa-gas-pump'
        })
    elseif phoneType == 'qb' then
        TriggerEvent('qb-phone:client:CustomNotification', 
            title, 
            message, 
            'fas fa-gas-pump', 
            '#00F2EA', 
            5000
        )
    elseif phoneType == 'qs' then
        exports['qs-smartphone']:SendNotification({
            app = 'gasstation',
            title = title,
            text = message
        })
    end
end

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Large sale notification
RegisterNetEvent('mlfaGasStation:phone:largeSale')
AddEventHandler('mlfaGasStation:phone:largeSale', function(amount, stationName)
    SendPhoneNotification(
        '💰 Vente Importante',
        string.format('%s: $%s', stationName, tostring(amount))
    )
end)

-- Low stock warning
RegisterNetEvent('mlfaGasStation:phone:lowStock')
AddEventHandler('mlfaGasStation:phone:lowStock', function(stationName, stock)
    SendPhoneNotification(
        '⚠️ Stock Faible',
        string.format('%s: %dL restants', stationName, stock)
    )
end)

-- Salary paid
RegisterNetEvent('mlfaGasStation:phone:salaryPaid')
AddEventHandler('mlfaGasStation:phone:salaryPaid', function(amount, stationName)
    SendPhoneNotification(
        '💵 Salaire Reçu',
        string.format('%s: $%s', stationName, tostring(amount))
    )
end)

-- Rank change
RegisterNetEvent('mlfaGasStation:phone:rankChange')
AddEventHandler('mlfaGasStation:phone:rankChange', function(newRank, stationName)
    SendPhoneNotification(
        '🏆 Classement',
        string.format('%s: %s', stationName, newRank)
    )
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('SendPhoneNotif', SendPhoneNotification)
exports('GetPhoneType', function() return phoneType end)
exports('IsPhoneAvailable', function() return phoneResource ~= nil end)

print('[MLFA GASSTATION] Mobile phone app integration loaded')
