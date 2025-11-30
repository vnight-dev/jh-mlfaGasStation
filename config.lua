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
