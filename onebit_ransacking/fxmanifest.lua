name "OneBit Ransacking"
author "GalaxyMom"
version "v1.2.1"
description "Criminal activity centered on rummaging through vehicles for loot"
fx_version "cerulean"
game "gta5"
lua54 'yes'

client_scripts {
    '@ox_inventory/data/vehicles.lua',
    'client.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}