ESX = exports['es_extended']:getSharedObject()

-- Event pour mettre un joueur de force sur le brancard
RegisterNetEvent('esx_stretcher:requestPutPlayerOnStretcher', function(targetServerId, stretcherNetId)
    local source = source

    -- Validation : vérifier que le joueur ciblé existe
    if not targetServerId or GetPlayerPing(targetServerId) == 0 then
        TriggerClientEvent('esx:showNotification', source, '~r~Joueur introuvable')
        return
    end

    -- Trigger l'event client sur le joueur ciblé pour le forcer à se coucher
    TriggerClientEvent('esx_stretcher:forcePutOnStretcher', targetServerId, stretcherNetId)

    -- Notification pour le joueur qui a effectué l'action
    TriggerClientEvent('esx:showNotification', source, '~g~Joueur placé sur le brancard')
end)

-- Event pour retirer un joueur de force du brancard
RegisterNetEvent('esx_stretcher:requestRemovePlayerFromStretcher', function(targetServerId)
    local source = source

    -- Validation : vérifier que le joueur ciblé existe
    if not targetServerId or GetPlayerPing(targetServerId) == 0 then
        TriggerClientEvent('esx:showNotification', source, '~r~Joueur introuvable')
        return
    end

    -- Trigger l'event client sur le joueur ciblé pour le forcer à se lever
    TriggerClientEvent('esx_stretcher:forceRemoveFromStretcher', targetServerId)

    -- Notification pour le joueur qui a effectué l'action
    TriggerClientEvent('esx:showNotification', source, '~g~Joueur retiré du brancard')
end)

