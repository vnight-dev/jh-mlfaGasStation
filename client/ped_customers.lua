-- ============================================================================
-- NPC CUSTOMERS SYSTEM
-- Optimized AI customers that visit gas stations
-- Target: Minimal CPU usage with realistic behavior
-- ============================================================================

local PerfUtils = _G.PerfUtils or require('client.perf_utils')

-- ============================================================================
-- CONFIGURATION (from config.lua)
-- ============================================================================

-- Vérifier si le système NPC est activé
if not Config.NPC.Enabled then
    print('[NPC] System disabled in config')
    return
end

-- Logs de debug
local function debugLog(category, message)
    if Config.Debug.Enabled and Config.Debug.Logs.NPC then
        print('[NPC] [' .. category .. '] ' .. message)
    end
end

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local pedPool = {}
local vehiclePool = {}
local usedPeds = {}
local usedVehicles = {}
local activeCustomers = {}
local stationActivity = {} -- Track NPCs per station

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Get current time period for spawn rate
local function getTimePeriod()
    local hour = GetClockHours()
    if hour >= 0 and hour < 6 then return 'night'
    elseif hour >= 6 and hour < 9 then return 'morning'
    elseif hour >= 9 and hour < 17 then return 'day'
    elseif hour >= 17 and hour < 22 then return 'evening'
    else return 'late' end
end

-- Calculate spawn interval based on time
local function getSpawnInterval()
    -- Utiliser un intervalle fixe basé sur Config.NPC.SpawnInterval
    local min = Config.NPC.SpawnInterval.Min * 1000
    local max = Config.NPC.SpawnInterval.Max * 1000
    return math.random(min, max)
end

-- ============================================================================
-- POOLING SYSTEM
-- ============================================================================

-- Initialize ped pool
local function initPedPool()
    print('[NPC] Initializing ped pool...')
    
    for i = 1, Config.NPC.PedPoolSize do
        local modelName = Config.NPC.PedModels[math.random(#Config.NPC.PedModels)]
        local modelHash = GetHashKey(modelName)
        
        RequestModel(modelHash)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
            Wait(50)
        end
        
        if HasModelLoaded(modelHash) then
            local ped = CreatePed(26, modelHash, 0.0, 0.0, -1000.0, 0.0, false, false)
            
            if DoesEntityExist(ped) then
                SetEntityAlpha(ped, 0, false)
                FreezeEntityPosition(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedCanRagdoll(ped, false)
                SetEntityInvincible(ped, true)
                SetEntityAsMissionEntity(ped, false, false)
                
                table.insert(pedPool, ped)
                usedPeds[#pedPool] = false
                
                print('[NPC] ✅ Ped ' .. i .. ' created successfully')
            else
                print('[NPC] ❌ Failed to create ped ' .. i)
            end
            
            SetModelAsNoLongerNeeded(modelHash)
        else
            print('[NPC] ❌ Failed to load ped model: ' .. modelName)
        end
    end
    
    print('[NPC] Ped pool initialized: ' .. #pedPool .. ' peds')
end

-- Initialize vehicle pool
local function initVehiclePool()
    print('[NPC] Initializing vehicle pool...')
    
    for i = 1, Config.NPC.VehiclePoolSize do
        local modelName = Config.NPC.VehicleModels[math.random(#Config.NPC.VehicleModels)]
        local modelHash = GetHashKey(modelName)
        
        print('[NPC] Loading vehicle model: ' .. modelName)
        
        RequestModel(modelHash)
        local timeout = GetGameTimer() + 5000 -- Increased timeout
        while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
            Wait(50)
        end
        
        if HasModelLoaded(modelHash) then
            local veh = CreateVehicle(modelHash, 0.0, 0.0, -1000.0, 0.0, false, false)
            
            if DoesEntityExist(veh) then
                SetEntityAlpha(veh, 0, false)
                FreezeEntityPosition(veh, true)
                SetVehicleEngineOn(veh, false, true, true)
                SetEntityAsMissionEntity(veh, false, false)
                
                table.insert(vehiclePool, veh)
                usedVehicles[#vehiclePool] = false
                
                print('[NPC] ✅ Vehicle ' .. i .. ' created successfully')
            else
                print('[NPC] ❌ Failed to create vehicle ' .. i)
            end
            
            SetModelAsNoLongerNeeded(modelHash)
        else
            print('[NPC] ❌ Failed to load model: ' .. modelName)
        end
    end
    
    print('[NPC] Vehicle pool initialized: ' .. #vehiclePool .. ' vehicles')
end

-- Acquire ped from pool
local function acquirePed()
    for i = 1, #pedPool do
        if not usedPeds[i] then
            usedPeds[i] = true
            local ped = pedPool[i]
            SetEntityAlpha(ped, 255, false)
            FreezeEntityPosition(ped, false)
            SetEntityInvincible(ped, false)
            return i, ped
        end
    end
    return nil, nil
end

-- Release ped back to pool
local function releasePed(index)
    if not pedPool[index] then return end
    
    local ped = pedPool[index]
    usedPeds[index] = false
    
    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, 0.0, 0.0, -1000.0, false, false, false, false)
    SetEntityAlpha(ped, 0, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
end

-- Acquire vehicle from pool
local function acquireVehicle()
    for i = 1, #vehiclePool do
        if not usedVehicles[i] then
            usedVehicles[i] = true
            local veh = vehiclePool[i]
            SetEntityAlpha(veh, 255, false)
            FreezeEntityPosition(veh, false)
            return i, veh
        end
    end
    return nil, nil
end

-- Release vehicle back to pool
local function releaseVehicle(index)
    if not vehiclePool[index] then return end
    
    local veh = vehiclePool[index]
    usedVehicles[index] = false
    
    SetEntityCoords(veh, 0.0, 0.0, -1000.0, false, false, false, false)
    SetEntityAlpha(veh, 0, false)
    FreezeEntityPosition(veh, true)
    SetVehicleEngineOn(veh, false, true, true)
end

-- ============================================================================
-- CUSTOMER BEHAVIOR (State Machine)
-- ============================================================================

local function runCustomerFlow(station)
    local profiler = PerfUtils.ProfileAsync('CustomerFlow')
    
    -- Acquire resources
    local pedIdx, ped = acquirePed()
    local vehIdx, vehicle = acquireVehicle()
    
    if not ped or not vehicle then
        print('[NPC] Pool exhausted, skipping spawn')
        profiler.finish()
        return
    end
    
    -- Track activity
    stationActivity[station.id] = (stationActivity[station.id] or 0) + 1
    
    -- Generate spawn point (road near station)
    local spawnPoint = station.coords + vector3(
        math.random(-30, 30),
        math.random(-30, 30),
        0.0
    )
    
    -- Position vehicle and ped
    SetEntityCoords(vehicle, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, false)
    SetEntityHeading(vehicle, math.random(0, 360))
    SetVehicleEngineOn(vehicle, true, true, false)
    
    SetPedIntoVehicle(ped, vehicle, -1)
    
    -- STATE 1: Drive to pump
    local pumpCoords = station.coords -- Simplified, should use actual pump positions
    TaskVehicleDriveToCoord(ped, vehicle, pumpCoords.x, pumpCoords.y, pumpCoords.z, 
        15.0, 0, GetEntityModel(vehicle), 786603, 2.0, true)
    
    -- Wait for arrival (with timeout)
    local arrived = false
    local startTime = GetGameTimer()
    while not arrived and GetGameTimer() - startTime < 30000 do
        Wait(100) -- Coarse check
        local pedPos = GetEntityCoords(ped)
        if PerfUtils.IsWithinRadius(pedPos, pumpCoords, 5.0) then
            arrived = true
        end
    end
    
    if not arrived then
        -- Timeout, cleanup
        releasePed(pedIdx)
        releaseVehicle(vehIdx)
        stationActivity[station.id] = stationActivity[station.id] - 1
        profiler.finish()
        return
    end
    
    -- STATE 2: Exit vehicle and fuel
    TaskLeaveVehicle(ped, vehicle, 0)
    PerfUtils.Delay(2000)
    
    -- Fueling animation (using Config.NPC.Animations.Refueling)
    local refuelAnim = Config.NPC.Animations.Refueling
    RequestAnimDict(refuelAnim.dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(refuelAnim.dict) and GetGameTimer() < timeout do
        Wait(50)
    end
    
    if HasAnimDictLoaded(refuelAnim.dict) then
        TaskPlayAnim(ped, refuelAnim.dict, refuelAnim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        debugLog('ANIMATION', 'Playing refueling animation')
    else
        -- Fallback to scenario
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    end
    
    PerfUtils.Delay(Config.NPC.Animations.Refueling.duration)
    
    ClearPedTasksImmediately(ped)
    
    -- STATE 3: Payment (simulate)
    local fuelAmount = math.random(Config.NPC.FuelAmount.Min, Config.NPC.FuelAmount.Max)
    local fuelPrice = 2.5 -- Should get from station data
    local totalCost = fuelAmount * fuelPrice
    
    -- Payment animation (using Config.NPC.Animations.Payment)
    local paymentAnim = Config.NPC.Animations.Payment
    RequestAnimDict(paymentAnim.dict)
    timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(paymentAnim.dict) and GetGameTimer() < timeout do
        Wait(50)
    end
    
    if HasAnimDictLoaded(paymentAnim.dict) then
        TaskPlayAnim(ped, paymentAnim.dict, paymentAnim.anim, 8.0, -8.0, -1, 0, 0, false, false, false)
        debugLog('ANIMATION', 'Playing payment animation')
    end
    
    -- Trigger server event for payment
    TriggerServerEvent('mlfaGasStation:npcPurchase', station.id, fuelAmount, totalCost)
    
    PerfUtils.Delay(Config.NPC.Animations.Payment.duration)
    
    -- STATE 4: Return to vehicle and leave
    TaskEnterVehicle(ped, vehicle, 10000, -1, 1.0, 1, 0)
    PerfUtils.Delay(3000)
    
    -- Drive away
    local leavePoint = pumpCoords + vector3(
        math.random(-50, 50),
        math.random(-50, 50),
        0.0
    )
    
    TaskVehicleDriveToCoord(ped, vehicle, leavePoint.x, leavePoint.y, leavePoint.z,
        25.0, 0, GetEntityModel(vehicle), 786603, 5.0, true)
    
    -- Wait then cleanup
    PerfUtils.Delay(15000)
    
    -- Release resources
    releasePed(pedIdx)
    releaseVehicle(vehIdx)
    stationActivity[station.id] = stationActivity[station.id] - 1
    
    profiler.finish()
end

-- ============================================================================
-- SPAWN MANAGER
-- ============================================================================

local function manageNPCSpawns()
    if not Config.NPC.Enabled then return end
    
    local playerPos = GetEntityCoords(PlayerPedId())
    
    for _, station in ipairs(Config.Stations) do
        local distance = PerfUtils.Distance3D(playerPos, station.coords)
        
        -- Only spawn if player nearby
        if distance <= 120.0 then -- Stream radius
            local currentActivity = stationActivity[station.id] or 0
            
            -- Spawn if below max
            if currentActivity < 3 then -- Max per station
                CreateThread(function()
                    runCustomerFlow(station)
                end)
            end
        end
    end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    Wait(5000) -- Wait for game to load
    
    if not Config.NPC.Enabled then
        print('[NPC] NPC customer system is disabled')
        return
    end
    
    print('[NPC] Initializing NPC customer system...')
    
    -- Initialize pools
    initPedPool()
    initVehiclePool()
    
    -- Schedule spawn manager
    PerfUtils.ScheduleTask(getSpawnInterval(), manageNPCSpawns, false)
    
    -- Adjust spawn rate every 5 minutes based on time
    PerfUtils.ScheduleTask(300000, function()
        local newInterval = getSpawnInterval()
        print('[NPC] Adjusting spawn rate for ' .. getTimePeriod() .. ' period')
    end, false)
    
    print('[NPC] NPC customer system initialized')
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('SetNPCEnabled', function(enabled)
    Config.NPC.Enabled = enabled
    print('[NPC] NPC system ' .. (enabled and 'enabled' or 'disabled'))
end)

exports('GetActiveCustomers', function()
    local count = 0
    for _, active in pairs(stationActivity) do
        count = count + active
    end
    return count
end)

print('[MLFA GASSTATION] NPC customers module loaded')
