-- ============================================================================
-- NPC PURCHASE HANDLER (Server-side)
-- Handles automated purchases from NPC customers
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- Handle NPC fuel purchase
RegisterNetEvent('mlfaGasStation:npcPurchase')
AddEventHandler('mlfaGasStation:npcPurchase', function(stationId, liters, totalCost)
    -- Validate station exists
    GetStationData(stationId, function(stationData)
        if not stationData then
            print('[NPC] Invalid station ID: ' .. stationId)
            return
        end
        
        -- Check if station has enough fuel
        if stationData.fuel_stock < liters then
            print('[NPC] Station ' .. stationId .. ' out of fuel, skipping NPC purchase')
            return
        end
        
        -- Deduct fuel from stock
        UpdateStationFuel(stationId, -liters)
        
        -- Add revenue to station
        UpdateStationMoney(stationId, totalCost)
        
        -- Log fuel sale
        MySQL.insert([[
            INSERT INTO gas_fuel_sales (station_id, player_id, vehicle_plate, liters, price_per_liter, total_cost)
            VALUES (?, ?, ?, ?, ?, ?)
        ]], {
            stationId,
            'NPC',
            'NPC-' .. math.random(1000, 9999),
            liters,
            stationData.fuel_price,
            totalCost
        })
        
        -- Add transaction
        AddTransaction(
            stationId,
            'fuel_sale',
            totalCost,
            string.format('Vente NPC: %.2fL', liters),
            'system'
        )
        
        -- Discord logging
        if DiscordLog and Config.Discord.Logs.Fuel then
            local stationName = 'Station ' .. stationId
            for _, station in ipairs(Config.Stations) do
                if station.id == stationId then
                    stationName = station.label
                    break
                end
            end
            DiscordLog.FuelSale(stationId, stationName, liters, totalCost, 'NPC')
        end
        
        print(string.format('[NPC] Station %d: NPC purchased %.2fL for $%.2f', stationId, liters, totalCost))
    end)
end)

print('[MLFA GASSTATION] NPC purchase handler loaded')
