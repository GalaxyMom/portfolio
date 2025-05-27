name "OneBit Pawn Shop"
author "Mack/GalaxyMom"
version "v0.8.3"
description "Resource for selling various items found around the city"
fx_version "cerulean"
game "gta5"
lua54 'yes'

dependencies {
    'ox_inventory',
    'onebit_persistents'
}

client_scripts {
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