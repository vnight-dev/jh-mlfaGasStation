local ESX = exports['es_extended']:getSharedObject()

-- This module integrates with fscript_fuel to track fuel sales and manage station stock

print('[MLFA GASSTATION] Fuel integration module loading...')

-- Hook into fscript_fuel payment event
RegisterNetEvent('fuel:pay')
AddEventHandler('fuel:pay', function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Get player coords to find nearest station
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local nearestStation, distance = GetNearestStation(playerCoords)
    
    -- Only track if player is at a gas station (within 50m)
    if nearestStation and distance < 50.0 then
        print('[MLFA GASSTATION] Fuel purchase detected at ' .. nearestStation.label)
        
        -- Get station data
        GetStationData(nearestStation.id, function(stationData)
            if not stationData then return end
            
            -- Calculate liters purchased based on price and fuel price
            local fuelPrice = stationData.fuel_price
            local litersPurchased = price / fuelPrice
            
            -- Get vehicle info
            local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
            local plate = GetVehicleNumberPlateText(vehicle)
            
            print(string.format('[MLFA GASSTATION] Sale: %.2fL at $%.2f/L = $%.2f', litersPurchased, fuelPrice, price))
            
            -- Check if station has enough fuel
            if stationData.fuel_stock >= litersPurchased then
                -- Deduct fuel from station stock
                UpdateStationFuel(nearestStation.id, -litersPurchased)
                
                -- Add revenue to station
                UpdateStationMoney(nearestStation.id, price)
                
                -- Log fuel sale
                MySQL.insert([[
                    INSERT INTO gas_fuel_sales (station_id, player_id, vehicle_plate, liters, price_per_liter, total_cost)
                    VALUES (?, ?, ?, ?, ?, ?)
                ]], {
                    nearestStation.id,
                    xPlayer.identifier,
                    plate,
                    litersPurchased,
                    fuelPrice,
                    price
                })
                
                -- Add transaction
                AddTransaction(
                    nearestStation.id,
                    'fuel_sale',
                    price,
                    string.format('Vente de %.2fL à %s', litersPurchased, xPlayer.getName()),
                    'system'
                )
                
                print('[MLFA GASSTATION] Fuel sale recorded successfully')
                
                -- Check for low stock warning
                if stationData.fuel_stock - litersPurchased < 1000 then
                    print('[MLFA GASSTATION] WARNING: Station ' .. nearestStation.label .. ' has low fuel stock!')
                    -- TODO: Notify station owner/employees
                end
            else
                print('[MLFA GASSTATION] WARNING: Station ' .. nearestStation.label .. ' out of fuel!')
                -- Station is out of fuel - still allow purchase but don't deduct stock
                -- This prevents breaking fscript_fuel functionality
                
                -- Add revenue anyway
                UpdateStationMoney(nearestStation.id, price)
                
                -- Log sale with note about low stock
                AddTransaction(
                    nearestStation.id,
                    'fuel_sale',
                    price,
                    string.format('Vente de %.2fL (STOCK INSUFFISANT) à %s', litersPurchased, xPlayer.getName()),
                    'system'
                )
            end
        end)
    end
end)

-- Export function to get station fuel stock
exports('GetStationFuelStock', function(stationId)
    local p = promise.new()
    
    GetStationData(stationId, function(data)
        if data then
            p:resolve(data.fuel_stock)
        else
            p:resolve(0)
        end
    end)
    
    return Citizen.Await(p)
end)

-- Export function to get station by coords
exports('GetStationByCoords', function(coords)
    return GetNearestStation(coords)
end)

-- Command to check fuel stock (for testing)
RegisterCommand('checkfuelstock', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local nearestStation, distance = GetNearestStation(playerCoords)
    
    if nearestStation and distance < 50.0 then
        GetStationData(nearestStation.id, function(data)
            if data then
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 242, 234},
                    multiline = true,
                    args = {"GasStation", string.format("%s - Stock: %dL | Prix: $%.2f/L | Caisse: $%d", 
                        nearestStation.label, 
                        data.fuel_stock, 
                        data.fuel_price, 
                        data.money
                    )}
                })
            end
        end)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 107, 107},
            multiline = false,
            args = {"GasStation", "Vous n'êtes pas près d'une station-service"}
        })
    end
end, false)

print('[MLFA GASSTATION] Fuel integration module loaded successfully')
