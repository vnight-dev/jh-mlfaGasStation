-- ============================================================================
-- REPAIR SCRIPT v6.0
-- Fixes missing columns and adds new tables
-- ============================================================================

-- Fix missing 'label' column in gas_stations
ALTER TABLE `gas_stations` ADD COLUMN IF NOT EXISTS `label` VARCHAR(100) NOT NULL DEFAULT 'Station Service' AFTER `name`;

-- Add reputation tables
CREATE TABLE IF NOT EXISTS `gas_player_progress` (
    `identifier` VARCHAR(60) NOT NULL,
    `level` INT(11) DEFAULT 1,
    `xp` INT(11) DEFAULT 0,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `gas_achievements` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `achievement_id` VARCHAR(50) NOT NULL,
    `unlocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_achievement` (`identifier`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add stock market tables
CREATE TABLE IF NOT EXISTS `gas_stocks` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `station_id` INT(11) NOT NULL,
    `identifier` VARCHAR(60) NOT NULL,
    `shares` INT(11) DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_stock` (`station_id`, `identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add franchise tables (if needed)
-- Franchise logic is mostly handled by ownership checks in code

-- Add EV charging logs (optional, reusing gas_transactions)
