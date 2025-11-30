-- ============================================================================
-- PERFORMANCE UTILITIES MODULE
-- Optimized patterns and helpers to minimize CPU usage
-- Target: <0.1ms per tick for critical operations
-- ============================================================================

local PerfUtils = {}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

PerfUtils.Config = {
    enableProfiling = false, -- Set to true for development
    logThreshold = 1.0, -- Log operations taking more than 1ms
}

-- ============================================================================
-- NATIVE CACHING (Micro-optimization)
-- ============================================================================

-- Cache frequently used natives to avoid lookup overhead
local GetEntityCoords = GetEntityCoords
local GetPlayerPed = PlayerPedId
local GetGameTimer = GetGameTimer
local Wait = Wait
local CreateThread = CreateThread

-- Math functions
local sqrt = math.sqrt
local abs = math.abs
local floor = math.floor
local random = math.random

-- Table functions
local insert = table.insert
local remove = table.remove

-- ============================================================================
-- PROFILING UTILITIES
-- ============================================================================

-- Simple profiler for measuring execution time
function PerfUtils.Profile(name, fn)
    if not PerfUtils.Config.enableProfiling then
        return fn()
    end
    
    local t0 = GetGameTimer()
    local result = fn()
    local dt = GetGameTimer() - t0
    
    if dt >= PerfUtils.Config.logThreshold then
        print(string.format('[PERF] %s took %.2f ms', name, dt))
    end
    
    return result
end

-- Async profiler (for coroutines)
function PerfUtils.ProfileAsync(name)
    if not PerfUtils.Config.enableProfiling then
        return {
            finish = function() end
        }
    end
    
    local t0 = GetGameTimer()
    return {
        finish = function()
            local dt = GetGameTimer() - t0
            if dt >= PerfUtils.Config.logThreshold then
                print(string.format('[PERF] %s took %.2f ms', name, dt))
            end
        end
    }
end

-- ============================================================================
-- OPTIMIZED DISTANCE CALCULATIONS
-- ============================================================================

-- Fast 2D distance (no Z axis, no sqrt)
function PerfUtils.Distance2DSquared(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

-- Fast 3D distance squared (avoids expensive sqrt)
function PerfUtils.Distance3DSquared(v1, v2)
    local dx = v2.x - v1.x
    local dy = v2.y - v1.y
    local dz = v2.z - v1.z
    return dx * dx + dy * dy + dz * dz
end

-- Use this when you need actual distance
function PerfUtils.Distance3D(v1, v2)
    return sqrt(PerfUtils.Distance3DSquared(v1, v2))
end

-- Check if within radius (optimized, no sqrt)
function PerfUtils.IsWithinRadius(v1, v2, radius)
    return PerfUtils.Distance3DSquared(v1, v2) <= (radius * radius)
end

-- ============================================================================
-- SMART WAIT PATTERNS
-- ============================================================================

-- Never use Wait(0) - it's a CPU killer
-- Use this helper to enforce minimum wait times
function PerfUtils.SmartWait(ms)
    ms = ms or 10 -- Default 10ms minimum
    if ms < 5 then
        print('[PERF WARNING] Wait time too low: ' .. ms .. 'ms, using 5ms')
        ms = 5
    end
    Wait(ms)
end

-- Delay with minimum wait time (non-blocking)
function PerfUtils.Delay(ms)
    local t0 = GetGameTimer()
    while GetGameTimer() - t0 < ms do
        PerfUtils.SmartWait(5)
    end
end

-- ============================================================================
-- SCHEDULED TASKS (Event-driven instead of polling)
-- ============================================================================

local scheduledTasks = {}
local nextTaskId = 1

-- Schedule a task to run at specific intervals
function PerfUtils.ScheduleTask(interval, callback, immediate)
    local taskId = nextTaskId
    nextTaskId = nextTaskId + 1
    
    scheduledTasks[taskId] = {
        interval = interval,
        callback = callback,
        lastRun = immediate and 0 or GetGameTimer()
    }
    
    return taskId
end

-- Cancel a scheduled task
function PerfUtils.CancelTask(taskId)
    scheduledTasks[taskId] = nil
end

-- Task scheduler thread (runs once)
CreateThread(function()
    while true do
        local now = GetGameTimer()
        
        for taskId, task in pairs(scheduledTasks) do
            if now - task.lastRun >= task.interval then
                task.lastRun = now
                
                -- Run in protected mode to prevent crashes
                local success, err = pcall(task.callback)
                if not success then
                    print('[PERF ERROR] Task ' .. taskId .. ' failed: ' .. tostring(err))
                end
            end
        end
        
        PerfUtils.SmartWait(10) -- Check every 10ms
    end
end)

-- ============================================================================
-- OBJECT POOLING
-- ============================================================================

PerfUtils.Pools = {}

-- Create a new pool
function PerfUtils.CreatePool(name, size, createFn, resetFn)
    local pool = {
        name = name,
        objects = {},
        used = {},
        createFn = createFn,
        resetFn = resetFn,
        size = size
    }
    
    -- Pre-create objects
    for i = 1, size do
        local obj = createFn(i)
        if obj then
            pool.objects[i] = obj
            pool.used[i] = false
        end
    end
    
    PerfUtils.Pools[name] = pool
    print(string.format('[PERF] Created pool "%s" with %d objects', name, size))
    
    return pool
end

-- Acquire object from pool
function PerfUtils.AcquireFromPool(poolName)
    local pool = PerfUtils.Pools[poolName]
    if not pool then
        print('[PERF ERROR] Pool not found: ' .. poolName)
        return nil, nil
    end
    
    for i = 1, pool.size do
        if not pool.used[i] then
            pool.used[i] = true
            return i, pool.objects[i]
        end
    end
    
    print('[PERF WARNING] Pool "' .. poolName .. '" exhausted')
    return nil, nil
end

-- Release object back to pool
function PerfUtils.ReleaseToPool(poolName, index)
    local pool = PerfUtils.Pools[poolName]
    if not pool then return end
    
    if pool.used[index] then
        pool.used[index] = false
        if pool.resetFn then
            pool.resetFn(pool.objects[index], index)
        end
    end
end

-- ============================================================================
-- SPATIAL PARTITIONING (For large numbers of entities)
-- ============================================================================

-- Simple grid-based spatial hash
function PerfUtils.CreateSpatialGrid(cellSize)
    return {
        cellSize = cellSize,
        cells = {},
        
        -- Get cell key for position
        getKey = function(self, x, y)
            local cx = floor(x / self.cellSize)
            local cy = floor(y / self.cellSize)
            return cx .. ',' .. cy
        end,
        
        -- Add entity to grid
        add = function(self, id, x, y, data)
            local key = self:getKey(x, y)
            self.cells[key] = self.cells[key] or {}
            self.cells[key][id] = {x = x, y = y, data = data}
        end,
        
        -- Remove entity from grid
        remove = function(self, id, x, y)
            local key = self:getKey(x, y)
            if self.cells[key] then
                self.cells[key][id] = nil
            end
        end,
        
        -- Get nearby entities
        getNearby = function(self, x, y, radius)
            local results = {}
            local radiusSq = radius * radius
            
            -- Check 9 cells (3x3 grid around position)
            for dx = -1, 1 do
                for dy = -1, 1 do
                    local cx = floor(x / self.cellSize) + dx
                    local cy = floor(y / self.cellSize) + dy
                    local key = cx .. ',' .. cy
                    
                    if self.cells[key] then
                        for id, entity in pairs(self.cells[key]) do
                            local distSq = PerfUtils.Distance2DSquared(x, y, entity.x, entity.y)
                            if distSq <= radiusSq then
                                insert(results, {id = id, entity = entity, distance = sqrt(distSq)})
                            end
                        end
                    end
                end
            end
            
            return results
        end
    }
end

-- ============================================================================
-- BATCH PROCESSING
-- ============================================================================

-- Process large arrays in batches to avoid frame drops
function PerfUtils.ProcessBatch(array, batchSize, processFn, onComplete)
    local index = 1
    local total = #array
    
    CreateThread(function()
        while index <= total do
            local endIndex = math.min(index + batchSize - 1, total)
            
            for i = index, endIndex do
                processFn(array[i], i)
            end
            
            index = endIndex + 1
            PerfUtils.SmartWait(5) -- Small wait between batches
        end
        
        if onComplete then
            onComplete()
        end
    end)
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

_G.PerfUtils = PerfUtils

print('[MLFA GASSTATION] Performance utilities loaded')
print('[PERF] Profiling: ' .. (PerfUtils.Config.enableProfiling and 'ENABLED' or 'DISABLED'))

return PerfUtils
