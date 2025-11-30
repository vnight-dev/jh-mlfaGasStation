Config = {}

-- Framework
Config.Framework = 'ESX'

-- UI Settings
Config.OpenKey = 38 -- E key
Config.TabletProp = 'prop_cs_tablet'
Config.TabletAnim = {
    dict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
    anim = "idle_a"
}

-- Theme Colors
Config.Theme = {
    primary = '#00F2EA',
    secondary = '#1a1a2e',
    success = '#00C9A7',
    danger = '#FF6B6B',
    warning = '#FFD93D'
}

-- Gas Stations (using fscript_fuel locations)
Config.Stations = {
    { id = 1, name = "Station 1", label = "Station Downtown", coords = vector3(265.648, -1261.309, 29.292), blip = {sprite = 361, color = 3}, purchasePoint = vector3(265.648, -1261.309, 29.292) },
    { id = 2, name = "Station 2", label = "Station Grove Street", coords = vector3(-70.2148, -1761.792, 29.534), blip = {sprite = 361, color = 3}, purchasePoint = vector3(-70.2148, -1761.792, 29.534) },
    { id = 3, name = "Station 3", label = "Station Sandy Shores", coords = vector3(1701.314, 6416.028, 32.763), blip = {sprite = 361, color = 3}, purchasePoint = vector3(1701.314, 6416.028, 32.763) },
    { id = 4, name = "Station 4", label = "Station Paleto Bay", coords = vector3(-94.4619, 6419.594, 31.489), blip = {sprite = 361, color = 3}, purchasePoint = vector3(-94.4619, 6419.594, 31.489) },
    { id = 5, name = "Station 5", label = "Station Great Ocean Highway", coords = vector3(1208.951, -1402.567, 35.224), blip = {sprite = 361, color = 3}, purchasePoint = vector3(1208.951, -1402.567, 35.224) },
}

-- Purchase Marker Settings
Config.PurchaseMarker = {
    type = 1, -- Marker type
    size = {x = 1.5, y = 1.5, z = 1.0},
    color = {r = 0, g = 242, b = 234, a = 100},
    distance = 2.5 -- Distance to show prompt
}

-- Default Fuel Price (per liter)
Config.DefaultFuelPrice = 2.5

-- Station Purchase Price
Config.StationPurchasePrice = 500000

-- Maximum Fuel Stock (liters)
Config.MaxFuelStock = 10000

-- Fuel Delivery Mission
Config.FuelDeliveryMission = {
    vehicleModel = 'tanker',
    spawnPoint = vector3(1163.0, -3196.0, 5.0), -- Port
    fuelAmount = 500, -- Liters delivered
    reward = 1500, -- Money reward
    cooldown = 600 -- 10 minutes
}

-- Employee Ranks
Config.Ranks = {
    {
        name = 'owner',
        label = 'Propriétaire',
        salary = 0,
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

-- Apps Configuration (matching jh-juge structure)
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
        roles = { 'owner', 'manager' }
    },
    ['permissions'] = {
        label = 'Permissions',
        icon = 'fas fa-shield-alt',
        roles = { 'owner' }
    },
    ['missions'] = {
        label = 'Missions',
        icon = 'fas fa-tasks',
        roles = { 'all' }
    },
    ['reports'] = {
        label = 'Reports',
        icon = 'fas fa-chart-line',
        roles = { 'owner', 'manager' }
    },
    ['settings'] = {
        label = 'Settings',
        icon = 'fas fa-cog',
        roles = { 'owner', 'manager' }
    }
}

-- Notifications
Config.Notifications = {
    success = function(msg)
        if GetResourceState('mlfa_notifications') == 'started' then
            exports['mlfa_notifications']:SendNotification({
                type = 'success',
                message = msg,
                duration = 3000
            })
        else
            print('[SUCCESS] ' .. msg)
        end
    end,
    error = function(msg)
        if GetResourceState('mlfa_notifications') == 'started' then
            exports['mlfa_notifications']:SendNotification({
                type = 'error',
                message = msg,
                duration = 3000
            })
        else
            print('[ERROR] ' .. msg)
        end
    end,
    info = function(msg)
        if GetResourceState('mlfa_notifications') == 'started' then
            exports['mlfa_notifications']:SendNotification({
                type = 'info',
                message = msg,
                duration = 3000
            })
        else
            print('[INFO] ' .. msg)
        end
    end
}
