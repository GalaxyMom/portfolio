name "OSRP"
author "GalaxyMom"
version "v1.1.1"
description "Vehicle showroom for mechanic shops to easily sell vehicles"
fx_version "cerulean"
game "gta5"

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
shared_scripts { 'config.lua' }

dependencies { 'os-utilities' }