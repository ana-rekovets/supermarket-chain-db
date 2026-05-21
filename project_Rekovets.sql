CREATE DATABASE  IF NOT EXISTS `supermarket_chain` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `supermarket_chain`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: supermarket_chain
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `customer_id` int NOT NULL,
  `first_name` varchar(60) NOT NULL,
  `last_name` varchar(60) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (101,'Anna','Rossi','+41 77 111 11 11','anna.rossi@mail.com'),(102,'Mark','Weber','+49 151 222 22 22','mark.weber@mail.com'),(103,'Giulia','Bianchi','+39 333 333 333','giulia.b@mail.com'),(104,'Tom','Keller','+49 89 444 44 44','tom.keller@mail.com'),(105,'Sofia','Conti','+41 79 555 55 55','sofia.conti@mail.com');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_card`
--

DROP TABLE IF EXISTS `loyalty_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_card` (
  `card_id` int NOT NULL,
  `issue_date` date NOT NULL,
  `points_balance` int NOT NULL DEFAULT '0',
  `customer_id` int NOT NULL,
  `point_id` int NOT NULL,
  PRIMARY KEY (`card_id`),
  UNIQUE KEY `customer_id` (`customer_id`),
  KEY `fk_card_point` (`point_id`),
  CONSTRAINT `fk_card_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  CONSTRAINT `fk_card_point` FOREIGN KEY (`point_id`) REFERENCES `point_of_sale` (`point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_card`
--

LOCK TABLES `loyalty_card` WRITE;
/*!40000 ALTER TABLE `loyalty_card` DISABLE KEYS */;
INSERT INTO `loyalty_card` VALUES (301,'2025-10-01',120,101,1),(302,'2025-10-02',40,102,3),(303,'2025-10-05',220,103,2),(304,'2025-10-07',10,104,3),(305,'2025-10-10',80,105,1);
/*!40000 ALTER TABLE `loyalty_card` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_method`
--

DROP TABLE IF EXISTS `payment_method`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_method` (
  `point_id` int NOT NULL,
  `payment_method` varchar(40) NOT NULL,
  PRIMARY KEY (`point_id`,`payment_method`),
  CONSTRAINT `fk_pay_point` FOREIGN KEY (`point_id`) REFERENCES `point_of_sale` (`point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_method`
--

LOCK TABLES `payment_method` WRITE;
/*!40000 ALTER TABLE `payment_method` DISABLE KEYS */;
INSERT INTO `payment_method` VALUES (1,'cash'),(1,'check'),(1,'credit_card'),(2,'cash'),(2,'credit_card'),(3,'cash'),(3,'credit_card'),(3,'mobile_pay');
/*!40000 ALTER TABLE `payment_method` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_of_sale`
--

DROP TABLE IF EXISTS `point_of_sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_of_sale` (
  `point_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `country` varchar(80) NOT NULL,
  `city` varchar(80) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `street_address` varchar(150) NOT NULL,
  PRIMARY KEY (`point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_of_sale`
--

LOCK TABLES `point_of_sale` WRITE;
/*!40000 ALTER TABLE `point_of_sale` DISABLE KEYS */;
INSERT INTO `point_of_sale` VALUES (1,'Lugano Central','Switzerland','Lugano','6900','Via Nassa 10'),(2,'Milan Centro','Italy','Milano','20121','Corso Buenos Aires 5'),(3,'Munich Mitte','Germany','München','80331','Sendlinger Str. 8');
/*!40000 ALTER TABLE `point_of_sale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_offers_product`
--

DROP TABLE IF EXISTS `point_offers_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_offers_product` (
  `point_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`point_id`,`product_id`),
  KEY `fk_pop_product` (`product_id`),
  CONSTRAINT `fk_pop_point` FOREIGN KEY (`point_id`) REFERENCES `point_of_sale` (`point_id`),
  CONSTRAINT `fk_pop_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  CONSTRAINT `point_offers_product_chk_1` CHECK ((`quantity` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_offers_product`
--

LOCK TABLES `point_offers_product` WRITE;
/*!40000 ALTER TABLE `point_offers_product` DISABLE KEYS */;
INSERT INTO `point_offers_product` VALUES (1,201,120),(1,202,200),(1,203,150),(1,204,60),(1,205,90),(1,206,70),(2,201,80),(2,202,220),(2,203,140),(2,204,50),(2,205,110),(2,206,65),(3,201,100),(3,202,180),(3,203,160),(3,204,55),(3,205,95),(3,206,75);
/*!40000 ALTER TABLE `point_offers_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `points_movement`
--

DROP TABLE IF EXISTS `points_movement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `points_movement` (
  `movements_id` int NOT NULL,
  `movement_type` varchar(30) NOT NULL,
  `date` date NOT NULL,
  `points_delta` int NOT NULL,
  `transaction_id` int DEFAULT NULL,
  `card_id` int NOT NULL,
  PRIMARY KEY (`movements_id`),
  KEY `fk_pm_transaction` (`transaction_id`),
  KEY `idx_pm_card_date` (`card_id`,`date`),
  CONSTRAINT `fk_pm_card` FOREIGN KEY (`card_id`) REFERENCES `loyalty_card` (`card_id`),
  CONSTRAINT `fk_pm_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transaction` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `points_movement`
--

LOCK TABLES `points_movement` WRITE;
/*!40000 ALTER TABLE `points_movement` DISABLE KEYS */;
INSERT INTO `points_movement` VALUES (501,'EARN','2025-11-01',80,401,301),(502,'EARN','2025-11-02',120,402,303),(503,'EARN','2025-11-02',70,403,305),(504,'EARN','2025-11-03',150,404,302),(505,'EARN','2025-11-04',90,405,304),(506,'REDEEM','2025-11-05',-50,406,301);
/*!40000 ALTER TABLE `points_movement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `product_id` int NOT NULL,
  `name` varchar(120) NOT NULL,
  `brand` varchar(80) DEFAULT NULL,
  `category` varchar(80) DEFAULT NULL,
  `list_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`product_id`),
  CONSTRAINT `product_chk_1` CHECK ((`list_price` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (201,'Milk 1L','Alpine','Dairy',1.50),(202,'Pasta 500g','Roma','Grocery',1.20),(203,'Chocolate 100g','ChocoCo','Snacks',2.10),(204,'Olive Oil 1L','Medit','Grocery',9.90),(205,'Bananas 1kg','Fresh','Fruit',2.50),(206,'Shampoo 250ml','CarePlus','Hygiene',4.80);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_in_transaction`
--

DROP TABLE IF EXISTS `product_in_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_in_transaction` (
  `product_id` int NOT NULL,
  `transaction_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`product_id`,`transaction_id`),
  KEY `idx_pit_transaction` (`transaction_id`),
  CONSTRAINT `fk_pit_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  CONSTRAINT `fk_pit_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transaction` (`transaction_id`),
  CONSTRAINT `product_in_transaction_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `product_in_transaction_chk_2` CHECK ((`unit_price` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_in_transaction`
--

LOCK TABLES `product_in_transaction` WRITE;
/*!40000 ALTER TABLE `product_in_transaction` DISABLE KEYS */;
INSERT INTO `product_in_transaction` VALUES (201,401,2,1.50),(201,403,1,1.50),(201,405,2,1.50),(202,402,3,1.20),(202,405,2,1.20),(203,401,1,2.10),(203,404,1,2.10),(203,406,1,2.30),(204,402,1,9.90),(204,406,2,9.90),(205,401,1,2.50),(205,403,2,2.50),(205,405,1,2.50),(206,404,2,4.80);
/*!40000 ALTER TABLE `product_in_transaction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction` (
  `transaction_id` int NOT NULL,
  `date` date NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `customer_id` int NOT NULL,
  `point_id` int NOT NULL,
  `payment_method` varchar(40) NOT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `fk_tr_payment` (`point_id`,`payment_method`),
  KEY `idx_tr_customer_date` (`customer_id`,`date`),
  CONSTRAINT `fk_tr_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  CONSTRAINT `fk_tr_payment` FOREIGN KEY (`point_id`, `payment_method`) REFERENCES `payment_method` (`point_id`, `payment_method`),
  CONSTRAINT `fk_tr_point` FOREIGN KEY (`point_id`) REFERENCES `point_of_sale` (`point_id`),
  CONSTRAINT `transaction_chk_1` CHECK ((`total_price` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction`
--

LOCK TABLES `transaction` WRITE;
/*!40000 ALTER TABLE `transaction` DISABLE KEYS */;
INSERT INTO `transaction` VALUES (401,'2025-11-01',8.40,101,1,'credit_card'),(402,'2025-11-02',12.30,103,2,'cash'),(403,'2025-11-02',6.90,105,1,'cash'),(404,'2025-11-03',15.00,102,3,'mobile_pay'),(405,'2025-11-04',9.60,104,3,'credit_card'),(406,'2025-11-05',22.10,101,1,'check');
/*!40000 ALTER TABLE `transaction` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-17 18:27:11
