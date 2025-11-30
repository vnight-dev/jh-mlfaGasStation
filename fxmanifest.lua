fx_version 'cerulean'
game 'gta5'

description 'MLFA GasStation - Gas Station Management System'
version '2.0.0'
author 'MLFA'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/purchase.lua',
    'client/missions.lua',
    'client/fuel_tracking.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/database.lua',
    'server/fuel_integration.lua',
    'server/missions.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/*.ttf'
}

dependencies {
    'es_extended',
    'oxmysql',
    'fscripts_fuel'
}

lua54 'yes'