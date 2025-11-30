-- ============================================================================
-- DISCORD LOGGING SYSTEM
-- Send detailed logs to Discord webhook
-- ============================================================================

local DiscordWebhook = 'https://discord.com/api/webhooks/1444809920288391229/MoW70gHx25IhQE4gh05RlsL6A5CG4vg4SvkWaNCaq4zG6vL7DmSHPETiX5RiI9SLCcN3'

-- Colors for different log types
local Colors = {
    success = 3066993,  -- Green
    error = 15158332,   -- Red
    warning = 15105570, -- Orange
    info = 3447003,     -- Blue
    money = 15844367,   -- Gold
    purchase = 10181046 -- Purple
}

-- Send log to Discord
local function SendDiscordLog(title, description, color, fields)
    if not Config.Discord or not Config.Discord.Enabled then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or Colors.info,
            ["fields"] = fields or {},
            ["footer"] = {
                ["text"] = "jh-mlfaGasStation | " .. os.date("%d/%m/%Y %H:%M:%S")
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }
    }
    
    PerformHttpRequest(DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Gas Station Manager",
        avatar_url = "https://i.imgur.com/4M34hi2.png",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Log station purchase
function LogStationPurchase(playerName, identifier, stationId, stationName, price)
    if not Config.Discord.Logs.Purchase then return end
    
    SendDiscordLog(
        "🏪 Station Achetée",
        "Une station-service a été achetée",
        Colors.purchase,
        {
            {name = "👤 Joueur", value = playerName, inline = true},
            {name = "🆔 Identifier", value = identifier, inline = true},
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "💰 Prix", value = "$" .. price, inline = true}
        }
    )
end

-- Log station sale
function LogStationSale(playerName, identifier, stationId, stationName, price)
    if not Config.Discord.Logs.Purchase then return end
    
    SendDiscordLog(
        "🏪 Station Vendue",
        "Une station-service a été vendue",
        Colors.warning,
        {
            {name = "👤 Joueur", value = playerName, inline = true},
            {name = "🆔 Identifier", value = identifier, inline = true},
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "💰 Prix de vente", value = "$" .. price, inline = true}
        }
    )
end

-- Log fuel sale
function LogFuelSale(stationId, stationName, liters, amount, buyer)
    if not Config.Discord.Logs.Fuel then return end
    
    SendDiscordLog(
        "⛽ Vente de Carburant",
        "Carburant vendu à la station " .. stationName,
        Colors.success,
        {
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "⛽ Litres", value = liters .. "L", inline = true},
            {name = "💰 Montant", value = "$" .. amount, inline = true},
            {name = "👤 Acheteur", value = buyer or "NPC", inline = true}
        }
    )
end

-- Log employee hire
function LogEmployeeHire(stationId, stationName, employeeName, employeeId, rank, hiredBy)
    if not Config.Discord.Logs.Employees then return end
    
    SendDiscordLog(
        "👥 Employé Embauché",
        "Un nouvel employé a été embauché",
        Colors.success,
        {
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "👤 Employé", value = employeeName, inline = true},
            {name = "🆔 ID", value = employeeId, inline = true},
            {name = "🎖️ Rang", value = rank, inline = true},
            {name = "👔 Embauché par", value = hiredBy, inline = true}
        }
    )
end

-- Log employee fire
function LogEmployeeFire(stationId, stationName, employeeName, employeeId, rank, firedBy)
    if not Config.Discord.Logs.Employees then return end
    
    SendDiscordLog(
        "👥 Employé Licencié",
        "Un employé a été licencié",
        Colors.error,
        {
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "👤 Employé", value = employeeName, inline = true},
            {name = "🆔 ID", value = employeeId, inline = true},
            {name = "🎖️ Rang", value = rank, inline = true},
            {name = "👔 Licencié par", value = firedBy, inline = true}
        }
    )
end

-- Log money transaction
function LogMoneyTransaction(stationId, stationName, type, amount, playerName, description)
    if not Config.Discord.Logs.Money then return end
    
    local title = type == 'deposit' and "💰 Dépôt d'Argent" or "💸 Retrait d'Argent"
    local color = type == 'deposit' and Colors.success or Colors.warning
    
    SendDiscordLog(
        title,
        description or "Transaction financière effectuée",
        color,
        {
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "💰 Montant", value = "$" .. amount, inline = true},
            {name = "👤 Joueur", value = playerName, inline = true},
            {name = "📝 Type", value = type == 'deposit' and "Dépôt" or "Retrait", inline = true}
        }
    )
end

-- Log mission completion
function LogMissionComplete(stationId, stationName, missionType, reward, playerName)
    if not Config.Discord.Logs.Missions then return end
    
    SendDiscordLog(
        "🎯 Mission Terminée",
        "Une mission a été complétée",
        Colors.success,
        {
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "🎯 Type", value = missionType, inline = true},
            {name = "💰 Récompense", value = "$" .. reward, inline = true},
            {name = "👤 Joueur", value = playerName, inline = true}
        }
    )
end

-- Log system error
function LogSystemError(errorType, errorMessage, stackTrace)
    if not Config.Discord.Logs.Errors then return end
    
    SendDiscordLog(
        "❌ Erreur Système",
        "Une erreur s'est produite dans le système",
        Colors.error,
        {
            {name = "⚠️ Type", value = errorType, inline = false},
            {name = "📝 Message", value = errorMessage, inline = false},
            {name = "📍 Stack Trace", value = stackTrace or "N/A", inline = false}
        }
    )
end

-- Log fuel delivery
function LogFuelDelivery(stationId, stationName, liters, playerName)
    if not Config.Discord.Logs.Fuel then return end
    
    SendDiscordLog(
        "🚛 Livraison de Carburant",
        "Carburant livré à la station",
        Colors.info,
        {
            {name = "🏪 Station", value = stationName .. " (ID: " .. stationId .. ")", inline = false},
            {name = "⛽ Litres livrés", value = liters .. "L", inline = true},
            {name = "👤 Livreur", value = playerName, inline = true}
        }
    )
end

-- Export functions
_G.DiscordLog = {
    StationPurchase = LogStationPurchase,
    StationSale = LogStationSale,
    FuelSale = LogFuelSale,
    EmployeeHire = LogEmployeeHire,
    EmployeeFire = LogEmployeeFire,
    MoneyTransaction = LogMoneyTransaction,
    MissionComplete = LogMissionComplete,
    SystemError = LogSystemError,
    FuelDelivery = LogFuelDelivery
}

print('[MLFA GASSTATION] Discord logging system loaded')
