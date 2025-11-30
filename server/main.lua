local ESX = exports['es_extended']:getSharedObject()

-- Get My Identifier Callback
ESX.RegisterServerCallback('mlfaGasStation:getMyIdentifier', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        cb(xPlayer.identifier)
    else
        cb(nil)
    end
end)

-- Get My Rank Callback
ESX.RegisterServerCallback('mlfaGasStation:getMyRank', function(source, cb, stationId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end
    
    GetEmployeeRank(xPlayer.identifier, stationId, function(rank)
        cb(rank)
    end)
end)

-- Get Station Data Callback
ESX.RegisterServerCallback('mlfaGasStation:getStationData', function(source, cb, stationId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end
    
    GetStationData(stationId, function(stationData)
        if not stationData then return cb(nil) end
        
        -- Add label from Config
        for _, station in ipairs(Config.Stations) do
            if station.id == stationId then
                stationData.label = station.label
                break
            end
        end
        
        GetEmployeeRank(xPlayer.identifier, stationId, function(rank)
            GetStationEmployees(stationId, function(employees)
                GetStationTransactions(stationId, 20, function(transactions)
                    GetFuelSalesStats(stationId, 'today', function(todayStats)
                        GetFuelSalesStats(stationId, 'week', function(weekStats)
                            
                            -- If no rank, player is a visitor
                            if not rank then
                                rank = 'visitor'
                            end
                            
                            -- Get rank permissions
                            local permissions = {}
                            for _, r in ipairs(Config.Ranks) do
                                if r.name == rank then
                                    permissions = r.permissions
                                    break
                                end
                            end
                            
                            -- Get allowed apps
                            local allowedApps = {}
                            for appKey, appData in pairs(Config.Apps) do
                                local hasAccess = false
                                for _, allowedRole in ipairs(appData.roles) do
                                    if allowedRole == 'all' or allowedRole == rank then
                                        hasAccess = true
                                        break
                                    end
                                end
                                if hasAccess then
                                    allowedApps[appKey] = appData
                                end
                            end
                            
                            cb({
                                station = stationData,
                                player = {
                                    name = xPlayer.getName(),
                                    rank = rank,
                                    permissions = permissions
                                },
                                apps = allowedApps,
                                employees = employees,
                                transactions = transactions,
                                stats = {
                                    today = todayStats,
                                    week = weekStats
                                }
                            })
                        end)
                    end)
                end)
            end)
        end)
    end)
end)

-- Get Station Owner Callback (for purchase markers)
ESX.RegisterServerCallback('mlfaGasStation:getStationOwner', function(source, cb, stationId)
    MySQL.scalar('SELECT owner FROM gas_stations WHERE id = ?', {stationId}, function(owner)
        cb(owner)
    end)
end)

-- Hire Employee
RegisterNetEvent('mlfaGasStation:hireEmployee')
AddEventHandler('mlfaGasStation:hireEmployee', function(stationId, targetId, rank)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not xTarget then return end
    
    GetEmployeeRank(xPlayer.identifier, stationId, function(playerRank)
        local permissions = {}
        for _, r in ipairs(Config.Ranks) do
            if r.name == playerRank then permissions = r.permissions break end
        end
        
        if not permissions.hireEmployees then
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Permission refusée')
            return
        end
        
        local salary = 1200
        for _, r in ipairs(Config.Ranks) do
            if r.name == rank then salary = r.salary break end
        end
        
        MySQL.insert([[
            INSERT INTO gas_employees (station_id, identifier, rank, salary)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE rank = ?, salary = ?
        ]], {stationId, xTarget.identifier, rank, salary, rank, salary}, function(id)
            if id then
                AddTransaction(stationId, 'expense', 0, 'Employé embauché: ' .. xTarget.getName(), xPlayer.identifier)
                TriggerClientEvent('mlfaGasStation:notify', source, 'success', xTarget.getName() .. ' embauché(e)')
                TriggerClientEvent('mlfaGasStation:notify', targetId, 'success', 'Vous avez été embauché(e)')
            end
        end)
    end)
end)

-- Fire Employee
RegisterNetEvent('mlfaGasStation:fireEmployee')
AddEventHandler('mlfaGasStation:fireEmployee', function(stationId, employeeId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    GetEmployeeRank(xPlayer.identifier, stationId, function(playerRank)
        local permissions = {}
        for _, r in ipairs(Config.Ranks) do
            if r.name == playerRank then permissions = r.permissions break end
        end
        
        if not permissions.fireEmployees then
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Permission refusée')
            return
        end
        
        MySQL.update('DELETE FROM gas_employees WHERE id = ?', {employeeId}, function(affected)
            if affected > 0 then
                AddTransaction(stationId, 'expense', 0, 'Employé licencié', xPlayer.identifier)
                TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Employé licencié')
            end
        end)
    end)
end)

-- Withdraw Money
RegisterNetEvent('mlfaGasStation:withdrawMoney')
AddEventHandler('mlfaGasStation:withdrawMoney', function(stationId, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    GetEmployeeRank(xPlayer.identifier, stationId, function(playerRank)
        local permissions = {}
        for _, r in ipairs(Config.Ranks) do
            if r.name == playerRank then permissions = r.permissions break end
        end
        
        if not permissions.manageMoney then
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Permission refusée')
            return
        end
        
        GetStationData(stationId, function(station)
            if not station or station.money < amount then
                TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Fonds insuffisants')
                return
            end
            
            UpdateStationMoney(stationId, -amount)
            xPlayer.addMoney(amount)
            AddTransaction(stationId, 'expense', -amount, 'Retrait', xPlayer.identifier)
            TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Retrait de $' .. amount)
        end)
    end)
end)

-- Deposit Money
RegisterNetEvent('mlfaGasStation:depositMoney')
AddEventHandler('mlfaGasStation:depositMoney', function(stationId, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.getMoney() < amount then
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Argent insuffisant')
        return
    end
    
    xPlayer.removeMoney(amount)
    UpdateStationMoney(stationId, amount)
    AddTransaction(stationId, 'fuel_sale', amount, 'Dépôt', xPlayer.identifier)
    TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Dépôt de $' .. amount)
end)

-- Update Fuel Price
RegisterNetEvent('mlfaGasStation:updateFuelPrice')
AddEventHandler('mlfaGasStation:updateFuelPrice', function(stationId, newPrice)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    GetEmployeeRank(xPlayer.identifier, stationId, function(playerRank)
        local permissions = {}
        for _, r in ipairs(Config.Ranks) do
            if r.name == playerRank then permissions = r.permissions break end
        end
        
        if not permissions.changeSettings then
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Permission refusée')
            return
        end
        
        MySQL.update('UPDATE gas_stations SET fuel_price = ? WHERE id = ?', {newPrice, stationId}, function()
            AddTransaction(stationId, 'expense', 0, 'Prix modifié: $' .. newPrice, xPlayer.identifier)
            TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Prix mis à jour')
        end)
    end)
end)

-- Purchase Station
RegisterNetEvent('mlfaGasStation:purchaseStation')
AddEventHandler('mlfaGasStation:purchaseStation', function(stationId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        print('[GASSTATION] ERROR: Player not found for purchase')
        return 
    end
    
    print('[GASSTATION] Purchase request from ' .. xPlayer.getName() .. ' for station ' .. stationId)
    
    local purchasePrice = Config.StationPurchasePrice or 500000
    
    if xPlayer.getMoney() < purchasePrice then
        print('[GASSTATION] Player has insufficient funds')
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Argent insuffisant')
        return
    end
    
    -- Check if station is already owned
    MySQL.scalar('SELECT owner FROM gas_stations WHERE id = ?', {stationId}, function(currentOwner)
        if currentOwner and currentOwner ~= '' then
            print('[GASSTATION] Station already owned by ' .. currentOwner)
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Station déjà possédée')
            return
        end
        
        print('[GASSTATION] Processing purchase...')
        xPlayer.removeMoney(purchasePrice)
        
        MySQL.update('UPDATE gas_stations SET owner = ? WHERE id = ?', {xPlayer.identifier, stationId}, function()
            -- Add player as owner employee
            MySQL.insert('INSERT INTO gas_employees (station_id, identifier, rank, salary) VALUES (?, ?, ?, ?)', 
                {stationId, xPlayer.identifier, 'owner', 0}, function()
                    AddTransaction(stationId, 'expense', -purchasePrice, 'Achat de la station', xPlayer.identifier)
                    print('[GASSTATION] Purchase completed successfully')
                    TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Station achetée !')
                    TriggerClientEvent('mlfaGasStation:purchaseSuccess', source, stationId)
                    
                    -- Broadcast to all clients that this station is now owned
                    TriggerClientEvent('mlfaGasStation:updateStationOwner', -1, stationId, xPlayer.identifier)
                end)
        end)
    end)
end)

-- Sell Station
RegisterNetEvent('mlfaGasStation:sellStation')
AddEventHandler('mlfaGasStation:sellStation', function(stationId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    IsStationOwner(xPlayer.identifier, stationId, function(isOwner)
        if not isOwner then
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Vous n\'êtes pas propriétaire')
            return
        end
        
        GetStationData(stationId, function(station)
            if not station then return end
            
            local sellPrice = (Config.StationPurchasePrice or 500000) * 0.7 -- 70% of purchase price
            sellPrice = sellPrice + station.money -- Add station money
            
            xPlayer.addMoney(sellPrice)
            
            -- Remove all employees
            MySQL.update('DELETE FROM gas_employees WHERE station_id = ?', {stationId})
            
            -- Reset station
            MySQL.update('UPDATE gas_stations SET owner = NULL, money = 0 WHERE id = ?', {stationId}, function()
                TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Station vendue pour $' .. sellPrice)
                TriggerClientEvent('mlfaGasStation:close', source)
            end)
        end)
    end)
end)

-- Toggle Permission
RegisterNetEvent('mlfaGasStation:togglePermission')
AddEventHandler('mlfaGasStation:togglePermission', function(stationId, rankName, permissionKey)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    IsStationOwner(xPlayer.identifier, stationId, function(isOwner)
        if not isOwner then
            TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Seul le propriétaire peut modifier les permissions')
            return
        end
        
        -- Update permissions in config (this would need to be saved to database in production)
        -- For now, just notify success
        TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Permission mise à jour')
    end)
end)

print('[MLFA GASSTATION] Server main loaded')
