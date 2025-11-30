-- ============================================================================
-- DEBUG COMMANDS
-- Only available when Config.Debug.Enabled = true
-- ============================================================================

if Config.Debug.Enabled then
    -- Toggle debug logs
    RegisterCommand('gasdebug', function(source, args)
        if args[1] then
            local category = args[1]:lower()
            if Config.Debug.Logs[category:upper()] ~= nil then
                Config.Debug.Logs[category:upper()] = not Config.Debug.Logs[category:upper()]
                print('[DEBUG] ' .. category .. ' logs: ' .. tostring(Config.Debug.Logs[category:upper()]))
            else
                print('[DEBUG] Categories: npc, purchase, fuel, ui, database')
            end
        else
            print('[DEBUG] Usage: /gasdebug [category]')
        end
    end)
    
    -- Toggle debug markers
    RegisterCommand('gasmarkers', function(source, args)
        if args[1] then
            local markerType = args[1]:lower()
            if markerType == 'spawn' then
                Config.Debug.ShowMarkers.SpawnPoints = not Config.Debug.ShowMarkers.SpawnPoints
                print('[DEBUG] Spawn markers: ' .. tostring(Config.Debug.ShowMarkers.SpawnPoints))
            elseif markerType == 'fuel' then
                Config.Debug.ShowMarkers.FuelPoints = not Config.Debug.ShowMarkers.FuelPoints
                print('[DEBUG] Fuel markers: ' .. tostring(Config.Debug.ShowMarkers.FuelPoints))
            elseif markerType == 'paths' then
                Config.Debug.ShowMarkers.NPCPaths = not Config.Debug.ShowMarkers.NPCPaths
                print('[DEBUG] NPC path markers: ' .. tostring(Config.Debug.ShowMarkers.NPCPaths))
            else
                print('[DEBUG] Types: spawn, fuel, paths')
            end
        else
            print('[DEBUG] Usage: /gasmarkers [type]')
        end
    end)
    
    -- Force spawn NPC
    RegisterCommand('gasspawn', function(source, args)
        local stationId = tonumber(args[1]) or 1
        print('[DEBUG] Forcing NPC spawn at station ' .. stationId)
        -- Trigger NPC spawn (will be implemented in ped_customers.lua)
        TriggerEvent('mlfaGasStation:forceSpawnNPC', stationId)
    end)
    
    -- Add money to station
    RegisterCommand('gasmoney', function(source, args)
        local stationId = tonumber(args[1]) or 1
        local amount = tonumber(args[2]) or 10000
        print('[DEBUG] Adding $' .. amount .. ' to station ' .. stationId)
        TriggerServerEvent('mlfaGasStation:debugAddMoney', stationId, amount)
    end)
    
    -- Reset station
    RegisterCommand('gasreset', function(source, args)
        local stationId = tonumber(args[1])
        if stationId then
            print('[DEBUG] Resetting station ' .. stationId)
            TriggerServerEvent('mlfaGasStation:debugResetStation', stationId)
        else
            print('[DEBUG] Usage: /gasreset [stationId]')
        end
    end)
    
    -- Test system
    RegisterCommand('gastest', function()
        print('[DEBUG] ========== SYSTEM TEST ==========')
        print('[DEBUG] NPC Enabled: ' .. tostring(Config.NPC.Enabled))
        print('[DEBUG] Ped Pool Size: ' .. Config.NPC.PedPoolSize)
        print('[DEBUG] Vehicle Pool Size: ' .. Config.NPC.VehiclePoolSize)
        print('[DEBUG] Spawn Interval: ' .. Config.NPC.SpawnInterval.Min .. '-' .. Config.NPC.SpawnInterval.Max .. 's')
        print('[DEBUG] Fuel Amount: ' .. Config.NPC.FuelAmount.Min .. '-' .. Config.NPC.FuelAmount.Max .. 'L')
        print('[DEBUG] Stations: ' .. #Config.Stations)
        print('[DEBUG] ================================')
    end)
    
    print('[DEBUG] Debug commands loaded: /gasdebug, /gasmarkers, /gasspawn, /gasmoney, /gasreset, /gastest')
end

print('[MLFA GASSTATION] Debug commands loaded')
