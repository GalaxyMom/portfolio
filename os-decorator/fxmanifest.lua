name "OSRP Decorator"
author "GalaxyMom"
version "v0.6.2"
description "A resource for handling simple placement of local props"
fx_version "cerulean"
game "gta5"

dependencies { 'qb-target', 'os-utilities' }

client_scripts { 'client.lua' }
server_scripts { 'server.lua' }
shared_scripts { 'config.lua' }

exports {
    'PropPlace',
    'PropRemove',
    'PropMenu'
}