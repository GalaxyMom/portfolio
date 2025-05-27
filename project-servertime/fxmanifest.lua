name "ProjectRP Server Time"
fx_version 'cerulean'
game 'gta5'

description 'Server time sync resource'
version '1.0.0'

client_scripts {
    'client.lua'
}

server_script {
    'server.lua',
}

dependency 'menuv'