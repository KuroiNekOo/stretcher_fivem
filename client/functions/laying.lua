-- Fonction pour se coucher sur un brancard
function LayOnStretcher(stretcher)
    if not stretcher or not DoesEntityExist(stretcher) then return end
    if isLayingOnStretcher then return end

    local playerPed = PlayerPedId()
    local playerServerId = GetPlayerServerId(PlayerId())

    -- DEMANDER LE CONTRÔLE RÉSEAU DE L'ENTITÉ
    NetworkRequestControlOfEntity(stretcher)

    -- Attendre d'avoir le contrôle (avec timeout configurable)
    local timeout = 0
    while not NetworkHasControlOfEntity(stretcher) and timeout < Config.NetworkTimeouts.stretcher do
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

    -- Marquer le brancard comme occupé
    Entity(stretcher).state:set('occupiedByServerId', playerServerId, true)

    -- Stocker la référence du brancard
    layingStretcherObject = stretcher

    -- Charger l'animation
    local animDict = Config.LayingAnimation.dict
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    -- Obtenir la position du brancard
    local stretcherCoords = GetEntityCoords(stretcher)
    local stretcherHeading = GetEntityHeading(stretcher)

    -- Téléporter le joueur sur le brancard
    -- SetEntityCoords(entity, xPos, yPos, zPos, xAxis, yAxis, zAxis, clearArea)
    SetEntityCoords(playerPed, stretcherCoords.x, stretcherCoords.y, stretcherCoords.z + 0.3, false, false, false, true)
    SetEntityHeading(playerPed, stretcherHeading)

    -- Jouer l'animation
    TaskPlayAnim(playerPed, animDict, Config.LayingAnimation.anim, 8.0, -8.0, -1, Config.LayingAnimation.flags, 0, false, false, false)

    -- Détacher le joueur si déjà attaché (sécurité pour compatibilité avec autres scripts)
    if IsEntityAttached(playerPed) then
        DetachEntity(playerPed, true, false)
        Wait(50)
    end

    -- Attacher le joueur au brancard
    AttachEntityToEntity(playerPed, stretcher, 0, 0.0, 0.0, 2.1, 0.0, 0.0, 90.0, false, false, false, false, 2, true)

    isLayingOnStretcher = true
    ESX.ShowNotification(_U('laying_on_stretcher'))
end

-- Fonction pour se relever du brancard
function GetUpFromStretcher()
    if not isLayingOnStretcher then return end
    if not layingStretcherObject or not DoesEntityExist(layingStretcherObject) then
        isLayingOnStretcher = false
        layingStretcherObject = nil
        return
    end

    -- Vérifier si le brancard est actuellement rangé dans un véhicule
    local storedInVehicleNetId = Entity(layingStretcherObject).state.storedInVehicleNetId

    if storedInVehicleNetId then
      ESX.ShowNotification(_U('cannot_get_up_stored'))
      return
    end

    local playerPed = PlayerPedId()

    -- Obtenir la position et rotation du brancard
    local stretcherCoords = GetEntityCoords(layingStretcherObject)
    local stretcherHeading = GetEntityHeading(layingStretcherObject)

    -- Calculer une position à 1.5m à côté du brancard (sur le côté droit)
    local offsetX = 1.5 * math.cos(math.rad(stretcherHeading - 90))
    local offsetY = 1.5 * math.sin(math.rad(stretcherHeading - 90))

    -- Demander le contrôle du brancard pour modifier son statebag
    NetworkRequestControlOfEntity(layingStretcherObject)
    local timeout = 0
    while not NetworkHasControlOfEntity(layingStretcherObject) and timeout < Config.NetworkTimeouts.vehicle do
        Wait(10)
        timeout = timeout + 1
    end

    -- Détacher le joueur du brancard (toujours, même sans contrôle pour ne pas bloquer le joueur)
    DetachEntity(playerPed, true, false)

    -- Arrêter l'animation
    ClearPedTasks(playerPed)

    -- Téléporter le joueur à côté du brancard
    SetEntityCoords(playerPed, stretcherCoords.x + offsetX, stretcherCoords.y + offsetY, stretcherCoords.z, false, false, false, true)

    -- Libérer le brancard seulement si on a le contrôle réseau
    if NetworkHasControlOfEntity(layingStretcherObject) then
        Entity(layingStretcherObject).state:set('occupiedByServerId', nil, true)
    end

    -- Réinitialiser les variables
    isLayingOnStretcher = false
    layingStretcherObject = nil

    ESX.ShowNotification(_U('got_up_from_stretcher'))
end
