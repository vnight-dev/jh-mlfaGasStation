# jh-mlfaGasStation

Un système complet de gestion de stations-service pour FiveM avec interface moderne, système de propriété, missions, et intégration carburant.

## 📋 Dépendances Requises

Ce script nécessite les ressources suivantes pour fonctionner correctement :

- **[es_extended](https://github.com/esx-framework/esx_core)** - Framework ESX
- **[oxmysql](https://github.com/overextended/oxmysql)** - Système de base de données
- **[fscripts_fuel](https://github.com/fscripts-dev/fscripts_fuel)** - Système de carburant (OBLIGATOIRE)

> [!IMPORTANT]
> Le script `fscripts_fuel` est **obligatoire** pour le bon fonctionnement du système de tracking de carburant et des revenus de la station.

## 📦 Installation

1. **Télécharger les dépendances**
   - Assurez-vous d'avoir installé toutes les dépendances listées ci-dessus
   - Téléchargez `fscripts_fuel` depuis leur GitHub ou votre source

2. **Installation du script**
   ```bash
   cd resources
   git clone https://github.com/VOTRE_USERNAME/jh-mlfaGasStation.git
   ```

3. **Configuration de la base de données**
   - Importez le fichier `mlfa_gasstations.sql` dans votre base de données MySQL
   ```bash
   mysql -u votre_utilisateur -p votre_base_de_donnees < mlfa_gasstations.sql
   ```

4. **Configuration du server.cfg**
   - Ajoutez les ressources dans votre `server.cfg` dans l'ordre suivant :
   ```cfg
   ensure es_extended
   ensure oxmysql
   ensure fscripts_fuel
   ensure jh-mlfaGasStation
   ```

> [!WARNING]
> L'ordre de chargement est important ! `fscripts_fuel` doit être démarré **avant** `jh-mlfaGasStation`.

## ⚙️ Configuration

Modifiez le fichier `config.lua` pour personnaliser :
- Les emplacements des stations-service
- Les prix d'achat et de vente
- Les permissions et grades autorisés
- Les paramètres de missions
- L'intégration avec le système de carburant

## 🎮 Fonctionnalités

- ✅ Système d'achat/vente de stations-service
- ✅ Interface moderne avec design glassmorphism
- ✅ Gestion des employés et permissions
- ✅ Système de missions pour générer des revenus
- ✅ Tracking automatique des ventes de carburant
- ✅ Statistiques en temps réel
- ✅ Intégration complète avec `fscripts_fuel`

## 🔧 Support

Pour toute question ou problème :
- Vérifiez que toutes les dépendances sont installées
- Consultez les logs F8 pour les erreurs
- Assurez-vous que `fscripts_fuel` fonctionne correctement

## 📝 Licence

Voir le fichier [LICENSE](LICENSE) pour plus de détails.
