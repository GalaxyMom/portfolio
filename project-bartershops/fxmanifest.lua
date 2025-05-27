name "Project Roleplay Barter Shops"
author "GalaxyMom"
version "v0.1.0"
description "Resource for handling buying and selling resources to specific defined shops"
fx_version "cerulean"
game "gta5"
lua54 'yes'

client_scripts {
    'client.lua'
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
    'project-persistents'
}