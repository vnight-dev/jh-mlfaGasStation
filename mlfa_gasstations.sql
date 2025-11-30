-- ============================================================================
-- jh-mlfaGasStation - Database Schema
-- Version: 2.2.0
-- Date: 30/11/2024
-- ============================================================================

-- Supprimer les tables existantes si elles existent
DROP TABLE IF EXISTS `gas_missions`;
DROP TABLE IF EXISTS `gas_transactions`;
DROP TABLE IF EXISTS `gas_employees`;
DROP TABLE IF EXISTS `gas_stations`;

-- ============================================================================
-- TABLE: gas_stations
-- Stocke les informations des stations-service
-- ============================================================================
CREATE TABLE `gas_stations` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `owner` VARCHAR(60) DEFAULT NULL COMMENT 'Identifier du propriétaire',
    `money` INT(11) DEFAULT 0 COMMENT 'Argent dans la caisse',
    `fuel_stock` INT(11) DEFAULT 5000 COMMENT 'Stock de carburant en litres',
    `fuel_price` DECIMAL(10,2) DEFAULT 2.50 COMMENT 'Prix du carburant par litre',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: gas_employees
-- Stocke les employés de chaque station
-- ============================================================================
CREATE TABLE `gas_employees` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `station_id` INT(11) NOT NULL,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifier du joueur',
    `rank` VARCHAR(50) NOT NULL DEFAULT 'employee' COMMENT 'boss, manager, employee',
    `salary` INT(11) DEFAULT 0 COMMENT 'Salaire horaire',
    `hired_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_employee` (`station_id`, `identifier`),
    INDEX `idx_station` (`station_id`),
    INDEX `idx_identifier` (`identifier`),
    FOREIGN KEY (`station_id`) REFERENCES `gas_stations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: gas_transactions
-- Historique des transactions financières
-- ============================================================================
CREATE TABLE `gas_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `station_id` INT(11) NOT NULL,
    `type` VARCHAR(50) NOT NULL COMMENT 'fuel_sale, expense, deposit, withdrawal',
    `amount` DECIMAL(10,2) NOT NULL COMMENT 'Montant (positif ou négatif)',
    `description` VARCHAR(255) DEFAULT NULL,
    `created_by` VARCHAR(60) DEFAULT NULL COMMENT 'Identifier du joueur ou "system"',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_station` (`station_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_at` (`created_at`),
    FOREIGN KEY (`station_id`) REFERENCES `gas_stations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: gas_missions
-- Missions actives et leur statut
-- ============================================================================
CREATE TABLE `gas_missions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `station_id` INT(11) NOT NULL,
    `mission_type` VARCHAR(50) NOT NULL COMMENT 'fuel_delivery, maintenance, cleaning',
    `player_identifier` VARCHAR(60) NOT NULL,
    `status` VARCHAR(20) DEFAULT 'active' COMMENT 'active, completed, failed',
    `reward` INT(11) DEFAULT 0,
    `started_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_station` (`station_id`),
    INDEX `idx_player` (`player_identifier`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`station_id`) REFERENCES `gas_stations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DONNÉES DE DÉMONSTRATION
-- 5 stations-service (non possédées par défaut)
-- ============================================================================
INSERT INTO `gas_stations` (`id`, `name`, `label`, `owner`, `money`, `fuel_stock`, `fuel_price`) VALUES
(1, 'Station 1', 'Station Downtown', NULL, 0, 5000, 2.50),
(2, 'Station 2', 'Station Grove Street', NULL, 0, 5000, 2.50),
(3, 'Station 3', 'Station Sandy Shores', NULL, 0, 5000, 2.50),
(4, 'Station 4', 'Station Paleto Bay', NULL, 0, 5000, 2.50),
(5, 'Station 5', 'Station Great Ocean Highway', NULL, 0, 5000, 2.50);

-- ============================================================================
-- NOTES D'INSTALLATION
-- ============================================================================
-- 1. Assurez-vous que votre base de données utilise utf8mb4_unicode_ci
-- 2. Les coordonnées des stations sont définies dans config.lua
-- 3. Les stations sont créées sans propriétaire (disponibles à l'achat)
-- 4. Le stock initial est de 5000L par station
-- 5. Le prix par défaut est de $2.50/L
-- 
-- Pour réinitialiser une station :
-- UPDATE gas_stations SET owner = NULL, money = 0, fuel_stock = 5000 WHERE id = 1;
-- DELETE FROM gas_employees WHERE station_id = 1;
-- DELETE FROM gas_transactions WHERE station_id = 1;
-- 
-- Pour voir les statistiques :
-- SELECT s.label, s.owner, s.money, s.fuel_stock, COUNT(e.id) as employees
-- FROM gas_stations s
-- LEFT JOIN gas_employees e ON s.id = e.station_id
-- GROUP BY s.id;
-- ============================================================================