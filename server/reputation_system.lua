-- ============================================================================
-- REPUTATION & ACHIEVEMENTS SYSTEM
-- Gamification with levels, badges, and rewards
-- ============================================================================

local ESX = exports['es_extended']:getSharedObject()

-- ============================================================================
-- ACHIEVEMENTS DEFINITION
-- ============================================================================

local Achievements = {
    -- Starter Achievements
    {id = 'first_station', name = 'Premier Pas', desc = 'Acheter votre première station', xp = 100, reward = 5000},
    {id = 'first_sale', name = 'Première Vente', desc = 'Réaliser votre première vente', xp = 50, reward = 1000},
    {id = 'first_employee', name = 'Recruteur', desc = 'Embaucher votre premier employé', xp = 75, reward = 2000},
    
    -- Sales Achievements
    {id = 'sales_100', name = 'Vendeur Bronze', desc = '100 ventes réalisées', xp = 200, reward = 10000},
    {id = 'sales_500', name = 'Vendeur Argent', desc = '500 ventes réalisées', xp = 500, reward = 25000},
    {id = 'sales_1000', name = 'Vendeur Or', desc = '1000 ventes réalisées', xp = 1000, reward = 50000},
    {id = 'sales_5000', name = 'Vendeur Platine', desc = '5000 ventes réalisées', xp = 2500, reward = 150000},
    
    -- Revenue Achievements
    {id = 'revenue_100k', name = 'Entrepreneur', desc = '$100,000 de revenus', xp = 300, reward = 15000},
    {id = 'revenue_500k', name = 'Businessman', desc = '$500,000 de revenus', xp = 750, reward = 40000},
    {id = 'revenue_1m', name = 'Millionnaire', desc = '$1,000,000 de revenus', xp = 1500, reward = 100000},
    {id = 'revenue_10m', name = 'Magnat', desc = '$10,000,000 de revenus', xp = 5000, reward = 500000},
    
    -- Franchise Achievements
    {id = 'franchise_2', name = 'Expansion', desc = 'Posséder 2 stations', xp = 500, reward = 20000},
    {id = 'franchise_3', name = 'Chaîne', desc = 'Posséder 3 stations', xp = 1000, reward = 50000},
    {id = 'franchise_5', name = 'Empire', desc = 'Posséder 5 stations', xp = 2500, reward = 150000},
    
    -- Employee Achievements
    {id = 'employees_5', name = 'Manager', desc = '5 employés embauchés', xp = 250, reward = 10000},
    {id = 'employees_10', name = 'Directeur RH', desc = '10 employés embauchés', xp = 500, reward = 25000},
    {id = 'employees_25', name = 'CEO', desc = '25 employés embauchés', xp = 1250, reward = 75000},
    
    -- Competition Achievements
    {id = 'rank_1', name = 'Champion', desc = 'Atteindre la 1ère place', xp = 1000, reward = 100000},
    {id = 'rank_top3', name = 'Podium', desc = 'Atteindre le top 3', xp = 500, reward = 30000},
    {id = 'rank_streak_7', name = 'Domination', desc = 'Rester 1er pendant 7 jours', xp = 2000, reward = 200000},
    
    -- Mission Achievements
    {id = 'missions_10', name = 'Travailleur', desc = '10 missions complétées', xp = 200, reward = 8000},
    {id = 'missions_50', name = 'Dévoué', desc = '50 missions complétées', xp = 600, reward = 30000},
    {id = 'missions_100', name = 'Professionnel', desc = '100 missions complétées', xp = 1200, reward = 75000},
    
    -- Special Achievements
    {id = 'perfect_week', name = 'Semaine Parfaite', desc = 'Aucun stock vide pendant 7 jours', xp = 800, reward = 50000},
    {id = 'stock_master', name = 'Maître du Stock', desc = 'Stock toujours >50% pendant 30 jours', xp = 1500, reward = 100000},
    {id = 'investor', name = 'Investisseur', desc = 'Acheter 100 actions', xp = 400, reward = 20000},
    {id = 'dividend_king', name = 'Roi des Dividendes', desc = 'Recevoir $100k en dividendes', xp = 1000, reward = 50000},
    
    -- Legendary Achievements
    {id = 'legend', name = 'Légende', desc = 'Atteindre le niveau 100', xp = 10000, reward = 1000000},
    {id = 'tycoon', name = 'Tycoon', desc = '$100M de revenus totaux', xp = 15000, reward = 2000000},
    {id = 'monopoly', name = 'Monopole', desc = 'Posséder toutes les stations', xp = 20000, reward = 5000000}
}

-- Player progression data
local playerProgress = {}  -- [identifier] = {level, xp, achievements, badges}

-- ============================================================================
-- LEVEL SYSTEM
-- ============================================================================

local function GetXPForLevel(level)
    return 100 * level * (level + 1) / 2  -- Progressive XP requirement
end

local function CalculateLevel(totalXP)
    local level = 1
    while GetXPForLevel(level) <= totalXP and level < 100 do
        level = level + 1
    end
    return level - 1
end

local function AddXP(identifier, amount, source)
    if not playerProgress[identifier] then
        playerProgress[identifier] = {level = 1, xp = 0, achievements = {}, badges = {}}
    end
    
    local oldLevel = playerProgress[identifier].level
    playerProgress[identifier].xp = playerProgress[identifier].xp + amount
    local newLevel = CalculateLevel(playerProgress[identifier].xp)
    
    -- Level up
    if newLevel > oldLevel then
        playerProgress[identifier].level = newLevel
        
        -- Level up rewards
        local reward = newLevel * 1000
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(reward)
            TriggerClientEvent('mlfaGasStation:levelUp', source, newLevel, reward)
        end
        
        print(string.format('[REPUTATION] %s leveled up to %d', identifier, newLevel))
    end
    
    -- Save to database
    MySQL.update([[
        UPDATE gas_player_progress 
        SET level = ?, xp = ?
        WHERE identifier = ?
    ]], {newLevel, playerProgress[identifier].xp, identifier})
end

-- ============================================================================
-- ACHIEVEMENT SYSTEM
-- ============================================================================

local function UnlockAchievement(identifier, achievementId, source)
    if not playerProgress[identifier] then
        playerProgress[identifier] = {level = 1, xp = 0, achievements = {}, badges = {}}
    end
    
    -- Check if already unlocked
    if playerProgress[identifier].achievements[achievementId] then
        return false
    end
    
    -- Find achievement
    local achievement = nil
    for _, ach in ipairs(Achievements) do
        if ach.id == achievementId then
            achievement = ach
            break
        end
    end
    
    if not achievement then return false end
    
    -- Unlock
    playerProgress[identifier].achievements[achievementId] = true
    
    -- Give rewards
    AddXP(identifier, achievement.xp, source)
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(achievement.reward)
        TriggerClientEvent('mlfaGasStation:achievementUnlocked', source, achievement)
    end
    
    -- Save to database
    MySQL.insert([[
        INSERT INTO gas_achievements (identifier, achievement_id, unlocked_at)
        VALUES (?, ?, NOW())
    ]], {identifier, achievementId})
    
    print(string.format('[ACHIEVEMENTS] %s unlocked: %s', identifier, achievement.name))
    return true
end

-- ============================================================================
-- PROGRESS TRACKING
-- ============================================================================

-- Track sales
RegisterServerEvent('mlfaGasStation:trackSale')
AddEventHandler('mlfaGasStation:trackSale', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Update sales count
    MySQL.scalar('SELECT COUNT(*) FROM gas_transactions WHERE created_by = ? AND type = "fuel_sale"', 
        {xPlayer.identifier}, function(count)
        -- Check achievements
        if count == 1 then UnlockAchievement(xPlayer.identifier, 'first_sale', source) end
        if count == 100 then UnlockAchievement(xPlayer.identifier, 'sales_100', source) end
        if count == 500 then UnlockAchievement(xPlayer.identifier, 'sales_500', source) end
        if count == 1000 then UnlockAchievement(xPlayer.identifier, 'sales_1000', source) end
        if count == 5000 then UnlockAchievement(xPlayer.identifier, 'sales_5000', source) end
    end)
    
    -- Add XP for sale
    AddXP(xPlayer.identifier, 10, source)
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('AddXP', AddXP)
exports('UnlockAchievement', UnlockAchievement)
exports('GetProgress', function(identifier) return playerProgress[identifier] end)

print('[MLFA GASSTATION] Reputation & achievements system loaded')
