fx_version 'cerulean'
game 'gta5'

description 'MLFA GasStation - Gas Station Management System with AI Customers'
version '2.1.0'
author 'MLFA'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/perf_utils.lua',      -- Performance utilities (LOAD FIRST)
    'client/main.lua',
    'client/purchase.lua',
    'client/missions.lua',
    'client/fuel_tracking.lua',
    'client/ped_customers.lua'     -- NPC customer system
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/database.lua',
    'server/fuel_integration.lua',
    'server/missions.lua',
    'server/npc_handler.lua'       -- NPC purchase handler
}

ui_page 'html/index.html'

files {
    'html/index.html',
    
    -- CSS Modules
    'html/css/base.css',
    'html/css/layout.css',
    'html/css/components.css',
    'html/css/apps.css',
    
    -- JS Modules
    'html/js/main.js',
    'html/js/utils.js',
    'html/js/ui-manager.js',
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