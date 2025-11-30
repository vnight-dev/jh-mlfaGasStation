fx_version 'cerulean'
game 'gta5'

description 'MLFA GasStation - The Singularity Update (v6.0)'
version '6.0.0'
author 'MLFA'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/perf_utils.lua',
    'client/main.lua',
    'client/purchase.lua',
    'client/missions.lua',
    'client/fuel_tracking.lua',
    'client/ped_customers.lua',
    'client/objectives_ui.lua',
    'client/push_notifications.lua',
    'client/weather_integration.lua',
    'client/phone_integration.lua',
    'server/events_system.lua',
    'server/competition_system.lua',
    'server/franchise_system.lua',
    'server/stock_market.lua',
    'server/reputation_system.lua',
    'server/ev_system.lua'         -- NEW v6.0
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/objectives.html',
    
    -- CSS Modules
    'html/css/base.css',
    'html/css/layout.css',
    'html/css/components.css',
    'html/css/apps.css',
    'html/css/objectives.css',
    
    -- JS Modules
    'html/js/main.js',
    'html/js/utils.js',
    'html/js/ui-manager.js',
    'html/js/theme_engine.js',     -- NEW v6.0
    'html/js/objectives.js',
    'html/js/charts.js',
    'html/js/apps/dashboard.js',
    'html/js/apps/fuel.js',
    'html/js/apps/employees.js',
    'html/js/apps/missions.js',
    'html/js/apps/reports.js',
    'html/js/apps/settings.js'
}

dependencies {
    'es_extended',
    'oxmysql',
    'fscripts_fuel'
}

lua54 'yes'