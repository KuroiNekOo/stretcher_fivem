-- Ajoute une cible ox_target sur les véhicules ambulances
exports.ox_target:addModel(ambulanceModels, {
    {
        name = 'manage_stretcher',
        icon = 'fas fa-bed',
        label = 'Sortir le brancard',
        canInteract = function(entity, distance, data)
          -- Bloquer si le joueur est sur un brancard ou en porte un
          if not CanUseStretcherTargets() then
              return false
          end

          -- Vérifier que le joueur a un job autorisé
          if not HasAllowedJob() then
              return false
          end

          -- Vérifier si un brancard est déjà sorti de ce véhicule
          local hasStretcherOut = Entity(entity).state.hasStretcherOut or false
          -- Vérifier si un brancard est rangé dans ce véhicule
          local storedStretcherNetId = Entity(entity).state.storedStretcherNetId

          -- Afficher le target si:
          -- 1. Aucun brancard n'est sorti (hasStretcherOut = false)
          -- 2. OU un brancard est rangé dans ce véhicule (storedStretcherNetId existe)
          return not hasStretcherOut or (storedStretcherNetId ~= nil)
        end,
        onSelect = function(data)
            local vehicle = data.entity
            if not vehicle or not DoesEntityExist(vehicle) then return end

            -- Demander le contrôle réseau du véhicule pour modifier ses statebags
            if not RequestEntityControl(vehicle, Config.NetworkTimeouts.vehicle) then
                return
            end

            -- Vérifier si un brancard est déjà rangé dans ce véhicule
            local storedStretcherNetId = Entity(vehicle).state.storedStretcherNetId

            if storedStretcherNetId then
                -- Ressortir le brancard rangé
                local storedStretcher = NetworkGetEntityFromNetworkId(storedStretcherNetId)

                if storedStretcher and DoesEntityExist(storedStretcher) then
                    -- Demander le contrôle réseau du brancard AVANT de modifier les statebags
                    if not RequestEntityControl(storedStretcher, Config.NetworkTimeouts.stretcher) then
                        return
                    end

                    -- Maintenant qu'on a le contrôle, on peut modifier les statebags
                    -- Marquer le véhicule comme ayant un brancard sorti
                    Entity(vehicle).state:set('hasStretcherOut', true, true)

                    -- Retirer le brancard du stockage dans le véhicule
                    Entity(vehicle).state:set('storedStretcherNetId', nil, true)

                    -- Nettoyer le statebag du brancard (il n'est plus rangé)
                    Entity(storedStretcher).state:set('storedInVehicleNetId', nil, true)

                    -- Attacher le brancard existant au joueur
                    AttachExistingStretcherToPlayer(storedStretcher)
                    return
                else
                    -- Le brancard stocké n'existe plus, nettoyer le statebag
                    Entity(vehicle).state:set('storedStretcherNetId', nil, true)
                end
            end

            -- Passage ici si aucun brancard n'était rangé, créer un nouveau brancard...

            -- Marquer le véhicule comme ayant un brancard sorti
            -- clé / valeur / synchronisé
            Entity(vehicle).state:set('hasStretcherOut', true, true)

            -- Créer et attacher un nouveau brancard au joueur
            AttachStretcherToPlayer(vehicle)
        end
    },
    {
        name = 'remove_stretcher_from_vehicle',
        icon = 'fas fa-trash',
        label = 'Retirer le brancard',
        canInteract = function(entity, distance, data)
            -- Bloquer si le joueur est sur un brancard ou en porte un
            if not CanUseStretcherTargets() then
                return false
            end

            -- Vérifier que le joueur a un job autorisé
            if not HasAllowedJob() then
                return false
            end

            -- Afficher seulement si un brancard est censé être sorti de ce véhicule
            local hasStretcherOut = Entity(entity).state.hasStretcherOut or false
            return hasStretcherOut
        end,
        onSelect = function(data)
            local vehicle = data.entity
            if not vehicle or not DoesEntityExist(vehicle) then return end

            -- Demander le contrôle réseau du véhicule
            if not RequestEntityControl(vehicle, Config.NetworkTimeouts.vehicle) then
                return
            end

            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)

            -- Chercher et supprimer le brancard associé à ce véhicule (s'il existe)
            local objects = GetGamePool('CObject')
            for _, obj in ipairs(objects) do
                if GetEntityModel(obj) == GetHashKey(Config.StretcherModel) then
                    local sourceVehicleNetId = Entity(obj).state.sourceVehicleNetId

                    -- Vérifier si ce brancard vient de ce véhicule
                    if sourceVehicleNetId == vehicleNetId then
                        -- Demander le contrôle du brancard
                        if RequestEntityControl(obj, Config.NetworkTimeouts.stretcher) then
                            -- Si quelqu'un est couché dessus, le forcer à se lever
                            local occupiedByServerId = Entity(obj).state.occupiedByServerId
                            if occupiedByServerId then
                                TriggerServerEvent('esx_stretcher:requestRemovePlayerFromStretcher', occupiedByServerId)
                                Wait(100)
                            end

                            -- Nettoyer le statebag du véhicule de stockage si le brancard était rangé ailleurs
                            local storedInVehicleNetId = Entity(obj).state.storedInVehicleNetId
                            if storedInVehicleNetId then
                                local storedVehicle = NetworkGetEntityFromNetworkId(storedInVehicleNetId)
                                if storedVehicle and DoesEntityExist(storedVehicle) then
                                    if RequestEntityControl(storedVehicle, Config.NetworkTimeouts.vehicle) then
                                        Entity(storedVehicle).state:set('storedStretcherNetId', nil, true)
                                    end
                                end
                            end

                            -- Si c'est le brancard du joueur, réinitialiser les variables locales
                            if stretcherObject == obj then
                                ClearPedTasks(PlayerPedId())
                                stretcherObject = nil
                                isCarryingStretcher = false
                            end

                            -- Supprimer le brancard
                            SetEntityAsMissionEntity(obj, true, true)
                            DeleteEntity(obj)
                        end
                        break
                    end
                end
            end

            -- Réinitialiser les statebags du véhicule
            Entity(vehicle).state:set('hasStretcherOut', false, true)
            Entity(vehicle).state:set('storedStretcherNetId', nil, true)

            ESX.ShowNotification('~g~Brancard retiré')
        end
    }
})
