-- Auto-create database tables on resource start
MySQL.ready(function()
    print('[MLFA GASSTATION] Initializing database...')
    
    -- Gas Stations Table
    MySQL.query([[
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
        )
    ]])
    
    -- Employees Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS gas_employees (
            id INT AUTO_INCREMENT PRIMARY KEY,
            station_id INT NOT NULL,
            identifier VARCHAR(60) NOT NULL,
            rank VARCHAR(20) DEFAULT 'employee',
            salary INT DEFAULT 1200,
            hired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE,
            UNIQUE KEY unique_employee (station_id, identifier),
            INDEX idx_identifier (identifier)
        )
    ]])
    
    -- Transactions Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS gas_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            station_id INT NOT NULL,
            type ENUM('fuel_sale', 'expense', 'salary', 'mission_reward', 'fuel_purchase') NOT NULL,
            amount DECIMAL(10,2) NOT NULL,
            description TEXT,
            created_by VARCHAR(60),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE,
            INDEX idx_station (station_id),
            INDEX idx_type (type),
            INDEX idx_date (created_at)
        )
    ]])
    
    -- Fuel Sales Table (detailed tracking)
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS gas_fuel_sales (
            id INT AUTO_INCREMENT PRIMARY KEY,
            station_id INT NOT NULL,
            player_id VARCHAR(60) NOT NULL,
            vehicle_plate VARCHAR(20),
            liters DECIMAL(10,2) NOT NULL,
            price_per_liter DECIMAL(10,2) NOT NULL,
            total_cost DECIMAL(10,2) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE,
            INDEX idx_station (station_id),
            INDEX idx_player (player_id),
            INDEX idx_date (created_at)
        )
    ]])
    
    -- Missions Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS gas_missions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            station_id INT NOT NULL,
            player_id VARCHAR(60) NOT NULL,
            mission_type VARCHAR(50) NOT NULL,
            status ENUM('active', 'completed', 'failed') DEFAULT 'active',
            reward INT DEFAULT 0,
            started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            completed_at TIMESTAMP NULL,
            FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE,
            INDEX idx_player (player_id),
            INDEX idx_status (status)
        )
    ]])
    
    -- Initialize default stations
    for _, station in ipairs(Config.Stations) do
        MySQL.query('SELECT id FROM gas_stations WHERE name = ?', {station.name}, function(result)
            if not result or #result == 0 then
                MySQL.insert('INSERT INTO gas_stations (name, fuel_stock, fuel_price) VALUES (?, ?, ?)', {
                    station.name,
                    Config.MaxFuelStock / 2,
                    Config.DefaultFuelPrice
                })
                print('[MLFA GASSTATION] Created station: ' .. station.label)
            end
        end)
    end
    
    print('[MLFA GASSTATION] Database initialized successfully')
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
    MySQL.query('SELECT rank FROM gas_employees WHERE identifier = ? AND station_id = ?', {
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
