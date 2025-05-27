name 'Project Weather Sync'
fx_version 'cerulean'
game 'gta5'

description 'Procedural planned weather patterns'
version 'v2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_script 'server.lua'
client_script 'client.lua'

lua54 'yes'