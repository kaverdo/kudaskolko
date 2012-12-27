-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.1.40-community - MySQL Community Server (GPL)
-- Server OS:                    Win32
-- HeidiSQL version:             7.0.0.4053
-- Date/time:                    2012-12-28 00:10:24
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET FOREIGN_KEY_CHECKS=0 */;

-- Dumping database structure for budget_prod
CREATE DATABASE IF NOT EXISTS `budget_prod` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `budget_prod`;


-- Dumping structure for table budget_prod.transaction_types
CREATE TABLE IF NOT EXISTS `transaction_types` (
  `type` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  KEY `Index 1` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40014 SET FOREIGN_KEY_CHECKS=1 */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
