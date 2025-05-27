name "ProjectRP Mugging"
author "GalaxyMom"
version "v1.0.0"
description "A resource for hanlding the criminal activiy of mugging npc peds"
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

dependency 'project-utilities'