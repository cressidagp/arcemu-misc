# --------------------------------------------------------
# Host:                         127.0.0.1
# Server version:               5.5.11
# Server OS:                    Win64
# HeidiSQL version:             6.0.0.3916
# Date/time:                    2011-08-04 13:28:57
# --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

# Dumping database structure for custom_gossip
DROP DATABASE IF EXISTS `custom_gossip`;
CREATE DATABASE IF NOT EXISTS `custom_gossip` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `custom_gossip`;


# Dumping structure for table custom_gossip.gossip_conditions
DROP TABLE IF EXISTS `gossip_conditions`;
CREATE TABLE IF NOT EXISTS `gossip_conditions` (
  `menu_id` int(10) unsigned NOT NULL COMMENT 'menu_id from gossip_menu_option',
  `order` tinyint(2) unsigned NOT NULL COMMENT 'order from gossip_menu_option',
  `has_id` int(10) unsigned NOT NULL DEFAULT '0',
  `value` int(10) NOT NULL DEFAULT '0',
  `bool` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '0 = must not have, 1 = must have',
  PRIMARY KEY (`menu_id`,`order`,`has_id`,`value`,`bool`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is used for extra conditions.\r\nThere can be more than one of each has_id.\r\nConditions of any kind do not apply on GMs';

# Data exporting was unselected.


# Dumping structure for table custom_gossip.gossip_menu
DROP TABLE IF EXISTS `gossip_menu`;
CREATE TABLE IF NOT EXISTS `gossip_menu` (
  `menu_id` int(10) unsigned NOT NULL COMMENT 'menu_id from gossip_menu_option',
  `npc_text_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entry from world.npc_text',
  PRIMARY KEY (`menu_id`,`npc_text_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Used for linking the menu_id to a text in world database.\r\nThis text is shown at the top of the menu.';

# Data exporting was unselected.


# Dumping structure for table custom_gossip.gossip_menu_option
DROP TABLE IF EXISTS `gossip_menu_option`;
CREATE TABLE IF NOT EXISTS `gossip_menu_option` (
  `menu_id` int(10) unsigned NOT NULL COMMENT 'Unique number for a menu',
  `order` tinyint(2) unsigned NOT NULL COMMENT 'min 1, max 30. Order of the options',
  `icon` tinyint(2) unsigned NOT NULL DEFAULT '2' COMMENT 'Icon number',
  `name` text NOT NULL COMMENT 'Name of the teleport (label)',
  `script_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'ID that links to gossip_scripts script_id. You can have multiple scripts for one option',
  `next_menu_id` bigint(10) NOT NULL DEFAULT '-1' COMMENT 'the menu_id of the next menu shown.',
  `cost` mediumint(10) unsigned NOT NULL DEFAULT '0' COMMENT 'cost in copper',
  `popup` text NOT NULL COMMENT 'popup text',
  `req_level` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'required level',
  `team` tinyint(1) unsigned NOT NULL DEFAULT '2' COMMENT '0 = ally, 1 = horde, 2=both',
  PRIMARY KEY (`menu_id`,`order`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table holds all the items for menus and a part of their requirements\r\nand information on what do the items do on click.';

# Data exporting was unselected.


# Dumping structure for table custom_gossip.gossip_scripts
DROP TABLE IF EXISTS `gossip_scripts`;
CREATE TABLE IF NOT EXISTS `gossip_scripts` (
  `script_id` bigint(20) unsigned NOT NULL COMMENT 'id that is the same in gossip_menu_option',
  `command` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '0 = teleport. More on release site',
  `float` float unsigned NOT NULL DEFAULT '0' COMMENT 'used for: scale',
  `value` int(10) NOT NULL DEFAULT '0' COMMENT 'a value',
  `value2` int(10) NOT NULL DEFAULT '0' COMMENT 'a value',
  `string` text COMMENT 'text field. Separate entry numbers with a space',
  `bool` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '0 = false, 1 = true',
  `map` smallint(6) NOT NULL DEFAULT '0' COMMENT 'map ID',
  `x` float NOT NULL DEFAULT '0' COMMENT 'X-coord',
  `y` float NOT NULL DEFAULT '0' COMMENT 'Y-coord',
  `z` float NOT NULL DEFAULT '0' COMMENT 'Z-coord',
  `o` float NOT NULL DEFAULT '0' COMMENT 'Orientation',
  `comment` text COMMENT 'optional comment'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table stores all the events that can happen when you click an item in a menu.\r\nThis table does not store data for next menu, only the event scripts.';

# Data exporting was unselected.


# Dumping structure for table custom_gossip.units
DROP TABLE IF EXISTS `units`;
CREATE TABLE IF NOT EXISTS `units` (
  `entry` int(10) unsigned NOT NULL COMMENT 'Max 200000, Min 1',
  `type` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '0 = NPC, 1 = Gob, 2 = item',
  `menu_id` int(10) unsigned NOT NULL COMMENT 'MAIN menu''s menu_id for this NPC entry - reloadable',
  `check_combat` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT 'bool defining whether we will error if player in combat. 1 = yes, 0 = no - reloadable',
  PRIMARY KEY (`entry`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table holds all the items, gameobjects and NPCs that have gossip.\r\nThis table also holds the data on what menu does the unit open on click (gossip hello)\r\nand whether to error out if the player is in combat when trying to click the unit.';

# Data exporting was unselected.
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;