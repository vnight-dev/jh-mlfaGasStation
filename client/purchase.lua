local ESX = exports['es_extended']:getSharedObject()
local purchaseUIOpen = false
local currentPurchaseStation = nil

-- Simple Purchase UI
function ShowPurchaseUI(station)
    if purchaseUIOpen then return end
    
    purchaseUIOpen = true
    currentPurchaseStation = station
    
    print('[PURCHASE] Opening purchase UI for ' .. station.label)
    
    SendNUIMessage({
        type = 'showPurchasePrompt',
        data = {
            stationName = station.label,
            price = Config.StationPurchasePrice
        }
    })
    
    -- Enable NUI focus for mouse clicks
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    
    print('[PURCHASE] NUI focus enabled')
end

function HidePurchaseUI()
    if not purchaseUIOpen then return end
    
    purchaseUIOpen = false
    currentPurchaseStation = nil
    
    SendNUIMessage({
        type = 'hidePurchasePrompt'
    })
    SetNuiFocus(false, false)
end

-- NUI Callback for purchase
RegisterNUICallback('confirmPurchase', function(data, cb)
    print('[PURCHASE] Confirm purchase callback received')
    cb('ok')
    
    if currentPurchaseStation then
        print('[PURCHASE] Purchasing station ID: ' .. currentPurchaseStation.id)
        TriggerServerEvent('mlfaGasStation:purchaseStation', currentPurchaseStation.id)
        HidePurchaseUI()
    else
        print('[PURCHASE] ERROR: No current purchase station')
    end
end)

RegisterNUICallback('cancelPurchase', function(data, cb)
    print('[PURCHASE] Cancel purchase callback received')
    cb('ok')
    HidePurchaseUI()
end)

-- Check if station is owned
local stationOwners = {}

RegisterNetEvent('mlfaGasStation:updateStationOwner')
AddEventHandler('mlfaGasStation:updateStationOwner', function(stationId, owner)
    stationOwners[stationId] = owner
end)

-- Request station owners on resource start
Citizen.CreateThread(function()
    Wait(1000)
    for _, station in ipairs(Config.Stations) do
        ESX.TriggerServerCallback('mlfaGasStation:getStationOwner', function(owner)
            stationOwners[station.id] = owner
        end, station.id)
    end
end)

-- Purchase markers thread
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        for _, station in ipairs(Config.Stations) do
            local purchasePoint = station.purchasePoint or station.coords
            local dist = #(coords - purchasePoint)
            
            -- Only show marker if station is not owned
            if not stationOwners[station.id] or stationOwners[station.id] == '' then
                if dist < 50.0 then
                    wait = 0
                    
                    -- Draw marker
                    DrawMarker(
                        Config.PurchaseMarker.type,
                        purchasePoint.x, purchasePoint.y, purchasePoint.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.PurchaseMarker.size.x, Config.PurchaseMarker.size.y, Config.PurchaseMarker.size.z,
                        Config.PurchaseMarker.color.r, Config.PurchaseMarker.color.g, Config.PurchaseMarker.color.b, Config.PurchaseMarker.color.a,
                        false, true, 2, false
                    )
                    
                    if dist < Config.PurchaseMarker.distance then
                        -- Show help text
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour acheter ~b~" .. station.label)
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            ShowPurchaseUI(station)
                        end
                    end
                end
            end
        end
        
        Wait(wait)
    end
end)

-- Close UI on ESC
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if purchaseUIOpen then
            if IsControlJustReleased(0, 322) then -- ESC
                HidePurchaseUI()
            end
        else
            Wait(500)
        end
    end
end)

print('[MLFA GASSTATION] Purchase system loaded')
