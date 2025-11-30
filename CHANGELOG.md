# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [2.3.0] - 2024-11-30

### Ajouté
- 💰 **Système de salaires automatiques**
  - Paiement horaire des employés
  - Prélèvement automatique de la caisse de la station
  - Notifications aux joueurs connectés
  - Gestion des joueurs offline (ajout à la banque)
  - Commande admin `/gaspaysalaries`
  - Discord logging des paiements

- 🎲 **Système d'événements aléatoires**
  - Panne de pompe (réparation requise)
  - Livraison urgente (bonus si acceptée)
  - Inspection gouvernementale
  - Heure de pointe (ventes x2)
  - Promotion carburant (-20%)
  - Notifications automatiques aux employés
  - Discord logging des événements

- 📄 **Documentation**
  - LICENSE (MIT)
  - CHANGELOG.md
  - Guide de test complet

### Modifié
- Version bump: 2.2.0 → 2.3.0
- fxmanifest.lua mis à jour avec nouveaux scripts

---

## [2.2.0] - 2024-11-30

### Ajouté
- ⚙️ **Configuration centralisée complète**
  - Config.NPC (système de clients)
  - Config.Debug (mode debug et logs)
  - Config.Discord (logging Discord)
  - Config.Missions (missions et récompenses)
  - Config.Economy (prix, taxes, bonus)
  - Config.Employees (rangs et salaires)
  - Config.UI (thème et notifications)
  - Config.Stations (emplacements + spawn points)

- 💬 **Discord Logging System**
  - Webhook Discord intégré
  - Logs pour achats/ventes de stations
  - Logs pour ventes de carburant
  - Logs pour embauches/licenciements
  - Logs pour transactions financières
  - Logs pour missions complétées
  - Logs pour erreurs système
  - Embeds colorés avec informations détaillées

- 🐛 **Mode Debug Complet**
  - Commandes: /gastest, /gasdebug, /gasmarkers, /gasspawn, /gasmoney, /gasreset
  - Logs conditionnels par catégorie
  - Marqueurs visuels 3D (spawn points, fuel points, paths)
  - Labels et lignes de chemin
  - Toggle via commandes

- 🤖 **Animations NPC Améliorées**
  - Animation de ravitaillement (configurable)
  - Animation de paiement (configurable)
  - Animation d'attente
  - Fallback si animation fail
  - Montants configurables (Min/Max)

- 📚 **Documentation Complète**
  - README.md (300+ lignes)
  - mlfa_gasstations.sql (schéma complet)
  - Guide de test
  - Récapitulatif de session

### Corrigé
- ❌ Erreur `NPCConfig is nil` (8 références corrigées)
- ❌ Erreur UI `classList null` (vérifications ajoutées)
- ✅ Fermeture UI améliorée (contrôles restaurés à 100%)
- ✅ Commande `/closegas` pour fermeture forcée

### Modifié
- client/ped_customers.lua adapté pour Config.NPC
- html/js/ui-manager.js avec vérifications null
- client/main.lua callback close amélioré
- Version bump: 2.1.0 → 2.2.0

---

## [2.1.0] - 2024-11-29

### Ajouté
- 🏪 Système d'achat/vente de stations
- 👥 Gestion des employés (3 rangs)
- 💰 Transactions financières
- 🎯 Système de missions
- 📊 Interface tablette moderne
- 🤖 Système NPC avec pool optimisé

### Corrigé
- Problèmes de focus NUI
- Marker persistence après achat
- SQL collation mismatch

---

## [2.0.0] - 2024-11-28

### Ajouté
- 🎨 UI complètement redesignée (style iOS)
- 📱 7 applications dans la tablette
- ⚡ Système de performance optimisé
- 🗄️ Base de données restructurée

### Modifié
- Architecture modulaire complète
- Séparation client/serveur améliorée

---

## [1.0.0] - 2024-11-27

### Ajouté
- 🏪 Système de base de gestion de stations
- ⛽ Gestion du stock de carburant
- 💵 Système de prix configurable
- 👤 Système de propriété basique
- 📊 Interface simple

---

## Types de Changements

- **Ajouté** : pour les nouvelles fonctionnalités
- **Modifié** : pour les changements dans les fonctionnalités existantes
- **Déprécié** : pour les fonctionnalités bientôt supprimées
- **Supprimé** : pour les fonctionnalités supprimées
- **Corrigé** : pour les corrections de bugs
- **Sécurité** : en cas de vulnérabilités

---

[2.3.0]: https://github.com/votre-repo/jh-mlfaGasStation/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/votre-repo/jh-mlfaGasStation/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/votre-repo/jh-mlfaGasStation/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/votre-repo/jh-mlfaGasStation/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/votre-repo/jh-mlfaGasStation/releases/tag/v1.0.0
