name "OSRP KayNine"
author "GalaxyMom"
version "v1.0.0"
description "Resource for player-controlled police K9s"
fx_version "cerulean"
game "gta5"

dependencies { 'os-utilities', }

client_scripts { 'client/*.lua' }
server_scripts { 'server.lua' }
shared_scripts {
    'config.lua',
    'emotes.lua'
 }

files { 'peds.meta' }

data_file 'PED_METADATA_FILE' 'peds.meta'