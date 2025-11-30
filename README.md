# jh-mlfaGasStation

Un système complet de gestion de stations-service pour FiveM avec interface tablette moderne, système de propriété, gestion d'employés, missions, et tracking automatique des ventes de carburant.

## 📋 Dépendances Requises

Ce script nécessite les ressources suivantes pour fonctionner correctement :

- **[es_extended](https://github.com/esx-framework/esx_core)** - Framework ESX
- **[oxmysql](https://github.com/overextended/oxmysql)** - Système de base de données MySQL
- **[fscripts_fuel](https://github.com/fscripts-dev/fscripts_fuel)** - Système de carburant (OBLIGATOIRE)

> [!IMPORTANT]
> Le script `fscripts_fuel` est **obligatoire** pour le bon fonctionnement du système de tracking de carburant et des revenus de la station.

## 📦 Installation

### 1. Télécharger les dépendances
- Assurez-vous d'avoir installé toutes les dépendances listées ci-dessus
- Téléchargez `fscripts_fuel` depuis leur GitHub ou votre source

### 2. Installation du script
```bash
cd resources
git clone https://github.com/VOTRE_USERNAME/jh-mlfaGasStation.git
```

### 3. Configuration de la base de données
Importez le fichier `mlfa_gasstations.sql` dans votre base de données MySQL :
```bash
mysql -u votre_utilisateur -p votre_base_de_donnees < mlfa_gasstations.sql
```

### 4. Configuration du server.cfg
Ajoutez les ressources dans votre `server.cfg` dans l'ordre suivant :
```cfg
ensure es_extended
ensure oxmysql
ensure fscripts_fuel
ensure jh-mlfaGasStation
```

> [!WARNING]
> L'ordre de chargement est important ! `fscripts_fuel` doit être démarré **avant** `jh-mlfaGasStation`.

---

## 🎮 Fonctionnalités Complètes

### 🏢 Système de Propriété
- **Achat de stations** : Achetez des stations-service pour **$500,000** (configurable)
- **Vente de stations** : Revendez votre station à tout moment
- **Marqueurs d'achat** : Marqueurs visuels aux points d'achat avec interaction `E`
- **5 stations disponibles** par défaut :
  - Station Downtown
  - Station Grove Street
  - Station Sandy Shores
  - Station Paleto Bay
  - Station Great Ocean Highway

### 💼 Gestion des Employés
- **3 rangs hiérarchiques** :
  - **Propriétaire** : Accès complet à toutes les fonctionnalités
  - **Gérant** : Gestion des employés, missions, paramètres (salaire : $2,000)
  - **Employé** : Accès aux missions uniquement (salaire : $1,200)

- **Permissions personnalisables** :
  - Gestion de l'argent (retrait/dépôt)
  - Embauche d'employés
  - Licenciement d'employés
  - Démarrage de missions
  - Modification des paramètres
  - Consultation des rapports

- **Actions disponibles** :
  - Embaucher des joueurs à proximité
  - Licencier des employés
  - Modifier les rangs et permissions
  - Gérer les salaires

### 💰 Gestion Financière
- **Caisse de la station** : Argent séparé pour chaque station
- **Dépôt d'argent** : Déposez votre argent personnel dans la caisse
- **Retrait d'argent** : Retirez de l'argent (permission requise)
- **Historique des transactions** : Suivi complet de toutes les opérations
- **Types de transactions** :
  - Ventes de carburant
  - Dépôts/retraits
  - Récompenses de missions
  - Achats de stock

### ⛽ Gestion du Carburant
- **Stock de carburant** : Jusqu'à **10,000 litres** par station (configurable)
- **Prix personnalisable** : Définissez votre prix par litre (défaut : $2.50/L)
- **Tracking automatique** : Intégration complète avec `fscripts_fuel`
- **Ventes en temps réel** : Chaque vente est automatiquement enregistrée
- **Alertes de stock faible** : Notification quand le stock < 1,000L
- **Statistiques détaillées** :
  - Litres vendus aujourd'hui
  - Litres vendus cette semaine
  - Revenus générés
  - Nombre de transactions

### 🚚 Système de Missions
- **Mission de livraison de carburant** :
  - Récupérez un camion citerne au port
  - Livrez le carburant à votre station
  - Récompense : **$1,500** + **500 litres** de carburant
  - Cooldown : **10 minutes** entre chaque mission
  - Véhicule : Tanker avec blip GPS
  - Suivi en temps réel de la mission

- **Fonctionnalités** :
  - Blip de navigation vers le camion
  - Blip de navigation vers la station
  - Détection automatique de la livraison
  - Échec si le véhicule est détruit
  - Système de cooldown par station

### 📊 Statistiques et Rapports
- **Dashboard en temps réel** :
  - Argent en caisse
  - Stock de carburant actuel
  - Nombre d'employés
  - Ventes du jour
  - Ventes de la semaine

- **Historique des ventes** :
  - Nom du client
  - Plaque du véhicule
  - Litres achetés
  - Prix total
  - Date et heure

- **Rapports détaillés** :
  - Statistiques journalières
  - Statistiques hebdomadaires
  - Historique des transactions
  - Performance des employés

### 🖥️ Interface Tablette Moderne
- **Design glassmorphism** : Interface élégante et moderne
- **Animation de tablette** : Prop 3D avec animation réaliste
- **Navigation par apps** : 7 applications intégrées
- **Responsive** : Interface adaptative et fluide

#### Applications disponibles :
1. **📊 Dashboard** : Vue d'ensemble de la station
2. **⛽ Fuel Management** : Gestion du carburant et des prix
3. **👥 Employees** : Gestion des employés (Propriétaire/Gérant)
4. **🛡️ Permissions** : Configuration des permissions (Propriétaire uniquement)
5. **📋 Missions** : Lancement et suivi des missions
6. **📈 Reports** : Statistiques et rapports détaillés
7. **⚙️ Settings** : Paramètres de la station

### 🎨 Personnalisation
- **Thème de couleurs configurable** :
  - Primaire : `#00F2EA` (Cyan)
  - Secondaire : `#1a1a2e` (Bleu foncé)
  - Succès : `#00C9A7` (Vert)
  - Danger : `#FF6B6B` (Rouge)
  - Warning : `#FFD93D` (Jaune)

- **Touches configurables** :
  - Touche d'ouverture : `E` (38) par défaut
  - Personnalisable dans `config.lua`

- **Marqueurs personnalisables** :
  - Type de marqueur
  - Taille et couleur
  - Distance d'interaction

### 🔔 Système de Notifications
- **Support multi-systèmes** :
  - Compatible avec `mlfa_notifications`
  - Fallback sur notifications console
  - Types : Succès, Erreur, Info

- **Notifications automatiques** :
  - Ventes de carburant
  - Embauche/licenciement
  - Dépôts/retraits
  - Missions complétées
  - Alertes de stock

### 🗺️ Blips et Marqueurs
- **Blips sur la carte** :
  - Icône de pompe à essence (sprite 361)
  - Couleur verte (color 3)
  - Nom personnalisé pour chaque station
  - Visible à longue distance

- **Marqueurs 3D** :
  - Marqueur cyan aux points d'interaction
  - Visible dans un rayon de 10m
  - Aide contextuelle à 2m

### 🔧 Commandes Disponibles

#### Commandes Joueur
- `/gasmanager` : Ouvre la tablette de gestion (à proximité d'une station)
- Touche `E` : Interaction rapide avec les marqueurs

#### Commandes Admin/Debug
- `/checkfuelstock` : Affiche les infos de la station la plus proche
  - Stock de carburant
  - Prix par litre
  - Argent en caisse

### 🔌 Exports Disponibles

#### Server-side
```lua
-- Obtenir le stock de carburant d'une station
local stock = exports['jh-mlfaGasStation']:GetStationFuelStock(stationId)

-- Obtenir la station la plus proche
local station, distance = exports['jh-mlfaGasStation']:GetStationByCoords(coords)
```

### 📡 Events Disponibles

#### Client Events
```lua
-- Notification
TriggerEvent('mlfaGasStation:notify', type, message)
```

#### Server Events
```lua
-- Embaucher un employé
TriggerServerEvent('mlfaGasStation:hireEmployee', stationId, targetId, rank)

-- Licencier un employé
TriggerServerEvent('mlfaGasStation:fireEmployee', stationId, employeeId)

-- Retirer de l'argent
TriggerServerEvent('mlfaGasStation:withdrawMoney', stationId, amount)

-- Déposer de l'argent
TriggerServerEvent('mlfaGasStation:depositMoney', stationId, amount)

-- Mettre à jour le prix du carburant
TriggerServerEvent('mlfaGasStation:updateFuelPrice', stationId, price)

-- Acheter une station
TriggerServerEvent('mlfaGasStation:purchaseStation', stationId)

-- Vendre une station
TriggerServerEvent('mlfaGasStation:sellStation', stationId)

-- Compléter une mission
TriggerServerEvent('mlfaGasStation:completeMission', missionId, success)
```

---

## ⚙️ Configuration Détaillée

### Fichier `config.lua`

#### Paramètres Généraux
```lua
Config.Framework = 'ESX'                    -- Framework utilisé
Config.OpenKey = 38                         -- Touche E
Config.TabletProp = 'prop_cs_tablet'        -- Modèle de tablette
Config.DefaultFuelPrice = 2.5               -- Prix par défaut ($/L)
Config.StationPurchasePrice = 500000        -- Prix d'achat d'une station
Config.MaxFuelStock = 10000                 -- Stock maximum (litres)
```

#### Configuration des Missions
```lua
Config.FuelDeliveryMission = {
    vehicleModel = 'tanker',                -- Modèle du véhicule
    spawnPoint = vector3(1163.0, -3196.0, 5.0), -- Point de spawn
    fuelAmount = 500,                       -- Litres livrés
    reward = 1500,                          -- Récompense ($)
    cooldown = 600                          -- Cooldown (secondes)
}
```

#### Rangs et Permissions
Personnalisez les 3 rangs avec leurs permissions spécifiques dans `Config.Ranks`.

#### Emplacements des Stations
Ajoutez ou modifiez les stations dans `Config.Stations` avec :
- ID unique
- Nom et label
- Coordonnées
- Configuration du blip
- Point d'achat

---

## 🗄️ Structure de la Base de Données

Le script crée automatiquement 4 tables :

### `gas_stations`
- Informations principales de chaque station
- Propriétaire, argent, stock de carburant, prix

### `gas_employees`
- Liste des employés par station
- Rangs et permissions

### `gas_transactions`
- Historique de toutes les transactions
- Type, montant, description, date

### `gas_fuel_sales`
- Détails de chaque vente de carburant
- Joueur, véhicule, litres, prix

---

## 🔧 Support et Dépannage

### Problèmes Courants

#### La tablette ne s'ouvre pas
- Vérifiez que vous êtes à proximité d'une station (< 10m)
- Vérifiez les logs F8 pour les erreurs
- Assurez-vous que `es_extended` est bien chargé

#### Les ventes ne sont pas trackées
- Vérifiez que `fscripts_fuel` est démarré **avant** ce script
- Vérifiez l'event `fuel:pay` dans `fscripts_fuel`
- Utilisez `/checkfuelstock` pour vérifier le tracking

#### Erreurs de base de données
- Vérifiez que le fichier SQL a été importé
- Vérifiez la connexion `oxmysql`
- Consultez les logs serveur

### Logs de Debug
Le script affiche des logs détaillés :
- `[MLFA GASSTATION]` : Messages généraux
- `[GASMANAGER]` : Interface tablette
- Activez les logs dans F8 pour le debug

---

## 📝 Changelog

### Version 2.0.0 (Actuelle)
- ✅ Système complet de gestion de stations
- ✅ Interface tablette moderne
- ✅ Intégration `fscripts_fuel`
- ✅ Système de missions
- ✅ Gestion des employés et permissions
- ✅ Statistiques en temps réel
- ✅ Support multi-stations

---

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs via les Issues
- Proposer des améliorations
- Soumettre des Pull Requests

---

## � Licence

Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🙏 Crédits

- **Framework** : ESX Legacy
- **Base de données** : OxMySQL
- **Système de carburant** : fscripts_fuel
- **Design** : Inspiré de mon jh-juge avec glassmorphism moderne

---

## 📞 Contact

Pour toute question ou support :
- GitHub Issues : [Créer une issue](https://github.com/VOTRE_USERNAME/jh-mlfaGasStation/issues)
- Discord : Votre serveur Discord (optionnel)

---

**Développé avec ❤️ pour la communauté FiveM**
