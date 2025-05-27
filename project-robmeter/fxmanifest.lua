fx_version 'bodacious'
 
game 'gta5'

lua54 'yes'

client_scripts {
    'client/client.lua',
    'config.lua',
}
server_scripts {
    'server/server.lua',
    'config.lua',
}

escrow_ignore {
    'client/*',
    'config.lua',
  }

shared_script '@ox_lib/init.lua'

dependencies { '/assetpacks' }