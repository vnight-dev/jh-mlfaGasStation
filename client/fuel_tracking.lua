-- This module tracks fuel purchases client-side and sends data to server

local lastFuelLevel = {}

-- Monitor vehicle fuel levels
Citizen.CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle and vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            
            -- Get current fuel level from fscript_fuel
            if exports['fscripts_fuel'] then
                local currentFuel = exports['fscripts_fuel']:getVehFuel(vehicle)
                
                if currentFuel then
                    -- Convert to number (fscripts_fuel might return string)
                    currentFuel = tonumber(currentFuel) or 0
                    
                    -- Check if fuel increased (player refueled)
                    if lastFuelLevel[plate] and currentFuel > lastFuelLevel[plate] + 1.0 then
                        local fuelAdded = currentFuel - lastFuelLevel[plate]
                        print('[MLFA GASSTATION CLIENT] Fuel added: ' .. fuelAdded .. 'L')
                        
                        -- The server will handle this via the fuel:pay event hook
                        -- This is just for client-side tracking/debugging
                    end
                    
                    lastFuelLevel[plate] = currentFuel
                end
            end
        end
    end
end)

-- Clean up old entries
Citizen.CreateThread(function()
    while true do
        Wait(300000) -- Every 5 minutes
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local currentPlate = vehicle and vehicle ~= 0 and GetVehicleNumberPlateText(vehicle) or nil
        
        -- Keep only current vehicle data
        local newTable = {}
        if currentPlate and lastFuelLevel[currentPlate] then
            newTable[currentPlate] = lastFuelLevel[currentPlate]
        end
        lastFuelLevel = newTable
    end
end)

print('[MLFA GASSTATION] Fuel tracking client loaded')
