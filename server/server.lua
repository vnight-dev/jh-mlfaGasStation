local ESX = exports['es_extended']:getSharedObject()

-- === AUTO SQL & DB POPULATION ===
MySQL.ready(function()
    -- 1. Run SQL File
    local sqlFile = LoadResourceFile(GetCurrentResourceName(), 'mlfa_gasstations.sql')
    if sqlFile then
        local queries = {}
        for query in sqlFile:gmatch('([^;]+);') do
            query = query:gsub('%-%-[^\n]*', ''):gsub('^%s+', ''):gsub('%s+$', '')
            if query ~= '' then table.insert(queries, query) end
        end
        
        local success = 0
        for _, q in ipairs(queries) do
            MySQL.query(q, {}, function(affected)
                if affected then success = success + 1 end
            end)
        end
        print('^2[mlfaGasStation] SQL Init: Executed '..success..' queries.^7')
    else
        print('^1[mlfaGasStation] Error: mlfa_gasstations.sql not found!^7')
    end

    -- 2. Populate Stations from Config
    Citizen.Wait(2000) -- Wait for tables to be created
    for _, station in ipairs(Config.Stations) do
        MySQL.query('SELECT id FROM mlfa_gasstations WHERE id = @id', {['@id'] = station.id}, function(result)
            if not result[1] then
                print('^3[mlfaGasStation] Inserting Station #'..station.id..' into DB...^7')
                local pos = {x = station.position.x, y = station.position.y, z = station.position.z}
                MySQL.insert('INSERT INTO mlfa_gasstations (id, name, price, stock, fuel_price, money, position) VALUES (@id, @name, @price, @stock, @fuel_price, @money, @position)', {
                    ['@id'] = station.id,
                    ['@name'] = station.name,
                    ['@price'] = 50000, -- Default price
                    ['@stock'] = 10000,
                    ['@fuel_price'] = 1.5,
                    ['@money'] = 0,
                    ['@position'] = json.encode(pos)
                })
            end
        end)
    end

    -- 3. Create Employees Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mlfa_gasstation_employees` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `station_id` int(11) NOT NULL,
            `identifier` varchar(60) NOT NULL,
            `name` varchar(100) NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- === CALLBACKS & EVENTS ===

ESX.RegisterServerCallback('mlfaGasStation:getStationInfo', function(source, cb, stationId)
    MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
        if result[1] then
            local station = result[1]
            station.employees = {}

            -- Get Employees
            MySQL.query('SELECT * FROM mlfa_gasstation_employees WHERE station_id = @id', {['@id'] = stationId}, function(empResult)
                if empResult then
                    station.employees = empResult
                end

                -- Get owner name if owned
                if station.owner then
                    local xPlayer = ESX.GetPlayerFromIdentifier(station.owner)
                    if xPlayer then
                        station.owner_name = xPlayer.getName()
                        cb(station)
                    else
                        -- Fallback if offline (query users table)
                        MySQL.query('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {['@identifier'] = station.owner}, function(userResult)
                            if userResult[1] then
                                station.owner_name = userResult[1].firstname .. " " .. userResult[1].lastname
                            else
                                station.owner_name = "Inconnu"
                            end
                            cb(station)
                        end)
                    end
                else
                    cb(station)
                end
            end)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('mlfaGasStation:buyStation')
AddEventHandler('mlfaGasStation:buyStation', function(stationId)
    if not stationId then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
        if result[1] and not result[1].owner then
            if xPlayer.getMoney() >= result[1].price then
                xPlayer.removeMoney(result[1].price)
                MySQL.update('UPDATE mlfa_gasstations SET owner = @owner WHERE id = @id', {
                    ['@owner'] = xPlayer.identifier,
                    ['@id'] = stationId
                })
                TriggerClientEvent('esx:showNotification', source, 'Vous avez acheté la station !')
                if Config.Webhook then
                    PerformHttpRequest(Config.Webhook, function() end, 'POST', json.encode({embeds = {{title = 'Achat Station', description = xPlayer.getName() .. ' a acheté la station ' .. stationId}}} ), {['Content-Type'] = 'application/json'})
                end
            else
                TriggerClientEvent('esx:showNotification', source, 'Pas assez d\'argent !')
            end
        end
    end)
end)

RegisterServerEvent('mlfaGasStation:payFuel')
AddEventHandler('mlfaGasStation:payFuel', function(stationId, liters, cost)
    if not stationId then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= cost then
        xPlayer.removeMoney(cost)
        MySQL.update('UPDATE mlfa_gasstations SET money = money + @cost, stock = stock - @liters WHERE id = @id', {
            ['@cost'] = cost,
            ['@liters'] = liters,
            ['@id'] = stationId
        })
        MySQL.insert('INSERT INTO mlfa_gasstations_sales (station_id, buyer, liters, price) VALUES (@station_id, @buyer, @liters, @price)', {
            ['@station_id'] = stationId,
            ['@buyer'] = xPlayer.identifier,
            ['@liters'] = liters,
            ['@price'] = cost
        })
        TriggerClientEvent('mlfaGasStation:setFuel', source, liters)
    else
        TriggerClientEvent('esx:showNotification', source, 'Pas assez d\'argent !')
    end
end)

RegisterServerEvent('mlfaGasStation:withdrawMoney')
AddEventHandler('mlfaGasStation:withdrawMoney', function(stationId, amount)
    if not stationId then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
        if result[1] and result[1].owner == xPlayer.identifier then
            local currentMoney = result[1].money
            if amount and amount > 0 and currentMoney >= amount then
                MySQL.update('UPDATE mlfa_gasstations SET money = money - @amount WHERE id = @id', {
                    ['@amount'] = amount,
                    ['@id'] = stationId
                })
                xPlayer.addMoney(amount)
                TriggerClientEvent('esx:showNotification', source, 'Vous avez retiré $' .. amount)
            else
                TriggerClientEvent('esx:showNotification', source, 'Montant invalide ou fonds insuffisants !')
            end
        end
    end)
end)

RegisterServerEvent('mlfaGasStation:setPrice')
AddEventHandler('mlfaGasStation:setPrice', function(stationId, price)
    if not stationId then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
        if result[1] and result[1].owner == xPlayer.identifier then
            MySQL.update('UPDATE mlfa_gasstations SET fuel_price = @price WHERE id = @id', {
                ['@price'] = price,
                ['@id'] = stationId
            })
            TriggerClientEvent('esx:showNotification', source, 'Prix mis à jour : $' .. price .. '/L')
        end
    end)
end)

RegisterServerEvent('mlfaGasStation:missionReward')
AddEventHandler('mlfaGasStation:missionReward', function(stationId)
    if not stationId then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
        if result[1] then
            MySQL.update('UPDATE mlfa_gasstations SET stock = stock + @amount WHERE id = @id', {
                ['@amount'] = Config.MissionStockAdd,
                ['@id'] = stationId
            })
            xPlayer.addMoney(Config.MissionReward)
            TriggerClientEvent('esx:showNotification', source, 'Mission terminée ! Stock: +'..Config.MissionStockAdd..'L | Gain: $'..Config.MissionReward)
        end
    end)
end)

RegisterServerEvent('mlfaGasStation:hireEmployee')
AddEventHandler('mlfaGasStation:hireEmployee', function(stationId, targetId)
    if not stationId then return end
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if xTarget then
        MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
            if result[1] and result[1].owner == xPlayer.identifier then
                MySQL.insert('INSERT INTO mlfa_gasstation_employees (station_id, identifier, name) VALUES (@station_id, @identifier, @name)', {
                    ['@station_id'] = stationId,
                    ['@identifier'] = xTarget.identifier,
                    ['@name'] = xTarget.getName()
                })
                TriggerClientEvent('esx:showNotification', source, 'Vous avez embauché ' .. xTarget.getName())
                TriggerClientEvent('esx:showNotification', targetId, 'Vous avez été embauché à la station ' .. stationId)
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', source, 'Joueur introuvable !')
    end
end)

RegisterServerEvent('mlfaGasStation:fireEmployee')
AddEventHandler('mlfaGasStation:fireEmployee', function(stationId, identifier)
    if not stationId then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.query('SELECT * FROM mlfa_gasstations WHERE id = @id', {['@id'] = stationId}, function(result)
        if result[1] and result[1].owner == xPlayer.identifier then
            MySQL.update('DELETE FROM mlfa_gasstation_employees WHERE station_id = @station_id AND identifier = @identifier', {
                ['@station_id'] = stationId,
                ['@identifier'] = identifier
            })
            TriggerClientEvent('esx:showNotification', source, 'Employé viré !')
        end
    end)
end)