-- ============================================================================
-- DEBUG VISUAL MARKERS
-- Show spawn points, fuel points, and NPC paths for debugging
-- ============================================================================

-- Only load if debug is enabled
if not Config.Debug.Enabled then
    print('[DEBUG MARKERS] Debug mode disabled, markers not loaded')
    return
end

-- ============================================================================
-- MARKER RENDERING
-- ============================================================================

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        -- Only render if any marker type is enabled
        if Config.Debug.ShowMarkers.SpawnPoints or 
           Config.Debug.ShowMarkers.FuelPoints or 
           Config.Debug.ShowMarkers.NPCPaths then
            sleep = 0
            
            for _, station in ipairs(Config.Stations) do
                local distance = #(playerCoords - station.coords)
                
                -- Only show markers if player is nearby (within 100m)
                if distance < 100.0 then
                    
                    -- Show NPC Spawn Points (Blue)
                    if Config.Debug.ShowMarkers.SpawnPoints and station.npcSpawnPoints then
                        for i, spawnPoint in ipairs(station.npcSpawnPoints) do
                            local coords = vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z)
                            DrawMarker(
                                1,  -- Cylinder
                                coords.x, coords.y, coords.z - 1.0,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                2.0, 2.0, 1.0,
                                0, 100, 255, 100,  -- Blue
                                false, true, 2, false, nil, nil, false
                            )
                            
                            -- Draw text label
                            if distance < 20.0 then
                                local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.0)
                                if onScreen then
                                    SetTextScale(0.35, 0.35)
                                    SetTextFont(4)
                                    SetTextProportional(1)
                                    SetTextColour(255, 255, 255, 215)
                                    SetTextEntry("STRING")
                                    SetTextCentre(true)
                                    AddTextComponentString("Spawn " .. i)
                                    DrawText(_x, _y)
                                end
                            end
                        end
                    end
                    
                    -- Show Fuel Points / Pumps (Green)
                    if Config.Debug.ShowMarkers.FuelPoints and station.fuelPoints then
                        for i, fuelPoint in ipairs(station.fuelPoints) do
                            DrawMarker(
                                1,  -- Cylinder
                                fuelPoint.x, fuelPoint.y, fuelPoint.z - 1.0,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                1.5, 1.5, 1.0,
                                0, 255, 100, 100,  -- Green
                                false, true, 2, false, nil, nil, false
                            )
                            
                            -- Draw text label
                            if distance < 20.0 then
                                local onScreen, _x, _y = World3dToScreen2d(fuelPoint.x, fuelPoint.y, fuelPoint.z + 1.0)
                                if onScreen then
                                    SetTextScale(0.35, 0.35)
                                    SetTextFont(4)
                                    SetTextProportional(1)
                                    SetTextColour(255, 255, 255, 215)
                                    SetTextEntry("STRING")
                                    SetTextCentre(true)
                                    AddTextComponentString("Pump " .. i)
                                    DrawText(_x, _y)
                                end
                            end
                        end
                    end
                    
                    -- Show NPC Paths (Yellow lines connecting spawn to pumps)
                    if Config.Debug.ShowMarkers.NPCPaths and station.npcSpawnPoints and station.fuelPoints then
                        for _, spawnPoint in ipairs(station.npcSpawnPoints) do
                            local spawnCoords = vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z)
                            
                            for _, fuelPoint in ipairs(station.fuelPoints) do
                                -- Draw line from spawn to pump
                                DrawLine(
                                    spawnCoords.x, spawnCoords.y, spawnCoords.z,
                                    fuelPoint.x, fuelPoint.y, fuelPoint.z,
                                    255, 255, 0, 150  -- Yellow
                                )
                            end
                        end
                    end
                    
                    -- Show station center (White)
                    DrawMarker(
                        2,  -- Sphere
                        station.coords.x, station.coords.y, station.coords.z,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        0.5, 0.5, 0.5,
                        255, 255, 255, 200,  -- White
                        false, true, 2, false, nil, nil, false
                    )
                    
                    -- Draw station label
                    if distance < 30.0 then
                        local onScreen, _x, _y = World3dToScreen2d(station.coords.x, station.coords.y, station.coords.z + 2.0)
                        if onScreen then
                            SetTextScale(0.4, 0.4)
                            SetTextFont(4)
                            SetTextProportional(1)
                            SetTextColour(255, 255, 255, 255)
                            SetTextEntry("STRING")
                            SetTextCentre(true)
                            AddTextComponentString(station.label)
                            DrawText(_x, _y)
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- ============================================================================
-- HELPER FUNCTION
-- ============================================================================

function World3dToScreen2d(x, y, z)
    local _, sX, sY = GetScreenCoordFromWorldCoord(x, y, z)
    return sX > 0 and sY > 0, sX, sY
end

print('[DEBUG MARKERS] Visual markers system loaded')
print('[DEBUG MARKERS] Use /gasmarkers [type] to toggle markers')
print('[DEBUG MARKERS] Types: spawn, fuel, paths')
