name "ProjectRP PersistEnts"
author "GalaxyMom"
version "v1.0.0"
description "A resource for making forcing entity persistence by respawning when in player scope"
fx_version "cerulean"
game "gta5"
lua54 'yes'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}