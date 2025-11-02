-- Event client pour forcer un joueur à se coucher sur le brancard
RegisterNetEvent('esx_stretcher:forcePutOnStretcher', function(stretcherNetId)
    -- Récupérer le brancard depuis le NetworkID
    local stretcher = NetworkGetEntityFromNetworkId(stretcherNetId)

    if not stretcher or not DoesEntityExist(stretcher) then
        ESX.ShowNotification(_U('stretcher_not_found'))
        return
    end

    -- Exécuter la fonction pour se coucher
    LayOnStretcher(stretcher)
end)

-- Event client pour forcer un joueur à se lever du brancard
RegisterNetEvent('esx_stretcher:forceRemoveFromStretcher', function()
    -- Vérifier que le joueur est bien couché sur un brancard
    if not isLayingOnStretcher then
        return
    end

    -- Exécuter la fonction pour se lever
    GetUpFromStretcher()
end)
