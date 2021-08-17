SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `ad_types`;
CREATE TABLE `ad_types`
(
    `id`    int unsigned NOT NULL AUTO_INCREMENT,
    `value` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `value` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `ads`;
CREATE TABLE `ads`
(
    `id`               int unsigned NOT NULL AUTO_INCREMENT,
    `title`            varchar(60) NOT NULL,
    `locality`         varchar(40) NOT NULL,
    `coordinates`      point       NOT NULL /*!80003 SRID 4326 */,
    `price`            int unsigned NOT NULL,
    `company`          varchar(40) DEFAULT NULL,
    `seller`           varchar(40) NOT NULL,
    `building_type`    varchar(10) NOT NULL,
    `ownership`        varchar(20) DEFAULT NULL,
    `floor`            tinyint     DEFAULT NULL,
    `usable_area`      smallint unsigned NOT NULL,
    `floor_area`       smallint unsigned DEFAULT NULL,
    `energy_intensity` char(1)     NOT NULL,
    `parking`          tinyint unsigned NOT NULL,
    `elevator`         tinyint unsigned NOT NULL,
    `terrace`          tinyint unsigned NOT NULL,
    `ad_type_id`       int unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY                `ad_type_id` (`ad_type_id`),
    CONSTRAINT `ads_ibfk_1` FOREIGN KEY (`ad_type_id`) REFERENCES `ad_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `districts`;
CREATE TABLE `districts`
(
    `id`          int unsigned NOT NULL AUTO_INCREMENT,
    `name`        varchar(25) NOT NULL,
    `coordinates` polygon     NOT NULL /*!80003 SRID 4326 */,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `pois`;
CREATE TABLE `pois`
(
    `id`          int unsigned NOT NULL AUTO_INCREMENT,
    `name`        varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    `description` varchar(60)                                            NOT NULL,
    `coordinates` point                                                  NOT NULL /*!80003 SRID 4326 */,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `stations`;
CREATE TABLE `stations`
(
    `id`           int unsigned NOT NULL AUTO_INCREMENT,
    `name`         varchar(45) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    `coordinates`  point                                                  NOT NULL /*!80003 SRID 4326 */,
    `barrier_free` tinyint unsigned NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tariff_bands`;
CREATE TABLE `tariff_bands`
(
    `id`          int unsigned NOT NULL AUTO_INCREMENT,
    `name`        varchar(7) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    `coordinates` multipolygon                                          NOT NULL /*!80003 SRID 4326 */,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `transport_lines`;
CREATE TABLE `transport_lines`
(
    `id`            int unsigned NOT NULL AUTO_INCREMENT,
    `short_name`    varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL,
    `long_name`     varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    `coordinates`   multilinestring                                         NOT NULL /*!80003 SRID 4326 */,
    `night_traffic` tinyint unsigned NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
