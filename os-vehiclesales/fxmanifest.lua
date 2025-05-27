fx_version 'bodacious'
game 'gta5'

description 'os-vehiclesales'
version '1.0.0'

lua54 'yes'

client_scripts {
    'client.lua',
    'config.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'config.lua',
}