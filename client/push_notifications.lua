-- ============================================================================
-- PUSH NOTIFICATIONS SYSTEM
-- Real-time notifications for important events
-- ============================================================================

local notificationQueue = {}
local maxNotifications = 5

-- ============================================================================
-- NOTIFICATION TYPES
-- ============================================================================

local NotificationTypes = {
    SALE = {
        icon = '💰',
        color = '#00C9A7',
        sound = true
    },
    LOW_STOCK = {
        icon = '⚠️',
        color = '#FFD93D',
        sound = true
    },
    SALARY = {
        icon = '💵',
        color = '#00F2EA',
        sound = false
    },
    EVENT = {
        icon = '🎲',
        color = '#FF6B6B',
        sound = true
    },
    RANK = {
        icon = '🏆',
        color = '#FFD700',
        sound = true
    },
    MISSION = {
        icon = '🎯',
        color = '#00F2EA',
        sound = false
    }
}

-- ============================================================================
-- PUSH NOTIFICATION FUNCTION
-- ============================================================================

function SendPushNotification(type, title, message, duration)
    duration = duration or 5000
    
    local notification = {
        id = #notificationQueue + 1,
        type = type,
        title = title,
        message = message,
        duration = duration,
        timestamp = GetGameTimer(),
        config = NotificationTypes[type] or NotificationTypes.SALE
    }
    
    -- Add to queue
    table.insert(notificationQueue, notification)
    
    -- Remove oldest if queue is full
    if #notificationQueue > maxNotifications then
        table.remove(notificationQueue, 1)
    end
    
    -- Send to NUI
    SendNUIMessage({
        type = 'pushNotification',
        notification = notification
    })
    
    -- Play sound if enabled
    if notification.config.sound then
        PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
    end
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

-- Large sale notification
RegisterNetEvent('mlfaGasStation:largeSale')
AddEventHandler('mlfaGasStation:largeSale', function(amount, liters)
    SendPushNotification(
        'SALE',
        'Vente Importante',
        string.format('$%s pour %dL', tostring(amount), liters),
        6000
    )
end)

-- Low stock warning
RegisterNetEvent('mlfaGasStation:lowStock')
AddEventHandler('mlfaGasStation:lowStock', function(stationName, stock)
    SendPushNotification(
        'LOW_STOCK',
        'Stock Faible',
        string.format('%s: %dL restants', stationName, stock),
        8000
    )
end)

-- Salary paid
RegisterNetEvent('mlfaGasStation:salaryPaid')
AddEventHandler('mlfaGasStation:salaryPaid', function(amount)
    SendPushNotification(
        'SALARY',
        'Salaire Reçu',
        string.format('$%s déposés', tostring(amount)),
        4000
    )
end)

-- Random event
RegisterNetEvent('mlfaGasStation:randomEvent')
AddEventHandler('mlfaGasStation:randomEvent', function(eventName, description)
    SendPushNotification(
        'EVENT',
        eventName,
        description,
        7000
    )
end)

-- Rank change
RegisterNetEvent('mlfaGasStation:rankChange')
AddEventHandler('mlfaGasStation:rankChange', function(newRank, oldRank)
    local message = newRank < oldRank and 'Vous montez au classement !' or 'Vous descendez au classement'
    SendPushNotification(
        'RANK',
        'Classement Mis à Jour',
        message,
        6000
    )
end)

-- Mission available
RegisterNetEvent('mlfaGasStation:missionAvailable')
AddEventHandler('mlfaGasStation:missionAvailable', function(missionName, reward)
    SendPushNotification(
        'MISSION',
        'Nouvelle Mission',
        string.format('%s (+$%s)', missionName, tostring(reward)),
        5000
    )
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('PushNotification', SendPushNotification)
exports('GetNotifications', function() return notificationQueue end)
exports('ClearNotifications', function() notificationQueue = {} end)

print('[MLFA GASSTATION] Push notifications system loaded')
