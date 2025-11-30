-- ============================================================================
-- FRANCHISE SYSTEM
-- Own and manage multiple gas stations as a business empire
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local FranchiseConfig = {
    Enabled = true,
    MaxStationsPerPlayer = 5,
    
    -- Franchise bonuses (based on number of stations owned)
    NetworkBonus = {
        [2] = 0.05,  -- 2 stations: +5% revenue
        [3] = 0.10,  -- 3 stations: +10% revenue
        [4] = 0.15,  -- 4 stations: +15% revenue
        [5] = 0.20   -- 5 stations: +20% revenue
    },
    
    -- Franchise perks
    Perks = {
        SharedEmployees = true,      -- Employees can work at any franchise station
        CentralizedMoney = true,      -- Money pooled across all stations
        BulkFuelDiscount = 0.10,     -- 10% discount on fuel purchases
        BrandingBonus = 0.05          -- 5% bonus from unified branding
    },
    
    -- Expansion costs
    ExpansionCost = {
        [2] = 400000,  -- 2nd station: $400k
        [3] = 600000,  -- 3rd station: $600k
        [4] = 800000,  -- 4th station: $800k
        [5] = 1000000  -- 5th station: $1M
    }
}

-- Franchise data cache
local franchiseData = {}

-- ============================================================================
-- FRANCHISE MANAGEMENT
-- ============================================================================

-- Get player's franchise
function GetPlayerFranchise(identifier)
    MySQL.query([[
        SELECT 
            s.id,
            s.label,
            s.money,
            s.fuel_stock,
            COUNT(e.id) as employees
        FROM gas_stations s
        LEFT JOIN gas_employees e ON s.id = e.station_id
        WHERE s.owner = ?
        GROUP BY s.id
    ]], {identifier}, function(stations)
        if stations and #stations > 0 then
            franchiseData[identifier] = {
                stations = stations,
                totalStations = #stations,
                totalMoney = 0,
                totalEmployees = 0,
                networkBonus = FranchiseConfig.NetworkBonus[#stations] or 0
            }
            
            -- Calculate totals
            for _, station in ipairs(stations) do
                franchiseData[identifier].totalMoney = franchiseData[identifier].totalMoney + station.money
                franchiseData[identifier].totalEmployees = franchiseData[identifier].totalEmployees + station.employees
            end
        end
    end)
end

-- Check if player can buy another station
function CanExpandFranchise(identifier)
    local franchise = franchiseData[identifier]
    if not franchise then return true end
    
    return franchise.totalStations < FranchiseConfig.MaxStationsPerPlayer
end

-- Get expansion cost
function GetExpansionCost(identifier)
    local franchise = franchiseData[identifier]
    if not franchise then return Config.Economy.StationPurchasePrice end
    
    local nextStation = franchise.totalStations + 1
    return FranchiseConfig.ExpansionCost[nextStation] or Config.Economy.StationPurchasePrice
end

-- Apply franchise bonuses
function ApplyFranchiseBonus(identifier, baseAmount)
    local franchise = franchiseData[identifier]
    if not franchise then return baseAmount end
    
    local bonus = baseAmount * franchise.networkBonus
    if FranchiseConfig.Perks.BrandingBonus then
        bonus = bonus + (baseAmount * FranchiseConfig.Perks.BrandingBonus)
    end
    
    return baseAmount + bonus
end

-- ============================================================================
-- CENTRALIZED MONEY MANAGEMENT
-- ============================================================================

function GetFranchiseTotalMoney(identifier)
    local franchise = franchiseData[identifier]
    if not franchise then return 0 end
    
    return franchise.totalMoney
end

function WithdrawFromFranchise(identifier, amount)
    local franchise = franchiseData[identifier]
    if not franchise or franchise.totalMoney < amount then
        return false
    end
    
    -- Deduct proportionally from each station
    local remaining = amount
    for _, station in ipairs(franchise.stations) do
        if remaining <= 0 then break end
        
        local stationShare = math.min(station.money, remaining)
        UpdateStationMoney(station.id, -stationShare)
        remaining = remaining - stationShare
    end
    
    return true
end

-- ============================================================================
-- FRANCHISE STATISTICS
-- ============================================================================

function GetFranchiseStats(identifier)
    local franchise = franchiseData[identifier]
    if not franchise then return nil end
    
    -- Get detailed stats
    MySQL.query([[
        SELECT 
            SUM(CASE WHEN t.type = 'fuel_sale' THEN t.amount ELSE 0 END) as total_revenue,
            SUM(CASE WHEN t.type = 'fuel_sale' THEN 1 ELSE 0 END) as total_sales,
            COUNT(DISTINCT s.id) as active_stations
        FROM gas_stations s
        LEFT JOIN gas_transactions t ON s.id = t.station_id
        WHERE s.owner = ?
        AND t.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    ]], {identifier}, function(stats)
        if stats and stats[1] then
            franchise.weeklyRevenue = stats[1].total_revenue or 0
            franchise.weeklySales = stats[1].total_sales or 0
        end
    end)
    
    return franchise
end

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Get franchise data
RegisterServerEvent('mlfaGasStation:getFranchise')
AddEventHandler('mlfaGasStation:getFranchise', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    GetPlayerFranchise(xPlayer.identifier)
    
    Citizen.SetTimeout(500, function()
        local franchise = franchiseData[xPlayer.identifier]
        TriggerClientEvent('mlfaGasStation:updateFranchise', source, franchise)
    end)
end)

-- Check expansion eligibility
RegisterServerEvent('mlfaGasStation:checkExpansion')
AddEventHandler('mlfaGasStation:checkExpansion', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local canExpand = CanExpandFranchise(xPlayer.identifier)
    local cost = GetExpansionCost(xPlayer.identifier)
    
    TriggerClientEvent('mlfaGasStation:expansionInfo', source, {
        canExpand = canExpand,
        cost = cost,
        currentStations = franchiseData[xPlayer.identifier] and franchiseData[xPlayer.identifier].totalStations or 0,
        maxStations = FranchiseConfig.MaxStationsPerPlayer
    })
end)

-- Withdraw from franchise
RegisterServerEvent('mlfaGasStation:franchiseWithdraw')
AddEventHandler('mlfaGasStation:franchiseWithdraw', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if WithdrawFromFranchise(xPlayer.identifier, amount) then
        xPlayer.addMoney(amount)
        TriggerClientEvent('mlfaGasStation:notify', source, 'success', 
            string.format('Retrait de $%s effectué', tostring(amount)))
        
        -- Discord log
        if DiscordLog then
            DiscordLog.MoneyTransaction(
                0,
                'Franchise',
                'withdrawal',
                amount,
                xPlayer.getName(),
                'Retrait franchise'
            )
        end
    else
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Fonds insuffisants')
    end
end)

-- ============================================================================
-- AUTO UPDATE
-- ============================================================================

Citizen.CreateThread(function()
    if not FranchiseConfig.Enabled then
        print('[FRANCHISE] Franchise system is disabled')
        return
    end
    
    print('[FRANCHISE] Franchise system started')
    
    while true do
        Wait(300000) -- Update every 5 minutes
        
        -- Update all active franchises
        for identifier, _ in pairs(franchiseData) do
            GetPlayerFranchise(identifier)
        end
    end
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('GetFranchise', function(identifier)
    return franchiseData[identifier]
end)

exports('CanExpand', CanExpandFranchise)
exports('GetExpansionCost', GetExpansionCost)
exports('ApplyBonus', ApplyFranchiseBonus)

print('[MLFA GASSTATION] Franchise system loaded')
