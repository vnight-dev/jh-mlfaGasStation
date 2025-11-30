# 🏪 jh-mlfaGasStation

> Système complet de gestion de stations-service pour FiveM avec clients NPC intelligents, interface moderne, missions avec objectifs UI, et configuration centralisée.

![Version](https://img.shields.io/badge/version-2.4.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-ESX-green.svg)
![Lua](https://img.shields.io/badge/Lua-5.4-purple.svg)

---

## 📋 Table des Matières

- [Fonctionnalités](#-fonctionnalités)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Commandes](#-commandes)
- [Discord Logging](#-discord-logging)
- [Mode Debug](#-mode-debug)
- [Roadmap](#-roadmap)

---

## ✨ Fonctionnalités

### 🏪 Gestion de Stations
- ✅ **Achat/Vente** de stations-service
- ✅ **Système de propriété** persistant en base de données
- ✅ **Gestion du stock** de carburant
- ✅ **Prix configurables** par station
- ✅ **Transactions financières** (dépôts/retraits)
- ✅ **Historique complet** des transactions

### 👥 Gestion des Employés
- ✅ **3 rangs** : Propriétaire, Gérant, Employé
- ✅ **Permissions personnalisables** par rang
- ✅ **Salaires configurables**
- ✅ **Embauche/Licenciement** via l'interface
- ✅ **Système de permissions** granulaire

### 🎮 Interface Utilisateur
- ✅ **Tablette 3D** avec animation
- ✅ **UI moderne** style iOS
- ✅ **7 applications** :
  - 📊 Dashboard (statistiques en temps réel)
  - ⛽ Gestion du carburant
  - 👥 Gestion des employés
  - 🎯 Missions
  - 📈 Rapports
  - ⚙️ Paramètres
  - 🔐 Permissions
- ✅ **Fermeture** par ECHAP ou bouton X
- ✅ **Contrôles restaurés** à 100%

### 🤖 Système NPC (Clients IA)
- ✅ **Pool de 8 PNJ** réutilisables (optimisé)
- ✅ **Pool de 8 véhicules** réutilisables
- ✅ **Modèles configurables** (peds et véhicules)
- ✅ **Spawn intelligent** basé sur la proximité du joueur
- ✅ **Animations** :
  - Ravitaillement (15 secondes)
  - Paiement (2 secondes)
  - Attente
- ✅ **Ventes automatiques** enregistrées en BDD
- ✅ **Montants aléatoires** (20-60L configurables)

### 🎯 Missions
- ✅ **Livraison de carburant** (tanker)
- ✅ **Maintenance** de la station
- ✅ **Nettoyage**
- ✅ **Récompenses configurables**
- ✅ **Cooldowns** personnalisables

### ⚙️ Configuration Centralisée
Tout est configurable dans `config.lua` :
- 🤖 **Config.NPC** - Système de clients
- 🐛 **Config.Debug** - Mode debug et logs
- 💬 **Config.Discord** - Logging Discord
- 🎯 **Config.Missions** - Missions et récompenses
- 💰 **Config.Economy** - Prix, taxes, bonus
- 👥 **Config.Employees** - Rangs et salaires
- 🎨 **Config.UI** - Thème et notifications
- 🗺️ **Config.Stations** - Emplacements et points de spawn

### 📊 Discord Logging
- ✅ **Webhook Discord** intégré
- ✅ **Logs détaillés** :
  - 🏪 Achats/ventes de stations
  - ⛽ Ventes de carburant
  - 👥 Embauches/licenciements
  - 💰 Transactions financières
  - 🎯 Missions complétées
  - ❌ Erreurs système
- ✅ **Activable/désactivable** par catégorie
- ✅ **Embeds colorés** avec informations complètes

### 🐛 Mode Debug
- ✅ **Logs conditionnels** par catégorie
- ✅ **Marqueurs visuels** :
  - Points de spawn NPC
  - Emplacements des pompes
  - Chemins des PNJ
- ✅ **Commandes de test** (voir ci-dessous)

---

## 📦 Installation

### 1. Prérequis
- **ESX Legacy** (ou ESX 1.2+)
- **oxmysql**
- **fscripts_fuel** (optionnel, pour intégration carburant)

### 2. Installation
```bash
# 1. Télécharger le script
cd resources
git clone https://github.com/votre-repo/jh-mlfaGasStation

# 2. Importer la base de données
# Exécuter mlfa_gasstations.sql dans votre BDD

# 3. Ajouter au server.cfg
ensure jh-mlfaGasStation

# 4. Restart le serveur
restart jh-mlfaGasStation
```

### 3. Configuration Discord (Optionnel)
```lua
-- Dans config.lua
Config.Discord = {
    Enabled = true,
    WebhookURL = 'VOTRE_WEBHOOK_ICI',
    Logs = {
        Purchase = true,
        Fuel = true,
        Employees = true,
        Money = true,
        Missions = true,
        Errors = true
    }
}
```

---

## ⚙️ Configuration

### Activer le Mode Debug
```lua
-- Dans config.lua
Config.Debug.Enabled = true
Config.Debug.Logs.NPC = true
Config.Debug.ShowMarkers.SpawnPoints = true
```

### Configurer les PNJ
```lua
Config.NPC = {
    Enabled = true,
    PedPoolSize = 8,
    VehiclePoolSize = 8,
    SpawnInterval = {Min = 30, Max = 120},
    FuelAmount = {Min = 20, Max = 60},
    -- Modifier les modèles
    PedModels = {'a_m_m_business_01', ...},
    VehicleModels = {'blista', 'panto', ...}
}
```

### Configurer l'Économie
```lua
Config.Economy = {
    StationPurchasePrice = 500000,
    DefaultFuelPrice = 2.5,
    MaxFuelStock = 10000,
    SalesTax = 0.05
}
```

---

## 🎮 Commandes

### Commandes Utilisateur
| Commande | Description |
|----------|-------------|
| `/gasmanager` | Ouvrir la tablette de gestion |
| `/closegas` | Fermer la tablette (force) |
| `/gasfix` | Réinitialiser le focus NUI |

### Commandes Debug (si `Config.Debug.Enabled = true`)
| Commande | Description |
|----------|-------------|
| `/gastest` | Afficher les infos système |
| `/gasdebug [category]` | Toggle logs (npc, purchase, fuel, ui, database) |
| `/gasmarkers [type]` | Toggle marqueurs (spawn, fuel, paths) |
| `/gasspawn [stationId]` | Forcer spawn d'un PNJ |
| `/gasmoney [stationId] [amount]` | Ajouter de l'argent à la station |
| `/gasreset [stationId]` | Reset une station |

---

## 💬 Discord Logging

### Configuration
```lua
Config.Discord = {
    Enabled = true,
    WebhookURL = 'https://discord.com/api/webhooks/...',
    Logs = {
        Purchase = true,    -- Achats/ventes
        Fuel = true,        -- Ventes carburant
        Employees = true,   -- RH
        Money = true,       -- Transactions
        Missions = true,    -- Missions
        Errors = true       -- Erreurs
    }
}
```

### Exemple de Log
```
🏪 Station Achetée
Une station-service a été achetée

👤 Joueur: Marcus Clint
🆔 Identifier: ESX-DEBUG-LICENCE
🏪 Station: Station Downtown (ID: 1)
💰 Prix: $500,000
```

---

## 🐛 Mode Debug

### Activer les Logs
```
/gasdebug npc      # Logs des PNJ
/gasdebug purchase # Logs des achats
/gasdebug fuel     # Logs du carburant
```

### Afficher les Marqueurs
```
/gasmarkers spawn  # Points de spawn
/gasmarkers fuel   # Pompes
/gasmarkers paths  # Chemins NPC
```

### Tester le Système
```
/gastest           # Infos système
/gasspawn 1        # Spawn NPC à la station 1
/gasmoney 1 10000  # Ajouter $10,000 à la station 1
```

---

## 🗺️ Roadmap

### ✅ Phase 1 - Complétée (v2.2.0)
- [x] Configuration centralisée
- [x] Système NPC optimisé
- [x] Discord logging
- [x] Mode debug complet
- [x] UI moderne fonctionnelle

### ⏳ Phase 2 - En Cours
- [ ] Animations NPC avancées
- [ ] Marqueurs visuels de debug
- [ ] Salaires automatiques
- [ ] Graphiques UI (Chart.js)

### 📅 Phase 3 - Planifiée
- [ ] Système de concurrence
- [ ] Événements aléatoires
- [ ] Statistiques avancées
- [ ] Intégration météo/heure

---

## 📝 Support

- **Discord**: [Votre Discord]
- **GitHub**: [Issues](https://github.com/votre-repo/jh-mlfaGasStation/issues)
- **Documentation**: [Wiki](https://github.com/votre-repo/jh-mlfaGasStation/wiki)

---

## 📄 Licence

License - Voir [LICENSE](LICENSE)

---

## 🙏 Crédits

- **Développeur**: MLFA
- **Framework**: ESX Legacy
- **Inspirations**: jh-juge

---

**Version**: 2.2.0 | **Dernière mise à jour**: 30/11/2024
