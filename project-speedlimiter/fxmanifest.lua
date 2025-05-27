name "Project RP Speed Limiter"
author "GalaxyMom"
version "v1.0.0"
description "Speed limiter for vehicles"
fx_version "cerulean"
game "gta5"
lua54 'yes'

dependencies { 'qb-core', }
client_scripts { 'client.lua', }
server_scripts { 'server.lua' }
shared_scripts {
    '@ox_lib/init.lua',
}