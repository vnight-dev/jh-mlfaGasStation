-- ============================================================================
-- AUTO-REPAIR DATABASE SYSTEM v6.0
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

-- Check and insert default stations
local function checkDefaultStations()
    MySQL.scalar('SELECT COUNT(*) FROM gas_stations', {}, function(count)
        if count == 0 then
            print('[MLFA GASSTATION] 📥 Inserting default stations...')
            
            local stations = {
                {1, 'Station 1', 'Station Downtown', 5000, 2.50},
                {2, 'Station 2', 'Station Grove Street', 5000, 2.50},
                {3, 'Station 3', 'Station Sandy Shores', 5000, 2.50},
                {4, 'Station 4', 'Station Paleto Bay', 5000, 2.50},
                {5, 'Station 5', 'Station Great Ocean Highway', 5000, 2.50}
            }
            
            for _, s in ipairs(stations) do
                MySQL.insert('INSERT INTO gas_stations (id, name, label, fuel_stock, fuel_price) VALUES (?, ?, ?, ?, ?)',
                    {s[1], s[2], s[3], s[4], s[5]})
            end
            
            print('[MLFA GASSTATION] ✅ Default stations inserted successfully')
        else
            print('[MLFA GASSTATION] ✅ Stations table already populated (' .. count .. ' stations)')
        end
    end)
end

MySQL.ready(function()
    print('[MLFA GASSTATION] Initializing database with auto-repair system v6.0...')
    
    -- SEQUENTIAL TABLE CREATION (to avoid foreign key issues)
    
    -- Step 1: Gas Stations Table (must be first - referenced by others)
    createTableSafe('gas_stations', [[
        CREATE TABLE IF NOT EXISTS gas_stations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            label VARCHAR(100) NOT NULL DEFAULT 'Station Service',
            owner VARCHAR(60),
            fuel_stock INT DEFAULT 5000,
            money INT DEFAULT 0,
            fuel_price DECIMAL(10,2) DEFAULT 2.50,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_owner (owner)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]], function()
        
        -- Step 2: Employees Table
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
                INDEX idx_station (station_id),
                FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Step 3: Transactions Table
        createTableSafe('gas_transactions', [[
            CREATE TABLE IF NOT EXISTS gas_transactions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                `type` VARCHAR(50) NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                description TEXT,
                created_by VARCHAR(60),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_station (station_id),
                INDEX idx_type (`type`),
                INDEX idx_date (created_at),
                FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Step 4: Fuel Sales Table
        createTableSafe('gas_fuel_sales', [[
            CREATE TABLE IF NOT EXISTS gas_fuel_sales (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                liters DECIMAL(10,2) NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                buyer_identifier VARCHAR(60),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_station (station_id),
                FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Step 5: Missions Table
        createTableSafe('gas_missions', [[
            CREATE TABLE IF NOT EXISTS gas_missions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                mission_type VARCHAR(50) NOT NULL,
                player_identifier VARCHAR(60) NOT NULL,
                status VARCHAR(20) DEFAULT 'active',
                reward INT DEFAULT 0,
                started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP NULL,
                INDEX idx_station (station_id),
                INDEX idx_player (player_identifier),
                FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Step 6: Player Progress (Reputation)
        createTableSafe('gas_player_progress', [[
            CREATE TABLE IF NOT EXISTS gas_player_progress (
                identifier VARCHAR(60) NOT NULL PRIMARY KEY,
                level INT DEFAULT 1,
                xp INT DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Step 7: Achievements
        createTableSafe('gas_achievements', [[
            CREATE TABLE IF NOT EXISTS gas_achievements (
                id INT AUTO_INCREMENT PRIMARY KEY,
                identifier VARCHAR(60) NOT NULL,
                achievement_id VARCHAR(50) NOT NULL,
                unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_achievement (identifier, achievement_id),
                INDEX idx_identifier (identifier)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Step 8: Stock Market
        createTableSafe('gas_stocks', [[
            CREATE TABLE IF NOT EXISTS gas_stocks (
                id INT AUTO_INCREMENT PRIMARY KEY,
                station_id INT NOT NULL,
                identifier VARCHAR(60) NOT NULL,
                shares INT DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY unique_stock (station_id, identifier),
                FOREIGN KEY (station_id) REFERENCES gas_stations(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]], function()
            -- All tables created, check for default data
            print('[MLFA GASSTATION] ✅ Database initialized successfully')
            checkDefaultStations()
        end)
        
    end)
end)
