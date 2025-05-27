name "ProjectRP Vehicle Control"
author "GalaxyMom"
version "v1.1.0"
description "Resource for handling vehicle state"
fx_version "cerulean"
game "gta5"
lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

dependencies {
    'project-utilities'
}