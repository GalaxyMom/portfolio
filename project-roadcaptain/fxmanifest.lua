name "Project Road Captain"
author "GalaxyMom"
version "v0.5.0"
description "Resource for easing formation riding for bikers"
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