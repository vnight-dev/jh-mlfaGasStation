local ESX = exports['es_extended']:getSharedObject()
local isTabletOpen = false
local tabletProp = nil
local currentStation = nil

-- Toggle Tablet (matching jh-juge style)
function ToggleTablet(state, stationId)
    local playerPed = PlayerPedId()
    
    if state then
        if not isTabletOpen then
            currentStation = stationId
            
            print('[GASMANAGER] Opening tablet for station ' .. stationId)
            
            -- Animation
            RequestAnimDict(Config.TabletAnim.dict)
            while not HasAnimDictLoaded(Config.TabletAnim.dict) do Wait(10) end
            
            TaskPlayAnim(playerPed, Config.TabletAnim.dict, Config.TabletAnim.anim, 8.0, -8.0, -1, 50, 0, false, false, false)
            
            -- Prop
            if not tabletProp then
                RequestModel(Config.TabletProp)
                while not HasModelLoaded(Config.TabletProp) do Wait(10) end
                
                local coords = GetEntityCoords(playerPed)
                local boneIndex = GetPedBoneIndex(playerPed, 28422)
                
                tabletProp = CreateObject(GetHashKey(Config.TabletProp), coords.x, coords.y, coords.z, true, true, true)
                AttachEntityToEntity(tabletProp, playerPed, boneIndex, -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
            end
            
            isTabletOpen = true
            
            -- Fetch station data
            ESX.TriggerServerCallback('mlfaGasStation:getStationData', function(data)
                print('[GASMANAGER] Received data from server:', json.encode(data))
                if data then
                    -- Set NUI focus AFTER receiving data
                    SetNuiFocus(true, true)
                    
                    SendNUIMessage({
                        type = 'open',
                        data = data
                    })
                    print('[GASMANAGER] Sent open message to NUI')
                else
                    print('[GASMANAGER] No data received from server')
                    Config.Notifications.error('Impossible de charger les données')
                    ToggleTablet(false)
                end
            end, stationId)
        end
    else
        if isTabletOpen then
            print('[GASMANAGER] Closing tablet')
            
            -- Clear NUI focus FIRST
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            
            -- Stop animation
            ClearPedTasks(playerPed)
            StopAnimTask(playerPed, Config.TabletAnim.dict, Config.TabletAnim.anim, 1.0)
            
            -- Remove prop
            if tabletProp then
                DeleteEntity(tabletProp)
                tabletProp = nil
            end
            
            isTabletOpen = false
            currentStation = nil
            
            -- Send close message to NUI
            SendNUIMessage({ type = 'close' })
            
            -- Force enable controls
            Citizen.Wait(100)
            EnableAllControlActions(0)
        end
    end
end

-- Command to open tablet
RegisterCommand('gasmanager', function()
    if not isTabletOpen then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearestStation = nil
        local nearestDist = 999999.0
        
        for _, station in ipairs(Config.Stations) do
            local dist = #(playerCoords - station.coords)
            if dist < nearestDist and dist < 10.0 then
                nearestDist = dist
                nearestStation = station
            end
        end
        
        if nearestStation then
            ToggleTablet(true, nearestStation.id)
        else
            Config.Notifications.error('Vous devez être près d\'une station-service')
        end
    else
        ToggleTablet(false)
    end
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    print('[GASMANAGER] NUI close callback received')
    cb('ok')
    ToggleTablet(false)
end)

RegisterNUICallback('startMission', function(data, cb)
    ESX.TriggerServerCallback('mlfaGasStation:startMission', function(result)
        cb(result)
    end, currentStation, data.missionType)
end)

RegisterNUICallback('hireEmployee', function(data, cb)
    TriggerServerEvent('mlfaGasStation:hireEmployee', currentStation, data.targetId, data.rank)
    cb('ok')
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    TriggerServerEvent('mlfaGasStation:fireEmployee', currentStation, data.employeeId)
    cb('ok')
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('mlfaGasStation:withdrawMoney', currentStation, data.amount)
    cb('ok')
end)

RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('mlfaGasStation:depositMoney', currentStation, data.amount)
    cb('ok')
end)

RegisterNUICallback('updateFuelPrice', function(data, cb)
    TriggerServerEvent('mlfaGasStation:updateFuelPrice', currentStation, data.price)
    cb('ok')
end)

RegisterNUICallback('purchaseStation', function(data, cb)
    TriggerServerEvent('mlfaGasStation:purchaseStation', currentStation)
    cb('ok')
end)

RegisterNUICallback('sellStation', function(data, cb)
    TriggerServerEvent('mlfaGasStation:sellStation', currentStation)
    cb('ok')
end)

RegisterNUICallback('togglePermission', function(data, cb)
    TriggerServerEvent('mlfaGasStation:togglePermission', currentStation, data.rankName, data.permissionKey)
    cb('ok')
end)

-- Notification handler
RegisterNetEvent('mlfaGasStation:notify')
AddEventHandler('mlfaGasStation:notify', function(type, message)
    if type == 'success' then
        Config.Notifications.success(message)
    elseif type == 'error' then
        Config.Notifications.error(message)
    else
        Config.Notifications.info(message)
    end
end)

-- Create blips
Citizen.CreateThread(function()
    for _, station in ipairs(Config.Stations) do
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, station.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, station.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Interaction markers
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        for _, station in ipairs(Config.Stations) do
            local dist = #(coords - station.coords)
            if dist < 10.0 then
                wait = 0
                DrawMarker(20, station.coords.x, station.coords.y, station.coords.z,
                    0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 242, 234, 100, false, true, 2, false)
                
                if dist < 2.0 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le GasManager")
                    if IsControlJustReleased(0, Config.OpenKey) then
                        ToggleTablet(true, station.id)
                    end
                end
            end
        end
        
        Wait(wait)
    end
end)

print('[MLFA GASSTATION] Client main loaded')
