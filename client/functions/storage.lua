-- Fonction pour ranger le brancard dans une ambulance
function StoreStretcherInVehicle(stretcher)
    if not stretcher or not DoesEntityExist(stretcher) then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Trouver l'ambulance la plus proche parmi les modèles configurés
    -- Une ambulance n'ayant pas déjà un brancard rangé en vérifiant son statebag
    local closestAmbulance = nil
    local closestAmbulanceData = nil
    local closestDistance = Config.MaxDistanceToStore + 1.0

    -- Parcourir tous les véhicules dans le jeu
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)

        -- Vérifier que le véhicule est dans le rayon
        if distance <= Config.MaxDistanceToStore then
            local vehicleModelHash = GetEntityModel(vehicle)

            -- Vérifier si c'est un modèle d'ambulance configuré (par hash)
            if ambulanceHashes[vehicleModelHash] then
                -- Vérifier si ce véhicule a DÉJÀ un brancard rangé
                local alreadyHasStretcher = Entity(vehicle).state.storedStretcherNetId ~= nil

                -- Garder la plus proche SEULEMENT si elle n'a pas déjà de brancard
                if distance < closestDistance and not alreadyHasStretcher then
                    closestDistance = distance
                    closestAmbulance = vehicle
                    closestAmbulanceData = ambulanceHashes[vehicleModelHash].data
                end
            end
        end
    end

    -- Vérifier qu'on a trouvé un véhicule compatible sans brancard déjà rangé
    if not closestAmbulance then
        ESX.ShowNotification(_U('no_compatible_vehicle'))
        return
    end

    -- Récupérer les données du modèle (déjà récupérées dans closestAmbulanceData)
    local vehicleData = closestAmbulanceData

    -- Vérification de sécurité : s'assurer que les données existent
    if not vehicleData or not vehicleData.offset or not vehicleData.rotation then
        ESX.ShowNotification(_U('invalid_vehicle_config'))
        return
    end

    -- Demander le contrôle réseau du véhicule pour modifier ses statebags
    NetworkRequestControlOfEntity(closestAmbulance)
    local vehicleTimeout = 0
    while not NetworkHasControlOfEntity(closestAmbulance) and vehicleTimeout < 30 do
        Wait(10)
        vehicleTimeout = vehicleTimeout + 1
    end

    -- Note: On continue même sans contrôle du véhicule (tolérant pour les véhicules)

    -- Définir l'entité comme mission pour pouvoir la gérer
    SetEntityAsMissionEntity(stretcher, true, true)

    -- DEMANDER LE CONTRÔLE RÉSEAU DE L'ENTITÉ
    NetworkRequestControlOfEntity(stretcher)

    -- Attendre d'avoir le contrôle (avec timeout de 500ms)
    local timeout = 0
    while not NetworkHasControlOfEntity(stretcher) and timeout < 50 do
        Wait(10)
        timeout = timeout + 1
    end

    -- Vérifier qu'on a bien obtenu le contrôle
    if not NetworkHasControlOfEntity(stretcher) then
        ESX.ShowNotification(_U('no_network_control'))
        return
    else
        ESX.ShowNotification(_U('network_control_success'))
    end

    -- Si le joueur porte le brancard, le détacher d'abord
    if stretcherObject == stretcher and isCarryingStretcher then
        ClearPedTasks(playerPed)
        DetachEntity(stretcher, false, false)
        stretcherObject = nil
        isCarryingStretcher = false
    end

    -- Enlever les collisions et la physique du brancard avant de l'attacher au véhicule
    -- Par sécurité
    SetEntityCollision(stretcher, false, false)

    -- Attacher le brancard au véhicule avec les offsets configurés
    AttachEntityToEntity(
        stretcher,                    -- Entité à attacher
        closestAmbulance,             -- Véhicule cible
        -1,                           -- Bone index
        vehicleData.offset.x,         -- Offset X
        vehicleData.offset.y,         -- Offset Y
        vehicleData.offset.z,         -- Offset Z
        vehicleData.rotation.x,       -- Rotation X (pitch)
        vehicleData.rotation.y,       -- Rotation Y (roll)
        vehicleData.rotation.z,       -- Rotation Z (yaw)
        false,                        -- physicsOnEntity1
        false,                        -- useSoftPinning
        false,                        -- collision (garder les collisions du véhicule)
        false,                        -- isPed
        2,                            -- vertexIndex
        true                          -- fixedRot
    )

    -- Figer le brancard (redondant mais par sécurité)
    FreezeEntityPosition(stretcher, true)

    -- Récupérer le véhicule source depuis le statebag du brancard
    local vehicleNetId = Entity(stretcher).state.sourceVehicleNetId
    if vehicleNetId then
        local sourceVehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        -- Libérer le véhicule source SEULEMENT si on range dans le MÊME véhicule
        if sourceVehicle and DoesEntityExist(sourceVehicle) then
            -- Vérifier si le véhicule source est le même que le véhicule de destination
            if sourceVehicle == closestAmbulance then
                -- Même véhicule : libérer le véhicule (le brancard est rentré chez lui)
                NetworkRequestControlOfEntity(sourceVehicle)
                local sourceTimeout = 0
                while not NetworkHasControlOfEntity(sourceVehicle) and sourceTimeout < 20 do
                    Wait(10)
                    sourceTimeout = sourceTimeout + 1
                end

                Entity(sourceVehicle).state:set('hasStretcherOut', false, true)
            end
            -- Sinon : NE PAS libérer le véhicule source (le brancard est rangé ailleurs)
        end
    end

    -- Marquer le brancard actuel comme étant rangé dans ce véhicule
    local storedVehicleNetId = NetworkGetNetworkIdFromEntity(closestAmbulance)
    Entity(stretcher).state:set('storedInVehicleNetId', storedVehicleNetId, true)

    -- Stocker l'ID réseau du brancard dans le statebag de l'ambulance
    local stretcherNetId = NetworkGetNetworkIdFromEntity(stretcher)
    Entity(closestAmbulance).state:set('storedStretcherNetId', stretcherNetId, true)

    ESX.ShowNotification(_U('stretcher_stored'))
end
