CREATE TABLE IF NOT EXISTS `mlfa_gasstations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `owner` VARCHAR(50) DEFAULT NULL,
  `price` INT DEFAULT 500000,
  `stock` INT DEFAULT 10000,  -- Stock d'essence en litres
  `max_stock` INT DEFAULT 20000,
  `fuel_price` FLOAT DEFAULT 1.5,  -- Prix par litre
  `money` INT DEFAULT 0,  -- Argent de la station
  `position` VARCHAR(255) NOT NULL,  -- JSON pour coords
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `mlfa_gasstations_employees` (
  `station_id` INT NOT NULL,
  `identifier` VARCHAR(50) NOT NULL,
  `grade` INT DEFAULT 0  -- 0: employé, 1: manager, etc.
);

CREATE TABLE IF NOT EXISTS `mlfa_gasstations_sales` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `station_id` INT NOT NULL,
  `buyer` VARCHAR(50) NOT NULL,
  `liters` INT NOT NULL,
  `price` FLOAT NOT NULL,
  `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);