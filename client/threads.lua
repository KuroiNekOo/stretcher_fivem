-- Thread optimisé pour détecter la touche E
CreateThread(function()
    while true do

        -- Passage à un délai court si le joueur porte le brancard OU est couché dessus
        -- Pourquoi ? Pour réagir rapidement à l'appui de la touche E
        if isCarryingStretcher or isLayingOnStretcher then
            Wait(5)

            if IsControlJustPressed(0, 38) then -- Touche E
                if isCarryingStretcher then
                    -- Détacher le brancard que le joueur porte
                    DetachStretcherFromPlayer()
                elseif isLayingOnStretcher then
                    -- Se relever du brancard
                    GetUpFromStretcher()
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
