-- Ajoute une cible ox_target sur les joueurs
exports.ox_target:addGlobalPlayer({
    {
        name = 'put_player_on_stretcher',
        icon = 'fas fa-bed',
        label = 'Mettre sur le brancard',
        canInteract = function(entity, distance, data)
            -- Vérifier qu'il y a un brancard libre à proximité (moins de 5m)
            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, stretcherData in pairs(GetGamePool('CObject')) do
                if GetEntityModel(stretcherData) == GetHashKey(Config.StretcherModel) then
                    local stretcherCoords = GetEntityCoords(stretcherData)
                    local dist = #(playerCoords - stretcherCoords)

                    if dist <= Config.MaxDistanceToFindStretcher then
                        -- Vérifier que le brancard n'est pas rangé
                        local isStored = Entity(stretcherData).state.storedInVehicleNetId ~= nil

                        -- Vérifier que le brancard est libre
                        local occupiedByServerId = Entity(stretcherData).state.occupiedByServerId

                        if not isStored and not occupiedByServerId then
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

            -- Trouver le brancard le plus proche
            local playerCoords = GetEntityCoords(PlayerPedId())
            local closestStretcher = nil
            local closestDistance = Config.MaxDistanceToFindStretcher

            for _, stretcherData in pairs(GetGamePool('CObject')) do
                if GetEntityModel(stretcherData) == GetHashKey(Config.StretcherModel) then
                    local stretcherCoords = GetEntityCoords(stretcherData)
                    local dist = #(playerCoords - stretcherCoords)

                    if dist < closestDistance then
                        local isStored = Entity(stretcherData).state.storedInVehicleNetId ~= nil
                        local occupiedByServerId = Entity(stretcherData).state.occupiedByServerId

                        if not isStored and not occupiedByServerId then
                            closestStretcher = stretcherData
                            closestDistance = dist
                        end
                    end
                end
            end

            if closestStretcher then
                -- Envoyer au serveur pour trigger l'event sur le joueur ciblé
                local stretcherNetId = NetworkGetNetworkIdFromEntity(closestStretcher)
                TriggerServerEvent('esx_stretcher:requestPutPlayerOnStretcher', targetServerId, stretcherNetId)
            else
                ESX.ShowNotification(_U('no_free_stretcher_nearby'))
            end
        end
    }
})
