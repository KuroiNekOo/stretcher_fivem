-- Nettoyer les statebags des véhicules au démarrage de la ressource
CreateThread(function()
    Wait(1000) -- Attendre que le client soit complètement chargé

    -- Parcourir tous les véhicules pour réinitialiser les statebags
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehicleModelHash = GetEntityModel(vehicle)

        -- Vérifier si c'est un véhicule ambulance configuré
        if ambulanceHashes[vehicleModelHash] then
            -- Réinitialiser les statebags de ce véhicule
            Entity(vehicle).state:set('hasStretcherOut', nil, true)
            Entity(vehicle).state:set('storedStretcherNetId', nil, true)
        end
    end

    -- Parcourir tous les objets pour nettoyer les brancards orphelins
    local objects = GetGamePool('CObject')
    for _, obj in ipairs(objects) do
        if GetEntityModel(obj) == GetHashKey(Config.StretcherModel) then
            -- Nettoyer les statebags du brancard
            Entity(obj).state:set('sourceVehicleNetId', nil, true)
            Entity(obj).state:set('storedInVehicleNetId', nil, true)
            Entity(obj).state:set('occupiedByServerId', nil, true)
        end
    end
end)

-- Commande pour lâcher le brancard / se lever (détection native, jamais ratée)
RegisterCommand('stretcher_release', function()
    if isCarryingStretcher then
        DetachStretcherFromPlayer()
    elseif isLayingOnStretcher then
        GetUpFromStretcher()
    end
end, false)

-- Associer la touche E par défaut (le joueur peut la changer dans Paramètres > Raccourcis > FiveM)
RegisterKeyMapping('stretcher_release', 'Lâcher/Se lever du brancard', 'keyboard', 'E')

-- Thread pour maintenir l'animation de poussée (si annulée par X, ragdoll, etc.)
CreateThread(function()
    while true do
        if isCarryingStretcher then
            Wait(100) -- 100ms suffit pour vérifier l'animation

            -- Re-vérifier après le Wait pour éviter des problèmes de timing
            if isCarryingStretcher then
                local playerPed = PlayerPedId()
                local animDict = Config.PushAnimation.dict
                local animName = Config.PushAnimation.anim

                if not IsEntityPlayingAnim(playerPed, animDict, animName, 3) then
                    PlayPushAnimation()
                end
            end
        else
            Wait(1000)
        end
    end
end)

-- Supprimer le brancard relié au client lors de l'arrêt du script
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local playerPed = PlayerPedId()

    -- Arrêter l'animation si le joueur porte le brancard ou est couché dessus
    if isCarryingStretcher or isLayingOnStretcher then
        ClearPedTasks(playerPed)
    end

    -- Si le joueur est couché sur un brancard, le libérer
    if isLayingOnStretcher and layingStretcherObject and DoesEntityExist(layingStretcherObject) then
        DetachEntity(playerPed, true, false)
        Entity(layingStretcherObject).state:set('occupiedByServerId', nil, true)
        layingStretcherObject = nil
        isLayingOnStretcher = false
    end

    if stretcherObject and DoesEntityExist(stretcherObject) then
        -- Récupérer le véhicule source depuis le statebag du brancard
        local vehicleNetId = Entity(stretcherObject).state.sourceVehicleNetId
        if vehicleNetId then
            local sourceVehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
            -- Libérer le véhicule source si il existe encore
            if sourceVehicle and DoesEntityExist(sourceVehicle) then
                Entity(sourceVehicle).state:set('hasStretcherOut', false, true)
            end
        end

        -- Vérifier si le brancard est rangé dans un véhicule
        local storedInVehicleNetId = Entity(stretcherObject).state.storedInVehicleNetId
        if storedInVehicleNetId then
            local storedVehicle = NetworkGetEntityFromNetworkId(storedInVehicleNetId)
            -- Nettoyer le statebag du véhicule de stockage
            if storedVehicle and DoesEntityExist(storedVehicle) then
                Entity(storedVehicle).state:set('storedStretcherNetId', nil, true)
            end
        end

        SetEntityAsMissionEntity(stretcherObject, true, true)
        DeleteEntity(stretcherObject)
        stretcherObject = nil
    end
end)
