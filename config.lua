Config = {}

-- Framework
Config.Framework = 'ESX'

-- ============================================================================
-- DEBUG CONFIGURATION
-- ============================================================================
Config.Debug = {
    -- Activer le mode debug
    Enabled = false,
    
    -- Logs détaillés
    Logs = {
        NPC = false,        -- Logs des PNJ
        Purchase = false,   -- Logs des achats
        Fuel = false,       -- Logs du carburant
        UI = false,         -- Logs de l'interface
        Database = false    -- Logs SQL
    },
    
    -- Marqueurs de debug (visualisation)
    ShowMarkers = {
        SpawnPoints = false,   -- Montrer les points de spawn
        FuelPoints = false,    -- Montrer les pompes
        NPCPaths = false       -- Montrer les chemins des PNJ
    }
}

-- ============================================================================
-- DISCORD LOGGING CONFIGURATION
-- ============================================================================
Config.Discord = {
    -- Activer les logs Discord
    Enabled = true,
    
    -- Webhook URL (configuré dans server/discord_logs.lua)
    WebhookURL = 'https://discord.com/api/webhooks/1444809920288391229/MoW70gHx25IhQE4gh05RlsL6A5CG4vg4SvkWaNCaq4zG6vL7DmSHPETiX5RiI9SLCcN3',
    
    -- Catégories de logs
    Logs = {
        Purchase = true,    -- Achats/ventes de stations
        Fuel = true,        -- Ventes de carburant
        Employees = true,   -- Embauches/licenciements
        Money = true,       -- Transactions financières
        Missions = true,    -- Missions complétées
        Errors = true       -- Erreurs système
    }
}

-- ============================================================================
-- UI CONFIGURATION
-- ============================================================================
Config.UI = {
    -- Touche d'ouverture
    OpenKey = 38, -- E key
    
    -- Tablette
    TabletProp = 'prop_cs_tablet',
    TabletAnim = {
        dict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
        anim = "idle_a"
    },
    
    -- Thème
    Theme = {
        primary = '#00F2EA',
        secondary = '#1a1a2e',
        success = '#00C9A7',
        danger = '#FF6B6B',
        warning = '#FFD93D'
    },
    
    -- Notifications
    UseCustomNotifications = false,  -- Utiliser mlfa_notifications
    NotificationDuration = 3000
}

-- ============================================================================
-- NPC CONFIGURATION
-- ============================================================================
Config.NPC = {
    -- Activer/Désactiver le système NPC
    Enabled = true,
    
    -- Pool de PNJ
    PedPoolSize = 8,
    VehiclePoolSize = 8,
    
    -- Modèles de PNJ
    PedModels = {
        'a_m_m_business_01',
        'a_f_y_business_01',
        'a_m_y_business_01',
        'a_f_m_business_02',
        'a_m_m_bevhills_01',
        'a_f_y_bevhills_01',
        'a_m_y_hipster_01',
        'a_f_y_hipster_01'
    },
    
    -- Modèles de véhicules
    VehicleModels = {
        'blista', 'dilettante', 'panto', 
        'issi2', 'prairie', 'asea', 
        'emperor', 'fugitive'
    },
    
    -- Fréquence d'apparition (en secondes)
    SpawnInterval = {
        Min = 30,  -- Minimum 30 secondes
        Max = 120  -- Maximum 2 minutes
    },
    
    -- Montant de carburant acheté par les PNJ
    FuelAmount = {
        Min = 20,  -- Litres minimum
        Max = 60   -- Litres maximum
    },
    
    -- Animations des PNJ
    Animations = {
        -- Animation pendant le ravitaillement
        Refueling = {
            dict = "timetable@gardener@filling_can",
            anim = "gar_ig_5_filling_can",
            duration = 15000  -- 15 secondes
        },
        
        -- Animation de paiement
        Payment = {
            dict = "mp_common",
            anim = "givetake1_a",
            duration = 2000  -- 2 secondes
        },
        
        -- Animation d'attente
        Idle = {
            dict = "amb@world_human_stand_mobile@male@text@base",
            anim = "base",
            duration = 5000  -- 5 secondes
        }
    }
}

-- ============================================================================
-- ECONOMY CONFIGURATION
-- ============================================================================
Config.Economy = {
    -- Prix d'achat d'une station
    StationPurchasePrice = 500000,
    
    -- Prix de revente (% du prix d'achat)
    StationSellPercentage = 0.7,  -- 70%
    
    -- Prix du carburant
    DefaultFuelPrice = 2.5,
    MinFuelPrice = 1.0,
    MaxFuelPrice = 5.0,
    
    -- Stock
    MaxFuelStock = 10000,
    LowStockWarning = 1000,  -- Alerte si < 1000L
    
    -- Taxes
    SalesTax = 0.05,  -- 5% de taxe sur les ventes
    
    -- Bonus propriétaire
    OwnerBonus = {
        Enabled = false,
        Percentage = 0.1,  -- 10% des ventes vont au proprio
        PaymentInterval = 3600  -- Toutes les heures (en secondes)
    }
}

-- ============================================================================
-- EMPLOYEES CONFIGURATION
-- ============================================================================
Config.Employees = {
    -- Salaire automatique
    AutoPayment = {
        Enabled = false,
        Interval = 3600,  -- Toutes les heures (en secondes)
        FromStationMoney = true  -- Prélever de la caisse de la station
    },
    
    -- Limites
    MaxEmployees = 10,
    
    -- Rangs
    Ranks = {
        {
            name = 'boss',
            label = 'Propriétaire',
            salary = 0,
            color = '#FFD700',
            permissions = {
                manageMoney = true,
                hireEmployees = true,
                fireEmployees = true,
                startMissions = true,
                changeSettings = true,
                viewReports = true
            }
        },
        {
            name = 'manager',
            label = 'Gérant',
            salary = 2000,
            color = '#00F2EA',
            permissions = {
                manageMoney = false,
                hireEmployees = true,
                fireEmployees = true,
                startMissions = true,
                changeSettings = true,
                viewReports = true
            }
        },
        {
            name = 'employee',
            label = 'Employé',
            salary = 1200,
            color = '#00C9A7',
            permissions = {
                manageMoney = false,
                hireEmployees = false,
                fireEmployees = false,
                startMissions = true,
                changeSettings = false,
                viewReports = false
            }
        }
    }
}

-- ============================================================================
-- MISSIONS CONFIGURATION
-- ============================================================================
Config.Missions = {
    -- Mission de livraison de carburant
    FuelDelivery = {
        Enabled = true,
        VehicleModel = 'tanker',
        SpawnPoint = vector4(1163.0, -3196.0, 5.0, 90.0),
        FuelAmount = 500,      -- Litres livrés
        Reward = 1500,         -- Récompense
        Cooldown = 600,        -- 10 minutes (en secondes)
        DeliveryTime = 300     -- 5 minutes max (en secondes)
    },
    
    -- Mission de maintenance
    Maintenance = {
        Enabled = true,
        Reward = 500,
        Cooldown = 1800,       -- 30 minutes
        Duration = 120         -- 2 minutes
    },
    
    -- Mission de nettoyage
    Cleaning = {
        Enabled = true,
        Reward = 300,
        Cooldown = 900,        -- 15 minutes
        Duration = 60          -- 1 minute
    }
}

-- ============================================================================
-- STATIONS CONFIGURATION
-- ============================================================================
Config.Stations = {
    { 
        id = 1, 
        name = "Station 1", 
        label = "Station Downtown", 
        coords = vector3(265.648, -1261.309, 29.292), 
        blip = {sprite = 361, color = 3}, 
        purchasePoint = vector3(265.648, -1261.309, 29.292),
        
        -- Points de spawn des véhicules NPC
        npcSpawnPoints = {
            vector4(265.0, -1265.0, 29.0, 90.0),
            vector4(270.0, -1265.0, 29.0, 90.0)
        },
        
        -- Points de ravitaillement (pompes)
        fuelPoints = {
            vector3(265.0, -1260.0, 29.0),
            vector3(268.0, -1260.0, 29.0),
            vector3(271.0, -1260.0, 29.0)
        }
    },
    { 
        id = 2, 
        name = "Station 2", 
        label = "Station Grove Street", 
        coords = vector3(-70.2148, -1761.792, 29.534), 
        blip = {sprite = 361, color = 3}, 
        purchasePoint = vector3(-70.2148, -1761.792, 29.534),
        
        npcSpawnPoints = {
            vector4(-75.0, -1765.0, 29.5, 180.0),
            vector4(-70.0, -1765.0, 29.5, 180.0)
        },
        
        fuelPoints = {
            vector3(-70.0, -1758.0, 29.5),
            vector3(-73.0, -1758.0, 29.5)
        }
    },
    { 
        id = 3, 
        name = "Station 3", 
        label = "Station Sandy Shores", 
        coords = vector3(1701.314, 6416.028, 32.763), 
        blip = {sprite = 361, color = 3}, 
        purchasePoint = vector3(1701.314, 6416.028, 32.763),
        
        npcSpawnPoints = {
            vector4(1700.0, 6420.0, 32.7, 270.0),
            vector4(1705.0, 6420.0, 32.7, 270.0)
        },
        
        fuelPoints = {
            vector3(1701.0, 6413.0, 32.7),
            vector3(1704.0, 6413.0, 32.7)
        }
    },
    { 
        id = 4, 
        name = "Station 4", 
        label = "Station Paleto Bay", 
        coords = vector3(-94.4619, 6419.594, 31.489), 
        blip = {sprite = 361, color = 3}, 
        purchasePoint = vector3(-94.4619, 6419.594, 31.489),
        
        npcSpawnPoints = {
            vector4(-98.0, 6423.0, 31.4, 45.0),
            vector4(-90.0, 6423.0, 31.4, 45.0)
        },
        
        fuelPoints = {
            vector3(-94.0, 6416.0, 31.4),
            vector3(-97.0, 6416.0, 31.4)
        }
    },
    { 
        id = 5, 
        name = "Station 5", 
        label = "Station Great Ocean Highway", 
        coords = vector3(1208.951, -1402.567, 35.224), 
        blip = {sprite = 361, color = 3}, 
        purchasePoint = vector3(1208.951, -1402.567, 35.224),
        
        npcSpawnPoints = {
            vector4(1205.0, -1406.0, 35.2, 0.0),
            vector4(1212.0, -1406.0, 35.2, 0.0)
        },
        
        fuelPoints = {
            vector3(1208.0, -1399.0, 35.2),
            vector3(1211.0, -1399.0, 35.2)
        }
    }
}

-- ============================================================================
-- MARKER CONFIGURATION
-- ============================================================================
Config.PurchaseMarker = {
    type = 1,
    size = {x = 1.5, y = 1.5, z = 1.0},
    color = {r = 0, g = 242, b = 234, a = 100},
    distance = 2.5
}

-- ============================================================================
-- APPS CONFIGURATION
-- ============================================================================
Config.Apps = {
    ['dashboard'] = {
        label = 'Dashboard',
        icon = 'fas fa-home',
        roles = { 'all' }
    },
    ['fuel'] = {
        label = 'Fuel Management',
        icon = 'fas fa-gas-pump',
        roles = { 'all' }
    },
    ['employees'] = {
        label = 'Employees',
        icon = 'fas fa-users',
        roles = { 'boss', 'manager' }
    },
    ['permissions'] = {
        label = 'Permissions',
        icon = 'fas fa-shield-alt',
        roles = { 'boss' }
    },
    ['missions'] = {
        label = 'Missions',
        icon = 'fas fa-tasks',
        roles = { 'all' }
    },
    ['reports'] = {
        label = 'Reports',
        icon = 'fas fa-chart-line',
        roles = { 'boss', 'manager' }
    },
    ['settings'] = {
        label = 'Settings',
        icon = 'fas fa-cog',
        roles = { 'boss', 'manager' }
    }
}

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================
Config.Notifications = {
    success = function(msg)
        if Config.UI.UseCustomNotifications and GetResourceState('mlfa_notifications') == 'started' then
            pcall(function()
                exports['mlfa_notifications']:SendNotification({
                    type = 'success',
                    message = msg,
                    duration = Config.UI.NotificationDuration
                })
            end)
        else
            ESX.ShowNotification('~g~' .. msg)
        end
    end,
    error = function(msg)
        if Config.UI.UseCustomNotifications and GetResourceState('mlfa_notifications') == 'started' then
            pcall(function()
                exports['mlfa_notifications']:SendNotification({
                    type = 'error',
                    message = msg,
                    duration = Config.UI.NotificationDuration
                })
            end)
        else
            ESX.ShowNotification('~r~' .. msg)
        end
    end,
    info = function(msg)
        if Config.UI.UseCustomNotifications and GetResourceState('mlfa_notifications') == 'started' then
            pcall(function()
                exports['mlfa_notifications']:SendNotification({
                    type = 'info',
                    message = msg,
                    duration = Config.UI.NotificationDuration
                })
            end)
        else
            ESX.ShowNotification('~b~' .. msg)
        end
    end
}

-- ============================================================================
-- PHONE APP CONFIGURATION (v3.0)
-- ============================================================================
Config.PhoneApp = {
    Enabled = true,
    
    -- Supported phone resources
    SupportedPhones = {
        'lb-phone',
        'qb-phone',
        'qs-smartphone'
    },
    
    -- App settings
    AppName = 'Gas Manager',
    AppIcon = 'fas fa-gas-pump',
    AppColor = '#00F2EA',
    
    -- Notifications
    SendNotifications = true,
    NotificationThreshold = {
        LargeSale = 5000,      -- Notify if sale > $5000
        LowStock = 1000        -- Notify if stock < 1000L
    }
}

-- ============================================================================
-- FRANCHISE SYSTEM CONFIGURATION (v3.0)
-- ============================================================================
Config.Franchise = {
    Enabled = true,
    MaxStationsPerPlayer = 5,
    
    -- Network bonuses (based on number of stations)
    NetworkBonus = {
        [2] = 0.05,  -- 2 stations: +5%
        [3] = 0.10,  -- 3 stations: +10%
        [4] = 0.15,  -- 4 stations: +15%
        [5] = 0.20   -- 5 stations: +20%
    },
    
    -- Franchise perks
    Perks = {
        SharedEmployees = true,
        CentralizedMoney = true,
        BulkFuelDiscount = 0.10,
        BrandingBonus = 0.05
    },
    
    -- Expansion costs
    ExpansionCost = {
        [2] = 400000,
        [3] = 600000,
        [4] = 800000,
        [5] = 1000000
    }
}

-- ============================================================================
-- STOCK MARKET CONFIGURATION (v3.0)
-- ============================================================================
Config.StockMarket = {
    Enabled = true,
    
    -- Stock settings
    TotalShares = 1000,
    MinSharePrice = 100,
    MaxSharePrice = 10000,
    
    -- Trading fees
    BuyFee = 0.02,   -- 2%
    SellFee = 0.02,  -- 2%
    
    -- Dividends
    DividendRate = 0.10,           -- 10% of profits
    DividendInterval = 86400,      -- Daily (seconds)
    
    -- Price calculation weights
    PriceWeights = {
        revenue = 0.40,
        sales = 0.30,
        stock = 0.20,
        employees = 0.10
    }
}

-- ============================================================================
-- REPUTATION & ACHIEVEMENTS CONFIGURATION (v3.0)
-- ============================================================================
Config.Reputation = {
    Enabled = true,
    MaxLevel = 100,
    
    -- XP rewards
    XPRewards = {
        Sale = 10,
        Mission = 50,
        Employee = 25,
        StationPurchase = 500
    },
    
    -- Level up rewards (money per level)
    LevelUpReward = 1000,
    
    -- Achievement notifications
    ShowAchievements = true,
    AchievementSound = true
}

-- ============================================================================
-- SERVER EVENTS CONFIGURATION (v3.0)
-- ============================================================================
Config.ServerEvents = {
    Enabled = true,
    
    -- Event types
    Events = {
        FuelShortage = {
            enabled = true,
            chance = 0.05,        -- 5% chance
            duration = 3600,      -- 1 hour
            priceMultiplier = 2.0 -- Fuel price x2
        },
        
        GasBoom = {
            enabled = true,
            chance = 0.03,        -- 3% chance
            duration = 7200,      -- 2 hours
            salesMultiplier = 3.0 -- Sales x3
        },
        
        TaxAudit = {
            enabled = true,
            chance = 0.02,        -- 2% chance
            duration = 1800,      -- 30 minutes
            taxRate = 0.25        -- 25% tax
        }
    },
    
    -- Event check interval
    CheckInterval = 1800  -- 30 minutes
}

-- ============================================================================
-- PVP STATION WARS CONFIGURATION (v3.0)
-- ============================================================================
Config.PvP = {
    Enabled = false,  -- Disabled by default
    
    -- War settings
    MinPlayersToStart = 4,
    WarDuration = 3600,        -- 1 hour
    WarCooldown = 86400,       -- 24 hours
    
    -- Capture settings
    CaptureRadius = 50.0,
    CaptureTime = 300,         -- 5 minutes
    MinAttackers = 2,
    
    -- Rewards
    WinnerReward = 100000,
    LoserPenalty = 50000,
    
    -- Protection
    NewStationProtection = 604800  -- 7 days
}

-- ============================================================================
-- THEME ENGINE CONFIGURATION (v6.0)
-- ============================================================================
Config.ThemeEngine = {
    Enabled = true,
    DefaultTheme = 'default',
    AllowCustomThemes = true, -- Allow players to create custom themes
    
    -- Available presets
    Presets = {
        'default',
        'cyberpunk',
        'minimal',
        'midnight'
    }
}

-- ============================================================================
-- EV CHARGING CONFIGURATION (v6.0)
-- ============================================================================
Config.EV = {
    Enabled = true,
    ElectricityCost = 0.15, -- Cost per kWh for station owner
    
    ChargerTypes = {
        standard = { speed = 22, price = 0.30 },
        fast = { speed = 50, price = 0.45 },
        super = { speed = 150, price = 0.60 }
    }
}

-- ============================================================================
-- SECURITY SYSTEM CONFIGURATION (v6.0)
-- ============================================================================
Config.Security = {
    Enabled = true,
    CCTV = true,           -- Enable CCTV cameras
    AlarmSystem = true,    -- Enable burglar alarms
    SecurityGuards = true, -- Hireable NPC guards
    
    GuardCost = 5000,      -- Hiring cost
    GuardSalary = 500      -- Daily salary
}

-- ============================================================================
-- GAS STATION OS AI (v6.0)
-- ============================================================================
Config.AI = {
    Enabled = true,
    Name = 'GasOS',
    Personality = 'helpful', -- helpful, sarcastic, professional
    
    -- Features
    AutoOrdering = true,   -- AI can order fuel automatically
    PriceOptimization = true, -- AI suggests optimal prices
    PredictiveAnalysis = true -- AI predicts rush hours
}

-- ============================================================================
-- COMPATIBILITY ALIASES (pour ne pas casser le code existant)
-- ============================================================================
Config.OpenKey = Config.UI.OpenKey
Config.TabletProp = Config.UI.TabletProp
Config.TabletAnim = Config.UI.TabletAnim
Config.Theme = Config.UI.Theme
Config.DefaultFuelPrice = Config.Economy.DefaultFuelPrice
Config.StationPurchasePrice = Config.Economy.StationPurchasePrice
Config.MaxFuelStock = Config.Economy.MaxFuelStock
Config.FuelDeliveryMission = Config.Missions.FuelDelivery
Config.Ranks = Config.Employees.Ranks
