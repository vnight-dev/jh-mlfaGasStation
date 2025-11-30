-- ============================================================================
-- jh-mlfaGasStation - Database Schema
-- Version: 6.0.0 (Singularity Update)
-- Date: 01/12/2024
-- ============================================================================

-- Supprimer les tables existantes si elles existent (pour reset complet)
DROP TABLE IF EXISTS `gas_stocks`;
DROP TABLE IF EXISTS `gas_achievements`;
DROP TABLE IF EXISTS `gas_player_progress`;
DROP TABLE IF EXISTS `gas_missions`;
DROP TABLE IF EXISTS `gas_fuel_sales`;
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
    `label` VARCHAR(100) NOT NULL DEFAULT 'Station Service',
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
-- TABLE: gas_fuel_sales
-- Historique détaillé des ventes de carburant
-- ============================================================================
CREATE TABLE `gas_fuel_sales` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `station_id` INT(11) NOT NULL,
    `liters` DECIMAL(10,2) NOT NULL,
    `amount` DECIMAL(10,2) NOT NULL,
    `buyer_identifier` VARCHAR(60) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_station` (`station_id`),
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
-- TABLE: gas_player_progress
-- Progression du joueur (Réputation & XP)
-- ============================================================================
CREATE TABLE `gas_player_progress` (
    `identifier` VARCHAR(60) NOT NULL,
    `level` INT(11) DEFAULT 1,
    `xp` INT(11) DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: gas_achievements
-- Succès débloqués par les joueurs
-- ============================================================================
CREATE TABLE `gas_achievements` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `achievement_id` VARCHAR(50) NOT NULL,
    `unlocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_achievement` (`identifier`, `achievement_id`),
    INDEX `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: gas_stocks
-- Actions boursières des stations
-- ============================================================================
CREATE TABLE `gas_stocks` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `station_id` INT(11) NOT NULL,
    `identifier` VARCHAR(60) NOT NULL,
    `shares` INT(11) DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_stock` (`station_id`, `identifier`),
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