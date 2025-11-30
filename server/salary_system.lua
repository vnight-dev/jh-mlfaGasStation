-- ============================================================================
-- AUTOMATIC SALARY SYSTEM
-- Pays employees automatically at configured intervals
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- Check if system is enabled
if not Config.Employees.AutoPayment.Enabled then
    print('[SALARY] Automatic salary system is disabled')
    return
end

-- ============================================================================
-- SALARY PAYMENT LOGIC
-- ============================================================================

local function PaySalaries()
    print('[SALARY] Processing salary payments...')
    
    -- Get all employees
    MySQL.query([[
        SELECT 
            e.id,
            e.station_id,
            e.identifier,
            e.rank,
            e.salary,
            s.money as station_money,
            s.label as station_name
        FROM gas_employees e
        JOIN gas_stations s ON e.station_id = s.id
        WHERE e.salary > 0
    ]], {}, function(employees)
        if not employees or #employees == 0 then
            print('[SALARY] No employees to pay')
            return
        end
        
        print('[SALARY] Found ' .. #employees .. ' employees to pay')
        
        for _, employee in ipairs(employees) do
            local stationId = employee.station_id
            local salary = employee.salary
            local stationMoney = employee.station_money
            local identifier = employee.identifier
            local rank = employee.rank
            local stationName = employee.station_name
            
            -- Check if station has enough money
            if Config.Employees.AutoPayment.FromStationMoney then
                if stationMoney >= salary then
                    -- Deduct from station
                    UpdateStationMoney(stationId, -salary)
                    
                    -- Pay employee
                    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                    if xPlayer then
                        xPlayer.addMoney(salary)
                        TriggerClientEvent('mlfaGasStation:notify', xPlayer.source, 'success', 
                            string.format('Salaire reçu: $%d (%s)', salary, stationName))
                        print('[SALARY] Paid ' .. xPlayer.getName() .. ' $' .. salary .. ' from station ' .. stationId)
                    else
                        -- Player offline, add to bank
                        MySQL.update('UPDATE users SET bank = bank + ? WHERE identifier = ?', {
                            salary, identifier
                        })
                        print('[SALARY] Paid offline player ' .. identifier .. ' $' .. salary .. ' (added to bank)')
                    end
                    
                    -- Add transaction
                    AddTransaction(stationId, 'expense', -salary, 
                        string.format('Salaire %s', rank), 'system')
                    
                    -- Discord logging
                    if DiscordLog and Config.Discord.Logs.Money then
                        local playerName = xPlayer and xPlayer.getName() or identifier
                        DiscordLog.MoneyTransaction(
                            stationId, 
                            stationName, 
                            'salary', 
                            salary, 
                            playerName, 
                            'Paiement automatique de salaire'
                        )
                    end
                else
                    -- Not enough money in station
                    print('[SALARY] Station ' .. stationId .. ' has insufficient funds ($' .. stationMoney .. ' < $' .. salary .. ')')
                    
                    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                    if xPlayer then
                        TriggerClientEvent('mlfaGasStation:notify', xPlayer.source, 'error', 
                            string.format('Salaire non payé: station sans argent (%s)', stationName))
                    end
                    
                    -- Log error to Discord
                    if DiscordLog and Config.Discord.Logs.Errors then
                        DiscordLog.SystemError(
                            'Salary Payment Failed',
                            string.format('Station %s cannot pay salary of $%d (balance: $%d)', 
                                stationName, salary, stationMoney),
                            'Station ID: ' .. stationId
                        )
                    end
                end
            else
                -- Pay from server (not from station money)
                local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                if xPlayer then
                    xPlayer.addMoney(salary)
                    TriggerClientEvent('mlfaGasStation:notify', xPlayer.source, 'success', 
                        string.format('Salaire reçu: $%d', salary))
                else
                    MySQL.update('UPDATE users SET bank = bank + ? WHERE identifier = ?', {
                        salary, identifier
                    })
                end
                
                print('[SALARY] Paid ' .. identifier .. ' $' .. salary .. ' (from server)')
            end
        end
        
        print('[SALARY] Salary payment completed')
    end)
end

-- ============================================================================
-- AUTOMATIC PAYMENT LOOP
-- ============================================================================

Citizen.CreateThread(function()
    local interval = Config.Employees.AutoPayment.Interval * 1000 -- Convert to ms
    
    print('[SALARY] Automatic salary system started')
    print('[SALARY] Payment interval: ' .. Config.Employees.AutoPayment.Interval .. ' seconds')
    print('[SALARY] From station money: ' .. tostring(Config.Employees.AutoPayment.FromStationMoney))
    
    while true do
        Wait(interval)
        PaySalaries()
    end
end)

-- ============================================================================
-- MANUAL PAYMENT COMMAND (Admin)
-- ============================================================================

RegisterCommand('gaspaysalaries', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and xPlayer.getGroup() == 'admin' then
        print('[SALARY] Manual salary payment triggered by ' .. xPlayer.getName())
        PaySalaries()
        TriggerClientEvent('mlfaGasStation:notify', source, 'success', 'Salaires payés manuellement')
    else
        TriggerClientEvent('mlfaGasStation:notify', source, 'error', 'Permission refusée')
    end
end, false)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('PaySalariesNow', function()
    PaySalaries()
end)

exports('GetNextPaymentTime', function()
    return Config.Employees.AutoPayment.Interval
end)

print('[MLFA GASSTATION] Automatic salary system loaded')
