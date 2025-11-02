# ESX Stretcher - Système de Brancard

Système complet de gestion de brancard pour serveur ESX utilisant les props de **don-emsprops**.

## Fonctionnalités

- ✅ Sortir un brancard d'un véhicule médical
- ✅ Pousser et déplacer le brancard
- ✅ Se coucher soi-même sur un brancard
- ✅ Forcer un joueur à se coucher sur le brancard
- ✅ Retirer un joueur du brancard
- ✅ Ranger le brancard dans un véhicule
- ✅ Synchronisation réseau multi-joueurs optimisée
- ✅ Support de plusieurs véhicules configurables

## Dépendances

- **ESX Legacy** (v1.10.0+)
- **ox_target** - Pour les interactions
- **don-emsprops** - Pour les modèles de brancard

## Installation

1. Assurez-vous que `don-emsprops` et `ox_target` sont installés et démarrés
2. Copiez le dossier `esx_stretcher` dans votre dossier `resources/[local]`
3. Ajoutez dans votre `server.cfg` :

```cfg
ensure don-emsprops
ensure ox_target
ensure esx_stretcher
```

## Utilisation

### 1. Sortir le brancard
- Approchez-vous d'un **véhicule médical** compatible
- Visez le véhicule avec `ox_target`
- Sélectionnez l'option **"Sortir le brancard"**
- Le brancard apparaîtra dans les mains du joueur
- Un seul brancard peut être sorti par véhicule

### 2. Poser et pousser le brancard
- **Poser** : Appuyez sur la touche E **"Poser le brancard"**
- **Pousser** : Visez un brancard posé et sélectionnez **"Pousser le brancard"**
- Utilisez les **touches de déplacement** pour diriger le brancard
- Appuyez sur **E** pour arrêter de pousser

### 3. Se coucher sur le brancard
- Approchez-vous d'un **brancard libre** (sans personne dessus)
- Visez le brancard avec `ox_target`
- Sélectionnez l'option **"Se coucher sur le brancard"**
- Appuyez sur **E** pour vous lever

### 4. Forcer un joueur sur le brancard
- Assurez-vous qu'un **brancard libre est à proximité** (moins de 5m)
- Visez un **joueur** avec `ox_target`
- Sélectionnez l'option **"Mettre sur le brancard"**
- Le joueur sera automatiquement allongé sur le brancard le plus proche

### 5. Retirer un joueur du brancard
- Visez le **brancard** qui contient un joueur
- Sélectionnez l'option **"Retirer du brancard"**
- Le joueur sera libéré et pourra se déplacer

### 6. Ranger le brancard
- Placez le brancard près d'un **véhicule compatible** (moins de 15m par défaut)
- Visez le **brancard** avec `ox_target`
- Sélectionnez l'option **"Ranger le brancard"**
- Le brancard sera **rangé dans le véhicule** (attaché à l'intérieur)
- Un seul brancard peut être rangé par véhicule

## Véhicules compatibles

Par défaut, les véhicules suivants sont configurés :
- `ambulance` - Ambulance standard
- `firetruk` - Camion de pompiers

Chaque véhicule nécessite une **configuration de position et rotation** pour le rangement du brancard.

Vous pouvez ajouter vos propres véhicules dans **`config.lua`** :

```lua
Config.AmbulanceModels = {
    ['ambulance'] = {
        offset = vector3(0.0, -2.0, 0.3),      -- Position X, Y, Z
        rotation = vector3(0.0, 0.0, -90.0)     -- Rotation pitch, roll, yaw
    },
    ['firetruk'] = {
        offset = vector3(0.0, -4.5, 0.0),
        rotation = vector3(0.0, 0.0, -90.0)
    },
    ['votre_vehicule'] = {
        offset = vector3(0.0, -3.0, 0.5),       -- À ajuster selon le véhicule
        rotation = vector3(0.0, 0.0, -90.0)
    }
}
```

**Note** : Les valeurs d'offset et de rotation doivent être ajustées pour chaque modèle de véhicule afin que le brancard soit correctement positionné à l'intérieur.

## Configuration

Tous les paramètres sont configurables dans le fichier **`config.lua`** :

```lua
Config = {}

-- Modèle de brancard (don-emsprops)
Config.StretcherModel = 'strykergurney'

-- Distance maximale pour ranger le brancard (en mètres)
Config.MaxDistanceToStore = 15.0

-- Véhicules compatibles avec configuration de position
Config.AmbulanceModels = {
    ['ambulance'] = {
        offset = vector3(0.0, -2.0, 0.3),
        rotation = vector3(0.0, 0.0, -90.0)
    },
    ['firetruk'] = {
        offset = vector3(0.0, -4.5, 0.0),
        rotation = vector3(0.0, 0.0, -90.0)
    }
}
```

### Paramètres disponibles

| Paramètre | Description | Valeur par défaut |
|-----------|-------------|-------------------|
| `StretcherModel` | Modèle du brancard (don-emsprops) | `'strykergurney'` |
| `MaxDistanceToStore` | Distance max pour ranger (mètres) | `15.0` |
| `AmbulanceModels` | Table des véhicules avec position/rotation | Voir config.lua |

## Architecture

Le script utilise une **architecture modulaire** pour une meilleure organisation :

```
esx_stretcher/
├── config.lua                    # Configuration globale
├── fxmanifest.lua                # Manifest du resource
├── client/
│   ├── main.lua                  # Point d'entrée et documentation
│   ├── variables.lua             # Variables globales et hash tables
│   ├── functions/
│   │   ├── animations.lua        # Gestion des animations
│   │   ├── attach.lua            # Attachement brancard ↔ joueur
│   │   ├── laying.lua            # Coucher/lever du brancard
│   │   └── storage.lua           # Rangement dans véhicule
│   ├── targets/
│   │   ├── vehicles.lua          # Interactions ox_target véhicules
│   │   ├── stretcher.lua         # Interactions ox_target brancard
│   │   └── players.lua           # Interactions ox_target joueurs
│   ├── events.lua                # Events réseau
│   └── threads.lua               # Threads et cleanup
└── server/
    └── main.lua                  # Relais des événements réseau
```

## Animations utilisées

- **Pousser le brancard** : `anim@heists@box_carry@`
- **Joueur sur le brancard** : `anim@gangops@morgue@table@`

## Support

Pour tout problème ou suggestion, créez une issue sur le dépôt GitHub.

## Crédits

- **Modèles de brancard** : [Tiddy](https://www.gta5-mods.com/users/Tiddy) (don-emsprops)
- **Développement** : ESX Stretcher System

## License

Ce script est open source et libre d'utilisation.
