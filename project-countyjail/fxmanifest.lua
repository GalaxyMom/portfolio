name "Project RP County Jail"
author "GalaxyMom"
version "v1.0.0"
description "Resource for handling a more common sense method of incarceration"
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