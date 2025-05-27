name "OneBit Mini Chop"
author "GalaxyMom"
version "v1.1.0"
description "Resource for an accessible petty vehilce chopping activity"
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