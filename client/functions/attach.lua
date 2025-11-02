-- Fonction pour attacher un brancard existant au joueur
function AttachExistingStretcherToPlayer(stretcherEntity)
    -- Vérifier que le joueur ne porte pas déjà un brancard
    if isCarryingStretcher then return end

    -- Vérifier que l'entité existe
    if not stretcherEntity or not DoesEntityExist(stretcherEntity) then return end

    local playerPed = PlayerPedId()

    -- DEMANDER LE CONTRÔLE RÉSEAU DE L'ENTITÉ
    NetworkRequestControlOfEntity(stretcherEntity)

    -- Attendre d'avoir le contrôle (avec timeout configurable)
    local timeout = 0
    while not NetworkHasControlOfEntity(stretcherEntity) and timeout < Config.NetworkTimeouts.stretcher do
        Wait(10)
        timeout = timeout + 1
    end

    -- Vérifier qu'on a bien obtenu le contrôle
    if not NetworkHasControlOfEntity(stretcherEntity) then
        ESX.ShowNotification(_U('no_network_control'))
        return
    else
        ESX.ShowNotification(_U('network_control_success'))
    end

    -- Définir l'entité comme mission pour pouvoir la gérer
    SetEntityAsMissionEntity(stretcherEntity, true, true)

    -- Dégeler le brancard si il était gelé
    -- Gardé par sécurité même si le AttachEntityToEntity devrait déjà dégeler l'entité
    FreezeEntityPosition(stretcherEntity, false)

    -- Désactiver les collisions pendant que le joueur porte le brancard
    -- Gardé par sécurité même si le AttachEntityToEntity devrait déjà désactiver les collisions
    SetEntityCollision(stretcherEntity, false, false)

    -- Stocker la référence du brancard
    stretcherObject = stretcherEntity

    -- DÉTACHER le brancard du véhicule AVANT de l'attacher au joueur
    -- Techniquement pas obligatoire mais évite des bugs visuels (multijoueur / réseau)
    DetachEntity(
      stretcherObject,    -- la référence de l'objet
      false,              -- collision
      false               -- physique
    )

    -- Attacher le brancard au joueur
    -- Bone index -1 (châssis principal)
    AttachEntityToEntity(
        stretcherObject,
        playerPed,
        -1,
        Config.CarryOffset.x, Config.CarryOffset.y, Config.CarryOffset.z,
        Config.CarryRotation.x, Config.CarryRotation.y, Config.CarryRotation.z,
        false, false, false, false, 2, true
    )
    isCarryingStretcher = true

    -- Jouer l'animation de poussée
    PlayPushAnimation()
end

-- Fonction pour créer et attacher un nouveau brancard au joueur
function AttachStretcherToPlayer(vehicle)
    if isCarryingStretcher then return end

    local playerPed = PlayerPedId()
    local modelHash = GetHashKey(Config.StretcherModel)

    -- Charge le modèle dans la mémoire vive du client
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end

    -- Création de l'objet brancard et stock la référence
    stretcherObject = CreateObject(
      modelHash,      -- Hashe du modèle
      0.0,            -- Position X
      0.0,            -- Position Y
      0.0,            -- Position Z
      true,           -- Est-ce que l'objet sera réseau (synchro avec les joueurs et même après un déconnexion du client) ?
      true,           -- ???
      false           -- ???
    )

    -- Attache le brancard au joueur
    if stretcherObject and DoesEntityExist(stretcherObject) then
        -- Marquer comme mission entity pour éviter le despawn automatique
        SetEntityAsMissionEntity(stretcherObject, true, true)
        -- Stocker le véhicule source dans le statebag du brancard
        -- On utilise le NetworkID pour assurer la compatibilité réseau
        local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
        Entity(stretcherObject).state:set('sourceVehicleNetId', vehicleNetId, true)

        AttachEntityToEntity(
            stretcherObject,
            playerPed,
            -1,
            Config.CarryOffset.x, Config.CarryOffset.y, Config.CarryOffset.z,
            Config.CarryRotation.x, Config.CarryRotation.y, Config.CarryRotation.z,
            false, false, false, false, 2, true
        )
        isCarryingStretcher = true

        -- Jouer l'animation de poussée
        PlayPushAnimation()
    end

    -- Libérer le modèle de la mémoire vive du client
    SetModelAsNoLongerNeeded(modelHash)

    ESX.ShowNotification(_U('pushing_stretcher'))
end

-- Fonction pour détacher le brancard et lui rendre sa physique
function DetachStretcherFromPlayer()
    if not stretcherObject or not DoesEntityExist(stretcherObject) then return end

    local playerPed = PlayerPedId()

    -- Arrêter l'animation de poussée
    ClearPedTasks(playerPed)

    -- Sépare l'objet du joueur. Les paramètres true, true activent collision et physique au moment du détachement
    DetachEntity(
      stretcherObject,    -- référence de l'objet
      false,               -- collision
      false                -- physique
    )

    -- Placer le brancard au sol correctement
    PlaceObjectOnGroundProperly(stretcherObject)

    -- Débloque la position de l'objet pour que la gravité et la physique s'appliquent (sinon l'objet resterait figé en l'air)
    -- Le second paramètre permet de réactiver la physique de l'objet
    FreezeEntityPosition(stretcherObject, true)

    -- Active les collisions avec le monde et les autres objets/joueurs
    -- Le second paramètre permet de modifier l'état de la physique de l'objet
    -- Le troisième paramètre permet de modifier l'état de la collision de l'objet
    SetEntityCollision(stretcherObject, true, true)

    -- Réinitialiser la variable de portage
    isCarryingStretcher = false
end
