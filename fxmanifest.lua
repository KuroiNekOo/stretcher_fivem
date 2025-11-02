fx_version 'cerulean'
game 'gta5'

author 'ESX Stretcher System'
description 'Système de gestion de brancard avec don-emsprops'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',               -- Point d'entrée (documentation)
    'client/variables.lua',           -- Variables globales et tables de hash

    -- Fonctions logiques
    'client/functions/animations.lua',
    'client/functions/attach.lua',
    'client/functions/laying.lua',
    'client/functions/storage.lua',

    -- Définitions ox_target
    'client/targets/vehicles.lua',
    'client/targets/stretcher.lua',
    'client/targets/players.lua',

    -- Events et threads
    'client/events.lua',
    'client/threads.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_target',
    'don-emsprops'
}

lua54 'yes'
