name "OneBit Shoplifting"
author "GalaxyMom"
version "v1.1.1"
description "Resource for handling stealing items from polyzones (prominently shoplifting from stores)"
fx_version "cerulean"
game "gta5"
lua54 'yes'

client_scripts { 'client.lua' }
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}