ALTER TABLE `items`
	ADD COLUMN `price` INT(11) NOT NULL DEFAULT 1
;

INSERT INTO `items` (`name`, `label`, `price`) VALUES
	('lowcalrounds', 'Low Caliber Clip', 25),
	('shotcalrounds', 'Shell Caliber Clip', 25),
	('midcalrounds', 'Mid Caliber Clip', 35),
	('highcalrounds', 'High Caliber Clip', 50),
	('speccalrounds', 'Special Caliber Clip', 100)
;

CREATE TABLE IF NOT EXISTS `inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` text NOT NULL,
  `type` varchar(50) NOT NULL,
  `data` longtext NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `inventories` ADD COLUMN `limit` int(11) NOT NULL DEFAULT 100;