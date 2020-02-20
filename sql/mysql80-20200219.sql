-- MySQL dump 10.13  Distrib 8.0.15, for Win64 (x86_64)
--
-- Host: localhost    Database: prepping
-- ------------------------------------------------------
-- Server version	8.0.15

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cb_feed`
--

DROP TABLE IF EXISTS `cb_feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cb_feed` (
  `contentID` int(11) NOT NULL,
  `feedUrl` varchar(255) NOT NULL,
  `tagLine` varchar(255) DEFAULT NULL,
  `isActive` bit(1) NOT NULL,
  `startDate` datetime DEFAULT NULL,
  `stopDate` datetime DEFAULT NULL,
  `settings` longtext,
  PRIMARY KEY (`contentID`),
  KEY `FK21AE757E963225F1` (`contentID`),
  KEY `idx_isActive` (`isActive`),
  KEY `idx_stopDate` (`stopDate`),
  KEY `idx_startDate` (`startDate`),
  CONSTRAINT `FK21AE757E963225F1` FOREIGN KEY (`contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cb_feedimport`
--

DROP TABLE IF EXISTS `cb_feedimport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cb_feedimport` (
  `feedImportID` int(11) NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `importedCount` bigint(20) DEFAULT NULL,
  `importFailed` bit(1) DEFAULT NULL,
  `metaInfo` longtext NOT NULL,
  `FK_feedID` int(11) NOT NULL,
  `FK_authorID` int(11) NOT NULL,
  PRIMARY KEY (`feedImportID`),
  KEY `FKA2F552A382151A90` (`FK_feedID`),
  KEY `FKA2F552A3AA6AC0EA` (`FK_authorID`),
  KEY `idx_importFailed` (`importFailed`),
  KEY `idx_createdDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`) /*!80000 INVISIBLE */,
  KEY `idx_deleted` (`isDeleted`),
  KEY `idx_createDate` (`createdDate`),
  CONSTRAINT `FKA2F552A382151A90` FOREIGN KEY (`FK_feedID`) REFERENCES `cb_content` (`contentID`),
  CONSTRAINT `FKA2F552A3AA6AC0EA` FOREIGN KEY (`FK_authorID`) REFERENCES `cb_author` (`authorID`)
) ENGINE=InnoDB AUTO_INCREMENT=50475 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cb_feeditem`
--

DROP TABLE IF EXISTS `cb_feeditem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cb_feeditem` (
  `contentID` int(11) NOT NULL,
  `excerpt` longtext,
  `uniqueId` varchar(510) NOT NULL,
  `itemAuthor` varchar(255) DEFAULT NULL,
  `itemUrl` varchar(510) NOT NULL,
  `metaInfo` longtext,
  PRIMARY KEY (`contentID`),
  KEY `FK128D01911ABA7EA4` (`contentID`),
  KEY `idx_uniqueId` (`uniqueId`),
  CONSTRAINT `FK128D01911ABA7EA4` FOREIGN KEY (`contentID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cb_feeditemattachment`
--

DROP TABLE IF EXISTS `cb_feeditemattachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cb_feeditemattachment` (
  `feedItemAttachmentID` int(11) NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `attachmentUrl` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medium` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mimeType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `FK_feedItemID` int(11) NOT NULL,
  PRIMARY KEY (`feedItemAttachmentID`),
  KEY `FKCB805974E7194996` (`FK_feedItemID`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`),
  CONSTRAINT `FKCB805974E7194996` FOREIGN KEY (`FK_feedItemID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB AUTO_INCREMENT=7059 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cb_feeditempodcast`
--

DROP TABLE IF EXISTS `cb_feeditempodcast`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cb_feeditempodcast` (
  `feedItemPodcastID` int(11) NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `podcastUrl` longtext COLLATE utf8mb4_unicode_ci,
  `mimeType` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `FK_feedItemID` int(11) NOT NULL,
  PRIMARY KEY (`feedItemPodcastID`),
  KEY `FK45DCC53E7194996` (`FK_feedItemID`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`),
  CONSTRAINT `FK45DCC53E7194996` FOREIGN KEY (`FK_feedItemID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB AUTO_INCREMENT=857 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cb_feeditemvideo`
--

DROP TABLE IF EXISTS `cb_feeditemvideo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cb_feeditemvideo` (
  `feedItemVideoID` int(11) NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `videoUrl` longtext COLLATE utf8mb4_unicode_ci,
  `FK_feedItemID` int(11) NOT NULL,
  PRIMARY KEY (`feedItemVideoID`),
  KEY `FK308A658AE7194996` (`FK_feedItemID`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`),
  CONSTRAINT `FK308A658AE7194996` FOREIGN KEY (`FK_feedItemID`) REFERENCES `cb_content` (`contentID`)
) ENGINE=InnoDB AUTO_INCREMENT=2293 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'prepping'
--

--
-- Dumping routines for database 'prepping'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-02-19 21:31:25
