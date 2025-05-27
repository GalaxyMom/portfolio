name "Project Pursuit Mode"
author "GalaxyMom"
version "v2.0.0"
description "Resource for handling pursuit mode on PD vehicles"
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