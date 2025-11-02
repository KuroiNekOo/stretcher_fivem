-- Ajoute une cible ox_target sur les véhicules ambulances
exports.ox_target:addModel(ambulanceModels, {
    {
        name = 'manage_stretcher',
        icon = 'fas fa-bed',
        label = 'Sortir le brancard',
        canInteract = function(entity, distance, data)
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
            NetworkRequestControlOfEntity(vehicle)
            local timeout = 0
            while not NetworkHasControlOfEntity(vehicle) and timeout < 30 do
                Wait(10)
                timeout = timeout + 1
            end

            if not NetworkHasControlOfEntity(vehicle) then
                ESX.ShowNotification(_U('no_vehicle_control'))
                return
            end

            -- Note: On continue même sans contrôle du véhicule, car les statebags de véhicules
            -- sont généralement synchronisés même sans contrôle strict

            -- Vérifier si un brancard est déjà rangé dans ce véhicule
            local storedStretcherNetId = Entity(vehicle).state.storedStretcherNetId

            if storedStretcherNetId then
                -- Ressortir le brancard rangé
                local storedStretcher = NetworkGetEntityFromNetworkId(storedStretcherNetId)

                if storedStretcher and DoesEntityExist(storedStretcher) then
                    -- Demander le contrôle réseau du brancard AVANT de modifier les statebags
                    NetworkRequestControlOfEntity(storedStretcher)
                    local timeout = 0
                    while not NetworkHasControlOfEntity(storedStretcher) and timeout < 50 do
                        Wait(10)
                        timeout = timeout + 1
                    end

                    if not NetworkHasControlOfEntity(storedStretcher) then
                        ESX.ShowNotification(_U('no_stored_stretcher_control'))
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
    }
})
