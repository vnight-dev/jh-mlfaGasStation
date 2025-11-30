local ESX = exports['es_extended']:getSharedObject()
local currentStation = nil
local inMission = false
local missionVehicle = nil
local missionBlip = nil
local missionDestination = nil

-- Blips
Citizen.CreateThread(function()
    for _, station in ipairs(Config.Stations) do
        local blip = AddBlipForCoord(station.position)
        SetBlipSprite(blip, station.blip.sprite)
        SetBlipColour(blip, station.blip.color)
        SetBlipScale(blip, station.blip.scale)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Markers & Interaction
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        for _, station in ipairs(Config.Stations) do
            -- 1. PUMP INTERACTION (Fueling)
            local distPump = #(coords - station.position)
            if distPump < 20.0 then
                wait = 0
                DrawMarker(1, station.position.x, station.position.y, station.position.z - 1.0, 0,0,0,0,0,0, 3.0,3.0,1.0, 255,165,0,100, false,true,2,false)
                
                if distPump < 3.0 then
                    ESX.ShowHelpNotification('Appuie sur ~INPUT_CONTEXT~ pour faire le plein')
                    if IsControlJustReleased(0, 38) then
                        -- Fetch station info first to check stock/price
                        ESX.TriggerServerCallback('mlfaGasStation:getStationInfo', function(info)
                            currentStation = info
                            TriggerEvent('mlfaGasStation:fuelVehicle')
                        end, station.id)
                    end
                end
            end

            -- 2. MANAGEMENT INTERACTION (UI)
            if station.management then
                local distMgmt = #(coords - station.management)
                if distMgmt < 10.0 then
                    wait = 0
                    DrawMarker(29, station.management.x, station.management.y, station.management.z, 0,0,0,0,0,0, 1.0,1.0,1.0, 0,255,255,100, false,true,2,false)
                    
                    if distMgmt < 2.0 then
                        ESX.ShowHelpNotification('Appuie sur ~INPUT_CONTEXT~ pour gérer la station')
                        if IsControlJustReleased(0, 38) then
                            OpenStationMenu(station.id)
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

function OpenStationMenu(stationId)
    ESX.TriggerServerCallback('mlfaGasStation:getStationInfo', function(info)
        currentStation = info
        if not currentStation then return end

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openMenu',
            station = currentStation
        })
    end, stationId)
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('fuelVehicle', function(data, cb)
    TriggerEvent('mlfaGasStation:fuelVehicle')
    cb('ok')
end)



RegisterNUICallback('startMission', function(data, cb)
    StartMission()
    cb('ok')
end)

-- Fueling Logic
RegisterNetEvent('mlfaGasStation:fuelVehicle')
AddEventHandler('mlfaGasStation:fuelVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle and currentStation and currentStation.stock > 0 then
        local currentFuel = 0
        -- Fix: Use correct export for fscripts_fuel or fallback
        if exports[Config.FuelExport] and exports[Config.FuelExport].getVehFuel then
            currentFuel = tonumber(exports[Config.FuelExport]:getVehFuel(vehicle))
        else
            currentFuel = GetVehicleFuelLevel(vehicle)
        end
        
        local maxFuel = 100.0
        local needed = maxFuel - currentFuel
        
        if needed > 1.0 then
            local cost = math.ceil(needed * currentStation.fuel_price)
            exports['mlfa_notifications']:ShowProgressBar("Remplissage en cours...", 5000)
            Wait(5000)
            TriggerServerEvent('mlfaGasStation:payFuel', currentStation.id, math.floor(needed), cost)
        else
            exports['mlfa_notifications']:ShowNotification("Réservoir déjà plein !", "error")
        end
    else
        exports['mlfa_notifications']:ShowNotification("Vous devez être dans un véhicule ou la station est vide !", "error")
    end
end)

RegisterNetEvent('mlfaGasStation:setFuel')
AddEventHandler('mlfaGasStation:setFuel', function(liters)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle then
        local currentFuel = GetVehicleFuelLevel(vehicle)
        local newFuel = currentFuel + liters
        if newFuel > 100.0 then newFuel = 100.0 end
        
        -- Fix: Use native SetVehicleFuelLevel as SetFuel export is missing
        SetVehicleFuelLevel(vehicle, newFuel)
        -- Try to update Decor if possible
        pcall(function() DecorSetFloat(vehicle, "_FUEL_LEVEL", newFuel) end)
        
        exports['mlfa_notifications']:ShowNotification("Véhicule ravitaillé : +" .. liters .. "L", "success")
    end
end)

-- === MISSION SYSTEM ===
function StartMission()
    if inMission then return exports['mlfa_notifications']:ShowNotification("Mission déjà en cours !", "error") end
    
    local spawnPoint = currentStation.position + vector3(5.0, 5.0, 0.0) -- Simple offset
    ESX.Game.SpawnVehicle(Config.MissionVehicle, spawnPoint, 0.0, function(veh)
        missionVehicle = veh
        inMission = true
        SetVehicleNumberPlateText(veh, "FUEL"..math.random(100,999))
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        
        -- Select Random Destination
        local dest = Config.MissionPoints[math.random(#Config.MissionPoints)]
        missionDestination = dest
        
        -- Blip
        missionBlip = AddBlipForCoord(dest)
        SetBlipSprite(missionBlip, 1)
        SetBlipColour(missionBlip, 5)
        SetBlipRoute(missionBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Livraison Essence")
        EndTextCommandSetBlipName(missionBlip)
        
        exports['mlfa_notifications']:ShowNotification("Livrez le camion au point indiqué GPS.", "info")
        MissionLoop()
    end)
end

function MissionLoop()
    Citizen.CreateThread(function()
        while inMission do
            Wait(1000)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            
            if not DoesEntityExist(missionVehicle) or GetEntityHealth(missionVehicle) <= 0 then
                exports['mlfa_notifications']:ShowNotification("Mission échouée : Camion détruit.", "error")
                EndMission(false)
                break
            end
            
            local dist = #(GetEntityCoords(ped) - missionDestination)
            if dist < 15.0 then
                if veh == missionVehicle then
                    exports['mlfa_notifications']:ShowNotification("Livraison effectuée ! Retournez à la station.", "success")
                    RemoveBlip(missionBlip)
                    
                    -- Return Trip
                    missionDestination = currentStation.position
                    missionBlip = AddBlipForCoord(missionDestination)
                    SetBlipSprite(missionBlip, 1)
                    SetBlipColour(missionBlip, 2)
                    SetBlipRoute(missionBlip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Retour Station")
                    EndTextCommandSetBlipName(missionBlip)
                    
                    while true do
                        Wait(1000)
                        local distReturn = #(GetEntityCoords(ped) - missionDestination)
                        if distReturn < 15.0 then
                            if veh == missionVehicle then
                                EndMission(true)
                                return
                            end
                        end
                    end
                else
                    exports['mlfa_notifications']:ShowNotification("Vous devez être dans le camion !", "error")
                end
            end
        end
    end)
end

function EndMission(success)
    inMission = false
    if missionBlip then RemoveBlip(missionBlip) end
    if missionVehicle then ESX.Game.DeleteVehicle(missionVehicle) end
    
    if success then
        TriggerServerEvent('mlfaGasStation:missionReward', currentStation.id)
        exports['mlfa_notifications']:ShowNotification("Mission réussie !", "success")
    end
end