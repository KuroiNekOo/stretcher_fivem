-- Ajoute une cible ox_target sur le brancard
exports.ox_target:addModel({Config.StretcherModel}, {
    {
        name = 'push_stretcher',
        icon = 'fas fa-hand-paper',
        label = 'Pousser le brancard',
        canInteract = function(entity, distance, data)
            -- Vérifier si le brancard est rangé dans un véhicule
            -- ~= (not equal) (différent de nil)
            local isStored = Entity(entity).state.storedInVehicleNetId ~= nil

            -- On peut pousser seulement si on ne porte pas déjà un brancard ET que le brancard n'est pas rangé
            return not isCarryingStretcher and not isStored
        end,
        onSelect = function(data)
            local stretcher = data.entity
            if not stretcher or not DoesEntityExist(stretcher) then return end

            -- Attacher le brancard existant au joueur
            AttachExistingStretcherToPlayer(stretcher)
        end
    },
    {
        name = 'store_stretcher',
        icon = 'fas fa-inbox',
        label = 'Ranger le brancard',
        canInteract = function(entity, distance, data)
            -- Vérifier si le brancard est déjà rangé dans un véhicule
            local isStored = Entity(entity).state.storedInVehicleNetId ~= nil

            -- On peut ranger seulement si le brancard n'est pas déjà rangé
            return not isStored
        end,
        onSelect = function(data)
            local stretcher = data.entity
            if not stretcher or not DoesEntityExist(stretcher) then return end

            -- Ranger le brancard dans l'ambulance la plus proche
            StoreStretcherInVehicle(stretcher)
        end
    },
    {
        name = 'lay_on_stretcher',
        icon = 'fas fa-bed',
        label = 'Se coucher sur le brancard',
        canInteract = function(entity, distance, data)
            -- Vérifier si le brancard est rangé
            local isStored = Entity(entity).state.storedInVehicleNetId ~= nil

            -- Vérifier si quelqu'un est déjà couché sur le brancard
            local occupiedByServerId = Entity(entity).state.occupiedByServerId

            -- On peut se coucher si: pas rangé, personne dessus, et on n'est pas déjà couché ailleurs
            return not isStored and not occupiedByServerId and not isLayingOnStretcher
        end,
        onSelect = function(data)
            local stretcher = data.entity
            if not stretcher or not DoesEntityExist(stretcher) then return end

            -- Se coucher sur le brancard
            LayOnStretcher(stretcher)
        end
    },
    {
        name = 'remove_player_from_stretcher',
        icon = 'fas fa-user-minus',
        label = 'Retirer du brancard',
        canInteract = function(entity, distance, data)
            -- Vérifier si le brancard est rangé
            local isStored = Entity(entity).state.storedInVehicleNetId ~= nil

            -- Vérifier si quelqu'un est couché sur le brancard
            local occupiedByServerId = Entity(entity).state.occupiedByServerId

            -- On peut retirer quelqu'un si: pas rangé et quelqu'un dessus
            return not isStored and occupiedByServerId ~= nil
        end,
        onSelect = function(data)
            local stretcher = data.entity
            if not stretcher or not DoesEntityExist(stretcher) then return end

            -- Récupérer l'ID du joueur couché sur le brancard
            local occupiedByServerId = Entity(stretcher).state.occupiedByServerId

            if occupiedByServerId then
                -- Envoyer au serveur pour forcer le joueur à se lever
                TriggerServerEvent('esx_stretcher:requestRemovePlayerFromStretcher', occupiedByServerId)
            end
        end
    },
    {
        name = 'remove_stretcher',
        icon = 'fas fa-trash',
        label = 'Retirer le brancard',
        onSelect = function(data)
            local stretcher = data.entity
            if not stretcher or not DoesEntityExist(stretcher) then return end

            -- Permet de dire au client FiveM : " Cette entité appartient maintenant à mon script, je peux la gérer et la supprimer "
            -- Pourquoi ? Car certaines entités peuvent être des entités réseau orphelines et donc plus référencées par le client
            -- SetEntityAsMissionEntity permet d'intéragir de nouveau avec l'entité
            -- Ceci est nécessaire quand ça concerne des entités réseau SEULEMENT
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
                ESX.ShowNotification('~r~Impossible de prendre le contrôle du brancard')
                return
            else
                ESX.ShowNotification('~g~Contrôle du brancard obtenu')
            end

            -- Récupérer le véhicule source depuis le statebag du brancard
            local vehicleNetId = Entity(stretcher).state.sourceVehicleNetId
            if vehicleNetId then
                local sourceVehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
                -- Libérer le véhicule source si il existe encore
                if sourceVehicle and DoesEntityExist(sourceVehicle) then
                    -- Demander le contrôle du véhicule source
                    NetworkRequestControlOfEntity(sourceVehicle)
                    local sourceTimeout = 0
                    while not NetworkHasControlOfEntity(sourceVehicle) and sourceTimeout < 20 do
                        Wait(10)
                        sourceTimeout = sourceTimeout + 1
                    end

                    Entity(sourceVehicle).state:set('hasStretcherOut', false, true)
                end
            end

            -- Vérifier si le brancard est rangé dans un véhicule
            local storedInVehicleNetId = Entity(stretcher).state.storedInVehicleNetId
            if storedInVehicleNetId then
                local storedVehicle = NetworkGetEntityFromNetworkId(storedInVehicleNetId)
                -- Nettoyer le statebag du véhicule de stockage
                if storedVehicle and DoesEntityExist(storedVehicle) then
                    -- Demander le contrôle du véhicule de stockage
                    NetworkRequestControlOfEntity(storedVehicle)
                    local storedTimeout = 0
                    while not NetworkHasControlOfEntity(storedVehicle) and storedTimeout < 20 do
                        Wait(10)
                        storedTimeout = storedTimeout + 1
                    end

                    Entity(storedVehicle).state:set('storedStretcherNetId', nil, true)
                end
            end

            -- Si c'est le brancard du joueur, réinitialiser les variables locales
            if stretcherObject == stretcher then
                stretcherObject = nil
                isCarryingStretcher = false
            end

            DeleteEntity(stretcher)
        end
    }
})
