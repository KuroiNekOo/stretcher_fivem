-- Ajoute une cible ox_target sur les joueurs
exports.ox_target:addGlobalPlayer({
    {
        name = 'put_player_on_stretcher',
        icon = 'fas fa-bed',
        label = 'Mettre sur le brancard',
        canInteract = function(entity, distance, data)
            -- Bloquer si le joueur est sur un brancard ou en porte un
            if not CanUseStretcherTargets() then
                return false
            end

            -- Vérifier que le joueur a un job autorisé
            if not HasAllowedJob() then
                return false
            end

            -- Vérifier qu'il y a un brancard à proximité (moins de 5m)
            -- On accepte les brancards même avec un occupant (on pourra le remplacer)
            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, stretcherData in pairs(GetGamePool('CObject')) do
                if GetEntityModel(stretcherData) == GetHashKey(Config.StretcherModel) then
                    local stretcherCoords = GetEntityCoords(stretcherData)
                    local dist = #(playerCoords - stretcherCoords)

                    if dist <= Config.MaxDistanceToFindStretcher then
                        -- Vérifier que le brancard n'est pas rangé
                        local isStored = Entity(stretcherData).state.storedInVehicleNetId ~= nil

                        if not isStored then
                            return true
                        end
                    end
                end
            end

            return false
        end,
        onSelect = function(data)
            local targetPed = data.entity
            local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))

            -- Trouver le brancard le plus proche (même s'il a un occupant)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local closestStretcher = nil
            local closestDistance = Config.MaxDistanceToFindStretcher

            for _, stretcherData in pairs(GetGamePool('CObject')) do
                if GetEntityModel(stretcherData) == GetHashKey(Config.StretcherModel) then
                    local stretcherCoords = GetEntityCoords(stretcherData)
                    local dist = #(playerCoords - stretcherCoords)

                    if dist < closestDistance then
                        local isStored = Entity(stretcherData).state.storedInVehicleNetId ~= nil

                        -- On accepte les brancards même avec un occupant (on le remplacera)
                        if not isStored then
                            closestStretcher = stretcherData
                            closestDistance = dist
                        end
                    end
                end
            end

            if closestStretcher then
                -- Récupérer l'ancien occupant (peut être nil ou orphelin)
                local previousOccupantServerId = Entity(closestStretcher).state.occupiedByServerId

                -- Demander le contrôle du brancard pour nettoyer le statebag
                if RequestEntityControl(closestStretcher, Config.NetworkTimeouts.stretcher) then
                    -- Forcer le nettoyage du statebag pour éviter les bugs
                    Entity(closestStretcher).state:set('occupiedByServerId', nil, true)
                end

                -- Envoyer au serveur pour trigger l'event sur le joueur ciblé
                local stretcherNetId = NetworkGetNetworkIdFromEntity(closestStretcher)
                TriggerServerEvent('esx_stretcher:requestPutPlayerOnStretcher', targetServerId, stretcherNetId, previousOccupantServerId)
            else
                ESX.ShowNotification(_U('no_free_stretcher_nearby'))
            end
        end
    }
})
