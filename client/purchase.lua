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
    
    print('[PURCHASE] Hiding purchase UI and disabling focus')
    purchaseUIOpen = false
    currentPurchaseStation = nil
    
    SendNUIMessage({
        type = 'hidePurchasePrompt'
    })
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end

-- NUI Callback for purchase
RegisterNUICallback('confirmPurchase', function(data, cb)
    print('[PURCHASE] Confirm purchase callback received')
    cb('ok')
    
    if currentPurchaseStation then
        print('[PURCHASE] Purchasing station ID: ' .. currentPurchaseStation.id)
        TriggerServerEvent('mlfaGasStation:purchaseStation', currentPurchaseStation.id)
        HidePurchaseUI()
        
        -- Open tablet immediately after purchase (optimistic UI)
        -- REMOVED: Caused race condition. Now waiting for server event.
    else
        print('[PURCHASE] ERROR: No current purchase station')
    end
end)

RegisterNetEvent('mlfaGasStation:purchaseSuccess')
AddEventHandler('mlfaGasStation:purchaseSuccess', function(stationId)
    print('[PURCHASE] DEBUG: purchaseSuccess event received for station ' .. tostring(stationId))
    
    -- Force update local owner cache immediately
    if myIdentifier then
        stationOwners[stationId] = myIdentifier
        print('[PURCHASE] DEBUG: Local owner cache updated. New owner: ' .. tostring(stationOwners[stationId]))
    else
        print('[PURCHASE] ERROR: myIdentifier is nil!')
    end
    
    Wait(500) -- Small delay to ensure DB sync
    print('[PURCHASE] DEBUG: Attempting to open tablet...')
    ToggleTablet(true, stationId)
end)

RegisterNUICallback('cancelPurchase', function(data, cb)
    print('[PURCHASE] Cancel purchase callback received')
    cb('ok')
    HidePurchaseUI()
end)

-- Check if station is owned
local stationOwners = {}
local myIdentifier = nil

RegisterNetEvent('mlfaGasStation:updateStationOwner')
AddEventHandler('mlfaGasStation:updateStationOwner', function(stationId, owner)
    print('[PURCHASE] Received owner update for station ' .. stationId .. ': ' .. tostring(owner))
    stationOwners[stationId] = owner
end)

-- Request station owners on resource start
Citizen.CreateThread(function()
    Wait(1000)
    
    -- Try to get identifier from PlayerData first
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.identifier then
        myIdentifier = playerData.identifier
        print('[PURCHASE] Identifier from PlayerData: ' .. tostring(myIdentifier))
    end
    
    -- Fallback to callback if needed
    if not myIdentifier then
        ESX.TriggerServerCallback('mlfaGasStation:getMyIdentifier', function(identifier)
            myIdentifier = identifier
            print('[PURCHASE] Identifier from callback: ' .. tostring(identifier))
        end)
    end
    
    -- Retry loop
    Citizen.CreateThread(function()
        while myIdentifier == nil do
            Wait(2000)
            if ESX.IsPlayerLoaded() then
                local pd = ESX.GetPlayerData()
                if pd and pd.identifier then
                    myIdentifier = pd.identifier
                    print('[PURCHASE] Identifier found in retry loop')
                else
                    ESX.TriggerServerCallback('mlfaGasStation:getMyIdentifier', function(identifier)
                        myIdentifier = identifier
                    end)
                end
            end
        end
    end)
    
    for _, station in ipairs(Config.Stations) do
        ESX.TriggerServerCallback('mlfaGasStation:getStationOwner', function(owner)
            stationOwners[station.id] = owner
        end, station.id)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.TriggerServerCallback('mlfaGasStation:getMyIdentifier', function(identifier)
        myIdentifier = identifier
        print('[PURCHASE] Identifier updated (playerLoaded): ' .. tostring(identifier))
    end)
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
            
            -- Logic:
            -- If NOT owned: Show BUY marker
            -- If OWNED: Handled by main.lua (Manage marker)
            
            if not stationOwners[station.id] or stationOwners[station.id] == '' then
                if dist < 50.0 then
                    wait = 0
                    
                    -- Draw marker (Green for Buy)
                    DrawMarker(
                        Config.PurchaseMarker.type,
                        purchasePoint.x, purchasePoint.y, purchasePoint.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.PurchaseMarker.size.x, Config.PurchaseMarker.size.y, Config.PurchaseMarker.size.z,
                        0, 255, 0, 150, -- Green
                        false, true, 2, false
                    )
                    
                    if dist < Config.PurchaseMarker.distance then
                        -- Show help text
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ~g~ACHETER~s~ cette station")
                        
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

RegisterCommand('debugpurchase', function(source, args)
    local stationId = tonumber(args[1])
    if stationId then
        print('[DEBUG] Simulating purchase success for station ' .. stationId)
        TriggerEvent('mlfaGasStation:purchaseSuccess', stationId)
    else
        print('[DEBUG] Usage: /debugpurchase [stationId]')
    end
end)

RegisterCommand('forcebuy', function(source, args)
    local stationId = tonumber(args[1])
    if stationId then
        print('[DEBUG] Forcing purchase for station ' .. stationId)
        TriggerServerEvent('mlfaGasStation:purchaseStation', stationId)
    else
        print('[DEBUG] Usage: /forcebuy [stationId]')
    end
end)
