fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Codex'
description 'QBCore real-time weather and clock sync from real world weather'
version '1.0.0'

dependency 'qb-core'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}
