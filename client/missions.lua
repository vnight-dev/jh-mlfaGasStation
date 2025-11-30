local activeMission = nil
local missionVehicle = nil
local missionBlip = nil

-- Start Fuel Delivery Mission
function StartFuelDeliveryMission(missionId, config)
    activeMission = {
        id = missionId,
        type = 'FuelDelivery',
        config = config
    }
    
    -- Spawn tanker
    local spawnPoint = config.spawnPoint
    RequestModel(config.vehicleModel)
    while not HasModelLoaded(config.vehicleModel) do Wait(10) end
    
    missionVehicle = CreateVehicle(GetHashKey(config.vehicleModel), spawnPoint.x, spawnPoint.y, spawnPoint.z, 0.0, true, false)
    SetVehicleNumberPlateText(missionVehicle, "FUEL"..missionId)
    SetEntityAsMissionEntity(missionVehicle, true, true)
    
    -- Blip
    missionBlip = AddBlipForEntity(missionVehicle)
    SetBlipSprite(missionBlip, 477)
    SetBlipColour(missionBlip, 5)
    SetBlipRoute(missionBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Camion citerne")
    EndTextCommandSetBlipName(missionBlip)
    
    Config.Notifications.info('Récupérez le camion au port')
    
    -- Monitor
    Citizen.CreateThread(function()
        while activeMission do
            Wait(1000)
            
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if vehicle == missionVehicle then
                local deliveryPoint = nil
                for _, station in ipairs(Config.Stations) do
                    if station.id == currentStation then
                        deliveryPoint = station.coords
                        break
                    end
                end
                
                if deliveryPoint then
                    local coords = GetEntityCoords(playerPed)
                    local dist = #(coords - deliveryPoint)
                    
                    if dist < 10.0 then
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour livrer")
                        if IsControlJustReleased(0, 38) then
                            CompleteMission(true)
                        end
                    end
                end
            end
            
            if not DoesEntityExist(missionVehicle) or IsEntityDead(missionVehicle) then
                CompleteMission(false)
            end
        end
    end)
end

function CompleteMission(success)
    if not activeMission then return end
    
    TriggerServerEvent('mlfaGasStation:completeMission', activeMission.id, success)
    
    if missionBlip then RemoveBlip(missionBlip) missionBlip = nil end
    if missionVehicle then DeleteVehicle(missionVehicle) missionVehicle = nil end
    
    activeMission = nil
end

RegisterNUICallback('startMissionClient', function(data, cb)
    if data.missionType == 'FuelDelivery' then
        StartFuelDeliveryMission(data.missionId, data.config)
    end
    cb('ok')
end)

print('[MLFA GASSTATION] Missions client loaded')
