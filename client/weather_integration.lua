-- ============================================================================
-- WEATHER INTEGRATION FOR NPC SPAWNING
-- Adjusts NPC spawn rates based on weather conditions
-- ============================================================================

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local WeatherConfig = {
    Enabled = true,
    
    -- Weather spawn modifiers (multiplier)
    Modifiers = {
        ['CLEAR'] = 1.2,        -- +20% spawn rate
        ['EXTRASUNNY'] = 1.3,   -- +30% spawn rate
        ['CLOUDS'] = 1.0,       -- Normal spawn rate
        ['OVERCAST'] = 0.9,     -- -10% spawn rate
        ['RAIN'] = 0.6,         -- -40% spawn rate
        ['THUNDER'] = 0.4,      -- -60% spawn rate
        ['CLEARING'] = 0.8,     -- -20% spawn rate
        ['NEUTRAL'] = 1.0,      -- Normal spawn rate
        ['SMOG'] = 0.7,         -- -30% spawn rate
        ['FOGGY'] = 0.7,        -- -30% spawn rate
        ['XMAS'] = 1.1,         -- +10% spawn rate
        ['SNOWLIGHT'] = 0.8,    -- -20% spawn rate
        ['BLIZZARD'] = 0.3      -- -70% spawn rate
    },
    
    -- Time of day modifiers (hour-based)
    TimeModifiers = {
        [0] = 0.3,   -- 00:00 - Night
        [1] = 0.2,
        [2] = 0.2,
        [3] = 0.2,
        [4] = 0.3,
        [5] = 0.4,
        [6] = 0.7,   -- 06:00 - Morning
        [7] = 1.0,
        [8] = 1.2,
        [9] = 1.3,
        [10] = 1.2,
        [11] = 1.1,
        [12] = 1.0,  -- 12:00 - Noon
        [13] = 1.0,
        [14] = 1.1,
        [15] = 1.2,
        [16] = 1.3,
        [17] = 1.4,  -- 17:00 - Rush hour
        [18] = 1.5,
        [19] = 1.3,
        [20] = 1.0,
        [21] = 0.8,
        [22] = 0.6,  -- 22:00 - Evening
        [23] = 0.4
    }
}

-- Current modifiers
local currentWeatherModifier = 1.0
local currentTimeModifier = 1.0
local currentWeather = 'CLEAR'

-- ============================================================================
-- WEATHER DETECTION
-- ============================================================================

local function GetCurrentWeather()
    -- Prioritize cd_easytime as requested
    if GetResourceState('cd_easytime') == 'started' then
        -- cd_easytime integration
        -- Note: Ensure cd_easytime has this export. If not, we might need to use a client event or state bag.
        -- Common export for cd_easytime is GetWeather or similar.
        local weather = exports['cd_easytime']:GetWeather() 
        return weather or 'CLEAR'
    elseif GetResourceState('vSync') == 'started' then
        -- vSync integration (kept as fallback but commented out if causing issues)
        -- local weather = exports.vSync:getWeather()
        -- return weather or 'CLEAR'
        return 'CLEAR' -- Placeholder to avoid error
    else
        -- Fallback to native
        -- GetPrevWeatherTypeHashName returns a hash, we need to convert it or use GetWeatherTypeTransition
        -- For simplicity, we'll assume CLEAR if no script is found, or try to map hashes.
        -- Actually, let's just use a safe default if no weather script.
        return 'CLEAR'
    end
end

local function UpdateWeatherModifier()
    currentWeather = GetCurrentWeather()
    currentWeatherModifier = WeatherConfig.Modifiers[currentWeather] or 1.0
    
    if Config.Debug.Enabled and Config.Debug.Logs.NPC then
        print(string.format('[WEATHER] Current: %s (Modifier: %.2f)', currentWeather, currentWeatherModifier))
    end
end

-- ============================================================================
-- TIME DETECTION
-- ============================================================================

local function UpdateTimeModifier()
    local hour = GetClockHours()
    currentTimeModifier = WeatherConfig.TimeModifiers[hour] or 1.0
    
    if Config.Debug.Enabled and Config.Debug.Logs.NPC then
        print(string.format('[WEATHER] Hour: %d (Modifier: %.2f)', hour, currentTimeModifier))
    end
end

-- ============================================================================
-- SPAWN RATE CALCULATION
-- ============================================================================

function GetWeatherAdjustedSpawnInterval()
    if not WeatherConfig.Enabled then
        return Config.NPC.SpawnInterval
    end
    
    -- Calculate combined modifier
    local combinedModifier = currentWeatherModifier * currentTimeModifier
    
    -- Adjust spawn interval (lower modifier = longer interval)
    local baseMin = Config.NPC.SpawnInterval.Min
    local baseMax = Config.NPC.SpawnInterval.Max
    
    local adjustedMin = baseMin / combinedModifier
    local adjustedMax = baseMax / combinedModifier
    
    -- Clamp values
    adjustedMin = math.max(10, math.min(300, adjustedMin))
    adjustedMax = math.max(20, math.min(600, adjustedMax))
    
    return {
        Min = adjustedMin,
        Max = adjustedMax,
        Modifier = combinedModifier
    }
end

-- ============================================================================
-- UPDATE LOOP
-- ============================================================================

Citizen.CreateThread(function()
    if not WeatherConfig.Enabled then
        print('[WEATHER] Weather integration is disabled')
        return
    end
    
    print('[WEATHER] Weather integration started')
    
    while true do
        UpdateWeatherModifier()
        UpdateTimeModifier()
        
        -- Update every 5 minutes
        Wait(300000)
    end
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('GetWeatherModifier', function()
    return currentWeatherModifier
end)

exports('GetTimeModifier', function()
    return currentTimeModifier
end)

exports('GetCombinedModifier', function()
    return currentWeatherModifier * currentTimeModifier
end)

exports('GetAdjustedSpawnInterval', GetWeatherAdjustedSpawnInterval)

print('[MLFA GASSTATION] Weather integration loaded')
