-- ============================================================================
-- CORE SERVER FUNCTIONS
-- Essential global functions for the resource
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- EMPLOYEE FUNCTIONS
-- ============================================================================

function GetEmployeeRank(identifier, stationId, cb)
    MySQL.scalar('SELECT `rank` FROM gas_employees WHERE identifier = ? AND station_id = ?', {identifier, stationId}, function(rank)
        cb(rank)
    end)
end

function GetStationEmployees(stationId, cb)
    MySQL.query('SELECT * FROM gas_employees WHERE station_id = ?', {stationId}, function(employees)
        -- Get names for each employee
        if employees and #employees > 0 then
            local processed = 0
            for i, employee in ipairs(employees) do
                local xPlayer = ESX.GetPlayerFromIdentifier(employee.identifier)
                if xPlayer then
                    employee.name = xPlayer.getName()
                    processed = processed + 1
                    if processed == #employees then cb(employees) end
                else
                    -- Fallback if player offline (could fetch from users table if needed)
                    MySQL.scalar('SELECT firstname, lastname FROM users WHERE identifier = ?', {employee.identifier}, function(result)
                        if result then
                            employee.name = result.firstname .. ' ' .. result.lastname
                        else
                            employee.name = 'Inconnu'
                        end
                        processed = processed + 1
                        if processed == #employees then cb(employees) end
                    end)
                end
            end
        else
            cb({})
        end
    end)
end

-- ============================================================================
-- TRANSACTION FUNCTIONS
-- ============================================================================

function AddTransaction(stationId, type, amount, description, createdBy)
    MySQL.insert('INSERT INTO gas_transactions (station_id, type, amount, description, created_by) VALUES (?, ?, ?, ?, ?)',
        {stationId, type, amount, description, createdBy}, function(id)
        
        -- Update station money cache/db if needed
        if type == 'fuel_sale' or type == 'deposit' or type == 'mission_reward' then
            MySQL.update('UPDATE gas_stations SET money = money + ? WHERE id = ?', {amount, stationId})
        elseif type == 'expense' or type == 'withdrawal' or type == 'salary' or type == 'fuel_purchase' then
            MySQL.update('UPDATE gas_stations SET money = money - ? WHERE id = ?', {math.abs(amount), stationId})
        end
    end)
end

function GetStationTransactions(stationId, limit, cb)
    limit = limit or 20
    MySQL.query('SELECT * FROM gas_transactions WHERE station_id = ? ORDER BY created_at DESC LIMIT ?', {stationId, limit}, function(transactions)
        cb(transactions or {})
    end)
end

-- ============================================================================
-- STATION DATA FUNCTIONS
-- ============================================================================

function GetStationData(stationId, cb)
    MySQL.single('SELECT * FROM gas_stations WHERE id = ?', {stationId}, function(station)
        cb(station)
    end)
end

function GetFuelSalesStats(stationId, period, cb)
    local query = ''
    if period == 'today' then
        query = [[
            SELECT COALESCE(SUM(liters), 0) as total_liters, COALESCE(SUM(amount), 0) as total_revenue 
            FROM gas_fuel_sales 
            WHERE station_id = ? AND DATE(created_at) = CURDATE()
        ]]
    elseif period == 'week' then
        query = [[
            SELECT COALESCE(SUM(liters), 0) as total_liters, COALESCE(SUM(amount), 0) as total_revenue 
            FROM gas_fuel_sales 
            WHERE station_id = ? AND YEARWEEK(created_at, 1) = YEARWEEK(CURDATE(), 1)
        ]]
    else
        cb({total_liters = 0, total_revenue = 0})
        return
    end
    
    MySQL.single(query, {stationId}, function(result)
        cb(result or {total_liters = 0, total_revenue = 0})
    end)
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('GetEmployeeRank', GetEmployeeRank)
exports('GetStationEmployees', GetStationEmployees)
exports('AddTransaction', AddTransaction)
exports('GetStationTransactions', GetStationTransactions)
exports('GetStationData', GetStationData)
