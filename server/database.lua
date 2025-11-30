-- ============================================================================
-- AUTO-REPAIR DATABASE SYSTEM
-- Automatically creates and repairs tables if there are issues
-- ============================================================================

local tablesCreated = false
local creationAttempts = 0
local MAX_ATTEMPTS = 3

-- Function to drop and recreate a table if it has issues
local function repairTable(tableName, createQuery)
    print('[MLFA GASSTATION] Attempting to repair table: ' .. tableName)
    
    -- Try to drop the table first (ignore errors)
    MySQL.query('DROP TABLE IF EXISTS ' .. tableName, {}, function()
        -- Recreate the table
        MySQL.query(createQuery, {}, function(success)
            if success then
                print('[MLFA GASSTATION] ✅ Table ' .. tableName .. ' repaired successfully')
            else
                print('[MLFA GASSTATION] ❌ Failed to repair table: ' .. tableName)
            end
        end)
    end)
end

-- Safe table creation with error handling
local function createTableSafe(tableName, createQuery, onSuccess)
    MySQL.query(createQuery, {}, function(success, err)
        if success then
            print('[MLFA GASSTATION] ✅ Table ' .. tableName .. ' ready')
            if onSuccess then onSuccess() end
        else
            print('[MLFA GASSTATION] ⚠️ Error creating ' .. tableName .. ': ' .. tostring(err))
            
            -- Auto-repair: drop and recreate
            if creationAttempts < MAX_ATTEMPTS then
                creationAttempts = creationAttempts + 1
                print('[MLFA GASSTATION] 🔧 Auto-repair attempt ' .. creationAttempts .. '/' .. MAX_ATTEMPTS)
                repairTable(tableName, createQuery)
            else
                print('[MLFA GASSTATION] ❌ Max repair attempts reached for ' .. tableName)
            end
        end
    end)
end

MySQL.ready(function()
    print('[MLFA GASSTATION] Initializing database with auto-repair system...')
    
    -- SEQUENTIAL TABLE CREATION (to avoid foreign key issues)
    -- Step 1: Gas Stations Table (must be first - referenced by others)
    createTableSafe('gas_stations', [[
        CREATE TABLE IF NOT EXISTS gas_stations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50) UNIQUE NOT NULL,
            owner VARCHAR(60),
            fuel_stock INT DEFAULT 5000,
            money INT DEFAULT 0,
            fuel_price DECIMAL(10,2) DEFAULT 2.50,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_owner (owner)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
    ]], function()
        -- Step 2: Employees Table (after gas_stations)
        createTableSafe('gas_employees', [[
            CREATE TABLE IF NOT EXISTS gas_employees (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                identifier VARCHAR(60) NOT NULL,
                `rank` VARCHAR(20) DEFAULT 'employee',
                salary INT DEFAULT 1200,
                hired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_employee (station_id, identifier),
                INDEX idx_identifier (identifier),
                INDEX idx_station (station_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ]])
        
        -- Step 3: Transactions Table (after gas_stations)
        createTableSafe('gas_transactions', [[
            CREATE TABLE IF NOT EXISTS gas_transactions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                `type` ENUM('fuel_sale', 'expense', 'salary', 'mission_reward', 'fuel_purchase') NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                description TEXT,
                created_by VARCHAR(60),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_station (station_id),
                INDEX idx_type (`type`),
                INDEX idx_date (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ]])
        
        -- Step 4: Fuel Sales Table (after gas_stations)
        createTableSafe('gas_fuel_sales', [[
            CREATE TABLE IF NOT EXISTS gas_fuel_sales (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                player_id VARCHAR(60) NOT NULL,
                vehicle_plate VARCHAR(20),
                liters DECIMAL(10,2) NOT NULL,
                price_per_liter DECIMAL(10,2) NOT NULL,
                total_cost DECIMAL(10,2) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_station (station_id),
                INDEX idx_player (player_id),
                INDEX idx_date (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ]])
        
        -- Step 5: Missions Table (after gas_stations)
        createTableSafe('gas_missions', [[
            CREATE TABLE IF NOT EXISTS gas_missions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                player_id VARCHAR(60) NOT NULL,
                mission_type VARCHAR(50) NOT NULL,
                `status` ENUM('active', 'completed', 'failed') DEFAULT 'active',
                reward INT DEFAULT 0,
                started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP NULL,
                INDEX idx_player (player_id),
                INDEX idx_status (`status`),
                INDEX idx_station (station_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ]])
    end)
    
    -- Wait a bit for tables to be created, then initialize stations
    SetTimeout(2000, function()
        -- Initialize default stations
        for _, station in ipairs(Config.Stations) do
            MySQL.query('SELECT id FROM gas_stations WHERE name = ?', {station.name}, function(result)
                if not result or #result == 0 then
                    MySQL.insert('INSERT INTO gas_stations (name, fuel_stock, fuel_price) VALUES (?, ?, ?)', {
                        station.name,
                        Config.MaxFuelStock / 2,
                        Config.DefaultFuelPrice
                    }, function(insertId)
                        if insertId then
                            print('[MLFA GASSTATION] ✅ Created station: ' .. station.label)
                        end
                    end)
                end
            end)
        end
        
        tablesCreated = true
        print('[MLFA GASSTATION] ✅ Database initialized successfully')
    end)
end)

-- Health check: verify tables every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        
        if tablesCreated then
            -- Verify critical tables exist
            MySQL.query('SHOW TABLES LIKE "gas_stations"', {}, function(result)
                if not result or #result == 0 then
                    print('[MLFA GASSTATION] ⚠️ Critical table missing! Attempting repair...')
                    tablesCreated = false
                    creationAttempts = 0
                    -- Trigger re-initialization
                    TriggerEvent('mlfaGasStation:reinitDatabase')
                end
            end)
        end
    end
end)

-- Event to manually trigger database repair
RegisterNetEvent('mlfaGasStation:reinitDatabase')
AddEventHandler('mlfaGasStation:reinitDatabase', function()
    print('[MLFA GASSTATION] 🔧 Manual database re-initialization triggered')
    tablesCreated = false
    creationAttempts = 0
end)

-- Helper Functions
function GetStationData(stationId, cb)
    MySQL.query('SELECT * FROM gas_stations WHERE id = ?', {stationId}, function(result)
        cb(result and #result > 0 and result[1] or nil)
    end)
end

function GetStationEmployees(stationId, cb)
    MySQL.query([[
        SELECT e.*, u.firstname, u.lastname 
        FROM gas_employees e
        LEFT JOIN users u ON u.identifier = e.identifier
        WHERE e.station_id = ?
    ]], {stationId}, function(result)
        cb(result or {})
    end)
end

function GetStationTransactions(stationId, limit, cb)
    MySQL.query([[
        SELECT * FROM gas_transactions 
        WHERE station_id = ? 
        ORDER BY created_at DESC 
        LIMIT ?
    ]], {stationId, limit or 50}, function(result)
        cb(result or {})
    end)
end

function GetFuelSalesStats(stationId, period, cb)
    local query = [[
        SELECT 
            COUNT(*) as total_sales,
            SUM(liters) as total_liters,
            SUM(total_cost) as total_revenue
        FROM gas_fuel_sales
        WHERE station_id = ?
    ]]
    
    if period == 'today' then
        query = query .. " AND DATE(created_at) = CURDATE()"
    elseif period == 'week' then
        query = query .. " AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"
    elseif period == 'month' then
        query = query .. " AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)"
    end
    
    MySQL.query(query, {stationId}, function(result)
        cb(result and #result > 0 and result[1] or {total_sales = 0, total_liters = 0, total_revenue = 0})
    end)
end

function AddTransaction(stationId, transType, amount, description, createdBy)
    MySQL.insert([[
        INSERT INTO gas_transactions (station_id, type, amount, description, created_by)
        VALUES (?, ?, ?, ?, ?)
    ]], {stationId, transType, amount, description, createdBy})
end

function UpdateStationMoney(stationId, amount)
    MySQL.update('UPDATE gas_stations SET money = money + ? WHERE id = ?', {amount, stationId})
end

function UpdateStationFuel(stationId, amount)
    MySQL.update('UPDATE gas_stations SET fuel_stock = fuel_stock + ? WHERE id = ?', {amount, stationId})
end

function IsStationOwner(identifier, stationId, cb)
    MySQL.query('SELECT owner FROM gas_stations WHERE id = ?', {stationId}, function(result)
        cb(result and #result > 0 and result[1].owner == identifier or false)
    end)
end

function GetEmployeeRank(identifier, stationId, cb)
    MySQL.query('SELECT `rank` FROM gas_employees WHERE identifier = ? AND station_id = ?', {
        identifier, stationId
    }, function(result)
        if result and #result > 0 then
            cb(result[1].rank)
        else
            IsStationOwner(identifier, stationId, function(isOwner)
                cb(isOwner and 'owner' or nil)
            end)
        end
    end)
end

function GetNearestStation(coords)
    local nearestStation = nil
    local nearestDist = 999999.0
    
    for _, station in ipairs(Config.Stations) do
        local dist = #(coords - station.coords)
        if dist < nearestDist then
            nearestDist = dist
            nearestStation = station
        end
    end
    
    return nearestStation, nearestDist
end
