name "Project Cinematic Camera"
author "GalaxyMom"
version "v2.0.0"
description "Resource for handling an RP-oriented cinematic camera"
fx_version "cerulean"
game "gta5"
lua54 'yes'

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

dependency 'fivem-freecam'