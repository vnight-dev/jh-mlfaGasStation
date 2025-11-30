-- ============================================================================
-- STATION COMPETITION SYSTEM
-- Competitive ranking and rewards between gas stations
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local CompetitionConfig = {
    Enabled = true,
    UpdateInterval = 3600000, -- Update every hour (ms)
    
    -- Ranking criteria weights
    Weights = {
        revenue = 0.4,      -- 40% weight
        sales = 0.3,        -- 30% weight
        customers = 0.2,    -- 20% weight
        efficiency = 0.1    -- 10% weight (profit margin)
    },
    
    -- Rewards for top stations
    Rewards = {
        [1] = {bonus = 0.15, label = '🥇 1ère Place'},  -- +15% revenue
        [2] = {bonus = 0.10, label = '🥈 2ème Place'},  -- +10% revenue
        [3] = {bonus = 0.05, label = '🥉 3ème Place'}   -- +5% revenue
    },
    
    -- Penalties for bottom stations
    Penalties = {
        last = {malus = 0.05, label = '⚠️ Dernière Place'}  -- -5% revenue
    }
}

-- Rankings storage
local stationRankings = {}
local lastUpdate = 0

-- ============================================================================
-- RANKING CALCULATION
-- ============================================================================

local function CalculateStationScore(stationData)
    -- Normalize values (0-100 scale)
    local revenueScore = math.min((stationData.total_revenue / 100000) * 100, 100)
    local salesScore = math.min((stationData.total_liters / 10000) * 100, 100)
    local customersScore = math.min((stationData.total_sales / 500) * 100, 100)
    local efficiencyScore = stationData.profit_margin or 50
    
    -- Calculate weighted score
    local score = (revenueScore * CompetitionConfig.Weights.revenue) +
                  (salesScore * CompetitionConfig.Weights.sales) +
                  (customersScore * CompetitionConfig.Weights.customers) +
                  (efficiencyScore * CompetitionConfig.Weights.efficiency)
    
    return math.floor(score)
end

local function UpdateRankings()
    print('[COMPETITION] Updating station rankings...')
    
    -- Get all stations with stats
    MySQL.query([[
        SELECT 
            s.id,
            s.label,
            s.owner,
            s.money,
            COALESCE(SUM(CASE WHEN t.type = 'fuel_sale' THEN t.amount ELSE 0 END), 0) as total_revenue,
            COALESCE(SUM(CASE WHEN t.type = 'fuel_sale' THEN 1 ELSE 0 END), 0) as total_sales,
            COALESCE(SUM(CASE WHEN t.description LIKE '%NPC%' THEN 1 ELSE 0 END), 0) as npc_sales,
            0 as total_liters,
            0 as profit_margin
        FROM gas_stations s
        LEFT JOIN gas_transactions t ON s.id = t.station_id
        WHERE s.owner IS NOT NULL AND s.owner != ''
        GROUP BY s.id
        ORDER BY total_revenue DESC
    ]], {}, function(stations)
        if not stations or #stations == 0 then
            print('[COMPETITION] No active stations to rank')
            return
        end
        
        -- Calculate scores and rank
        local rankings = {}
        for _, station in ipairs(stations) do
            local score = CalculateStationScore(station)
            table.insert(rankings, {
                id = station.id,
                label = station.label,
                owner = station.owner,
                score = score,
                revenue = station.total_revenue,
                sales = station.total_sales,
                money = station.money
            })
        end
        
        -- Sort by score
        table.sort(rankings, function(a, b) return a.score > b.score end)
        
        -- Assign ranks and rewards
        for rank, station in ipairs(rankings) do
            station.rank = rank
            station.bonus = 0
            station.rankLabel = rank .. 'ème'
            
            -- Apply rewards
            if CompetitionConfig.Rewards[rank] then
                station.bonus = CompetitionConfig.Rewards[rank].bonus
                station.rankLabel = CompetitionConfig.Rewards[rank].label
            end
            
            -- Apply penalties
            if rank == #rankings and #rankings > 1 then
                station.bonus = -CompetitionConfig.Penalties.last.malus
                station.rankLabel = CompetitionConfig.Penalties.last.label
            end
            
            -- Notify owner if online
            local xPlayer = ESX.GetPlayerFromIdentifier(station.owner)
            if xPlayer then
                local message = string.format(
                    'Classement: %s (Score: %d)',
                    station.rankLabel,
                    station.score
                )
                TriggerClientEvent('mlfaGasStation:notify', xPlayer.source, 'info', message)
            end
        end
        
        -- Store rankings
        stationRankings = rankings
        lastUpdate = os.time()
        
        -- Discord logging
        if DiscordLog then
            local leaderboard = '**🏆 Classement des Stations 🏆**\n\n'
            for i = 1, math.min(5, #rankings) do
                local station = rankings[i]
                leaderboard = leaderboard .. string.format(
                    '%s **%s** - Score: %d (Revenue: $%s)\n',
                    station.rankLabel,
                    station.label,
                    station.score,
                    tostring(station.revenue)
                )
            end
            
            -- Send to Discord (custom function needed)
            -- DiscordLog.Leaderboard(leaderboard)
        end
        
        print('[COMPETITION] Rankings updated: ' .. #rankings .. ' stations')
    end)
end

-- ============================================================================
-- BONUS APPLICATION
-- ============================================================================

-- Apply competition bonus to fuel sale
function ApplyCompetitionBonus(stationId, baseAmount)
    if not CompetitionConfig.Enabled then
        return baseAmount
    end
    
    -- Find station in rankings
    for _, station in ipairs(stationRankings) do
        if station.id == stationId then
            local bonus = baseAmount * station.bonus
            return baseAmount + bonus, station.bonus
        end
    end
    
    return baseAmount, 0
end

-- ============================================================================
-- AUTO UPDATE LOOP
-- ============================================================================

Citizen.CreateThread(function()
    if not CompetitionConfig.Enabled then
        print('[COMPETITION] Competition system is disabled')
        return
    end
    
    print('[COMPETITION] Competition system started')
    print('[COMPETITION] Update interval: ' .. (CompetitionConfig.UpdateInterval / 1000) .. ' seconds')
    
    -- Initial update
    Wait(10000) -- Wait 10 seconds after server start
    UpdateRankings()
    
    -- Periodic updates
    while true do
        Wait(CompetitionConfig.UpdateInterval)
        UpdateRankings()
    end
end)

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Get current rankings
RegisterServerEvent('mlfaGasStation:getRankings')
AddEventHandler('mlfaGasStation:getRankings', function()
    local source = source
    TriggerClientEvent('mlfaGasStation:updateRankings', source, stationRankings)
end)

-- Force update rankings (admin)
RegisterCommand('gasupdaterankings', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and xPlayer.getGroup() == 'admin' then
        UpdateRankings()
        TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Classement mis à jour')
    else
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Permission refusée')
    end
end, false)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('GetRankings', function()
    return stationRankings
end)

exports('GetStationRank', function(stationId)
    for _, station in ipairs(stationRankings) do
        if station.id == stationId then
            return station.rank, station.score, station.bonus
        end
    end
    return nil, 0, 0
end)

exports('ApplyBonus', ApplyCompetitionBonus)

print('[MLFA GASSTATION] Competition system loaded')
