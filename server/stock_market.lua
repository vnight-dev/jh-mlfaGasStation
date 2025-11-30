-- ============================================================================
-- STOCK MARKET SYSTEM FOR GAS STATIONS
-- Buy and sell shares in gas stations, earn dividends
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local StockConfig = {
    Enabled = true,
    
    -- Stock market settings
    TotalShares = 1000,              -- Total shares per station
    MinSharePrice = 100,             -- Minimum price per share
    MaxSharePrice = 10000,           -- Maximum price per share
    
    -- Trading fees
    BuyFee = 0.02,                   -- 2% fee on buy
    SellFee = 0.02,                  -- 2% fee on sell
    
    -- Dividends
    DividendRate = 0.10,             -- 10% of profits distributed
    DividendInterval = 86400000,     -- Daily (ms)
    
    -- Price calculation weights
    PriceWeights = {
        revenue = 0.40,
        sales = 0.30,
        stock = 0.20,
        employees = 0.10
    }
}

-- Market data
local stockMarket = {}
local shareholders = {}  -- [stationId][identifier] = shares

-- ============================================================================
-- STOCK PRICE CALCULATION
-- ============================================================================

local function CalculateStockPrice(stationId)
    MySQL.query([[
        SELECT 
            s.money,
            s.fuel_stock,
            COALESCE(SUM(CASE WHEN t.type = 'fuel_sale' THEN t.amount ELSE 0 END), 0) as revenue,
            COALESCE(SUM(CASE WHEN t.type = 'fuel_sale' THEN 1 ELSE 0 END), 0) as sales,
            COUNT(DISTINCT e.id) as employees
        FROM gas_stations s
        LEFT JOIN gas_transactions t ON s.id = t.station_id AND t.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        LEFT JOIN gas_employees e ON s.id = e.station_id
        WHERE s.id = ?
        GROUP BY s.id
    ]], {stationId}, function(data)
        if not data or not data[1] then return end
        
        local stats = data[1]
        
        -- Normalize values (0-100 scale)
        local revenueScore = math.min((stats.revenue / 50000) * 100, 100)
        local salesScore = math.min((stats.sales / 200) * 100, 100)
        local stockScore = math.min((stats.fuel_stock / 10000) * 100, 100)
        local employeesScore = math.min((stats.employees / 10) * 100, 100)
        
        -- Calculate weighted score
        local score = (revenueScore * StockConfig.PriceWeights.revenue) +
                      (salesScore * StockConfig.PriceWeights.sales) +
                      (stockScore * StockConfig.PriceWeights.stock) +
                      (employeesScore * StockConfig.PriceWeights.employees)
        
        -- Convert score to price
        local priceRange = StockConfig.MaxSharePrice - StockConfig.MinSharePrice
        local price = StockConfig.MinSharePrice + (priceRange * (score / 100))
        
        -- Store in market
        if not stockMarket[stationId] then
            stockMarket[stationId] = {}
        end
        
        stockMarket[stationId].price = math.floor(price)
        stockMarket[stationId].change = 0
        stockMarket[stationId].volume = 0
        stockMarket[stationId].lastUpdate = os.time()
        
        print(string.format('[STOCK MARKET] Station %d: $%d/share (Score: %.2f)', 
            stationId, stockMarket[stationId].price, score))
    end)
end

-- ============================================================================
-- TRADING FUNCTIONS
-- ============================================================================

local function BuyShares(identifier, stationId, shares)
    local stock = stockMarket[stationId]
    if not stock then return false, 'Station not on market' end
    
    local totalCost = (stock.price * shares) * (1 + StockConfig.BuyFee)
    
    -- Initialize shareholder data
    if not shareholders[stationId] then
        shareholders[stationId] = {}
    end
    if not shareholders[stationId][identifier] then
        shareholders[stationId][identifier] = 0
    end
    
    -- Update shares
    shareholders[stationId][identifier] = shareholders[stationId][identifier] + shares
    stock.volume = stock.volume + shares
    
    -- Save to database
    MySQL.insert([[
        INSERT INTO gas_stock_transactions (station_id, player_identifier, type, shares, price, total_cost)
        VALUES (?, ?, 'BUY', ?, ?, ?)
    ]], {stationId, identifier, shares, stock.price, totalCost})
    
    return true, totalCost
end

local function SellShares(identifier, stationId, shares)
    local stock = stockMarket[stationId]
    if not stock then return false, 'Station not on market' end
    
    if not shareholders[stationId] or not shareholders[stationId][identifier] then
        return false, 'No shares owned'
    end
    
    if shareholders[stationId][identifier] < shares then
        return false, 'Insufficient shares'
    end
    
    local totalRevenue = (stock.price * shares) * (1 - StockConfig.SellFee)
    
    -- Update shares
    shareholders[stationId][identifier] = shareholders[stationId][identifier] - shares
    stock.volume = stock.volume + shares
    
    -- Save to database
    MySQL.insert([[
        INSERT INTO gas_stock_transactions (station_id, player_identifier, type, shares, price, total_cost)
        VALUES (?, ?, 'SELL', ?, ?, ?)
    ]], {stationId, identifier, shares, stock.price, totalRevenue})
    
    return true, totalRevenue
end

-- ============================================================================
-- DIVIDEND DISTRIBUTION
-- ============================================================================

local function DistributeDividends()
    print('[STOCK MARKET] Distributing dividends...')
    
    for stationId, stock in pairs(stockMarket) do
        -- Get station profits
        MySQL.scalar([[
            SELECT COALESCE(SUM(CASE WHEN type = 'fuel_sale' THEN amount ELSE 0 END), 0)
            FROM gas_transactions
            WHERE station_id = ?
            AND created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        ]], {stationId}, function(profit)
            if not profit or profit <= 0 then return end
            
            local dividendPool = profit * StockConfig.DividendRate
            
            -- Distribute to shareholders
            if shareholders[stationId] then
                for identifier, shares in pairs(shareholders[stationId]) do
                    local sharePercentage = shares / StockConfig.TotalShares
                    local dividend = dividendPool * sharePercentage
                    
                    if dividend > 0 then
                        -- Pay dividend
                        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                        if xPlayer then
                            xPlayer.addAccountMoney('bank', dividend)
                            TriggerClientEvent('mlfaGasStation:notify', xPlayer.source, 'success',
                                string.format('Dividende reçu: $%d', math.floor(dividend)))
                        else
                            -- Offline player, add to bank
                            MySQL.update('UPDATE users SET bank = bank + ? WHERE identifier = ?', {
                                dividend, identifier
                            })
                        end
                        
                        print(string.format('[DIVIDENDS] Paid $%d to %s (Station %d)', 
                            math.floor(dividend), identifier, stationId))
                    end
                end
            end
        end)
    end
end

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Buy shares
RegisterServerEvent('mlfaGasStation:buyShares')
AddEventHandler('mlfaGasStation:buyShares', function(stationId, shares)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local success, result = BuyShares(xPlayer.identifier, stationId, shares)
    
    if success then
        if xPlayer.getMoney() >= result then
            xPlayer.removeMoney(result)
            TriggerClientEvent('mlfaGasStation:notify', source, 'success',
                string.format('Acheté %d actions pour $%d', shares, math.floor(result)))
        else
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Argent insuffisant')
        end
    else
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', result)
    end
end)

-- Sell shares
RegisterServerEvent('mlfaGasStation:sellShares')
AddEventHandler('mlfaGasStation:sellShares', function(stationId, shares)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local success, result = SellShares(xPlayer.identifier, stationId, shares)
    
    if success then
        xPlayer.addMoney(result)
        TriggerClientEvent('mlfaGasStation:notify', source, 'success',
            string.format('Vendu %d actions pour $%d', shares, math.floor(result)))
    else
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', result)
    end
end)

-- Get market data
RegisterServerEvent('mlfaGasStation:getMarketData')
AddEventHandler('mlfaGasStation:getMarketData', function()
    local source = source
    TriggerClientEvent('mlfaGasStation:updateMarket', source, stockMarket)
end)

-- ============================================================================
-- AUTO UPDATE
-- ============================================================================

Citizen.CreateThread(function()
    if not StockConfig.Enabled then
        print('[STOCK MARKET] Stock market is disabled')
        return
    end
    
    print('[STOCK MARKET] Stock market started')
    
    -- Initial price calculation
    Wait(10000)
    for _, station in ipairs(Config.Stations) do
        CalculateStockPrice(station.id)
    end
    
    -- Update prices every 10 minutes
    while true do
        Wait(600000)
        for _, station in ipairs(Config.Stations) do
            CalculateStockPrice(station.id)
        end
    end
end)

-- Dividend distribution thread
Citizen.CreateThread(function()
    while true do
        Wait(StockConfig.DividendInterval)
        DistributeDividends()
    end
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('GetStockPrice', function(stationId)
    return stockMarket[stationId] and stockMarket[stationId].price or 0
end)

exports('GetShares', function(identifier, stationId)
    return shareholders[stationId] and shareholders[stationId][identifier] or 0
end)

print('[MLFA GASSTATION] Stock market system loaded')
