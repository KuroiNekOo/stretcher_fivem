Config = {}

-- Langue utilisée pour les notifications
Config.Locale = 'fr'

-- Jobs autorisés à utiliser le brancard (mettre un joueur sur le brancard, etc.)
-- Mettre à {} (table vide) pour autoriser tout le monde
Config.AllowedJobs = {
    'ambulance',
    'police'
}

-- Modèle de brancard (don-emsprops)
Config.StretcherModel = 'strykergurney'

-- Distance maximale (en mètres) pour ranger le brancard dans un véhicule autorisé
Config.MaxDistanceToStore = 15.0

-- Distance maximale (en mètres) pour trouver un brancard libre lors de l'interaction avec un joueur
-- Utilisé notamment pour poser un joueur sur un brancard
Config.MaxDistanceToFindStretcher = 5.0

-- Timeouts réseau (en nombre d'itérations, 1 itération = 10ms)
-- Ajuster selon la qualité réseau du serveur
Config.NetworkTimeouts = {
    stretcher = 50,   -- Timeout pour contrôle brancard (500ms)
    vehicle = 30      -- Timeout pour contrôle véhicule (300ms)
}

-- Afficher les notifications de succès/échec du contrôle réseau
-- true = afficher les notifications (succès et échec)
-- false = ne pas afficher les notifications
Config.ShowNetworkControlNotifications = true

-- Offsets pour l'attachement du brancard au joueur (quand il le porte)
Config.CarryOffset = vector3(0.0, 1.5, -1.0)     -- Position X, Y, Z
Config.CarryRotation = vector3(0.0, 0.0, -90.0)  -- Rotation pitch, roll, yaw

-- Offsets pour l'attachement du joueur au brancard (quand il est couché)
Config.LayingOffset = vector3(0.0, 0.0, 2.1)     -- Position X, Y, Z
Config.LayingRotation = vector3(0.0, 0.0, 90.0)  -- Rotation pitch, roll, yaw

-- Animation quand le joueur pousse le brancard
Config.PushAnimation = {
    dict = 'anim@heists@box_carry@',        -- Dictionnaire d'animation
    anim = 'idle',                          -- Nom de l'animation
    flags = 49                              -- 49 = Haut du corps uniquement, boucle
}

-- Animation quand le joueur est couché sur le brancard
Config.LayingAnimation = {
    dict = 'anim@gangops@morgue@table@',    -- Dictionnaire d'animation
    anim = 'body_search',                   -- Nom de l'animation
    flags = 1                               -- 1 = Loop
}

-- Liste des véhicules autorisés à utiliser le brancard
Config.AmbulanceModels = {
    ['ambulance'] = {
        -- Position du brancard dans le véhicule (offset relatif au véhicule)
        -- X = latéral (négatif = gauche, positif = droite)
        -- Y = avant/arrière (négatif = arrière, positif = avant)
        -- Z = hauteur (négatif = bas, positif = haut)
        offset = vector3(0.0, -3.0, -0.20),

        -- Rotation du brancard dans le véhicule (en degrés)
        -- Pitch = inclinaison avant/arrière
        -- Roll = inclinaison latérale
        -- Yaw = rotation horizontale (0 = dans le sens du véhicule, -90 = perpendiculaire)
        rotation = vector3(0.0, 0.0, -90.0)
    },

    -- Camion de pompier (exemple)
    ['firetruk'] = {
        offset = vector3(0.0, -4.5, 0.0),
        rotation = vector3(0.0, 0.0, -90.0)
    }
}
