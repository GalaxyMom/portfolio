name "ProjectRP Utilities"
author "GalaxyMom"
version "v1.1.0"
description "Shared common functions and data to be used across ProjectRP resources"
fx_version "cerulean"
game "gta5"
lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}